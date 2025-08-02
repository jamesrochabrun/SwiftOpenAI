//
//  EmbeddingsDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftOpenAI
import SwiftUI

struct EmbeddingsDemoView: View {
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
          defer { isLoading = false } // ensure isLoading is set to false when the
          do {
            try await embeddingsProvider.createEmbeddings(parameters: .init(
              input: prompt,
              model: .textEmbedding3Large,
              encodingFormat: nil,
              dimensions: nil))
          } catch {
            errorMessage = "\(error)"
          }
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
      if !errorMessage.isEmpty {
        Text("Error \(errorMessage)")
          .bold()
      }
      list
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

  @State private var embeddingsProvider: EmbeddingsProvider
  @State private var isLoading = false
  @State private var prompt = ""
  @State private var errorMessage = ""
}
