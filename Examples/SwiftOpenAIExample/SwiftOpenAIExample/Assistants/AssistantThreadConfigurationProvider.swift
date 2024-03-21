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
   var messageText: String = ""
   
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
   
   func createRunAndStreamMessage(
      threadID: String,
      parameters: RunParameter)
      async throws
   {
      do {
         let stream = try await service.createRunAndStreamMessage(threadID: threadID, parameters: parameters)
         for try await result in stream {
            let content = result.delta.content.first
            switch content {
            case .imageFile, nil:
               break
            case .text(let textContent):
               messageText += textContent.text.value
            }
         }
      }  catch {
         print("THREAD ERROR: \(error)")
      }
   }
   
}

