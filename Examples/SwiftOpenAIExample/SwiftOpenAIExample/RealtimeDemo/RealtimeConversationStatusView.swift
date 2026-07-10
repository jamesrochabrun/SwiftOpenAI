//
//  RealtimeConversationStatusView.swift
//  SwiftOpenAIExample
//

import SwiftUI

struct RealtimeConversationStatusView: View {
  let phase: RealtimeConversationProvider.Phase

  var body: some View {
    HStack(spacing: 8) {
      Circle()
        .fill(indicatorColor)
        .frame(width: 10, height: 10)
        .accessibilityHidden(true)

      Text(title)
        .font(.headline)

      Spacer()

      if phase == .connecting {
        ProgressView()
          .controlSize(.small)
          .accessibilityLabel("Connecting")
      } else if phase == .listening {
        Image(systemName: "waveform")
          .foregroundStyle(.secondary)
          .accessibilityHidden(true)
      }
    }
    .padding()
    .background(.thinMaterial)
    .accessibilityElement(children: .combine)
  }

  private var indicatorColor: Color {
    switch phase {
    case .listening:
      .green
    case .responding:
      .blue
    case .connecting:
      .orange
    case .idle:
      .secondary
    }
  }

  private var title: String {
    switch phase {
    case .connecting:
      "Connecting"
    case .idle:
      "Idle"
    case .listening:
      "Listening"
    case .responding:
      "Assistant responding"
    }
  }
}
