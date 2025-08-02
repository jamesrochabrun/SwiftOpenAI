//
//  ResponseStreamProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 6/7/25.
//

import SwiftOpenAI
import SwiftUI

@MainActor
@Observable
class ResponseStreamProvider {
  // MARK: - Initialization

  init(service: OpenAIService) {
    self.service = service
  }

  // MARK: - Message Model

  struct ResponseMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    var content: String
    let timestamp: Date
    var isStreaming = false
    let responseId: String?

    enum MessageRole {
      case user
      case assistant
    }
  }

  var messages: [ResponseMessage] = []
  var isStreaming = false
  var currentStreamingMessage: ResponseMessage?
  var error: String?

  // MARK: - Public Methods

  func sendMessage(_ text: String) {
    // Cancel any existing stream
    streamTask?.cancel()

    // Add user message
    let userMessage = ResponseMessage(
      role: .user,
      content: text,
      timestamp: Date(),
      responseId: nil)
    messages.append(userMessage)

    // Start streaming response
    streamTask = Task {
      await streamResponse(for: text)
    }
  }

  func stopStreaming() {
    streamTask?.cancel()
    streamTask = nil

    // Finalize current streaming message
    if var message = currentStreamingMessage {
      message.isStreaming = false
      if let index = messages.firstIndex(where: { $0.id == message.id }) {
        messages[index] = message
      }
    }

    currentStreamingMessage = nil
    isStreaming = false
  }

  func clearConversation() {
    stopStreaming()
    messages.removeAll()
    previousResponseId = nil
    error = nil
  }

  private let service: OpenAIService
  private var previousResponseId: String?
  private var streamTask: Task<Void, Never>?

  // MARK: - Private Methods

  private func streamResponse(for userInput: String) async {
    isStreaming = true
    error = nil

    // Create streaming message placeholder
    let streamingMessage = ResponseMessage(
      role: .assistant,
      content: "",
      timestamp: Date(),
      isStreaming: true,
      responseId: nil)
    messages.append(streamingMessage)
    currentStreamingMessage = streamingMessage

    do {
      // Build input array with conversation history
      var inputArray: [InputItem] = []

      // Add conversation history
      for message in messages.dropLast(2) { // Exclude current user message and streaming placeholder
        let content = message.content
        switch message.role {
        case .user:
          inputArray.append(.message(InputMessage(role: "user", content: .text(content))))
        case .assistant:
          // Assistant messages in conversation history should be sent as simple text
          inputArray.append(.message(InputMessage(
            role: "assistant",
            content: .text(content))))
        }
      }

      // Add current user message
      inputArray.append(.message(InputMessage(role: "user", content: .text(userInput))))

      let parameters = ModelResponseParameter(
        input: .array(inputArray),
        model: .custom("gpt-4.1"),
        instructions: "You are a helpful assistant. Use the conversation history to provide contextual responses.",
        maxOutputTokens: 1000,
        previousResponseId: previousResponseId, temperature: 0.7)

      let stream = try await service.responseCreateStream(parameters)
      var accumulatedText = ""

      for try await event in stream {
        guard !Task.isCancelled else { break }

        switch event {
        case .responseCreated:
          // Response created event - we'll get the ID in responseCompleted
          break

        case .outputTextDelta(let delta):
          accumulatedText += delta.delta
          updateStreamingMessage(with: accumulatedText)

        case .responseCompleted(let completed):
          // Update previous response ID for conversation continuity
          previousResponseId = completed.response.id

          // Finalize the message
          finalizeStreamingMessage(
            with: accumulatedText,
            responseId: completed.response.id)

        case .responseFailed(let failed):
          throw APIError.requestFailed(
            description: failed.response.error?.message ?? "Stream failed")

        case .error(let errorEvent):
          throw APIError.requestFailed(
            description: errorEvent.message)

        default:
          // Handle other events as needed
          break
        }
      }

    } catch {
      self.error = error.localizedDescription

      // Remove streaming message on error
      if let streamingId = currentStreamingMessage?.id {
        messages.removeAll { $0.id == streamingId }
      }
    }

    currentStreamingMessage = nil
    isStreaming = false
  }

  private func updateStreamingMessage(with content: String) {
    guard
      let messageId = currentStreamingMessage?.id,
      let index = messages.firstIndex(where: { $0.id == messageId })
    else {
      return
    }

    messages[index].content = content
  }

  private func finalizeStreamingMessage(with content: String, responseId: String) {
    guard
      let messageId = currentStreamingMessage?.id,
      let index = messages.firstIndex(where: { $0.id == messageId })
    else {
      return
    }

    messages[index].content = content
    messages[index].isStreaming = false
    messages[index] = ResponseMessage(
      role: .assistant,
      content: content,
      timestamp: messages[index].timestamp,
      isStreaming: false,
      responseId: responseId)
  }
}
