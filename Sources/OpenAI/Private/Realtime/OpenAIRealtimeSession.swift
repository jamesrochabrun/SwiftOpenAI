//
//  OpenAIRealtimeSession.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

#if canImport(AVFoundation)
import AVFoundation
import Foundation
import OSLog

nonisolated private let kWebsocketDisconnectedErrorCode = 57
nonisolated private let kWebsocketDisconnectedEarlyThreshold: TimeInterval = 3

// MARK: - OpenAIRealtimeSession

@RealtimeActor
open class OpenAIRealtimeSession {
  nonisolated init(
    webSocketTask: URLSessionWebSocketTask,
    sessionConfiguration: OpenAIRealtimeSessionConfiguration)
  {
    let (receiver, continuation) = AsyncStream<OpenAIRealtimeMessage>.makeStream()
    self.webSocketTask = webSocketTask
    self.sessionConfiguration = sessionConfiguration
    self.receiver = receiver
    self.continuation = continuation

    Task { @RealtimeActor in
      await self.sendMessage(OpenAIRealtimeSessionUpdate(session: self.sessionConfiguration))
    }
    self.webSocketTask.resume()
    receiveMessage()
  }

  deinit {
    logger.debug("OpenAIRealtimeSession is being freed")
  }

  /// Messages sent from OpenAI, buffered from the moment the session is created.
  /// Consume this stream from one task for the lifetime of the session.
  public nonisolated let receiver: AsyncStream<OpenAIRealtimeMessage>

