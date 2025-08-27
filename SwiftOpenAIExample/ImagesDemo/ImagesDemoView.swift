//
//  ImagesDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/24/23.
//

import SwiftOpenAI
import SwiftUI

struct ImagesDemoView: View {
  init(service: OpenAIService) {
    _imagesProvider = State(initialValue: ImagesProvider(service: service))
  }

  var body: some View {
    ScrollView {
      textArea
      if !errorMessage.isEmpty {
        Text("Error \(errorMessage)")
          .bold()
      }
      ForEach(Array(imagesProvider.images.enumerated()), id: \.offset) { _, url in
        AsyncImage(url: url, scale: 1) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
        } placeholder: {
          EmptyView()
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
            try await imagesProvider.createImages(parameters: .init(prompt: prompt, model: .dalle3(.largeSquare)))
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

  @State private var imagesProvider: ImagesProvider
  @State private var isLoading = false
  @State private var prompt = ""
  @State private var errorMessage = ""
}
