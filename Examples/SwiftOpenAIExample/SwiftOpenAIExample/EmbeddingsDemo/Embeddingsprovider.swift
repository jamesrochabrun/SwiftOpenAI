//
//  Embeddingsprovider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftOpenAI
import SwiftUI

@Observable
class EmbeddingsProvider {
  init(service: OpenAIService) {
    self.service = service
  }

  var embeddings: [EmbeddingObject] = []

  func createEmbeddings(
    parameters: EmbeddingParameter)
    async throws
  {
    embeddings = try await service.createEmbeddings(parameters: parameters).data
  }

  private let service: OpenAIService
}
