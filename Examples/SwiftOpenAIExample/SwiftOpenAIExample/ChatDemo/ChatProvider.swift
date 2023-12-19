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
   var message: String = ""
   
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
         self.messages = ["\(error)"]
      }
   }
   
   func startStreamedChat(
      parameters: ChatCompletionParameters) async throws
   {
      // TODO: Create a better logic to improve the UI.
      do {
         let stream = try await service.startStreamedChat(parameters: parameters)
         for try await result in stream {
            self.message += result.choices.first?.delta.content ?? ""
         }
      } catch {
         self.message = "\(error)"
      }
   }
}
