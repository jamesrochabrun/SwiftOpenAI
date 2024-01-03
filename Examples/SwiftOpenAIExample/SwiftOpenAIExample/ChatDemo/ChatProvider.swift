//
//  ChatProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftUI
import SwiftOpenAI

@Observable class ChatProvider {
   
   private let service: OpenAIService
   
   var messages: [String] = []
   var errorMessage: String = ""
   var message: String = ""

   var streamTask: Task<Void, Never>? = nil

   init(service: OpenAIService) {
      self.service = service
   }
   
   func startChat(
      parameters: ChatCompletionParameters) async throws
   {
      do {
         let choices = try await service.startChat(parameters: parameters).choices
         let logprobs = choices.compactMap(\.logprobs)
         dump(logprobs)
         self.messages = choices.compactMap(\.message.content)
      } catch {
         self.errorMessage = "\(error)"
      }
   }
   
   func startStreamedChat(
      parameters: ChatCompletionParameters) async throws
   {
      streamTask = Task {
            do {
                let stream = try await service.startStreamedChat(parameters: parameters)
                for try await result in stream {
                  //  try Task.checkCancellation() // Explicitly check for cancellation
                   let content = result.choices.first?.delta.content ?? ""
                    self.message += content
                   print("Zizou \(content)")
                }
            } catch {
                if error is CancellationError {
                    self.errorMessage = "Stream cancelled"
                } else {
                    self.errorMessage = "\(error)"
                }
            }
        }
   }
   
   func cancelStream() {
      streamTask!.cancel()
   }
   
}
