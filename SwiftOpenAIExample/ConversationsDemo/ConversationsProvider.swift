////
////  ConversationsProvider.swift
////  SwiftOpenAIExample
////
////  Created by James Rochabrun on 10/5/25.
////
//
//import SwiftOpenAI
//import SwiftUI
//
//@MainActor
//@Observable
//class ConversationsProvider {
//	// MARK: - Initialization
//
//	init(service: OpenAIService) {
//		self.service = service
//	}
//
//	// MARK: - Message Model
//
//	struct ConversationMessage: Identifiable {
//		let id = UUID()
//		let role: MessageRole
//		var content: String
//		let timestamp: Date
//		var isLoading = false
//		let itemId: String?
//
//		enum MessageRole {
//			case user
//			case assistant
//			case system
//		}
//	}
//
//	var messages = [ConversationMessage]()
//	var isLoading = false
//	var error: String?
//	var conversationId: String?
//
//	// MARK: - Public Methods
//
//	func sendMessage(_ text: String) {
//		// Cancel any existing task
//		currentTask?.cancel()
//
//		// Add user message
//		let userMessage = ConversationMessage(
//			role: .user,
//			content: text,
//			timestamp: Date(),
//			itemId: nil)
//		messages.append(userMessage)
//
//		// Start response generation
//		currentTask = Task {
//			await generateResponse(for: text)
//		}
//	}
//
//	func clearConversation() {
//		currentTask?.cancel()
//		currentTask = nil
//
//		// Delete conversation on server if it exists
//		if let conversationId = conversationId {
//			Task {
//				do {
//					_ = try await service.deleteConversation(id: conversationId)
//				} catch {
//					print("Failed to delete conversation: \(error)")
//				}
//			}
//		}
//
//		messages.removeAll()
//		conversationId = nil
//		error = nil
//		isLoading = false
//	}
//
//	private let service: OpenAIService
//	private var currentTask: Task<Void, Never>?
//
//	// MARK: - Private Methods
//
//	private func generateResponse(for userInput: String) async {
//		isLoading = true
//		error = nil
//
//		// Add loading placeholder
//		let loadingMessage = ConversationMessage(
//			role: .assistant,
//			content: "",
//			timestamp: Date(),
//			isLoading: true,
//			itemId: nil)
//		messages.append(loadingMessage)
//
//		do {
//			// Step 1: Create or use existing conversation
//			if conversationId == nil {
//				let conversation = try await service.conversationCreate(
//					parameters: CreateConversationParameter(
//						metadata: ["demo": "conversations-api"]))
//				conversationId = conversation.id
//			}
//
//			guard let conversationId = conversationId else {
//				throw APIError.requestFailed(description: "No conversation ID available")
//			}
//
//			// Step 2: Add user message to conversation
//			let userItem = InputItem.message(
//				InputMessage(role: "user", content: .text(userInput)))
//
//			_ = try await service.createConversationItems(
//				id: conversationId,
//				parameters: CreateConversationItemsParameter(items: [userItem]))
//
//			// Step 3: Generate response using conversation context
//			let inputArray = [
//				InputItem.message(InputMessage(role: "user", content: .text(userInput)))
//			]
//
//			let parameters = ModelResponseParameter(
//				input: .array(inputArray),
//				model: .gpt5,
//				instructions: "You are a helpful assistant. Use the conversation history stored in the conversation to provide contextual responses.",
//				maxOutputTokens: 1000,
//				conversation: Conversation(id: conversationId))
//
//			let response = try await service.responseCreate(parameters)
//
//			// Step 4: Extract assistant's response
//			var assistantText = ""
//			if case .array(let items) = response.output {
//				for item in items {
//					switch item {
//					case .message(let message):
//						if case .array(let contentItems) = message.content {
//							for contentItem in contentItems {
//								if case .outputText(let textContent) = contentItem {
//									assistantText += textContent.text
//								}
//							}
//						} else if case .text(let text) = message.content {
//							assistantText += text
//						}
//					default:
//						break
//					}
//				}
//			}
//
//			// Remove loading message and add final response
//			messages.removeAll { $0.isLoading }
//			messages.append(ConversationMessage(
//				role: .assistant,
//				content: assistantText.isEmpty ? "No response generated" : assistantText,
//				timestamp: Date(),
//				isLoading: false,
//				itemId: response.id))
//
//		} catch {
//			self.error = error.localizedDescription
//
//			// Remove loading message on error
//			messages.removeAll { $0.isLoading }
//		}
//
//		isLoading = false
//	}
//}
