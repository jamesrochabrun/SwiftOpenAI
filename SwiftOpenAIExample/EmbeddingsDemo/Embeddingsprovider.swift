//
//  Embeddingsprovider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftUI
import SwiftOpenAI

@Observable class EmbeddingsProvider {
   
   private let service: OpenAIService
   
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
}
