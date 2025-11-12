//
//  RealtimeExample.swift
//  SwiftOpenAI
//
//  Example implementation of OpenAI Realtime API for bidirectional voice conversation
//

import AVFoundation
import OpenAI
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

    let audioController = try await AudioController(modes: [.playback, .record])
    let micStream = try audioController.micStream()

    // Configure the realtime session
    let configuration = OpenAIRealtimeSessionConfiguration(
      inputAudioFormat: .pcm16,
      inputAudioTranscription: .init(model: "whisper-1"),
      instructions: "You are a helpful, witty, and friendly AI assistant. " +
        "Your voice and personality should be warm and engaging, " +
        "with a lively and playful tone. Talk quickly.",
      maxResponseOutputTokens: .int(4096),
      modalities: [.audio, .text],
      outputAudioFormat: .pcm16,
      temperature: 0.7,
      turnDetection: .init(
        type: .semanticVAD(eagerness: .medium)),
      voice: "shimmer")

    // Create the realtime session
    let realtimeSession = try await service.realtimeSession(
      model: "gpt-4o-mini-realtime-preview-2024-12-17",
      configuration: configuration)

    // Send audio from the microphone to OpenAI once OpenAI is ready for it
    var isOpenAIReadyForAudio = false
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
          if aiSpeaksFirst {
            await realtimeSession.sendMessage(OpenAIRealtimeResponseCreate())
          } else {
            isOpenAIReadyForAudio = true
          }

        case .responseAudioDelta(let base64String):
          audioController.playPCM16Audio(base64String: base64String)

        case .inputAudioBufferSpeechStarted:
          // User started speaking, interrupt AI playback
          audioController.interruptPlayback()

        case .responseCreated:
          isOpenAIReadyForAudio = true

        case .responseTranscriptDone(let transcript):
          print("AI said: \(transcript)")

        case .inputAudioTranscriptionCompleted(let transcript):
          print("User said: \(transcript)")

        case .responseFunctionCallArgumentsDone(let name, let arguments, let callId):
          print("Function call: \(name) with args: \(arguments)")
                    // Handle function calls here

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
//       modalities: [.audio, .text],
//       outputAudioFormat: .pcm16,
//       voice: "shimmer"
//   )
//
// 5. Create the realtime session:
//   let session = try await service.realtimeSession(
//       model: "gpt-4o-mini-realtime-preview-2024-12-17",
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
//       case .responseAudioDelta(let base64Audio):
//           audioController.playPCM16Audio(base64String: base64Audio)
//       default:
//           break
//       }
//   }
