//
//  OptionsListView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftOpenAI
import SwiftUI

struct OptionsListView: View {
  /// https://platform.openai.com/docs/api-reference
  enum APIOption: String, CaseIterable, Identifiable {
    case audio = "Audio"
    case chat = "Chat"
    case chatPredictedOutput = "Chat Predicted Output"
    case localChat = "Local Chat" // Ollama
    case vision = "Vision"
    case embeddings = "Embeddings"
    case fineTuning = "Fine Tuning"
    case files = "Files"
    case images = "Images"
    case models = "Models"
    case moderations = "Moderations"
    case chatHistoryConversation = "Chat History Conversation"
    case chatFunctionCall = "Chat Functions call"
    case chatFunctionsCallStream = "Chat Functions call (Stream)"
    case chatStructuredOutput = "Chat Structured Output"
    case chatStructuredOutputTool = "Chat Structured Output Tools"
    case configureAssistant = "Configure Assistant"
    case realTimeAPI = "Real time API"
    case responseStream = "Response Stream Demo"
    case conversationsDemo = "Conversations Demo"

    var id: String { rawValue }
  }

  var openAIService: OpenAIService

  var options: [APIOption]

  var body: some View {
    VStack {
      // Custom model input field
      VStack(alignment: .leading, spacing: 8) {
        Text("Custom Model (Optional)")
          .font(.caption)
          .foregroundColor(.secondary)
        TextField("e.g., grok-beta, claude-3-opus, etc.", text: $customModel)
          .textFieldStyle(.roundedBorder)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      .padding()
      List(options, id: \.self, selection: $selection) { option in
        Text(option.rawValue)
      }
    }
    .sheet(item: $selection) { selection in
      VStack {
        Text(selection.rawValue)
          .font(.largeTitle)
          .padding()
        switch selection {
        case .audio:
          AudioDemoView(service: openAIService)
        case .chat:
          ChatDemoView(service: openAIService, customModel: customModel)
        case .chatPredictedOutput:
          ChatPredictedOutputDemoView(service: openAIService, customModel: customModel)
        case .vision:
          ChatVisionDemoView(service: openAIService, customModel: customModel)
        case .embeddings:
          EmbeddingsDemoView(service: openAIService)
        case .fineTuning:
          FineTuningJobDemoView(service: openAIService)
        case .files:
          FilesDemoView(service: openAIService)
        case .images:
          ImagesDemoView(service: openAIService)
        case .localChat:
          LocalChatDemoView(service: openAIService, customModel: customModel)
        case .models:
          ModelsDemoView(service: openAIService)
        case .moderations:
          ModerationDemoView(service: openAIService)
        case .chatHistoryConversation:
          ChatStreamFluidConversationDemoView(service: openAIService, customModel: customModel)
        case .chatFunctionCall:
          ChatFunctionCallDemoView(service: openAIService)
        case .chatFunctionsCallStream:
          ChatFunctionsCalllStreamDemoView(service: openAIService, customModel: customModel)
        case .chatStructuredOutput:
          ChatStructuredOutputDemoView(service: openAIService, customModel: customModel)
        case .chatStructuredOutputTool:
          ChatStructureOutputToolDemoView(service: openAIService, customModel: customModel)
        case .configureAssistant:
          AssistantConfigurationDemoView(service: openAIService)
        case .realTimeAPI:
          Text("WIP")
        case .responseStream:
          ResponseStreamDemoView(service: openAIService)
        case .conversationsDemo:
          ConversationsDemoView(service: openAIService)
        }
      }
    }
  }

  @State private var selection: APIOption? = nil
  @State private var customModel = ""
}

// MARK: - ConversationsProvider

@MainActor
@Observable
class ConversationsProvider {
	// MARK: - Initialization

	init(service: OpenAIService) {
		self.service = service
	}

	// MARK: - Message Model

	struct ConversationMessage: Identifiable {
		let id = UUID()
		let role: MessageRole
		var content: String
		let timestamp: Date
		var isLoading = false
		let itemId: String?

		enum MessageRole {
			case user
			case assistant
			case system
		}
	}

	var messages = [ConversationMessage]()
	var isLoading = false
	var error: String?
	var conversationId: String?

	// MARK: - Public Methods

