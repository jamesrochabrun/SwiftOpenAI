//
//  RealtimeExample.swift
//  SwiftOpenAI
//
//  Example implementation of OpenAI Realtime API for bidirectional voice conversation and tool calling
//

import AVFoundation
import Foundation
import SwiftOpenAI
import SwiftUI

// MARK: - RealtimeExampleView

struct RealtimeExampleView: View {
  let realtimeManager = RealtimeManager()

  var body: some View {
    VStack {
      Button(isRealtimeActive ? "Stop OpenAI Realtime" : "Start OpenAI Realtime") {
        isRealtimeActive.toggle()
      }
    }
  }

  @State private var isRealtimeActive = false {
    willSet {
      if newValue {
        startRealtime()
      } else {
        stopRealtime()
      }
    }
  }

  private func startRealtime() {
    Task {
      do {
        try await realtimeManager.startConversation()
      } catch {
        print("Could not start OpenAI realtime: \(error.localizedDescription)")
      }
    }
  }

  private func stopRealtime() {
    Task {
      await realtimeManager.stopConversation()
    }
  }

}

// MARK: - RealtimeManager

@RealtimeActor
final class RealtimeManager {
  nonisolated init() { }

  func startConversation() async throws {
    // Initialize the OpenAI service with your API key
    let service = OpenAIServiceFactory.service(apiKey: "your-api-key-here")

    // Set to false if you want your user to speak first
    let aiSpeaksFirst = true

    // Configure the realtime session
    let configuration = OpenAIRealtimeSessionConfiguration(
      inputAudioFormat: .pcm16,
      inputAudioTranscription: .init(model: Model.gptRealtimeWhisper.value, delay: .low, language: "en"),
      instructions: "You are a helpful, witty, and friendly AI assistant. " +
        "Your voice and personality should be warm and engaging, " +
        "with a lively and playful tone. Talk quickly. " +
        "When asked about the current demo context, call get_demo_context before answering.",
      maxResponseOutputTokens: .int(4096),
      modalities: [.audio],
      outputAudioFormat: .pcm16,
      parallelToolCalls: true,
      reasoning: .init(effort: .low),
      tools: [
        .function(.init(
          name: "get_demo_context",
          description: "Get current context from this SwiftOpenAI Realtime example.",
          parameters: [
            "type": "object",
            "properties": [
              "topic": [
                "type": "string",
                "description": "The context to retrieve.",
                "enum": ["time", "session"],
              ],
            ],
            "required": ["topic"],
            "additionalProperties": false,
          ])),
      ],
      toolChoice: .auto,
      turnDetection: .init(
        type: .semanticVAD(eagerness: .auto, createResponse: true, interruptResponse: true)),
      voice: "marin")

    // Create the realtime session
    let realtimeSession = try await service.realtimeSession(
      model: Model.gptRealtime21.value,
      configuration: configuration)

    // Install the input tap only after the buffered session exists. `micStream()` starts the
    // fully configured capture/playback graph before either event task begins consuming data.
    let audioController = try await AudioController(modes: [.playback, .record])
    let micStream = try audioController.micStream()

    // Send audio from the microphone to OpenAI once OpenAI is ready for it
    var isOpenAIReadyForAudio = false
    var currentResponseID: String?
    var pendingToolResponseID: String?
    var currentAudioItemID: String?
    Task {
      for await buffer in micStream {
        if
          isOpenAIReadyForAudio,
          let base64Audio = AudioUtils.base64EncodeAudioPCMBuffer(from: buffer)
        {
          await realtimeSession.sendMessage(
            OpenAIRealtimeInputAudioBufferAppend(audio: base64Audio))
        }
      }
    }

    // Listen for messages from OpenAI
    Task {
      for await message in realtimeSession.receiver {
        switch message {
        case .error(let errorMessage):
          print("Received error from OpenAI: \(errorMessage ?? "Unknown error")")
          realtimeSession.disconnect()

        case .sessionUpdated:
          isOpenAIReadyForAudio = true
          if aiSpeaksFirst {
            await realtimeSession.sendMessage(OpenAIRealtimeResponseCreate())
          }

        case .responseAudioDelta(let itemID, _, let base64String):
          currentAudioItemID = itemID
          audioController.playPCM16Audio(base64String: base64String, itemID: itemID)

        case .inputAudioBufferSpeechStarted:
          if
            let assistantItemID = currentAudioItemID,
            let audioEndMS = audioController.interruptPlayback()
          {
            await realtimeSession.sendMessage(OpenAIRealtimeConversationItemTruncate(
              itemID: assistantItemID,
              audioEndMS: audioEndMS))
          }
          currentAudioItemID = nil

        case .responseCreated(let responseID):
          currentResponseID = responseID

        case .responseDone(let responseID, let status, _):
          if Self.responseIDsMatch(currentResponseID, responseID) {
            currentResponseID = nil
          }
          if
            pendingToolResponseID != nil,
            Self.responseIDsMatch(pendingToolResponseID, responseID)
          {
            pendingToolResponseID = nil
            if status == "completed" {
              await realtimeSession.sendMessage(OpenAIRealtimeResponseCreate())
            }
          }

        case .responseTranscriptDone(_, _, let transcript):
          print("AI said: \(transcript)")

        case .inputAudioTranscriptionCompleted(_, let transcript):
          print("User said: \(transcript)")

        case .responseFunctionCallArgumentsDone(
          let name,
          let arguments,
          let callId,
          _,
          let responseID):
          print("Function call: \(name) with args: \(arguments)")
          let output = Self.handleFunctionCall(name: name, arguments: arguments)
          await realtimeSession.sendMessage(
            OpenAIRealtimeFunctionCallOutput(callID: callId, output: output))
          if currentResponseID != nil {
            pendingToolResponseID = responseID ?? currentResponseID
          }

        default:
          break
        }
      }
    }

    self.realtimeSession = realtimeSession
    self.audioController = audioController
  }

