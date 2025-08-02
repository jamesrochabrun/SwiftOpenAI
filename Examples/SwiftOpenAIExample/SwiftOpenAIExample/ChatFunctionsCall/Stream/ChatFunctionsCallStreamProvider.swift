//
//  ChatFunctionsCallStreamProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/6/23.
//

import SwiftOpenAI
import SwiftUI

// MARK: - FunctionCallStreamedResponse

/// This is a demo in how to implement parallel function calling when using the completion API stream = true

struct FunctionCallStreamedResponse {
  let name: String
  let id: String
  let toolCall: ToolCall
  var argument: String
}

// MARK: - ChatFunctionsCallStreamProvider

@Observable
class ChatFunctionsCallStreamProvider {
  // MARK: - Initializer

  init(service: OpenAIService) {
    self.service = service
  }

  // MARK: - Public Properties

  /// To be used for UI purposes.
  var chatDisplayMessages: [ChatMessageDisplayModel] = []

  @MainActor
  func generateImage(arguments: String) async throws -> String {
    let dictionary = arguments.toDictionary()!
    let prompt = dictionary["prompt"] as! String
    let count = (dictionary["count"] as? Int) ?? 1

    // TODO: Improve the loading state
    let assistantMessage = ChatMessageDisplayModel(
      content: .content(.init(text: "Generating images...")),
      origin: .received(.gpt))
    updateLastAssistantMessage(assistantMessage)

    let urls = try await service.legacyCreateImages(
      parameters: .init(prompt: prompt, model: .dalle2(.small), numberOfImages: count)).data.compactMap(\.url)

    let dalleAssistantMessage = ChatMessageDisplayModel(
      content: .content(.init(text: nil, urls: urls)),
      origin: .received(.dalle))
    updateLastAssistantMessage(dalleAssistantMessage)

    return prompt
  }

  // MARK: - Public Methods

  func chat(
    prompt: String)
    async throws
  {
    defer {
      functionCallsMap = [:]
      chatMessageParameters = []
    }

    await startNewUserDisplayMessage(prompt)

    await startNewAssistantEmptyDisplayMessage()

    let systemMessage = ChatCompletionParameters.Message(
      role: .system,
      content: .text(
        "You are an artist powered by AI, if the messages has a tool message you will weight that bigger in order to create a response, and you are providing me an image, you always respond in readable language and never providing URLs of images, most of the times you add an emoji on your responses if makes sense, do not describe the image. also always offer more help"))
    chatMessageParameters.append(systemMessage)

    /// # Step 1: send the conversation and available functions to the model
    let userMessage = createUserMessage(prompt)
    chatMessageParameters.append(userMessage)

    let tools = FunctionCallDefinition.allCases.map(\.functionTool)

    let parameters = ChatCompletionParameters(
      messages: chatMessageParameters,
      model: .gpt35Turbo1106,
      toolChoice: ToolChoice.auto,
      tools: tools)

    do {
      // Begin the chat stream with the updated parameters.
      let stream = try await service.startStreamedChat(parameters: parameters)
      for try await result in stream {
        // Extract the first choice from the stream results, if none exist, exit the loop.
        if let choice = result.choices?.first {
          /// Because we are using the stream API we need to wait to populate
          /// the needed values that comes from the streamed API to construct a valid tool call response.
          /// This is not needed if the stream is set to false in the API completion request.
          /// # Step 2: check if the model wanted to call a function
          if let toolCalls = choice.delta?.toolCalls {
            /// # Step 3: Define the available functions to be called
            availableFunctions = [.createImage: generateImage(arguments:)]

            mapStreamedToolCallsResponse(toolCalls)
          }

          /// The streamed content to display
          if let newContent = choice.delta?.content {
            await updateLastAssistantMessage(.init(
              content: .content(.init(text: newContent)),
              origin: .received(.gpt)))
          }
        }
      }
      // # extend conversation with assistant's reply
      // Append the `assistantMessage` in to the `chatMessageParameters` to extend the conversation
      if !functionCallsMap.isEmpty {
        let assistantMessage = createAssistantMessage()
        chatMessageParameters.append(assistantMessage)
        /// # Step 4: send the info for each function call and function response to the model
        let toolMessages = try await createToolsMessages()
        chatMessageParameters.append(contentsOf: toolMessages)

        // Lastly call the chat again
        await continueChat()
      }

      // TUTORIAL
    } catch {
      // If an error occurs, update the UI to display the error message.
      await updateLastAssistantMessage(.init(content: .error("\(error)"), origin: .received(.gpt)))
    }
  }

  func mapStreamedToolCallsResponse(
    _ toolCalls: [ToolCall])
  {
    for toolCall in toolCalls {
      // Intentionally force unwrapped to catch errrors quickly on demo. // This should be properly handled.
      let function = FunctionCallDefinition.allCases[toolCall.index!]
      if var streamedFunctionCallResponse = functionCallsMap[function] {
        streamedFunctionCallResponse.argument += toolCall.function.arguments
        functionCallsMap[function] = streamedFunctionCallResponse
      } else {
        let streamedFunctionCallResponse = FunctionCallStreamedResponse(
          name: toolCall.function.name!,
          id: toolCall.id!,
          toolCall: toolCall,
          argument: toolCall.function.arguments)
        functionCallsMap[function] = streamedFunctionCallResponse
      }
    }
  }

