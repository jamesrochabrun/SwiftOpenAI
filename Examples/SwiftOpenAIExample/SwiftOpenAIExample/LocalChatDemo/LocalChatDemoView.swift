//
//  LocalChatDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 6/24/24.
//

import SwiftOpenAI
import SwiftUI

/// For more visit https://github.com/ollama/ollama/blob/main/docs/openai.md

/// Important:
/// Before using a model, pull it locally ollama pull:

/// `ollama pull llama3`
/// Default model names
/// For tooling that relies on default OpenAI model names such as gpt-3.5-turbo, use ollama cp to copy an existing model name to a temporary name:

/// `ollama cp llama3 gpt-3.5-turbo`
/// Afterwards, this new model name can be specified the model field:

/// ```curl http://localhost:11434/v1/chat/completions \
///    -H "Content-Type: application/json" \
///    -d '{
///        "model": "gpt-3.5-turbo",
///        "messages": [
///           {
///               "role": "user",
///                "content": "Hello!"
///            }
///        ]
///    }'```

struct LocalChatDemoView: View {
  init(service: OpenAIService) {
    _chatProvider = State(initialValue: ChatProvider(service: service))
  }

  enum ChatConfig {
    case chatCompletion
    case chatCompeltionStream
  }

  var body: some View {
    ScrollView {
      VStack {
        picker
        textArea
        Text(chatProvider.errorMessage)
          .foregroundColor(.red)
        switch selectedSegment {
        case .chatCompeltionStream:
          streamedChatResultView
        case .chatCompletion:
          chatCompletionResultView
        }
      }
    }
    .overlay(
      Group {
        if isLoading {
          ProgressView()
        } else {
          EmptyView()
        }
      })
  }

  var picker: some View {
    Picker("Options", selection: $selectedSegment) {
      Text("Chat Completion").tag(ChatConfig.chatCompletion)
      Text("Chat Completion stream").tag(ChatConfig.chatCompeltionStream)
    }
    .pickerStyle(SegmentedPickerStyle())
    .padding()
  }

  var textArea: some View {
    HStack(spacing: 4) {
      TextField("Enter prompt", text: $prompt, axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .padding()
      Button {
        Task {
          isLoading = true
          defer { isLoading = false } // ensure isLoading is set to false when the

          let content = ChatCompletionParameters.Message.ContentType.text(prompt)
          prompt = ""
          let parameters = ChatCompletionParameters(
            messages: [.init(
              role: .user,
              content: content)],
            // Make sure you run `ollama pull llama3` in your terminal to download this model.
            model: .custom("llama3"))
          switch selectedSegment {
          case .chatCompletion:
            try await chatProvider.startChat(parameters: parameters)
          case .chatCompeltionStream:
            try await chatProvider.startStreamedChat(parameters: parameters)
          }
        }
      } label: {
        Image(systemName: "paperplane")
      }
      .buttonStyle(.bordered)
    }
    .padding()
  }

  /// stream = `false`
  var chatCompletionResultView: some View {
    ForEach(Array(chatProvider.messages.enumerated()), id: \.offset) { _, val in
      VStack(spacing: 0) {
        Text("\(val)")
      }
    }
  }

  /// stream = `true`
  var streamedChatResultView: some View {
    VStack {
      Button("Cancel stream") {
        chatProvider.cancelStream()
      }
      Text(chatProvider.message)
    }
  }

  @State private var chatProvider: ChatProvider
  @State private var isLoading = false
  @State private var prompt = ""
  @State private var selectedSegment = ChatConfig.chatCompeltionStream
}
