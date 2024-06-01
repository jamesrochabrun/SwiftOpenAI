//
//  AssistantConfigurationProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/17/23.
//

import Foundation
import SwiftOpenAI

@Observable class AssistantConfigurationProvider {
   
   // MARK: - Private Properties
   private let service: OpenAIService
   var assistant: AssistantObject?
   var assistants: [AssistantObject] = []
   var avatarURL: URL?
   var assistantDeletionStatus: DeletionStatus?
   
   // MARK: - Initializer
   
   init(service: OpenAIService) {
      self.service = service
   }
   
   func listAssistants() 
      async throws
   {
      do {
         let assistants = try await service.listAssistants(limit: nil, order: nil, after: nil, before: nil)
         self.assistants = assistants.data
      } catch {
         debugPrint("\(error)")
      }
   }
   
   func deleteAssistant(
      id: String)
      async throws
   {
      do {
         assistantDeletionStatus = try await service.deleteAssistant(id: id)
      } catch {
         debugPrint("\(error)")
      }
   }
   
   func createAssistant(
      parameters: AssistantParameters) 
      async throws
   {
      do {
         assistant = try await service.createAssistant(parameters: parameters)
      } catch {
         debugPrint("\(error)")
      }
   }
   
   func createAvatar(
      prompt: String)
      async throws
   {
      do {
         let avatarURLs = try await service.createImages(parameters: .init(prompt: prompt, model: .dalle3(.largeSquare))).data.compactMap(\.url)
         self.avatarURL = avatarURLs.first
      } catch {
         debugPrint("\(error)")
      }
   }
   
   // TODO: Create demo for this.
   func createVStore ()async throws  {
      let _ = try await service.createVectorStore(parameters: .init(name: "Personal Data"))
   }
}
