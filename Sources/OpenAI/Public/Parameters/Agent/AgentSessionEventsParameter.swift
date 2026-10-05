//
//  AgentSessionEventsParameter.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/1/26.
//

import Foundation

// MARK: - AgentSessionEventsParameter

/// [Submit client events to an agent session.](https://developers.openai.com/api/docs/guides/agents-api/quickstart)
///
/// `POST /v1/agents/sessions/{session_id}/events`
public struct AgentSessionEventsParameter: Encodable {

  public init(events: [AgentSessionClientEvent]) {
    self.events = events
  }

  /// The events to submit to the session.
  public var events: [AgentSessionClientEvent]
}

// MARK: - AgentSessionClientEvent

/// An event a client submits to an agent session.
public enum AgentSessionClientEvent: Encodable {
  /// Sends a user message to the session as a follow-up task or steering input.
  /// Encoded as `agent.session.input.message`.
  case message(String)
  /// Cancels the current turn. Encoded as `agent.session.input.cancel`.
  case cancel
  /// Escape hatch for client events not yet modeled by this SDK, such as approval
  /// responses to `agent.session.requires_action` events. The dictionary is encoded
  /// verbatim as the event object.
  case custom([String: OpenAIJSONValue])

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .message(let text):
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("agent.session.input.message", forKey: .type)
      let content = InputContent(type: "input_text", text: text)
      try container.encode([InputMessage(role: "user", content: [content])], forKey: .input)

    case .cancel:
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode("agent.session.input.cancel", forKey: .type)

    case .custom(let object):
      var container = encoder.singleValueContainer()
      try container.encode(object)
    }
  }

  private struct InputMessage: Encodable {
    let role: String
    let content: [InputContent]
  }

  private struct InputContent: Encodable {
    let type: String
    let text: String
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case input
  }
}
