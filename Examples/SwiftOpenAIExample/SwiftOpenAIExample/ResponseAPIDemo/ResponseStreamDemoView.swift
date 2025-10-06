//
//  ResponseStreamDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 6/7/25.
//

import SwiftOpenAI
import SwiftUI

// MARK: - ResponseStreamDemoView

struct ResponseStreamDemoView: View {
  init(service: OpenAIService) {
    _provider = State(initialValue: ResponseStreamProvider(service: service))
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
              MessageBubbleView(message: message)
                .id(message.id)
            }

            if provider.isStreaming {
              HStack {
                LoadingIndicatorView()
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
    .navigationTitle("Response Stream Demo")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Clear") {
          provider.clearConversation()
        }
        .disabled(provider.isStreaming)
      }
    }
  }

  @State private var provider: ResponseStreamProvider
  @State private var inputText = ""
  @FocusState private var isInputFocused: Bool

  // MARK: - Subviews

  private var headerView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Streaming Responses with Conversation State")
        .font(.headline)

      Text("This demo uses the Responses API with streaming to maintain conversation context across multiple turns.")
        .font(.caption)
        .foregroundColor(.secondary)

      if provider.messages.isEmpty {
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
        .disabled(provider.isStreaming)
        .onSubmit {
          sendMessage()
        }

      Button(action: sendMessage) {
        Image(systemName: provider.isStreaming ? "stop.circle.fill" : "arrow.up.circle.fill")
          .font(.title2)
          .foregroundColor(provider.isStreaming ? .red : (inputText.isEmpty ? .gray : .blue))
      }
      .disabled(!provider.isStreaming && inputText.isEmpty)
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

    if provider.isStreaming {
      provider.stopStreaming()
    } else {
      let message = inputText
      inputText = ""
      provider.sendMessage(message)
    }
  }
}

// MARK: - MessageBubbleView

struct MessageBubbleView: View {
  let message: ResponseStreamProvider.ResponseMessage
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
      if message.role == .assistant, message.isStreaming {
        HStack(spacing: 4) {
          Image(systemName: "dot.radiowaves.left.and.right")
            .font(.caption2)
            .foregroundColor(.blue)
          Text("Streaming...")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }

      Text(message.content.isEmpty && message.isStreaming ? " " : message.content)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)

      if message.role == .assistant, !message.isStreaming, message.responseId != nil {
        Text("Response ID: \(String(message.responseId?.prefix(8) ?? ""))")
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

// MARK: - LoadingIndicatorView

struct LoadingIndicatorView: View {
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

// MARK: - Preview

#Preview {
  NavigationView {
    ResponseStreamDemoView(service: OpenAIServiceFactory.service(apiKey: "test"))
  }
}
