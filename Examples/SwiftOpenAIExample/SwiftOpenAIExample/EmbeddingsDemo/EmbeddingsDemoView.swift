//
//  EmbeddingsDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftUI
import SwiftOpenAI

struct EmbeddingsDemoView: View {
   
   @State private var embeddingsProvider: EmbeddingsProvider
   @State private var isLoading: Bool = false
   @State private var prompt: String = ""
   
   init(service: OpenAIService) {
      _embeddingsProvider = State(initialValue: EmbeddingsProvider(service: service))
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
               try await embeddingsProvider.createEmbeddings(parameters: .init(input: prompt))
            }
         } label: {
            Image(systemName: "paperplane")
         }
         .buttonStyle(.bordered)
      }
      .padding()
   }
   
   var list: some View {
      List {
         ForEach(Array(embeddingsProvider.embeddings.enumerated()), id: \.offset) { _, embeddingObject in
            Section(header: Text("Section \(embeddingObject.index) \(embeddingObject.object)")) {
                 ForEach(embeddingObject.embedding, id: \.self) { embedding in
                      Text("Embedding Value \(embedding)")
                  }
              }
          }
      }
   }
   
   var body: some View {
      VStack {
         textArea
         list
      }
   }
}
