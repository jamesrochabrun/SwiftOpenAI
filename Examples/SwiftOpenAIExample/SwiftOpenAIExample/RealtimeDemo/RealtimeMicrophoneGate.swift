//
//  RealtimeMicrophoneGate.swift
//  SwiftOpenAIExample
//

import SwiftOpenAI

/// Keeps high-frequency microphone work off the main actor while the UI owns conversation state.
@RealtimeActor
final class RealtimeMicrophoneGate {
  nonisolated init() { }

  private(set) var isOpen = false

  func close() {
    isOpen = false
  }

  func open() {
    isOpen = true
  }
}
