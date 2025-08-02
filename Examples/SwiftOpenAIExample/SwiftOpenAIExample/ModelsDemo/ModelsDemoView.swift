//
//  ModelsDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/24/23.
//

import SwiftOpenAI
import SwiftUI

struct ModelsDemoView: View {
  init(service: OpenAIService) {
    _modelsProvider = State(initialValue: ModelsProvider(service: service))
  }

  var body: some View {
    VStack {
      showModelsButton
      list
    }
  }

  var list: some View {
    List {
      ForEach(Array(modelsProvider.models.enumerated()), id: \.offset) { _, model in
        Text("\(model.id)")
      }
    }
  }

  var showModelsButton: some View {
    Button("List models") {
      Task {
        isLoading = true
        defer { isLoading = false } // ensure isLoading is set to false when the
        do {
          try await modelsProvider.listModels()
        } catch {
          errorMessage = "\(error)"
        }
      }
    }
    .buttonStyle(.bordered)
  }

  @State private var modelsProvider: ModelsProvider
  @State private var isLoading = false
  @State private var errorMessage = ""
}
