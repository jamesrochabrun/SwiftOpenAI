//
//  ChatFunctionsCalllDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/6/23.
//

import SwiftUI
import SwiftOpenAI

struct ChatFunctionsCalllDemoView: View {
   
   @State private var isLoading = false
   @State private var prompt = ""
   @State private var chatProvider: ChatFunctionsCallProvider
   
   init(service: OpenAIService) {
      _chatProvider = State(initialValue: ChatFunctionsCallProvider(service: service))
   }
   
   var body: some View {
      ScrollViewReader { proxy in
         VStack {
            List(chatProvider.chatDisplayMessages) { message in
               ChatMessageView(message: message)
                  .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .onChange(of: chatProvider.chatDisplayMessages.last?.content) {
               let lastMessage = chatProvider.chatDisplayMessages.last
               if let id = lastMessage?.id {
                  proxy.scrollTo(id, anchor: .bottom)
               }
            }
            textArea
         }
      }
   }
   
   var textArea: some View {
      HStack(spacing: 0) {
         VStack(alignment: .leading, spacing: 0) {
            textField
               .padding(.vertical, Sizes.spacingExtraSmall)
               .padding(.horizontal, Sizes.spacingSmall)
         }
         .padding(.vertical, Sizes.spacingExtraSmall)
         .padding(.horizontal, Sizes.spacingExtraSmall)
         .background(
            RoundedRectangle(cornerRadius: 20)
               .stroke(.gray, lineWidth: 1)
         )
         .padding(.horizontal, Sizes.spacingMedium)
         textAreSendButton
      }
      .padding(.horizontal)
      .disabled(isLoading)
   }
   
   var textField: some View {
      TextField(
         "How Can I help you today?",
         text: $prompt,
         axis: .vertical)
   }
   
   var textAreSendButton: some View {
      Button {
         Task {
            /// Loading UI
            isLoading = true
            defer { isLoading = false }
            // Clears text field.
            let userPrompt = prompt
            prompt = ""
            try await chatProvider.chat(prompt: userPrompt)
         }
      } label: {
         Image(systemName: "paperplane")
      }
      .buttonStyle(.bordered)
      .tint(ThemeColor.tintColor)
      .disabled(prompt.isEmpty)
   }
}
