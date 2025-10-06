//
//  ModerationDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/24/23.
//

import SwiftOpenAI
import SwiftUI

struct ModerationDemoView: View {
  init(service: OpenAIService) {
    _moderationProvider = State(initialValue: ModerationProvider(service: service))
  }

  var body: some View {
    VStack {
      textArea
      if moderationProvider.isFlagged {
        Text("That is not a nice thing to say.")
      }
      if !errorMessage.isEmpty {
        Text("Error \(errorMessage)")
          .bold()
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
            try await moderationProvider.createModerationFromText(parameters: .init(input: prompt))
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

  @State private var moderationProvider: ModerationProvider
  @State private var isLoading = false
  @State private var prompt = ""
  @State private var errorMessage = ""
}
