//
//  ModelsProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/24/23.
//

import SwiftOpenAI
import SwiftUI

@Observable
class ModelsProvider {
  init(service: OpenAIService) {
    self.service = service
  }

  var models: [ModelObject] = []
  var retrievedModel: ModelObject?
  var deletionStatus: DeletionStatus?

  func listModels() async throws {
    models = try await service.listModels().data
  }

  func retrieveModelWith(
    id: String)
    async throws
  {
    retrievedModel = try await service.retrieveModelWith(id: id)
  }

  func deleteFineTuneModelWith(
    id: String)
    async throws
  {
    deletionStatus = try await service.deleteFineTuneModelWith(id: id)
  }

  private let service: OpenAIService
}
