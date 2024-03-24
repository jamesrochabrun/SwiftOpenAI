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
   var toolOuptutMessage: String = ""
   
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
         let stream = try await service.createRunStream(threadID: threadID, parameters: parameters)
         for try await result in stream {
            
            switch result {
            case .threadMessageDelta(let messageDelta):
                  let content = messageDelta.delta.content.first
                  switch content {
                  case .imageFile, nil:
                     break
                  case .text(let textContent):
                     messageText += textContent.text.value
                  }
            case .threadRunStepDelta(let runStepDelta):
                  let toolCall = runStepDelta.delta.stepDetails.toolCalls?.first?.toolCall
                  switch toolCall {
                  case .codeInterpreterToolCall(let toolCall):
                     toolOuptutMessage += toolCall.input ?? ""
                  case .retrieveToolCall(let toolCall):
                     print("PROVIDER: Retrieve tool call \(toolCall)")
                  case .functionToolCall(let toolCall):
                     print("PROVIDER: Function tool call \(toolCall)")
                  case nil:
                     print("PROVIDER: tool call nil")
                  }
            default: break
            }
         }
      }  catch {
         print("THREAD ERROR: \(error)")
      }
   }
}

