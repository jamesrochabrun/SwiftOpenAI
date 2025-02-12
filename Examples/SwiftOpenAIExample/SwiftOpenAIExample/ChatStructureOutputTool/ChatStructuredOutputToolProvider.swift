//
//  ChatStructuredOutputToolProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 8/11/24.
//

import Foundation
import SwiftOpenAI
import SwiftUI

enum StructuredToolCall: String, CaseIterable {
   
   case structureUI = "structured_ui"
   
   var functionTool: ChatCompletionParameters.Tool {
      switch self {
      case .structureUI:
         return .init(
            function: .init(
               name: self.rawValue,
               strict: true,
               description: "Dynamically generated UI",
               parameters: structureUISchema))
      }
   }
   
   var structureUISchema: JSONSchema {
      JSONSchema(
              type: .object,
              properties: [
                  "type": JSONSchema(
                      type: .string,
                      description: "The type of the UI component",
                      additionalProperties: false,
                      enum: ["div", "button", "header", "section", "field", "form"]
                  ),
                  "label": JSONSchema(
                      type: .string,
                      description: "The label of the UI component, used for buttons or form fields",
                      additionalProperties: false
                  ),
                  "children": JSONSchema(
                      type: .array,
                      description: "Nested UI components",
                      items: JSONSchema(ref: "#"),
                      additionalProperties: false
                  ),
                  "attributes": JSONSchema(
                      type: .array,
                      description: "Arbitrary attributes for the UI component, suitable for any element",
                      items: JSONSchema(
                          type: .object,
                          properties: [
                              "name": JSONSchema(
                                  type: .string,
                                  description: "The name of the attribute, for example onClick or className",
                                  additionalProperties: false
                              ),
                              "value": JSONSchema(
                                  type: .string,
                                  description: "The value of the attribute",
                                  additionalProperties: false
                              )
                          ],
                          required: ["name", "value"],
                          additionalProperties: false
                      ),
                      additionalProperties: false
                  )
              ],
              required: ["type", "label", "children", "attributes"],
              additionalProperties: false
          )
   }
}

@Observable
final class ChatStructuredOutputToolProvider {
   
   // MARK: - Init
   
   init(service: OpenAIService) {
      self.service = service
   }
   
   // MARK: - Public
   
   var chatDisplayMessages: [ChatMessageDisplayModel] = []
   let systemMessage = ChatCompletionParameters.Message(role: .system, content: .text("You are a math tutor"))
   
   func startChat(
      prompt: String)
   async throws
   {
      await startNewUserDisplayMessage(prompt)
      await startNewAssistantEmptyDisplayMessage()
      
      let userMessage = createUserMessage(prompt)
      chatMessageParameters.append(userMessage)
      
      let parameters = ChatCompletionParameters(
         messages: [systemMessage] + chatMessageParameters,
         model: .gpt4o20240806,
         tools: StructuredToolCall.allCases.map { $0.functionTool })
      
      do {
         
         let chat = try await service.startChat(parameters: parameters)
         guard let assistantMessage = chat.choices?.first?.message else { return }
         let content = assistantMessage.content ?? ""
         await updateLastAssistantMessage(.init(content: .content(.init(text: content)), origin: .received(.gpt)))
         if let toolCalls = assistantMessage.toolCalls {
            
            availableFunctions = [.structureUI: getStructureOutput(arguments:)]
            // Append the `assistantMessage` in to the `chatMessageParameters` to extend the conversation
            let parameterAssistantMessage = ChatCompletionParameters.Message(
               role: .assistant,
               content: .text(content), toolCalls: assistantMessage.toolCalls)
            
            chatMessageParameters.append(parameterAssistantMessage)
            
            /// # Step 4: send the info for each function call and function response to the model
            for toolCall in toolCalls {
               let name = toolCall.function.name
               let id = toolCall.id
               let functionToCall = availableFunctions[StructuredToolCall(rawValue: name!)!]!
               let arguments = toolCall.function.arguments
               let content = functionToCall(arguments)
               let toolMessage = ChatCompletionParameters.Message(
                  role: .tool,
                  content: .text(content),
                  name: name,
                  toolCallID: id)
               chatMessageParameters.append(toolMessage)
            }
            
            /// # get a new response from the model where it can see the function response
            await continueChat()
         }
         
      } catch let error as APIError {
         // If an error occurs, update the UI to display the error message.
         await updateLastAssistantMessage(.init(content: .error("\(error.displayDescription)"), origin: .received(.gpt)))
      }
   }
   
   // MARK: - Private
   
   private let service: OpenAIService
   private var lastDisplayedMessageID: UUID?
   private var chatMessageParameters: [ChatCompletionParameters.Message] = []
   private var availableFunctions: [StructuredToolCall: ((String) -> String)] = [:]
   
   // MARK: Tool functions
   
   func getStructureOutput(arguments: String) -> String {
      arguments
   }
}

// MARK: UI related

extension ChatStructuredOutputToolProvider {
   
   func createUserMessage(
      _ prompt: String)
   -> ChatCompletionParameters.Message
   {
      .init(role: .user, content: .text(prompt))
   }
   
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
            if let newText = newMedia.text,
               var lastMediaText = lastMedia.text {
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
   
   func continueChat() async {
      
      let paramsForChat = ChatCompletionParameters(
         messages: chatMessageParameters,
         model: .gpt4o)
      do {
         let chat = try await service.startChat(parameters: paramsForChat)
         guard let assistantMessage = chat.choices?.first?.message else { return }
         await updateLastAssistantMessage(.init(content: .content(.init(text: assistantMessage.content)), origin: .received(.gpt)))
      } catch {
         // If an error occurs, update the UI to display the error message.
         await updateLastAssistantMessage(.init(content: .error("\(error)"), origin: .received(.gpt)))
      }
   }
}
