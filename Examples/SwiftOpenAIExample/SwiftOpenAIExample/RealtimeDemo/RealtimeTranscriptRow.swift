//
//  RealtimeTranscriptRow.swift
//  SwiftOpenAIExample
//

import SwiftUI

struct RealtimeTranscriptRow: View {
  let entry: RealtimeConversation.Entry

  var body: some View {
    HStack {
      if entry.role == .user {
        Spacer(minLength: 40)
        bubble
      } else {
        bubble
        Spacer(minLength: 40)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(speaker): \(displayText)")
  }

  private var bubble: some View {
    HStack(spacing: 8) {
      if entry.state == .streaming {
        ProgressView()
          .controlSize(.small)
          .tint(foregroundStyle)
          .accessibilityHidden(true)
      }

      Text(displayText)
        .font(.body)
        .textSelection(.enabled)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .foregroundStyle(foregroundStyle)
    .background(backgroundStyle)
    .clipShape(.rect(cornerRadius: 12))
  }

  private var displayText: String {
    guard !entry.text.isEmpty else {
      return entry.role == .user ? "Listening…" : "Thinking…"
    }
    return entry.text
  }

  private var speaker: String {
    switch entry.role {
    case .assistant:
      "Assistant"
    case .tool:
      "Tool"
    case .user:
      "You"
    }
  }

  private var foregroundStyle: Color {
    entry.role == .user ? .white : .primary
  }

  private var backgroundStyle: Color {
    switch entry.role {
    case .assistant:
      .secondary.opacity(0.14)
    case .tool:
      .green.opacity(0.18)
    case .user:
      .blue
    }
  }
}
