//
//  ConversationType.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

// MARK: ConversationType

/// Defaults to null
/// The conversation that this response belongs to. Items from this conversation are prepended to input_items for this response request. Input items and output items from this response are automatically added to this conversation after this response completes.
public enum Conversation: Codable {
  /// Conversation ID
  /// The unique ID of the conversation.
  case id(String)

  /// Conversation object
  /// The conversation that this response belongs to.
  case object(ConversationObject)

  /// Conversation object
  public struct ConversationObject: Codable {
    /// The unique ID of the conversation.
    public var id: String

    public init(id: String) {
      self.id = id
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let stringValue = try? container.decode(String.self) {
      self = .id(stringValue)
    } else if let objectValue = try? container.decode(ConversationObject.self) {
      self = .object(objectValue)
    } else {
      throw DecodingError.typeMismatch(
        Conversation.self,
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Expected String or ConversationObject"
        )
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .id(let string):
      try container.encode(string)
    case .object(let object):
      try container.encode(object)
    }
  }
}
