//
//  ChatVisionProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/9/23.
//

import SwiftOpenAI
import SwiftUI

@Observable
class ChatVisionProvider {
  // MARK: - Initializer

  init(service: OpenAIService) {
    self.service = service
  }

  // MARK: - Public Properties

  /// A collection of messages for display in the UI, representing the conversation.
  var chatMessages: [ChatDisplayMessage] = []

  // MARK: - Public Methods

  func startStreamedChat(
    parameters: ChatCompletionParameters,
    content: [ChatCompletionParameters.Message.ContentType.MessageContent])
    async throws
  {
    // Displays the user message in the UI
    await startNewUserDisplayMessage(content)
    // Start a new assistant message that is initially empty.
    await startNewAssistantEmptyDisplayMessage()

    do {
      // Begin the chat stream with the updated parameters.
      let stream = try await service.startStreamedChat(parameters: parameters)
      for try await result in stream {
        // Extract the first choice from the stream results, if none exist, exit the loop.
        guard let choice = result.choices?.first else { return }

        // Store initial `role` and `functionCall` data from the first `choice.delta` for UI display.
        // This information is essential for maintaining context in the conversation and for updating
        // the chat UI with proper role attributions for each message.
        var newDelta = ChatDisplayMessage.Delta(role: "", content: "")
        if let firstDelta = firstChatMessageResponseDelta[result.id ?? ""] {
          // If we have already stored the first delta for this result ID, reuse its role.
          newDelta.role = firstDelta.role!
        } else {
          // Otherwise, store the first delta received for future reference.
          firstChatMessageResponseDelta[result.id ?? ""] = choice.delta
        }
        // Assign the content received in the current message to the newDelta.
        newDelta.content = temporalReceivedMessageContent
        // Update the UI with the latest assistant message and the corresponding delta.
        await updateLastAssistantMessage(content: choice.delta?.content ?? "", delta: newDelta)
      }
    } catch {
      // If an error occurs, update the UI to display the error message.
      updateLastDisplayedMessage(.init(content: .error("\(error)"), type: .received, delta: nil))
    }
  }

  // MARK: - Private Properties

  private let service: OpenAIService

  /// Accumulates the streamed message content for real-time display updates in the UI.
  private var temporalReceivedMessageContent = ""
  /// Tracks the identifier of the last message displayed, enabling updates in the from the streaming API response.
  private var lastDisplayedMessageID: UUID?
  /// Stores the initial chat message's delta, which uniquely includes metadata like `role`.
  private var firstChatMessageResponseDelta: [String: ChatCompletionChunkObject.ChatChoice.Delta] = [:]

  // MARK: - Private Methods

  @MainActor
  private func startNewUserDisplayMessage(_ content: [ChatCompletionParameters.Message.ContentType.MessageContent]) {
    // Updates the UI with
    let startingMessage = ChatDisplayMessage(
      content: .content(content),
      type: .sent, delta: nil)
    addMessage(startingMessage)
  }

  @MainActor
  private func startNewAssistantEmptyDisplayMessage() {
    firstChatMessageResponseDelta = [:]
    temporalReceivedMessageContent = ""
    let newMessage = ChatDisplayMessage(content: .text(temporalReceivedMessageContent), type: .received, delta: nil)
    let newMessageId = newMessage.id
    lastDisplayedMessageID = newMessageId
    addMessage(newMessage)
  }

  @MainActor
  private func updateLastAssistantMessage(
    content: String,
    delta: ChatDisplayMessage.Delta)
  {
    temporalReceivedMessageContent += content
    guard let id = lastDisplayedMessageID, let index = chatMessages.firstIndex(where: { $0.id == id }) else { return }
    chatMessages[index] = ChatDisplayMessage(
      id: id,
      content: .text(temporalReceivedMessageContent),
      type: .received,
      delta: delta)
  }

  @MainActor
  private func addMessage(_ message: ChatDisplayMessage) {
    withAnimation {
      chatMessages.append(message)
    }
  }

  private func updateLastDisplayedMessage(_ message: ChatDisplayMessage) {
    chatMessages[chatMessages.count - 1] = message
  }
}
