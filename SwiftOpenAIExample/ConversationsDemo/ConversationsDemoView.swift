////
////  ConversationsDemoView.swift
////  SwiftOpenAIExample
////
////  Created by James Rochabrun on 10/5/25.
////
//
//import SwiftOpenAI
//import SwiftUI
//
//// MARK: - ConversationsDemoView
//
//struct ConversationsDemoView: View {
//	init(service: OpenAIService) {
//		_provider = State(initialValue: ConversationsProvider(service: service))
//	}
//
//	@Environment(\.colorScheme) var colorScheme
//
//	var body: some View {
//		VStack(spacing: 0) {
//			// Header
//			headerView
//
//			// Messages
//			ScrollViewReader { proxy in
//				ScrollView {
//					LazyVStack(spacing: 12) {
//						ForEach(provider.messages) { message in
//							ConversationMessageBubbleView(message: message)
//								.id(message.id)
//						}
//
//						if provider.isLoading {
//							HStack {
//								ConversationLoadingIndicatorView()
//									.frame(width: 30, height: 30)
//								Spacer()
//							}
//							.padding(.horizontal)
//						}
//					}
//					.padding()
//				}
//				.onChange(of: provider.messages.count) { _, _ in
//					withAnimation {
//						proxy.scrollTo(provider.messages.last?.id, anchor: .bottom)
//					}
//				}
//			}
//
//			// Error view
//			if let error = provider.error {
//				Text(error)
//					.foregroundColor(.red)
//					.font(.caption)
//					.padding(.horizontal)
//					.padding(.vertical, 8)
//					.background(Color.red.opacity(0.1))
//			}
//
//			// Input area
//			inputArea
//		}
//		.navigationTitle("Conversations API Demo")
//		.navigationBarTitleDisplayMode(.inline)
//		.toolbar {
//			ToolbarItem(placement: .navigationBarTrailing) {
//				Button("Clear") {
//					provider.clearConversation()
//				}
//				.disabled(provider.isLoading)
//			}
//		}
//	}
//
//	@State private var provider: ConversationsProvider
//	@State private var inputText = ""
//	@FocusState private var isInputFocused: Bool
//
//	// MARK: - Subviews
//
//	private var headerView: some View {
//		VStack(alignment: .leading, spacing: 8) {
//			Text("Server-Side Conversation Management")
//				.font(.headline)
//
//			Text("This demo uses the Conversations API to maintain persistent conversation state on OpenAI's servers. Each message is stored as an item in the conversation.")
//				.font(.caption)
//				.foregroundColor(.secondary)
//
//			if let conversationId = provider.conversationId {
//				HStack(spacing: 4) {
//					Image(systemName: "cloud.fill")
//						.font(.caption2)
//						.foregroundColor(.blue)
//					Text("Conversation ID: \(String(conversationId.prefix(12)))...")
//						.font(.caption2)
//						.foregroundColor(.secondary)
//				}
//				.padding(.top, 4)
//			} else if provider.messages.isEmpty {
//				Label("Start a conversation below", systemImage: "bubble.left.and.bubble.right")
//					.font(.caption)
//					.foregroundColor(.blue)
//					.padding(.top, 4)
//			}
//		}
//		.frame(maxWidth: .infinity, alignment: .leading)
//		.padding()
//		.background(Color(UIColor.secondarySystemBackground))
//	}
//
//	private var inputArea: some View {
//		HStack(spacing: 12) {
//			TextField("Type a message...", text: $inputText, axis: .vertical)
//				.textFieldStyle(.roundedBorder)
//				.lineLimit(1 ... 5)
//				.focused($isInputFocused)
//				.disabled(provider.isLoading)
//				.onSubmit {
//					sendMessage()
//				}
//
//			Button(action: sendMessage) {
//				Image(systemName: "arrow.up.circle.fill")
//					.font(.title2)
//					.foregroundColor(inputText.isEmpty ? .gray : .blue)
//			}
//			.disabled(provider.isLoading || inputText.isEmpty)
//		}
//		.padding()
//		.background(Color(UIColor.systemBackground))
//		.overlay(
//			Rectangle()
//				.frame(height: 1)
//				.foregroundColor(Color(UIColor.separator)),
//			alignment: .top)
//	}
//
//	private func sendMessage() {
//		guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
//
//		let message = inputText
//		inputText = ""
//		provider.sendMessage(message)
//	}
//}
//
//// MARK: - ConversationMessageBubbleView
//
//struct ConversationMessageBubbleView: View {
//	let message: ConversationsProvider.ConversationMessage
//	@Environment(\.colorScheme) var colorScheme
//
//	var body: some View {
//		HStack {
//			if message.role == .assistant {
//				messageContent
//					.background(backgroundGradient)
//					.cornerRadius(16)
//					.overlay(
//						RoundedRectangle(cornerRadius: 16)
//							.stroke(borderColor, lineWidth: 1))
//				Spacer(minLength: 60)
//			} else {
//				Spacer(minLength: 60)
//				messageContent
//					.background(Color.blue)
//					.cornerRadius(16)
//					.foregroundColor(.white)
//			}
//		}
//	}
//
//	private var messageContent: some View {
//		VStack(alignment: .leading, spacing: 4) {
//			if message.role == .assistant, message.isLoading {
//				HStack(spacing: 4) {
//					Image(systemName: "cloud")
//						.font(.caption2)
//						.foregroundColor(.blue)
//					Text("Generating...")
//						.font(.caption2)
//						.foregroundColor(.secondary)
//				}
//			}
//
//			Text(message.content.isEmpty && message.isLoading ? " " : message.content)
//				.padding(.horizontal, 12)
//				.padding(.vertical, 8)
//
//			if message.role == .assistant, !message.isLoading, message.itemId != nil {
//				Text("Item ID: \(String(message.itemId?.prefix(8) ?? ""))")
//					.font(.caption2)
//					.foregroundColor(.secondary)
//					.padding(.horizontal, 12)
//					.padding(.bottom, 4)
//			}
//		}
//	}
//
//	private var backgroundGradient: some View {
//		LinearGradient(
//			gradient: Gradient(colors: [
//				Color(UIColor.secondarySystemBackground),
//				Color(UIColor.tertiarySystemBackground),
//			]),
//			startPoint: .topLeading,
//			endPoint: .bottomTrailing)
//	}
//
//	private var borderColor: Color {
//		colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
//	}
//}
//
//// MARK: - ConversationLoadingIndicatorView
//
//struct ConversationLoadingIndicatorView: View {
//	var body: some View {
//		ZStack {
//			ForEach(0 ..< 3) { index in
//				Circle()
//					.fill(Color.blue)
//					.frame(width: 8, height: 8)
//					.offset(x: CGFloat(index - 1) * 12)
//					.opacity(0.8)
//					.scaleEffect(animationScale(for: index))
//			}
//		}
//		.onAppear {
//			withAnimation(
//				.easeInOut(duration: 0.8)
//					.repeatForever(autoreverses: true))
//			{
//				animationAmount = 1
//			}
//		}
//	}
//
//	@State private var animationAmount = 0.0
//
//	private func animationScale(for index: Int) -> Double {
//		let delay = Double(index) * 0.1
//		let progress = (animationAmount + delay).truncatingRemainder(dividingBy: 1.0)
//		return 0.5 + (0.5 * sin(progress * .pi))
//	}
//}
//
//// MARK: - Preview
//
//#Preview {
//	NavigationView {
//		ConversationsDemoView(service: OpenAIServiceFactory.service(apiKey: "test"))
//	}
//}