	func sendMessage(_ text: String) {
		// Cancel any existing task
		currentTask?.cancel()

		// Add user message
		let userMessage = ConversationMessage(
			role: .user,
			content: text,
			timestamp: Date(),
			itemId: nil)
		messages.append(userMessage)

		// Start response generation
		currentTask = Task {
			await generateResponse(for: text)
		}
	}

	func clearConversation() {
		currentTask?.cancel()
		currentTask = nil

		// Delete conversation on server if it exists
		if let conversationId = conversationId {
			Task {
				do {
					_ = try await service.deleteConversation(id: conversationId)
				} catch {
					print("Failed to delete conversation: \(error)")
				}
			}
		}

		messages.removeAll()
		conversationId = nil
		error = nil
		isLoading = false
	}

	private let service: OpenAIService
	private var currentTask: Task<Void, Never>?

	// MARK: - Private Methods

	private func generateResponse(for userInput: String) async {
		isLoading = true
		error = nil

		// Add loading placeholder
		let loadingMessage = ConversationMessage(
			role: .assistant,
			content: "",
			timestamp: Date(),
			isLoading: true,
			itemId: nil)
		messages.append(loadingMessage)

		do {
			// Step 1: Create or use existing conversation
			if conversationId == nil {
				let conversation = try await service.conversationCreate(
					parameters: CreateConversationParameter(
						metadata: ["demo": "conversations-api"]))
				conversationId = conversation.id
			}

			guard let conversationId = conversationId else {
				throw APIError.requestFailed(description: "No conversation ID available")
			}

			// Step 2: Add user message to conversation
			let userItem = InputItem.message(
				InputMessage(role: "user", content: .text(userInput)))

			_ = try await service.createConversationItems(
				id: conversationId,
				parameters: CreateConversationItemsParameter(items: [userItem]))

			// Step 3: Generate response using conversation context
			let inputArray = [
				InputItem.message(InputMessage(role: "user", content: .text(userInput)))
			]

			let parameters = ModelResponseParameter(
				input: .array(inputArray),
				model: .gpt5,
				conversation: .id(conversationId),
				instructions: "You are a helpful assistant. Use the conversation history stored in the conversation to provide contextual responses.",
				maxOutputTokens: 1000)

			let response = try await service.responseCreate(parameters)

			// Step 4: Extract assistant's response
			var assistantText = ""
			for item in response.output {
				switch item {
				case .message(let message):
					for contentItem in message.content {
						if case .outputText(let textContent) = contentItem {
							assistantText += textContent.text
						}
					}
				default:
					break
				}
			}

			// Remove loading message and add final response
			messages.removeAll { $0.isLoading }
			messages.append(ConversationMessage(
				role: .assistant,
				content: assistantText.isEmpty ? "No response generated" : assistantText,
				timestamp: Date(),
				isLoading: false,
				itemId: response.id))

		} catch {
			self.error = error.localizedDescription

			// Remove loading message on error
			messages.removeAll { $0.isLoading }
		}

		isLoading = false
	}
}

// MARK: - ConversationsDemoView

struct ConversationsDemoView: View {
	init(service: OpenAIService) {
		_provider = State(initialValue: ConversationsProvider(service: service))
	}

	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		VStack(spacing: 0) {
			// Header
			headerView

			// Messages
			ScrollViewReader { proxy in
				ScrollView {
					LazyVStack(spacing: 12) {
						ForEach(provider.messages) { message in
							ConversationMessageBubbleView(message: message)
								.id(message.id)
						}

						if provider.isLoading {
							HStack {
								ConversationLoadingIndicatorView()
									.frame(width: 30, height: 30)
								Spacer()
							}
							.padding(.horizontal)
						}
					}
					.padding()
				}
				.onChange(of: provider.messages.count) { _, _ in
					withAnimation {
						proxy.scrollTo(provider.messages.last?.id, anchor: .bottom)
					}
				}
			}

			// Error view
			if let error = provider.error {
				Text(error)
					.foregroundColor(.red)
					.font(.caption)
					.padding(.horizontal)
					.padding(.vertical, 8)
					.background(Color.red.opacity(0.1))
			}

			// Input area
			inputArea
		}
		.navigationTitle("Conversations API Demo")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button("Clear") {
					provider.clearConversation()
				}
				.disabled(provider.isLoading)
			}
		}
	}

	@State private var provider: ConversationsProvider
	@State private var inputText = ""
	@FocusState private var isInputFocused: Bool

	// MARK: - Subviews

	private var headerView: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Server-Side Conversation Management")
				.font(.headline)

			Text("This demo uses the Conversations API to maintain persistent conversation state on OpenAI's servers. Each message is stored as an item in the conversation.")
				.font(.caption)
				.foregroundColor(.secondary)

			if let conversationId = provider.conversationId {
				HStack(spacing: 4) {
					Image(systemName: "cloud.fill")
						.font(.caption2)
						.foregroundColor(.blue)
					Text("Conversation ID: \(String(conversationId.prefix(12)))...")
						.font(.caption2)
						.foregroundColor(.secondary)
				}
				.padding(.top, 4)
			} else if provider.messages.isEmpty {
				Label("Start a conversation below", systemImage: "bubble.left.and.bubble.right")
					.font(.caption)
					.foregroundColor(.blue)
					.padding(.top, 4)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
		.background(Color(UIColor.secondarySystemBackground))
	}

	private var inputArea: some View {
		HStack(spacing: 12) {
			TextField("Type a message...", text: $inputText, axis: .vertical)
				.textFieldStyle(.roundedBorder)
				.lineLimit(1 ... 5)
				.focused($isInputFocused)
				.disabled(provider.isLoading)
				.onSubmit {
					sendMessage()
				}

			Button(action: sendMessage) {
				Image(systemName: "arrow.up.circle.fill")
					.font(.title2)
					.foregroundColor(inputText.isEmpty ? .gray : .blue)
			}
			.disabled(provider.isLoading || inputText.isEmpty)
		}
		.padding()
		.background(Color(UIColor.systemBackground))
		.overlay(
			Rectangle()
				.frame(height: 1)
				.foregroundColor(Color(UIColor.separator)),
			alignment: .top)
	}

	private func sendMessage() {
		guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

		let message = inputText
		inputText = ""
		provider.sendMessage(message)
	}
}

