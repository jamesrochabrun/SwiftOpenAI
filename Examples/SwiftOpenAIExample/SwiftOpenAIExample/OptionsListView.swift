//
//  OptionsListView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftUI
import SwiftOpenAI

struct OptionsListView: View {
   
   var openAIService: OpenAIService
   
   var options: [APIOption]
   
   @State private var selection: APIOption? = nil
   
   /// https://platform.openai.com/docs/api-reference
   enum APIOption: String, CaseIterable, Identifiable {
      case audio = "Audio"
      case chat = "Chat"
      case chatPredictedOutput = "Chat Predicted Output"
      case localChat = "Local Chat" // Ollama
      case vision = "Vision"
      case embeddings = "Embeddings"
      case fineTuning = "Fine Tuning"
      case files = "Files"
      case images = "Images"
      case models = "Models"
      case moderations = "Moderations"
      case chatHistoryConversation = "Chat History Conversation"
      case chatFunctionCall = "Chat Functions call"
      case chatFunctionsCallStream = "Chat Functions call (Stream)"
      case chatStructuredOutput = "Chat Structured Output"
      case chatStructuredOutputTool = "Chat Structured Output Tools"
      case configureAssistant = "Configure Assistant"
      case realTimeAPI = "Real time API"

      var id: String { rawValue }
   }
   
   var body: some View {
      List(options, id: \.self, selection: $selection) { option in
         Text(option.rawValue)
            .sheet(item: $selection) { selection in
               VStack {
                  Text(selection.rawValue)
                     .font(.largeTitle)
                     .padding()
                  switch selection {
                  case .audio:
                     AudioDemoView(service: openAIService)
                  case .chat:
                     ChatDemoView(service: openAIService)
                  case .chatPredictedOutput:
                     ChatPredictedOutputDemoView(service: openAIService)
                  case .vision:
                     ChatVisionDemoView(service: openAIService)
                  case .embeddings:
                     EmbeddingsDemoView(service: openAIService)
                  case .fineTuning:
                     FineTuningJobDemoView(service: openAIService)
                  case .files:
                     FilesDemoView(service: openAIService)
                  case .images:
                     ImagesDemoView(service: openAIService)
                  case .localChat:
                     LocalChatDemoView(service: openAIService)
                  case .models:
                     ModelsDemoView(service: openAIService)
                  case .moderations:
                     ModerationDemoView(service: openAIService)
                  case .chatHistoryConversation:
                     ChatStreamFluidConversationDemoView(service: openAIService)
                  case .chatFunctionCall:
                     ChatFunctionCallDemoView(service: openAIService)
                  case .chatFunctionsCallStream:
                     ChatFunctionsCalllStreamDemoView(service: openAIService)
                  case .chatStructuredOutput:
                     ChatStructuredOutputDemoView(service: openAIService)
                  case .chatStructuredOutputTool:
                     ChatStructureOutputToolDemoView(service: openAIService)
                  case .configureAssistant:
                     AssistantConfigurationDemoView(service: openAIService)
                  case .realTimeAPI:
                     RealTimeAPIDemoView(service: openAIService)
                  }
               }
            }
      }
   }
}

import SwiftUI
import AVFoundation

struct RealTimeAPIDemoView: View {
    @State private var realTimeAPIViewModel: RealTimeAPIViewModel
    @State private var microphonePermission: AVAudioSession.RecordPermission
    
    init(service: OpenAIService) {
        realTimeAPIViewModel = .init(service: service)
        _microphonePermission = State(initialValue: AVAudioSession.sharedInstance().recordPermission)
    }
    
    var body: some View {
        Group {
            switch microphonePermission {
            case .undetermined:
                requestPermissionButton
            case .denied:
                deniedPermissionView
            case .granted:
               actionButtons
            default:
                Text("Unknown permission state")
            }
        }
        .onAppear {
            updateMicrophonePermission()
        }
    }
   
   private var actionButtons: some View {
      VStack(spacing: 40) {
         startSessionButton
         endSessionButton
      }
   }
    
    private var startSessionButton: some View {
        Button {
            Task {
                await realTimeAPIViewModel.testOpenAIRealtime()
            }
        } label: {
            Label("Start session", systemImage: "microphone")
        }
    }
   
   public var endSessionButton: some View {
      Button {
          Task {
             await realTimeAPIViewModel.disconnect()
          }
      } label: {
          Label("Stop session", systemImage: "stop")
      }
   }
    
    private var requestPermissionButton: some View {
        Button {
            requestMicrophonePermission()
        } label: {
            Label("Allow microphone access", systemImage: "mic.slash")
        }
    }
    
    private var deniedPermissionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.slash.circle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Microphone access is required")
                .font(.headline)
            
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
    }
    
    private func updateMicrophonePermission() {
        microphonePermission = AVAudioSession.sharedInstance().recordPermission
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                microphonePermission = granted ? .granted : .denied
            }
        }
    }
}



import AVFoundation

@Observable
final class RealTimeAPIViewModel {
   
   let service: OpenAIService
   
   init(service: OpenAIService) {
      self.service = OpenAIServiceFactory.service(aiproxyPartialKey: "v2|fb95ad14|31VKBMnxTslxldTs", aiproxyServiceURL: "https://api.aiproxy.pro/84e28a54/4488ddf3")
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
          turnDetection: nil,//.init(prefixPaddingMs: 200, silenceDurationMs: 500, threshold: 0.5),
          voice: "shimmer"
      )
      
//      let sessionConfiguration = RealTimeSessionParameters(
//         modalities: ["audio", "text"],
//         model: .custom("gpt-4o-mini-realtime-preview-2024-12-17"),
//         instructions: "You are tour guide for Monument Valley, Utah",
//         voice: .shimmer,
//         inputAudioFormat: .pcm16,
//         outputAudioFormat: .pcm16,
//         inputAudioTranscription: .init(model: "whisper-1"),
//         turnDetection: .init(threshold: 0.5, prefixPaddingMs: 200, silenceDurationMs: 500),
//         temperature: 0.7,
//         maxResponseOutputTokens: .finite(4096))
      
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