  /// Sends a message through the websocket connection
  public func sendMessage(_ encodable: Encodable) async {
    guard !isTearingDown else {
      logger.debug("Ignoring ws sendMessage. The RT session is tearing down.")
      return
    }
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.sortedKeys]
      let data = try encoder.encode(encodable)
      guard let str = String(data: data, encoding: .utf8) else {
        logger.error("Could not get utf8 string representation of data")
        return
      }
      let wsMessage = URLSessionWebSocketTask.Message.string(str)
      try await webSocketTask.send(wsMessage)
    } catch {
      logger.error("Could not send message to OpenAI: \(error.localizedDescription)")
    }
  }

  /// Close the websocket connection
  public func disconnect() {
    isTearingDown = true
    continuation.finish()
    webSocketTask.cancel()
  }

  let sessionConfiguration: OpenAIRealtimeSessionConfiguration

  private var isTearingDown = false
  private let webSocketTask: URLSessionWebSocketTask
  private nonisolated let continuation: AsyncStream<OpenAIRealtimeMessage>.Continuation
  private let setupTime = Date.now
  private let logger = Logger(subsystem: "com.swiftopenai", category: "Realtime")

  nonisolated private static func jsonValues(from dictionary: [String: Any]) -> [String: OpenAIJSONValue] {
    dictionary.compactMapValues(OpenAIJSONValue.init(jsonObject:))
  }

  /// Tells the websocket task to receive a new message
  nonisolated private func receiveMessage() {
    webSocketTask.receive { result in
      switch result {
      case .failure(let error as NSError):
        Task { @RealtimeActor in
          self.didReceiveWebSocketError(error)
        }

      case .success(let message):
        Task { @RealtimeActor in
          self.didReceiveWebSocketMessage(message)
        }
      }
    }
  }

  /// Handles socket errors. We disconnect on all errors.
  private func didReceiveWebSocketError(_ error: NSError) {
    guard !isTearingDown else {
      return
    }

    switch error.code {
    case kWebsocketDisconnectedErrorCode:
      let disconnectedEarly = Date().timeIntervalSince(setupTime) <= kWebsocketDisconnectedEarlyThreshold
      if disconnectedEarly {
        logger.warning("Websocket disconnected immediately after connection")
      } else {
        logger.debug("Websocket disconnected normally")
      }

    default:
      logger.error("Received ws error: \(error.localizedDescription)")
    }

    continuation.yield(.disconnected(error.localizedDescription))
    disconnect()
  }

  /// Handles received websocket messages
  private func didReceiveWebSocketMessage(_ message: URLSessionWebSocketTask.Message) {
    switch message {
    case .string(let text):
      if let data = text.data(using: .utf8) {
        didReceiveWebSocketData(data)
      }

    case .data(let data):
      didReceiveWebSocketData(data)

    @unknown default:
      logger.error("Received an unknown websocket message format")
      disconnect()
    }
  }

  private func didReceiveWebSocketData(_ data: Data) {
    guard !isTearingDown else {
      // The caller already initiated disconnect,
      // don't send any more messages back to the caller
      return
    }

    guard
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let messageType = json["type"] as? String
    else {
      logger.error("Received websocket data that we don't understand")
      continuation.yield(.error("Received an invalid Realtime server event."))
      disconnect()
      return
    }
    switch messageType {
    case "response.output_audio.delta", "response.audio.delta",
         "response.output_audio_transcript.delta", "response.audio_transcript.delta",
         "conversation.item.input_audio_transcription.delta",
         "response.function_call_arguments.delta":
      break
    default:
      logger.debug("Received \(messageType) from OpenAI")
    }

    switch messageType {
    case "error":
      let error = json["error"] as? [String: Any]
      let errorMessage = error?["message"] as? String ?? "Unknown Realtime error"
      logger.error("Received error from OpenAI websocket: \(errorMessage)")
      continuation.yield(.error(errorMessage))

    case "session.created":
      continuation.yield(.sessionCreated)

    case "session.updated":
      continuation.yield(.sessionUpdated)

    case "response.output_audio.delta", "response.audio.delta":
      if let base64Audio = json["delta"] as? String {
        continuation.yield(.responseAudioDelta(
          itemID: json["item_id"] as? String,
          responseID: json["response_id"] as? String,
          delta: base64Audio))
      }

    case "response.output_audio.done", "response.audio.done":
      continuation.yield(.responseAudioDone(
        itemID: json["item_id"] as? String,
        responseID: json["response_id"] as? String))

    case "response.created":
      let response = json["response"] as? [String: Any]
      continuation.yield(.responseCreated(responseID: response?["id"] as? String))

    case "input_audio_buffer.speech_started":
      continuation.yield(.inputAudioBufferSpeechStarted(
        itemID: json["item_id"] as? String,
        audioStartMS: json["audio_start_ms"] as? Int))

    case "response.function_call_arguments.done":
      if
        let name = json["name"] as? String,
        let arguments = json["arguments"] as? String,
        let callId = json["call_id"] as? String
      {
        continuation.yield(.responseFunctionCallArgumentsDone(
          name: name,
          arguments: arguments,
          callID: callId,
          itemID: json["item_id"] as? String,
          responseID: json["response_id"] as? String))
      }

    case "response.function_call_arguments.delta":
      if let delta = json["delta"] as? String {
        continuation.yield(.responseFunctionCallArgumentsDelta(
          delta: delta,
          callID: json["call_id"] as? String,
          itemID: json["item_id"] as? String,
          responseID: json["response_id"] as? String))
      }

    // New cases for handling transcription messages
    case "response.output_audio_transcript.delta", "response.audio_transcript.delta":
      if let delta = json["delta"] as? String {
        continuation.yield(.responseTranscriptDelta(
          itemID: json["item_id"] as? String,
          responseID: json["response_id"] as? String,
          delta: delta))
      }

    case "response.output_audio_transcript.done", "response.audio_transcript.done":
      if let transcript = json["transcript"] as? String {
        continuation.yield(.responseTranscriptDone(
          itemID: json["item_id"] as? String,
          responseID: json["response_id"] as? String,
          transcript: transcript))
      }

    case "input_audio_buffer.speech_stopped", "input_audio_buffer.committed", "conversation.item.truncated":
      break

    case "input_audio_buffer.transcript":
      if let transcript = json["transcript"] as? String {
        continuation.yield(.inputAudioBufferTranscript(transcript))
      }

    case "conversation.item.input_audio_transcription.delta":
      if let delta = json["delta"] as? String {
        continuation.yield(.inputAudioTranscriptionDelta(
          itemID: json["item_id"] as? String,
          delta: delta))
      }

    case "conversation.item.input_audio_transcription.completed":
      if let transcript = json["transcript"] as? String {
        continuation.yield(.inputAudioTranscriptionCompleted(
          itemID: json["item_id"] as? String,
          transcript: transcript))
      }

    // MCP (Model Context Protocol) message types
    case "mcp_list_tools.in_progress":
      logger.debug("MCP: Tool discovery in progress")
      continuation.yield(.mcpListToolsInProgress)

    case "mcp_list_tools.completed":
      logger.debug("MCP: Tool discovery completed")
      if let tools = json["tools"] as? [String: Any] {
        continuation.yield(.mcpListToolsCompleted(Self.jsonValues(from: tools)))
      } else {
        continuation.yield(.mcpListToolsCompleted([:]))
      }

    case "mcp_list_tools.failed":
      logger.error("MCP: Tool discovery failed")
      logger.error("Full JSON payload: \(String(describing: json))")

      let errorDetails = json["error"] as? [String: Any]
      let errorMessage = errorDetails?["message"] as? String
      let errorCode = errorDetails?["code"] as? String

      // Also check for top-level error fields
      let topLevelMessage = json["message"] as? String
      let topLevelCode = json["code"] as? String
      let topLevelReason = json["reason"] as? String

      let finalMessage = errorMessage ?? topLevelMessage ?? topLevelReason ?? "Unknown MCP error"
      let finalCode = errorCode ?? topLevelCode
      let fullError = finalCode != nil ? "[\(finalCode!)] \(finalMessage)" : finalMessage

      logger.error("MCP Error: \(fullError)")
      logger.error("Error details: \(String(describing: errorDetails))")
      logger
        .error(
          "Top-level fields: message=\(String(describing: topLevelMessage)), code=\(String(describing: topLevelCode)), reason=\(String(describing: topLevelReason))")

      continuation.yield(.mcpListToolsFailed(fullError))

    case "response.mcp_call.completed":
      let eventId = json["event_id"] as? String
      let itemId = json["item_id"] as? String
      let outputIndex = json["output_index"] as? Int
      continuation.yield(.responseMcpCallCompleted(eventId: eventId, itemId: itemId, outputIndex: outputIndex))

    case "response.mcp_call.in_progress":
      continuation.yield(.responseMcpCallInProgress)

    case "response.mcp_call_arguments.done":
      if let arguments = json["arguments"] as? String {
        continuation.yield(.responseMcpCallArgumentsDone(
          arguments: arguments,
          itemId: json["item_id"] as? String,
          outputIndex: json["output_index"] as? Int,
          responseId: json["response_id"] as? String))
      }

    case "response.done":
      // Handle response completion (may contain errors like insufficient_quota)
      if
        let response = json["response"] as? [String: Any],
        let status = response["status"] as? String
      {
        logger.debug("Response done with status: \(status)")

        // Pass the full response object for detailed error handling
        continuation.yield(.responseDone(
          responseID: response["id"] as? String,
          status: status,
          statusDetails: Self.jsonValues(from: response)))

        // Log errors for debugging
        if
          let statusDetails = response["status_details"] as? [String: Any],
          let error = statusDetails["error"] as? [String: Any]
        {
          let code = error["code"] as? String ?? "unknown"
          let message = error["message"] as? String ?? "Unknown error"
          logger.error("Response error: [\(code)] \(message)")
        }
      } else {
        logger.warning("Received response.done with unexpected format")
      }

    case "response.output_text.delta", "response.text.delta":
      if let delta = json["delta"] as? String {
        continuation.yield(.responseTextDelta(
          itemID: json["item_id"] as? String,
          responseID: json["response_id"] as? String,
          delta: delta))
      }

    case "response.output_text.done", "response.text.done":
      if let text = json["text"] as? String {
        continuation.yield(.responseTextDone(
          itemID: json["item_id"] as? String,
          responseID: json["response_id"] as? String,
          text: text))
      }

    case "response.output_item.added":
      if
        let item = json["item"] as? [String: Any],
        let itemId = item["id"] as? String,
        let type = item["type"] as? String
      {
        continuation.yield(.responseOutputItemAdded(itemId: itemId, type: type))
      }

    case "response.output_item.done":
      if
        let item = json["item"] as? [String: Any],
        let itemId = item["id"] as? String,
        let type = item["type"] as? String
      {
        let content = (item["content"] as? [[String: Any]])?.map(Self.jsonValues(from:))
        continuation.yield(.responseOutputItemDone(itemId: itemId, type: type, content: content))
      }

    case "response.content_part.added":
      if
        let part = json["part"] as? [String: Any],
        let type = part["type"] as? String
      {
        continuation.yield(.responseContentPartAdded(type: type))
      }

    case "response.content_part.done":
      if
        let part = json["part"] as? [String: Any],
        let type = part["type"] as? String
      {
        let text = part["text"] as? String
        continuation.yield(.responseContentPartDone(type: type, text: text))
      }

    case "conversation.item.added", "conversation.item.created":
      if
        let item = json["item"] as? [String: Any],
        let itemId = item["id"] as? String,
        let type = item["type"] as? String
      {
        let role = item["role"] as? String
        continuation.yield(.conversationItemCreated(
          itemID: itemId,
          type: type,
          role: role,
          previousItemID: json["previous_item_id"] as? String))

        if
          type == "mcp_approval_request",
          let name = item["name"] as? String,
          let arguments = item["arguments"] as? String,
          let serverLabel = item["server_label"] as? String
        {
          continuation.yield(.mcpApprovalRequest(
            id: itemId,
            name: name,
            arguments: arguments,
            serverLabel: serverLabel))
        }
      }

    case "conversation.item.done":
      if
        let item = json["item"] as? [String: Any],
        let itemID = item["id"] as? String,
        let type = item["type"] as? String
      {
        let content = (item["content"] as? [[String: Any]])?.map(Self.jsonValues(from:))
        continuation.yield(.conversationItemDone(
          itemID: itemID,
          type: type,
          role: item["role"] as? String,
          previousItemID: json["previous_item_id"] as? String,
          content: content))
      }

    case "rate_limits.updated":
      continuation.yield(.rateLimitsUpdated)

    default:
      // Log unhandled message types with more detail for debugging
      logger.warning("⚠️ Unhandled message type: \(messageType)")
      logger.debug("Full JSON: \(String(describing: json))")
      break
    }

    if !isTearingDown {
      receiveMessage()
    }
  }

}
#endif
