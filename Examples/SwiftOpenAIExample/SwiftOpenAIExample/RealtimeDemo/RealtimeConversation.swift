//
//  RealtimeConversation.swift
//  SwiftOpenAIExample
//

import Foundation

/// A transport-independent projection of Realtime events into conversation rows.
/// Other apps can reuse this reducer while replacing the surrounding UI and tool layer.
struct RealtimeConversation {
  struct Entry: Identifiable, Equatable {
    enum Role: Equatable {
      case assistant
      case tool
      case user
    }

    enum State: Equatable {
      case streaming
      case complete
    }

    let id: String
    let role: Role
    var text: String
    var state: State
  }

  private(set) var entries = [Entry]()

  mutating func reset() {
    entries.removeAll(keepingCapacity: true)
    currentAssistantID = nil
    currentUserID = nil
    fallbackID = 0
  }

  mutating func beginUserTurn(itemID: String?) {
    let id = resolvedID(itemID, role: .user, responseID: nil)
    currentUserID = id
    upsert(id: id, role: .user, state: .streaming)
  }

  mutating func appendUserTranscript(_ delta: String, itemID: String?) {
    let id = resolvedID(itemID, role: .user, responseID: nil)
    currentUserID = id
    append(delta, to: id, role: .user)
  }

  mutating func finishUserTranscript(_ transcript: String, itemID: String?) {
    let id = resolvedID(itemID, role: .user, responseID: nil)
    finish(text: transcript, id: id, role: .user)
    if currentUserID == id {
      currentUserID = nil
    }
  }

  mutating func appendUserText(_ text: String, itemID: String) {
    finish(text: text, id: itemID, role: .user)
  }

  mutating func beginAssistantTurn(itemID: String?, responseID: String?) {
    let id = resolvedID(itemID, role: .assistant, responseID: responseID)
    currentAssistantID = id
    upsert(id: id, role: .assistant, state: .streaming)
  }

  mutating func appendAssistantTranscript(_ delta: String, itemID: String?, responseID: String?) {
    let id = resolvedID(itemID, role: .assistant, responseID: responseID)
    currentAssistantID = id
    append(delta, to: id, role: .assistant)
  }

  mutating func finishAssistantTranscript(_ transcript: String, itemID: String?, responseID: String?) {
    let id = resolvedID(itemID, role: .assistant, responseID: responseID)
    finish(text: transcript, id: id, role: .assistant)
    if currentAssistantID == id {
      currentAssistantID = nil
    }
  }

  mutating func finishAssistantItem(itemID: String, text: String?) {
    guard let text, !text.isEmpty else { return }
    finish(text: text, id: itemID, role: .assistant)
    if currentAssistantID == itemID {
      currentAssistantID = nil
    }
  }

  mutating func finishResponse() {
    guard let currentAssistantID else { return }

    if let index = entries.firstIndex(where: { $0.id == currentAssistantID }) {
      if entries[index].text.isEmpty {
        entries.remove(at: index)
      } else {
        entries[index].state = .complete
      }
    }

    self.currentAssistantID = nil
  }

  mutating func recordToolCall(name: String, callID: String) {
    finish(text: "Used \(name)", id: callID, role: .tool)
  }

  mutating func registerItem(
    itemID: String,
    type: String,
    role: String?,
    previousItemID: String?)
  {
    guard type == "message" else { return }

    switch role {
    case "assistant":
      beginAssistantTurn(itemID: itemID, responseID: nil)
    case "user":
      beginUserTurn(itemID: itemID)
    default:
      return
    }

    move(itemID: itemID, after: previousItemID)
  }

  private var currentAssistantID: String?
  private var currentUserID: String?
  private var fallbackID = 0

  private mutating func resolvedID(
    _ itemID: String?,
    role: Entry.Role,
    responseID: String?)
    -> String
  {
    if let itemID {
      return itemID
    }
    if role == .assistant, let responseID {
      return "response-\(responseID)"
    }
    if role == .assistant, let currentAssistantID {
      return currentAssistantID
    }
    if role == .user, let currentUserID {
      return currentUserID
    }

    fallbackID += 1
    return "local-\(role)-\(fallbackID)"
  }

  private mutating func upsert(id: String, role: Entry.Role, state: Entry.State) {
    guard !entries.contains(where: { $0.id == id }) else { return }
    entries.append(.init(id: id, role: role, text: "", state: state))
  }

  private mutating func append(_ delta: String, to id: String, role: Entry.Role) {
    guard !delta.isEmpty else { return }
    if let index = entries.firstIndex(where: { $0.id == id }) {
      entries[index].text += delta
      entries[index].state = .streaming
    } else {
      entries.append(.init(id: id, role: role, text: delta, state: .streaming))
    }
  }

  private mutating func finish(text: String, id: String, role: Entry.Role) {
    let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else {
      entries.removeAll { $0.id == id }
      return
    }

    if let index = entries.firstIndex(where: { $0.id == id }) {
      entries[index].text = text
      entries[index].state = .complete
    } else {
      entries.append(.init(id: id, role: role, text: text, state: .complete))
    }
  }

  private mutating func move(itemID: String, after previousItemID: String?) {
    guard let sourceIndex = entries.firstIndex(where: { $0.id == itemID }) else { return }

    guard let previousItemID else {
      if sourceIndex != entries.startIndex {
        let entry = entries.remove(at: sourceIndex)
        entries.insert(entry, at: entries.startIndex)
      }
      return
    }
    guard
      let previousIndex = entries.firstIndex(where: { $0.id == previousItemID }),
      sourceIndex != previousIndex + 1
    else { return }

    let entry = entries.remove(at: sourceIndex)
    let adjustedPreviousIndex = entries.firstIndex(where: { $0.id == previousItemID }) ?? previousIndex
    entries.insert(entry, at: min(adjustedPreviousIndex + 1, entries.endIndex))
  }
}
