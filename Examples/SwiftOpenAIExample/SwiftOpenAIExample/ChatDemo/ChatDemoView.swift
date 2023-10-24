//
//  ChatDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftUI
import SwiftOpenAI

struct ChatDemoView: View {
   
   @State private var chatProvider: ChatProvider
   @State private var isLoading: Bool = false
   @State private var prompt: String = ""
   @State private var selectedSegment: ChatConfig = .chatCompeltionStream
   
   enum ChatConfig {
      case chatCompletion
      case chatCompeltionStream
   }
   
   init(service: OpenAIService) {
      _chatProvider = State(initialValue: ChatProvider(service: service))
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
               defer { isLoading = false }  // ensure isLoading is set to false when the
               switch selectedSegment {
               case .chatCompletion:
                  try await chatProvider.startChat(parameters: .init(messages: [.init(role: .assistant, content: prompt)], model: .gpt35Turbo))
               case .chatCompeltionStream:
                  try await chatProvider.startStreamedChat(parameters: .init(messages: [.init(role: .assistant, content: prompt)], model: .gpt35Turbo))
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
      ForEach(Array(chatProvider.messages.enumerated()), id: \.offset) { idx, val in
         VStack(spacing: 0) {
            Text("\(val)")
         }
      }
   }
   
   /// stream = `true`
   var streamedChatResultView: some View {
      Text(chatProvider.message)
   }
      
   var body: some View {
      ScrollView {
         VStack {
            picker
            textArea
            chatCompletionResultView
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
}
