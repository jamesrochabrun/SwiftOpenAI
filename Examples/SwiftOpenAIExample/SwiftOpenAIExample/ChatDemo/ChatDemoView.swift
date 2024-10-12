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
   @State private var isLoading = false
   @State private var prompt = ""
   @State private var selectedSegment: ChatConfig = .chatCompeltionStream
   @State private var model: String = ""
   @FocusState private var focus
   
   enum ChatConfig {
      case chatCompletion
      case chatCompeltionStream
   }
   
   init(service: OpenAIService) {
      _chatProvider = State(initialValue: ChatProvider(service: service))
   }
   
   var body: some View {
      ScrollView {
         VStack {
            VStack {
               Text("Add a model name.")
                  .bold()
               TextField("Enter Model e.g: llama3-8b-8192", text: $model)
                  .focused($focus)
            }
            .padding()
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
      .onAppear {
         focus = true
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
               
               let content: ChatCompletionParameters.Message.ContentType = .text(prompt)
               prompt = ""
               let parameters = ChatCompletionParameters(
                  messages: [.init(
                  role: .user,
                  content: content)],
                  model: .custom(model))
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
      ForEach(Array(chatProvider.messages.enumerated()), id: \.offset) { idx, val in
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
}