// MARK: - ConversationMessageBubbleView

struct ConversationMessageBubbleView: View {
	let message: ConversationsProvider.ConversationMessage
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		HStack {
			if message.role == .assistant {
				messageContent
					.background(backgroundGradient)
					.cornerRadius(16)
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(borderColor, lineWidth: 1))
				Spacer(minLength: 60)
			} else {
				Spacer(minLength: 60)
				messageContent
					.background(Color.blue)
					.cornerRadius(16)
					.foregroundColor(.white)
			}
		}
	}

	private var messageContent: some View {
		VStack(alignment: .leading, spacing: 4) {
			if message.role == .assistant, message.isLoading {
				HStack(spacing: 4) {
					Image(systemName: "cloud")
						.font(.caption2)
						.foregroundColor(.blue)
					Text("Generating...")
						.font(.caption2)
						.foregroundColor(.secondary)
				}
			}

			Text(message.content.isEmpty && message.isLoading ? " " : message.content)
				.padding(.horizontal, 12)
				.padding(.vertical, 8)

			if message.role == .assistant, !message.isLoading, message.itemId != nil {
				Text("Item ID: \(String(message.itemId?.prefix(8) ?? ""))")
					.font(.caption2)
					.foregroundColor(.secondary)
					.padding(.horizontal, 12)
					.padding(.bottom, 4)
			}
		}
	}

	private var backgroundGradient: some View {
		LinearGradient(
			gradient: Gradient(colors: [
				Color(UIColor.secondarySystemBackground),
				Color(UIColor.tertiarySystemBackground),
			]),
			startPoint: .topLeading,
			endPoint: .bottomTrailing)
	}

	private var borderColor: Color {
		colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
	}
}

// MARK: - ConversationLoadingIndicatorView

struct ConversationLoadingIndicatorView: View {
	var body: some View {
		ZStack {
			ForEach(0 ..< 3) { index in
				Circle()
					.fill(Color.blue)
					.frame(width: 8, height: 8)
					.offset(x: CGFloat(index - 1) * 12)
					.opacity(0.8)
					.scaleEffect(animationScale(for: index))
			}
		}
		.onAppear {
			withAnimation(
				.easeInOut(duration: 0.8)
					.repeatForever(autoreverses: true))
			{
				animationAmount = 1
			}
		}
	}

	@State private var animationAmount = 0.0

	private func animationScale(for index: Int) -> Double {
		let delay = Double(index) * 0.1
		let progress = (animationAmount + delay).truncatingRemainder(dividingBy: 1.0)
		return 0.5 + (0.5 * sin(progress * .pi))
	}
}
