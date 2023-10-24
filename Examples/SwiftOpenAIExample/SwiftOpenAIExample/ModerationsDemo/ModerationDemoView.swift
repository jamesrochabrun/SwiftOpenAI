//
//  ModerationDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/24/23.
//

import SwiftUI
import SwiftOpenAI

struct ModerationDemoView: View {
   
   @State private var moderationProvider: ModerationProvider
   @State private var isLoading = false
   @State private var prompt = ""
   
   init(service: OpenAIService) {
      _moderationProvider = State(initialValue: ModerationProvider(service: service))
   }
   
   var body: some View {
      VStack {
         textArea
      }
      
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
               do {
                  try await moderationProvider.createModerationFromText(parameters: .init(input: prompt))
               }
            
            }
         } label: {
            Image(systemName: "paperplane")
         }
         .buttonStyle(.bordered)
      }
      .padding()
   }
}
