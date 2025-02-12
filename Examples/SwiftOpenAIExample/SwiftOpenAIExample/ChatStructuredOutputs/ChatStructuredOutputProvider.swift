//
//  ChatStructuredOutputProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 8/10/24.
//

import Foundation
import SwiftOpenAI

@Observable
final class ChatStructuredOutputProvider {
   
   private let service: OpenAIService
   private var streamTask: Task<Void, Never>? = nil
   var message: String = ""
   var messages: [String] = []
   var errorMessage: String = ""

   // MARK: - Initializer
   
   init(service: OpenAIService) {
      self.service = service
   }

   // MARK: - Public Methods
   
   func startChat(
      parameters: ChatCompletionParameters) async throws
   {
      do {
         let choices = try await service.startChat(parameters: parameters).choices
         self.messages = choices?.compactMap(\.message?.content).map { $0.asJsonFormatted() } ?? []
         assert(messages.count == 1)
         self.errorMessage = choices?.first?.message?.refusal ?? ""
      } catch APIError.responseUnsuccessful(let description, let statusCode) {
         self.errorMessage = "Network error with status code: \(statusCode) and description: \(description)"
      } catch {
         self.errorMessage = error.localizedDescription
      }
   }
   
   func startStreamedChat(
      parameters: ChatCompletionParameters) async throws
   {
      streamTask = Task {
         do {
            let stream = try await service.startStreamedChat(parameters: parameters)
            for try await result in stream {
               let firstChoiceDelta = result.choices?.first?.delta
               let content = firstChoiceDelta?.refusal ?? firstChoiceDelta?.content ?? ""
               self.message += content
               if result.choices?.first?.finishReason != nil {
                  self.message = self.message.asJsonFormatted()
               }
            }
         } catch APIError.responseUnsuccessful(let description, let statusCode) {
            self.errorMessage = "Network error with status code: \(statusCode) and description: \(description)"
         } catch {
            self.errorMessage = error.localizedDescription
         }
      }
   }
   
   func cancelStream() {
      streamTask?.cancel()
   }
}

/// Helper that allows to display the JSON Schema.
extension String {
   
   func asJsonFormatted() -> String {
      guard let data = self.data(using: .utf8) else { return self }
      do {
          // Parse JSON string to Any object
          if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
              // Convert back to data with pretty-printing
              let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
              
              // Convert formatted data back to string
             return String(data: prettyPrintedData, encoding: .utf8) ?? self
          }
      } catch {
          print("Error formatting JSON: \(error)")
      }
      return self
   }
}
