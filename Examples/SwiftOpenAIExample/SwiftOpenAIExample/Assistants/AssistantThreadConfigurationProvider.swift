//
//  AssistantThreadConfigurationProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 3/19/24.
//

import Foundation
import SwiftOpenAI


@Observable class AssistantThreadConfigurationProvider {
   
   // MARK: - Private Properties
   private let service: OpenAIService
   
   var thread: ThreadObject?
   var message: MessageObject?
   var runObject: RunObject?
   
   // MARK: - Initializer
   
   init(service: OpenAIService) {
      self.service = service
   }
   
   func createThread()
      async throws
   {
      do {
         thread = try await service.createThread(parameters: .init())
      } catch {
         print("THREAD ERROR: \(error)")
      }
   }
   
   func createMessage(
      threadID: String,
      parameters: MessageParameter)
      async throws
   {
      do {
         message = try await service.createMessage(threadID: threadID, parameters: parameters)
      } catch {
         print("THREAD ERROR: \(error)")
      }
   }
   
   func createRun(
      threadID: String,
      parameters: RunParameter)
      async throws
   {
      do {
         runObject = try await service.createRun(threadID: threadID, parameters: parameters)
      }  catch {
         print("THREAD ERROR: \(error)")
      }
   }
   
}

