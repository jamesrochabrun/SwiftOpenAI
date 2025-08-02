//
//  ChatFluidConversationProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/4/23.
//

import SwiftOpenAI
import SwiftUI

@Observable
class ChatFluidConversationProvider {
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
    prompt: String)
    async throws
  {
    // Displays the user message in the UI
    await startNewUserDisplayMessage(prompt)
    // Start a new assistant message that is initially empty.
    await startNewAssistantEmptyDisplayMessage()

    // Copy the provided parameters and update the messages for the chat stream.
    var localParameters = parameters
    localParameters.messages = parameterMessages

    do {
      // Begin the chat stream with the updated parameters.
      let stream = try await service.startStreamedChat(parameters: localParameters)
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
        updateLastAssistantMessage(content: choice.delta?.content ?? "", delta: newDelta)

        // Evaluate the `finishReason` to determine if the conversation has reached a logical end.
        // If so, package the accumulated data into a new message parameter that will be used
        // to enrich context in subsequent API calls, leading to better conversation continuity.
        if let finishReason = choice.finishReason {
          debugPrint("FINISH_REASON \(finishReason)")
          // Construct a new message parameter with the role and content derived from the delta.
          // Intentionally force unwrapped, if fails is programming error.
          let newMessage = ChatCompletionParameters.Message(
            role: .init(rawValue: newDelta.role)!,
            content: .text(newDelta.content))
          // Append the new message parameter to the collection for future requests.
          updateParameterMessagesArray(newMessage)
        }
      }
    } catch {
      // If an error occurs, update the UI to display the error message.
      updateLastDisplayedMessage(.init(content: .error("\(error)"), type: .received, delta: nil))
    }
  }

  /// Defines the maximum number of parameter messages to retain for context. A larger history can enrich
  /// the language model's responses but be mindful as it will also increase the number of tokens sent in each request,
  /// thus affecting API consumption. A balance is required; a count of 5 is a reasonable starting point.
  private static var parameterMessagesMaxStorageCount = 5

  // MARK: - Private Properties

  private let service: OpenAIService

  /// Accumulates the streamed message content for real-time display updates in the UI.
  private var temporalReceivedMessageContent = ""
  /// Tracks the identifier of the last message displayed, enabling updates in the from the streaming API response.
  private var lastDisplayedMessageID: UUID?
  /// Stores the initial chat message's delta, which uniquely includes metadata like `role`.
  private var firstChatMessageResponseDelta: [String: ChatCompletionChunkObject.ChatChoice.Delta] = [:]
  /// Builds a history of messages sent and received, enhancing the chat's context for future requests.
  private var parameterMessages: [ChatCompletionParameters.Message] = []

  // MARK: - Private Methods

  @MainActor
  private func startNewUserDisplayMessage(_ prompt: String) {
    // Updates the UI with
    let startingMessage = ChatDisplayMessage(
      content: .text(prompt),
      type: .sent, delta: nil)
    addMessage(startingMessage)
    // Stores a new
    let newParameterMessage = ChatCompletionParameters.Message(role: .user, content: .text(prompt))
    updateParameterMessagesArray(newParameterMessage)
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

  private func updateParameterMessagesArray(_ message: ChatCompletionParameters.Message) {
    parameterMessages.append(message)
    debugPrint("NEWCOUNT \(parameterMessages.count) message \(message)")
    if parameterMessages.count > Self.parameterMessagesMaxStorageCount {
      debugPrint("NEWCOUNT \(parameterMessages.count) removed message \(parameterMessages[0])")
      parameterMessages.removeFirst()
    }
  }

  private func updateLastDisplayedMessage(_ message: ChatDisplayMessage) {
    chatMessages[chatMessages.count - 1] = message
  }
}
