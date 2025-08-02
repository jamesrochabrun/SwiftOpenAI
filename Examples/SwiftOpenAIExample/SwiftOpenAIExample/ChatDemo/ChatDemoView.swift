//
//  ChatDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftOpenAI
import SwiftUI

struct ChatDemoView: View {
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
            model: .custom("claude-3-7-sonnet-20250219"))
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
