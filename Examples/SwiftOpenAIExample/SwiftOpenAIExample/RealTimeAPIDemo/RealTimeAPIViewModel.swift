//
//  RealTimeAPIViewModel.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/18/25.
//

import AVFoundation
import Foundation

@Observable
final class RealTimeAPIViewModel {

   let service: OpenAIService

   init(service: OpenAIService) {
      self.service = service
   }

   var kMicrophoneSampleVendor: MicrophonePCMSampleVendor?
   var kRealtimeSession: OpenAIRealtimeSession?

   @RealtimeActor
   func disconnect() {
      kRealtimeSession?.disconnect()
   }

   @RealtimeActor
   func testOpenAIRealtime() async {

      let sessionConfiguration = OpenAIRealtimeSessionUpdate.SessionConfiguration(
          inputAudioFormat: "pcm16",
          inputAudioTranscription: .init(model: "whisper-1"),
          instructions: "You are tour guide for Monument Valley, Utah",
          maxResponseOutputTokens: .int(4096),
          modalities: ["audio", "text"],
          outputAudioFormat: "pcm16",
          temperature: 0.7,
          turnDetection: .init(prefixPaddingMs: 200, silenceDurationMs: 500, threshold: 0.5),
          voice: "shimmer"
      )

      let microphoneSampleVendor = MicrophonePCMSampleVendor()
      let audioStream: AsyncStream<AVAudioPCMBuffer>
      do {
         audioStream = try microphoneSampleVendor.start(useVoiceProcessing: true)
      } catch {
         fatalError("Could not start audio stream: \(error.localizedDescription)")
      }

      let realtimeSession: OpenAIRealtimeSession
      do {
         realtimeSession = try await service.realTimeSession(sessionConfiguration: sessionConfiguration)
      } catch {
         fatalError("Could not create an OpenAI realtime session")
      }

      var isOpenAIReadyForAudio = true
      Task {
         for await buffer in audioStream {
            if isOpenAIReadyForAudio, let base64Audio = Helper.base64EncodeAudioPCMBuffer(from: buffer) {
               try await realtimeSession.sendMessage(
                  OpenAIRealtimeInputAudioBufferAppend(audio: base64Audio)
               )
            }
         }
         print("zizou Done streaming microphone audio")
      }

      Task {
         do {
            print("zizou Sending response create")
            try await realtimeSession.sendMessage(OpenAIRealtimeResponseCreate(response: .init(instructions: "Can you describe Monument Valley?", modalities: ["audio", "text"])))
         } catch {
            print("zizou Could not send the session configuration instructions")
         }
      }

      Task {
         for await message in realtimeSession.receiver {
            switch message {
            case .sessionUpdated:
               isOpenAIReadyForAudio = true
            case .responseAudioDelta(let base64Audio):
               InternalAudioPlayer.playPCM16Audio(from: base64Audio)
            default:
               break
            }
         }
         print("zizou Done listening for messages from OpenAI")
      }

      // Some time later
      // microphoneSampleVendor.stop()

      kMicrophoneSampleVendor = microphoneSampleVendor
      kRealtimeSession = realtimeSession
   }
}