  func createUserMessage(
    _ prompt: String)
    -> ChatCompletionParameters.Message
  {
    .init(role: .user, content: .text(prompt))
  }

  func createAssistantMessage() -> ChatCompletionParameters.Message {
    var toolCalls: [ToolCall] = []
    for (_, functionCallStreamedResponse) in functionCallsMap {
      let toolCall = functionCallStreamedResponse.toolCall
      // Intentionally force unwrapped to catch errrors quickly on demo. // This should be properly handled.
      let messageToolCall = ToolCall(
        id: toolCall.id!,
        function: .init(arguments: toolCall.function.arguments, name: toolCall.function.name!))
      toolCalls.append(messageToolCall)
    }
    return .init(role: .assistant, content: .text(""), toolCalls: toolCalls)
  }

  func createToolsMessages() async throws
    -> [ChatCompletionParameters.Message]
  {
    var toolMessages: [ChatCompletionParameters.Message] = []
    for (key, functionCallStreamedResponse) in functionCallsMap {
      let name = functionCallStreamedResponse.name
      let id = functionCallStreamedResponse.id
      let functionToCall = availableFunctions[key]!
      let arguments = functionCallStreamedResponse.argument
      let content = try await functionToCall(arguments)
      let toolMessage = ChatCompletionParameters.Message(
        role: .tool,
        content: .text(content),
        name: name,
        toolCallID: id)
      toolMessages.append(toolMessage)
    }
    return toolMessages
  }

  func continueChat() async {
    let paramsForChat = ChatCompletionParameters(
      messages: chatMessageParameters,
      model: .gpt41106Preview)
    do {
      // Begin the chat stream with the updated parameters.
      let stream = try await service.startStreamedChat(parameters: paramsForChat)
      for try await result in stream {
        // Extract the first choice from the stream results, if none exist, exit the loop.
        guard let choice = result.choices?.first else { return }

        /// The streamed content to display
        if let newContent = choice.delta?.content {
          await updateLastAssistantMessage(.init(content: .content(.init(text: newContent)), origin: .received(.gpt)))
        }
      }
    } catch {
      // If an error occurs, update the UI to display the error message.
      await updateLastAssistantMessage(.init(content: .error("\(error)"), origin: .received(.gpt)))
    }
  }

  // MARK: - Private Properties

  private let service: OpenAIService
  private var lastDisplayedMessageID: UUID?
  /// To be used for a new request
  private var chatMessageParameters: [ChatCompletionParameters.Message] = []
  private var functionCallsMap: [FunctionCallDefinition: FunctionCallStreamedResponse] = [:]
  private var availableFunctions: [FunctionCallDefinition: @MainActor (String) async throws -> String] = [:]

  // MARK: - Private Methods

  @MainActor
  private func startNewUserDisplayMessage(_ prompt: String) {
    let startingMessage = ChatMessageDisplayModel(
      content: .content(.init(text: prompt)),
      origin: .sent)
    addMessage(startingMessage)
  }

  @MainActor
  private func startNewAssistantEmptyDisplayMessage() {
    let newMessage = ChatMessageDisplayModel(
      content: .content(.init(text: "")),
      origin: .received(.gpt))
    addMessage(newMessage)
  }

  @MainActor
  private func updateLastAssistantMessage(
    _ message: ChatMessageDisplayModel)
  {
    guard let id = lastDisplayedMessageID, let index = chatDisplayMessages.firstIndex(where: { $0.id == id }) else { return }

    var lastMessage = chatDisplayMessages[index]

    switch message.content {
    case .content(let newMedia):
      switch lastMessage.content {
      case .content(let lastMedia):
        var updatedMedia = lastMedia
        if
          let newText = newMedia.text,
          var lastMediaText = lastMedia.text
        {
          lastMediaText += newText
          updatedMedia.text = lastMediaText
        } else {
          updatedMedia.text = ""
        }
        if let urls = newMedia.urls {
          updatedMedia.urls = urls
        }
        lastMessage.content = .content(updatedMedia)

      case .error:
        break
      }

    case .error:
      lastMessage.content = message.content
    }

    chatDisplayMessages[index] = ChatMessageDisplayModel(
      id: id,
      content: lastMessage.content,
      origin: message.origin)
  }

  @MainActor
  private func addMessage(_ message: ChatMessageDisplayModel) {
    let newMessageId = message.id
    lastDisplayedMessageID = newMessageId
    withAnimation {
      chatDisplayMessages.append(message)
    }
  }
}

extension String {
  fileprivate func toDictionary() -> [String: Any]? {
    guard let jsonData = data(using: .utf8) else {
      print("Failed to convert JSON string to Data.")
      return nil
    }

    do {
      return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
    } catch {
      print("Failed to deserialize JSON: \(error.localizedDescription)")
      return nil
    }
  }
}
