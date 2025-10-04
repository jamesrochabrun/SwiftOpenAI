//
//  OptionsListView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftOpenAI
import SwiftUI

struct OptionsListView: View {
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
    case responseStream = "Response Stream Demo"

    var id: String { rawValue }
  }

  var openAIService: OpenAIService

  var options: [APIOption]

  var body: some View {
    VStack {
      // Custom model input field
      VStack(alignment: .leading, spacing: 8) {
        Text("Custom Model (Optional)")
          .font(.caption)
          .foregroundColor(.secondary)
        TextField("e.g., grok-beta, claude-3-opus, etc.", text: $customModel)
          .textFieldStyle(.roundedBorder)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      .padding()
      List(options, id: \.self, selection: $selection) { option in
        Text(option.rawValue)
      }
    }
    .sheet(item: $selection) { selection in
      VStack {
        Text(selection.rawValue)
          .font(.largeTitle)
          .padding()
        switch selection {
        case .audio:
          AudioDemoView(service: openAIService)
        case .chat:
          ChatDemoView(service: openAIService, customModel: customModel)
        case .chatPredictedOutput:
          ChatPredictedOutputDemoView(service: openAIService, customModel: customModel)
        case .vision:
          ChatVisionDemoView(service: openAIService, customModel: customModel)
        case .embeddings:
          EmbeddingsDemoView(service: openAIService)
        case .fineTuning:
          FineTuningJobDemoView(service: openAIService)
        case .files:
          FilesDemoView(service: openAIService)
        case .images:
          ImagesDemoView(service: openAIService)
        case .localChat:
          LocalChatDemoView(service: openAIService, customModel: customModel)
        case .models:
          ModelsDemoView(service: openAIService)
        case .moderations:
          ModerationDemoView(service: openAIService)
        case .chatHistoryConversation:
          ChatStreamFluidConversationDemoView(service: openAIService, customModel: customModel)
        case .chatFunctionCall:
          ChatFunctionCallDemoView(service: openAIService)
        case .chatFunctionsCallStream:
          ChatFunctionsCalllStreamDemoView(service: openAIService, customModel: customModel)
        case .chatStructuredOutput:
          ChatStructuredOutputDemoView(service: openAIService, customModel: customModel)
        case .chatStructuredOutputTool:
          ChatStructureOutputToolDemoView(service: openAIService, customModel: customModel)
        case .configureAssistant:
          AssistantConfigurationDemoView(service: openAIService)
        case .realTimeAPI:
          Text("WIP")
        case .responseStream:
          ResponseStreamDemoView(service: openAIService)
        }
      }
    }
  }

  @State private var selection: APIOption? = nil
  @State private var customModel = ""
}
