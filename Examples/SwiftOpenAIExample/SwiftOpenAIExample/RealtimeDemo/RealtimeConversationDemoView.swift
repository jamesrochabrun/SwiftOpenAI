//
//  RealtimeConversationDemoView.swift
//  SwiftOpenAIExample
//

import SwiftOpenAI
import SwiftUI

struct RealtimeConversationDemoView: View {
  init(service: OpenAIService) {
    _provider = State(initialValue: RealtimeConversationProvider(service: service))
  }

  var body: some View {
    VStack(spacing: 0) {
      RealtimeConversationStatusView(phase: provider.phase)

      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(spacing: 10) {
            ForEach(provider.conversation.entries) { entry in
              RealtimeTranscriptRow(entry: entry)
                .id(entry.id)
            }
          }
          .padding()
        }
        .overlay {
          if provider.conversation.entries.isEmpty {
            ContentUnavailableView(
              "Ready for a conversation",
              systemImage: "waveform",
              description: Text("Start the session, then speak naturally."))
          }
        }
        .onChange(of: provider.conversation.entries.last) { _, entry in
          guard let entry else { return }
          proxy.scrollTo(entry.id, anchor: .bottom)
        }
      }

      RealtimeConversationControls(provider: provider)
    }
    .navigationTitle("Realtime")
    .navigationBarTitleDisplayMode(.inline)
    .onDisappear(perform: stopConversation)
  }

  @State private var provider: RealtimeConversationProvider

  private func stopConversation() {
    Task {
      await provider.stop()
    }
  }
}
