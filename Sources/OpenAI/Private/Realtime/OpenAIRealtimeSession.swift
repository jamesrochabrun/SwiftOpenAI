//
//  OpenAIRealtimeSession.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

import Foundation
import AVFoundation
import OSLog

nonisolated private let kWebsocketDisconnectedErrorCode = 57
nonisolated private let kWebsocketDisconnectedEarlyThreshold: TimeInterval = 3

@RealtimeActor open class OpenAIRealtimeSession {
    private var isTearingDown = false
    private let webSocketTask: URLSessionWebSocketTask
    private var continuation: AsyncStream<OpenAIRealtimeMessage>.Continuation?
    private let setupTime = Date()
    let sessionConfiguration: OpenAIRealtimeSessionConfiguration
    private let logger = Logger(subsystem: "com.swiftopenai", category: "Realtime")

    nonisolated init(
        webSocketTask: URLSessionWebSocketTask,
        sessionConfiguration: OpenAIRealtimeSessionConfiguration
    ) {
        self.webSocketTask = webSocketTask
        self.sessionConfiguration = sessionConfiguration

        Task { @RealtimeActor in
            await self.sendMessage(OpenAIRealtimeSessionUpdate(session: self.sessionConfiguration))
        }
        self.webSocketTask.resume()
        self.receiveMessage()
    }

    deinit {
        logger.debug("OpenAIRealtimeSession is being freed")
    }

    /// Messages sent from OpenAI are published on this receiver as they arrive
    public var receiver: AsyncStream<OpenAIRealtimeMessage> {
        return AsyncStream { continuation in
            self.continuation = continuation
        }
    }

    /// Sends a message through the websocket connection
    public func sendMessage(_ encodable: Encodable) async {
        guard !self.isTearingDown else {
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
            try await self.webSocketTask.send(wsMessage)
        } catch {
            logger.error("Could not send message to OpenAI: \(error.localizedDescription)")
        }
    }

    /// Close the websocket connection
    public func disconnect() {
        self.isTearingDown = true
        self.continuation?.finish()
        self.continuation = nil
        self.webSocketTask.cancel()
    }

    /// Tells the websocket task to receive a new message
    nonisolated private func receiveMessage() {
        self.webSocketTask.receive { result in
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

        self.disconnect()
    }

    /// Handles received websocket messages
    private func didReceiveWebSocketMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            if let data = text.data(using: .utf8) {
                self.didReceiveWebSocketData(data)
            }
        case .data(let data):
            self.didReceiveWebSocketData(data)
        @unknown default:
            logger.error("Received an unknown websocket message format")
            self.disconnect()
        }
    }

    private func didReceiveWebSocketData(_ data: Data) {
        guard !self.isTearingDown else {
            // The caller already initiated disconnect,
            // don't send any more messages back to the caller
            return
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let messageType = json["type"] as? String else {
            logger.error("Received websocket data that we don't understand")
            self.disconnect()
            return
        }
        logger.debug("Received \(messageType) from OpenAI")

        switch messageType {
        case "error":
            let errorBody = String(describing: json["error"] as? [String: Any])
            logger.error("Received error from OpenAI websocket: \(errorBody)")
            self.continuation?.yield(.error(errorBody))
        case "session.created":
            self.continuation?.yield(.sessionCreated)
        case "session.updated":
            self.continuation?.yield(.sessionUpdated)
        case "response.audio.delta":
            if let base64Audio = json["delta"] as? String {
                self.continuation?.yield(.responseAudioDelta(base64Audio))
            }
        case "response.created":
            self.continuation?.yield(.responseCreated)
        case "input_audio_buffer.speech_started":
            self.continuation?.yield(.inputAudioBufferSpeechStarted)
        case "response.function_call_arguments.done":
            if let name = json["name"] as? String,
               let arguments = json["arguments"] as? String,
               let callId = json["call_id"] as? String {
                self.continuation?.yield(.responseFunctionCallArgumentsDone(name, arguments, callId))
            }

        // New cases for handling transcription messages
        case "response.audio_transcript.delta":
            if let delta = json["delta"] as? String {
                self.continuation?.yield(.responseTranscriptDelta(delta))
            }

        case "response.audio_transcript.done":
            if let transcript = json["transcript"] as? String {
                self.continuation?.yield(.responseTranscriptDone(transcript))
            }

        case "input_audio_buffer.transcript":
            if let transcript = json["transcript"] as? String {
                self.continuation?.yield(.inputAudioBufferTranscript(transcript))
            }

        case "conversation.item.input_audio_transcription.delta":
            if let delta = json["delta"] as? String {
                self.continuation?.yield(.inputAudioTranscriptionDelta(delta))
            }

        case "conversation.item.input_audio_transcription.completed":
            if let transcript = json["transcript"] as? String {
                self.continuation?.yield(.inputAudioTranscriptionCompleted(transcript))
            }

        default:
            // Log unhandled message types for debugging
            logger.debug("Unhandled message type: \(messageType)")
            break
        }

        if messageType != "error" && !self.isTearingDown {
            self.receiveMessage()
        }
    }
}
