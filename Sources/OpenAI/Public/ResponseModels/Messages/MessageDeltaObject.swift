//
//  MessageDeltaObject.swift
//
//
//  Created by James Rochabrun on 3/17/24.
//

import Foundation

/// [MessageDeltaObject](https://platform.openai.com/docs/api-reference/assistants-streaming/message-delta-object)
///
/// Represents a message delta i.e. any changed fields on a message during streaming.
public struct MessageDeltaObject: Delta {
  public struct Delta: Decodable {
    /// The entity that produced the message. One of user or assistant.
    public let role: String?
    /// The content of the message in array of text and/or images.
    public let content: [AssistantMessageContent]

    enum Role: String {
      case user
      case assistant
    }

    enum CodingKeys: String, CodingKey {
      case role
      case content
    }
  }

  /// The identifier of the message, which can be referenced in API endpoints.
  public let id: String
  /// The object type, which is always thread.message.delta.
  public let object: String
  /// The delta containing the fields that have changed on the Message.
  public let delta: Delta
}
