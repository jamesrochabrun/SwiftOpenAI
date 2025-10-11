//
//  ChatProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftOpenAI
import SwiftUI

@Observable
class ChatProvider {
  init(service: OpenAIService) {
    self.service = service
  }

  var messages = [String]()
  var errorMessage = ""
  var message = ""
  var usage: ChatUsage?

  func startChat(
    parameters: ChatCompletionParameters)
    async throws
  {
    do {
      let response = try await service.startChat(parameters: parameters)
      let choices = response.choices
      let chatUsage = response.usage
      let logprobs = choices?.compactMap(\.logprobs)
      dump(logprobs)
      messages = choices?.compactMap(\.message?.content) ?? []
      dump(chatUsage)
      usage = chatUsage
    } catch APIError.responseUnsuccessful(let description, let statusCode, let responseBody) {
      var message = "Network error with status code: \(statusCode) and description: \(description)"
      if let responseBody {
        message += " — Response body: \(responseBody)"
      }
      self.errorMessage = message
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  func startStreamedChat(
    parameters: ChatCompletionParameters)
    async throws
  {
    streamTask = Task {
      do {
        let stream = try await service.startStreamedChat(parameters: parameters)
        for try await result in stream {
          let content = result.choices?.first?.delta?.content ?? ""
          self.message += content
        }
      } catch APIError.responseUnsuccessful(let description, let statusCode, let responseBody) {
        var message = "Network error with status code: \(statusCode) and description: \(description)"
        if let responseBody {
          message += " — Response body: \(responseBody)"
        }
        self.errorMessage = message
      } catch {
        self.errorMessage = error.localizedDescription
      }
    }
  }

  func cancelStream() {
    streamTask?.cancel()
  }

  private let service: OpenAIService
  private var streamTask: Task<Void, Never>?
}
