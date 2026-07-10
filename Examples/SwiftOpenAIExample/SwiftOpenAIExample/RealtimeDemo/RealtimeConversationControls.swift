//
//  RealtimeConversationControls.swift
//  SwiftOpenAIExample
//

import SwiftUI

struct RealtimeConversationControls: View {
  let provider: RealtimeConversationProvider

  var body: some View {
    VStack(spacing: 10) {
      if let errorMessage = provider.errorMessage {
        Text(errorMessage)
          .font(.caption)
          .foregroundStyle(.red)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityLabel("Realtime error: \(errorMessage)")
      }

      HStack(spacing: 12) {
        Button(
          provider.isConnected ? "Stop" : "Start",
          systemImage: provider.isConnected ? "stop.fill" : "mic.fill",
          action: toggleConversation)
          .frame(maxWidth: .infinity)
          .buttonStyle(.borderedProminent)
          .disabled(provider.phase == .connecting)

        Button("Ask Tool", systemImage: "wrench.and.screwdriver", action: askTool)
          .frame(maxWidth: .infinity)
          .buttonStyle(.bordered)
          .disabled(!provider.canSendToolPrompt)
      }
    }
    .padding()
    .background(.background)
    .overlay(alignment: .top) {
      Divider()
    }
  }

  private func toggleConversation() {
    Task {
      if provider.isConnected {
        await provider.stop()
      } else {
        await provider.start()
      }
    }
  }

  private func askTool() {
    Task {
      await provider.askToolPrompt()
    }
  }
}
