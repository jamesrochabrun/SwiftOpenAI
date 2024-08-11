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
      case configureAssistant = "Configure Assistant"

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
                  case .configureAssistant:
                     AssistantConfigurationDemoView(service: openAIService)
                  }
               }
            }
      }
   }
}