  func stopConversation() {
    audioController?.stop()
    realtimeSession?.disconnect()
    audioController = nil
    realtimeSession = nil
  }

  private var realtimeSession: OpenAIRealtimeSession?
  private var audioController: AudioController?

  private static func responseIDsMatch(_ lhs: String?, _ rhs: String?) -> Bool {
    guard let lhs, let rhs else { return true }
    return lhs == rhs
  }

  private static func handleFunctionCall(name: String, arguments _: String) -> String {
    guard name == "get_demo_context" else {
      return #"{"error":"Unknown function"}"#
    }

    let payload: [String: String] = [
      "model": Model.gptRealtime21.value,
      "current_time": ISO8601DateFormatter().string(from: Date()),
      "session_state": "connected",
    ]
    let data = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
    return data.flatMap { String(data: $0, encoding: .utf8) } ?? #"{"error":"Encoding failed"}"#
  }
}

// MARK: - Basic Usage Example

// To use the Realtime API:
//
// 1. Add NSMicrophoneUsageDescription to your Info.plist:
//   <key>NSMicrophoneUsageDescription</key>
//   <string>We need access to your microphone for voice conversations with AI</string>
//
// 2. On macOS, enable the following in your target's Signing & Capabilities:
//   - App Sandbox > Outgoing Connections (client)
//   - App Sandbox > Audio Input
//   - Hardened Runtime > Audio Input
//
// 3. Initialize the service with your API key:
//   let service = OpenAIServiceFactory.service(apiKey: "your-api-key")
//
// 4. Create a session configuration:
//   let config = OpenAIRealtimeSessionConfiguration(
//       inputAudioFormat: .pcm16,
//       instructions: "You are a helpful assistant",
//       modalities: [.audio],
//       outputAudioFormat: .pcm16,
//       voice: "marin"
//   )
//
// 5. Create the realtime session:
//   let session = try await service.realtimeSession(
//       model: Model.gptRealtime21.value,
//       configuration: config
//   )
//
// 6. Set up audio controller:
//   let audioController = try await AudioController(modes: [.playback, .record])
//
// 7. Stream microphone audio to OpenAI:
//   for await buffer in try audioController.micStream() {
//       if let base64Audio = AudioUtils.base64EncodeAudioPCMBuffer(from: buffer) {
//           await session.sendMessage(
//               OpenAIRealtimeInputAudioBufferAppend(audio: base64Audio)
//           )
//       }
//   }
//
// 8. Listen for and play responses:
//   for await message in session.receiver {
//       switch message {
//       case .responseAudioDelta(_, _, let base64Audio):
//           audioController.playPCM16Audio(base64String: base64Audio)
//       default:
//           break
//       }
//   }
