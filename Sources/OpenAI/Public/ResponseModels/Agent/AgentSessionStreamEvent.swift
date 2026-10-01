//
//  AgentSessionStreamEvent.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/1/26.
//

import Foundation

/// A server-sent event streamed from an agent session.
///
/// The Agents API is in public beta, so events are decoded leniently: `kind` maps the
/// documented event types, unrecognized types decode as `.unknown` instead of failing
/// the stream, and the full payload is retained in `raw`.
public struct AgentSessionStreamEvent: Decodable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    type = try container.decode(String.self, forKey: .type)
    sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId)
    turnId = try container.decodeIfPresent(String.self, forKey: .turnId)
    text = try container.decodeIfPresent(String.self, forKey: .text)
    requestId = try container.decodeIfPresent(String.self, forKey: .requestId)
    item = try container.decodeIfPresent(AgentSessionItem.self, forKey: .item)
    raw = try OpenAIJSONValue(from: decoder)
  }

  /// The documented agent session event types.
  public enum Kind: Equatable {
    /// The session is ready for new input.
    case sessionIdle
    /// The session failed.
    case sessionFailed
    /// The session has pending approvals that need a client response.
    case requiresAction
    /// The agent produced response text for the turn.
    case turnOutputTextDone
    /// The turn finished successfully.
    case turnCompleted
    /// The turn failed.
    case turnFailed
    /// The turn was cancelled.
    case turnCancelled
    /// An event type this SDK does not recognize; match on the associated raw type string.
    case unknown(String)

    init(type: String) {
      switch type {
      case "agent.session.idle": self = .sessionIdle
      case "agent.session.failed": self = .sessionFailed
      case "agent.session.requires_action": self = .requiresAction
      case "agent.session.turn.output_text.done": self = .turnOutputTextDone
      case "agent.session.turn.completed": self = .turnCompleted
      case "agent.session.turn.failed": self = .turnFailed
      case "agent.session.turn.cancelled": self = .turnCancelled
      default: self = .unknown(type)
      }
    }
  }

  /// The event type string, e.g. `agent.session.turn.completed`.
  public let type: String
  /// The identifier of the session this event belongs to. Store it from the initial
  /// events to send follow-up input and manage the session.
  public let sessionId: String?
  /// The identifier of the turn this event belongs to.
  public let turnId: String?
  /// The response text, present on output text events.
  public let text: String?
  /// The identifier to reference when responding to a pending approval.
  public let requestId: String?
  /// The session item carried by item events, e.g. `computer_use_call` activity.
  public let item: AgentSessionItem?
  /// The complete payload as returned by the API.
  public let raw: OpenAIJSONValue

  /// The event type mapped to the documented cases.
  public var kind: Kind {
    Kind(type: type)
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case sessionId = "session_id"
    case turnId = "turn_id"
    case text
    case requestId = "request_id"
    case item
  }
}
