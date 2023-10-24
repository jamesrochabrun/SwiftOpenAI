//
//  ModelsProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/24/23.
//

import SwiftUI
import SwiftOpenAI

@Observable class ModelsProvider {
   
   private let service: OpenAIService
   
   var models: [ModelObject] = []
   var retrievedModel: ModelObject? = nil
   var deletionStatus: ModelObject.DeletionStatus? = nil
   
   init(service: OpenAIService) {
      self.service = service
   }
   
   func listModels() async throws {
      self.models = try await service.listModels().data
   }
   
   func retrieveModelWith(
      id: String)
      async throws
   {
      self.retrievedModel = try await service.retrieveModelWith(id: id)
   }
   
   func deleteFineTuneModelWith(
      id: String)
      async throws
   {
      deletionStatus =  try await service.deleteFineTuneModelWith(id: id)
   }
}
