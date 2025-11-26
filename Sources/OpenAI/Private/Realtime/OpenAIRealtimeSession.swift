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
    self.webSocketTask = webSocketTask
    self.sessionConfiguration = sessionConfiguration

    Task { @RealtimeActor in
      await self.sendMessage(OpenAIRealtimeSessionUpdate(session: self.sessionConfiguration))
    }
    self.webSocketTask.resume()
    receiveMessage()
  }

  deinit {
    logger.debug("OpenAIRealtimeSession is being freed")
  }

  /// Messages sent from OpenAI are published on this receiver as they arrive
  public var receiver: AsyncStream<OpenAIRealtimeMessage> {
    AsyncStream { continuation in
      self.continuation = continuation
    }
  }

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
    continuation?.finish()
    continuation = nil
    webSocketTask.cancel()
  }

  let sessionConfiguration: OpenAIRealtimeSessionConfiguration

  private var isTearingDown = false
  private let webSocketTask: URLSessionWebSocketTask
  private var continuation: AsyncStream<OpenAIRealtimeMessage>.Continuation?
  private let setupTime = Date()
  private let logger = Logger(subsystem: "com.swiftopenai", category: "Realtime")

  /// Tells the websocket task to receive a new message
  nonisolated private func receiveMessage() {
    webSocketTask.receive { result in
      switch result {
      case .failure(let error as NSError):
        Task { @RealtimeActor in
          await self.didReceiveWebSocketError(error)
        }

      case .success(let message):
        Task { @RealtimeActor in
          await self.didReceiveWebSocketMessage(message)
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
      disconnect()
      return
    }
    logger.debug("Received \(messageType) from OpenAI")

    switch messageType {
    case "error":
      let errorBody = String(describing: json["error"] as? [String: Any])
      logger.error("Received error from OpenAI websocket: \(errorBody)")
      continuation?.yield(.error(errorBody))

    case "session.created":
      continuation?.yield(.sessionCreated)

    case "session.updated":
      continuation?.yield(.sessionUpdated)

    case "response.audio.delta":
      if let base64Audio = json["delta"] as? String {
        continuation?.yield(.responseAudioDelta(base64Audio))
      }

    case "response.created":
      continuation?.yield(.responseCreated)

    case "input_audio_buffer.speech_started":
      continuation?.yield(.inputAudioBufferSpeechStarted)

    case "response.function_call_arguments.done":
      if
        let name = json["name"] as? String,
        let arguments = json["arguments"] as? String,
        let callId = json["call_id"] as? String
      {
        continuation?.yield(.responseFunctionCallArgumentsDone(name, arguments, callId))
      }

    // New cases for handling transcription messages
    case "response.audio_transcript.delta":
      if let delta = json["delta"] as? String {
        continuation?.yield(.responseTranscriptDelta(delta))
      }

    case "response.audio_transcript.done":
      if let transcript = json["transcript"] as? String {
        continuation?.yield(.responseTranscriptDone(transcript))
      }

    case "input_audio_buffer.transcript":
      if let transcript = json["transcript"] as? String {
        continuation?.yield(.inputAudioBufferTranscript(transcript))
      }

    case "conversation.item.input_audio_transcription.delta":
      if let delta = json["delta"] as? String {
        continuation?.yield(.inputAudioTranscriptionDelta(delta))
      }

    case "conversation.item.input_audio_transcription.completed":
      if let transcript = json["transcript"] as? String {
        continuation?.yield(.inputAudioTranscriptionCompleted(transcript))
      }

    // MCP (Model Context Protocol) message types
    case "mcp_list_tools.in_progress":
      logger.debug("MCP: Tool discovery in progress")
      continuation?.yield(.mcpListToolsInProgress)

    case "mcp_list_tools.completed":
      logger.debug("MCP: Tool discovery completed")
      if let tools = json["tools"] as? [String: Any] {
        continuation?.yield(.mcpListToolsCompleted(tools))
      } else {
        continuation?.yield(.mcpListToolsCompleted([:]))
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

      continuation?.yield(.mcpListToolsFailed(fullError))

    case "response.done":
      // Handle response completion (may contain errors like insufficient_quota)
      if
        let response = json["response"] as? [String: Any],
        let status = response["status"] as? String
      {
        logger.debug("Response done with status: \(status)")

        // Pass the full response object for detailed error handling
        continuation?.yield(.responseDone(status: status, statusDetails: response))

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

    case "response.text.delta":
      if let delta = json["delta"] as? String {
        continuation?.yield(.responseTextDelta(delta))
      }

    case "response.text.done":
      if let text = json["text"] as? String {
        continuation?.yield(.responseTextDone(text))
      }

    case "response.output_item.added":
      if let item = json["item"] as? [String: Any],
        let itemId = item["id"] as? String,
        let type = item["type"] as? String
      {
        continuation?.yield(.responseOutputItemAdded(itemId: itemId, type: type))
      }

    case "response.output_item.done":
      if let item = json["item"] as? [String: Any],
        let itemId = item["id"] as? String,
        let type = item["type"] as? String
      {
        let content = item["content"] as? [[String: Any]]
        continuation?.yield(.responseOutputItemDone(itemId: itemId, type: type, content: content))
      }

    case "response.content_part.added":
      if let part = json["part"] as? [String: Any],
        let type = part["type"] as? String
      {
        continuation?.yield(.responseContentPartAdded(type: type))
      }

    case "response.content_part.done":
      if let part = json["part"] as? [String: Any],
        let type = part["type"] as? String
      {
        let text = part["text"] as? String
        continuation?.yield(.responseContentPartDone(type: type, text: text))
      }

    case "conversation.item.created":
      if let item = json["item"] as? [String: Any],
        let itemId = item["id"] as? String,
        let type = item["type"] as? String
      {
        let role = item["role"] as? String
        continuation?.yield(.conversationItemCreated(itemId: itemId, type: type, role: role))
      }

    default:
      // Log unhandled message types with more detail for debugging
      logger.warning("⚠️ Unhandled message type: \(messageType)")
      logger.debug("Full JSON: \(String(describing: json))")
      break
    }

    if messageType != "error", !isTearingDown {
      receiveMessage()
    }
  }
}
#endif
