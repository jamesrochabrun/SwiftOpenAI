//
//  ChatFunctionsCalllDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/6/23.
//

import SwiftUI
import SwiftOpenAI

struct ChatFunctionsCalllDemoView: View {
   
   @State private var chatProvider: ChatFunctionsCallProvider
   @State private var isLoading = false
   @State private var prompt = ""
   @State private var selectedModel: GPTModel = .gpt3dot5
   
   init(service: OpenAIService) {
      _chatProvider = State(initialValue: ChatFunctionsCallProvider(service: service))
   }
   
   enum GPTModel: String, CaseIterable {
      case gpt3dot5 = "GPT-3.5"
      case gpt4 = "GPT-4"
   }
   
   var body: some View {
      ScrollViewReader { proxy in
         VStack {
            picker
            List(chatProvider.chatMessages) { message in
               ChatDisplayMessageView(message: message)
                  .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .onChange(of: chatProvider.chatMessages.last?.content) {
               let lastMessage = chatProvider.chatMessages.last
               if let id = lastMessage?.id {
                  proxy.scrollTo(id, anchor: .bottom)
               }
            }
            textArea
         }
      }
   }
   
   var picker: some View {
      Picker("", selection: $selectedModel) {
         ForEach(GPTModel.allCases, id: \.self) { model in
            Text(model.rawValue)
               .font(.title)
               .tag(model)
         }
      }
      .pickerStyle(.segmented)
      .padding()
   }
   
   var textArea: some View {
      HStack(spacing: 0) {
         TextField(
            "How Can I help you today?",
            text: $prompt,
            axis: .vertical)
         .textFieldStyle(.roundedBorder)
         .padding()
         textAreButton
      }
      .padding(.horizontal)
      .disabled(isLoading)
   }
   
   var textAreButton: some View {
      Button {
         Task {
            isLoading = true
            defer {
               // ensure isLoading is set to false after the function executes.
               isLoading = false
               prompt = ""
            }
            /// Make the request
            try await chatProvider.startStreamedChat(parameters: .init(
               messages: [.init(role: .user, content: prompt)],
               model: selectedModel == .gpt3dot5 ? .gpt35Turbo1106 : .gpt41106Preview), prompt: prompt)
         }
      } label: {
         Image(systemName: "paperplane")
      }
      .buttonStyle(.bordered)
   }
}
