//
//  ChatPredictedOutputDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 1/3/25.
//

import Foundation
import SwiftOpenAI
import SwiftUI

// MARK: - ChatPredictedOutputDemoView

/// https://platform.openai.com/docs/guides/predicted-outputs
struct ChatPredictedOutputDemoView: View {
  init(service: OpenAIService) {
    chatProvider = ChatProvider(service: service)
  }

  var body: some View {
    ScrollView {
      VStack {
        textArea
        Text(chatProvider.errorMessage)
          .foregroundColor(.red)
        chatCompletionResultView
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
            messages: [
              .init(role: .system, content: .text(systemMessage)),
              .init(role: .user, content: content),
              .init(role: .user, content: .text(predictedCode)),
            ], // Sending the predicted code as another user message.
            model: .gpt4o,
            prediction: .init(content: .text(predictedCode)))
          try await chatProvider.startChat(parameters: parameters)
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

  @State private var chatProvider: ChatProvider
  @State private var isLoading = false
  @State private var prompt = ""
}

let systemMessage = """
  You are a code editor assistant. I only output code without any explanations, commentary, or additional text. I follow these rules:

  1. Respond with code only, never any text or explanations
  2. Use appropriate syntax highlighting/formatting 
  3. If the code needs to be modified/improved, output the complete updated code
  4. Do not include caveats, introductions, or commentary
  5. Do not ask questions or solicit feedback
  6. Do not explain what changes were made
  7. Assume the user knows what they want and will review the code themselves
  """

let predictedCode = """
  struct ChatPredictedOutputDemoView: View {

     @State private var chatProvider: ChatProvider
     @State private var isLoading = false
     @State private var prompt = ""

     init(service: OpenAIService) {
        chatProvider = ChatProvider(service: service)
     }

     var body: some View {
        ScrollView {
           VStack {
              textArea
              Text(chatProvider.errorMessage)
                 .foregroundColor(.red)
              streamedChatResultView
           }
        }
        .overlay(
           Group {
              if isLoading {
                 ProgressView()
              } else {
                 EmptyView()
              }
           }
        )
     }

     var textArea: some View {
        HStack(spacing: 4) {
           TextField("Enter prompt", text: $prompt, axis: .vertical)
              .textFieldStyle(.roundedBorder)
              .padding()
           Button {
              Task {
                 isLoading = true
                 defer { isLoading = false }  // ensure isLoading is set to false when the

                 let content: ChatCompletionParameters.Message.ContentType = .text(prompt)
                 prompt = ""
                 let parameters = ChatCompletionParameters(
                    messages: [.init(
                    role: .user,
                    content: content)],
                    model: .gpt4o)
              }
           } label: {
              Image(systemName: "paperplane")
           }
           .buttonStyle(.bordered)
        }
        .padding()
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
  }
  """
