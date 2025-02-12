//
//  ChatFunctionCallProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/14/23.
//

import SwiftUI
import SwiftOpenAI

enum FunctionCallDefinition: String, CaseIterable {
   
   case createImage = "create_image"
   // Add more functions if needed, parallel function calling is supported.

   var functionTool: ChatCompletionParameters.Tool {
      switch self {
      case .createImage:
         return .init(function: .init(
            name: self.rawValue,
            strict: nil,
            description: "call this function if the request asks to generate an image",
            parameters: .init(
               type: .object,
               properties: [
                  "prompt": .init(type: .string, description: "The exact prompt passed in."),
                  "count": .init(type: .integer, description: "The number of images requested")
               ],
               required: ["prompt", "count"])))
      }
   }
}

@Observable class ChatFunctionCallProvider {
   
   // MARK: - Private Properties
   
   private let service: OpenAIService
   private var lastDisplayedMessageID: UUID?
   /// To be used for a new request
   private var chatMessageParameters: [ChatCompletionParameters.Message] = []
   private var availableFunctions: [FunctionCallDefinition: (@MainActor (String) async throws -> String)] = [:]
   
   @MainActor
   func generateImage(arguments: String) async throws -> String {
      let dictionary = arguments.toDictionary()!
      let prompt = dictionary["prompt"] as! String
      let count = (dictionary["count"]  as? Int) ??  1
      
      let assistantMessage = ChatMessageDisplayModel(
         content: .content(.init(text: "Generating images...")),
         origin: .received(.gpt))
      updateLastAssistantMessage(assistantMessage)
      
      let urls = try await service.createImages(parameters: .init(prompt: prompt, model: .dalle2(.small), numberOfImages: count)).data.compactMap(\.url)
      
      let dalleAssistantMessage = ChatMessageDisplayModel(
         content: .content(.init(text: nil, urls: urls)),
         origin: .received(.dalle))
      updateLastAssistantMessage(dalleAssistantMessage)
      
      return prompt
   }

   // MARK: - Public Properties
   
   /// To be used for UI purposes.
   var chatDisplayMessages: [ChatMessageDisplayModel] = []
   
   // MARK: - Initializer
   
   init(service: OpenAIService) {
      self.service = service
   }
   
   // MARK: - Public Methods
   
   func startChat(
      prompt: String)
      async throws
   {
      defer {
         chatMessageParameters = []
      }
      
      await startNewUserDisplayMessage(prompt)
      
      await startNewAssistantEmptyDisplayMessage()
      
      
      /// # Step 1: send the conversation and available functions to the model
      let userMessage = createUserMessage(prompt)
      chatMessageParameters.append(userMessage)
      
      let tools = FunctionCallDefinition.allCases.map { $0.functionTool }
      
      let parameters = ChatCompletionParameters(
         messages: chatMessageParameters,
         model: .gpt41106Preview,
         toolChoice: ToolChoice.auto,
         tools: tools)
      
      do {
         let chat = try await service.startChat(parameters: parameters)
         
         guard let assistantMessage = chat.choices?.first?.message else { return }
         
         let content = assistantMessage.content ?? ""

         await updateLastAssistantMessage(.init(content: .content(.init(text: content)), origin: .received(.gpt)))
         
         /// # Step 2: check if the model wanted to call a function
         if let toolCalls = assistantMessage.toolCalls {
            
            /// # Step 3: call the function
            availableFunctions = [.createImage: generateImage(arguments:)]
            // Append the `assistantMessage` in to the `chatMessageParameters` to extend the conversation
            let parameterAssistantMessage = ChatCompletionParameters.Message(
               role: .assistant,
               content: .text(content), toolCalls: assistantMessage.toolCalls)
            
            chatMessageParameters.append(parameterAssistantMessage)
            
            /// # Step 4: send the info for each function call and function response to the model
            for toolCall in toolCalls {
               let name = toolCall.function.name
               let id = toolCall.id
               let functionToCall = availableFunctions[FunctionCallDefinition(rawValue: name!)!]!
               let arguments = toolCall.function.arguments
               let content = try await functionToCall(arguments)
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
   
   func continueChat() async {
      
      let systemMessage = ChatCompletionParameters.Message(role: .system, content: .text("You are an artist powered by AI, if the messages has a tool message you will weight that bigger in order to create a response, and you are providing me an image, you always respond in readable language and never providing URLs of images, most of the times you add an emoji on your responses if makes sense, do not describe the image. also always offer more help"))
            
      chatMessageParameters.insert(systemMessage, at: 0)
      
      let paramsForChat = ChatCompletionParameters(
         messages: chatMessageParameters,
         model: .gpt41106Preview)
      do {
         let chat = try await service.startChat(parameters: paramsForChat)
         guard let assistantMessage = chat.choices?.first?.message else { return }
         await updateLastAssistantMessage(.init(content: .content(.init(text: assistantMessage.content)), origin: .received(.gpt)))
      } catch {
         // If an error occurs, update the UI to display the error message.
         await updateLastAssistantMessage(.init(content: .error("\(error)"), origin: .received(.gpt)))
      }
   }
   
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
}

private extension String {
   
   func toDictionary() -> [String: Any]? {
      guard let jsonData = self.data(using: .utf8) else {
         print("Failed to convert JSON string to Data.")
         return nil
      }
      
      do {
         let dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
         return dict
      } catch let error {
         print("Failed to deserialize JSON: \(error.localizedDescription)")
         return nil
      }
   }
}
