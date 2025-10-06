//
//  Conversation.swift
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
          debugDescription: "Expected String or ConversationObject"))
    }
  }

  /// Conversation object
  public struct ConversationObject: Codable {
    public init(
      id: String,
      createdAt: Int? = nil,
      error: ErrorObject? = nil,
      incompleteDetails: IncompleteDetails? = nil)
    {
      self.id = id
      self.createdAt = createdAt
      self.error = error
      self.incompleteDetails = incompleteDetails
    }

    /// Error object for conversation
    public struct ErrorObject: Codable {
      /// The error code for the response
      public let code: String

      /// A human-readable description of the error
      public let message: String

      public init(code: String, message: String) {
        self.code = code
        self.message = message
      }
    }

    /// Incomplete details structure
    public struct IncompleteDetails: Codable {
      /// The reason why the response is incomplete
      public let reason: String

      public init(reason: String) {
        self.reason = reason
      }
    }

    /// The unique ID of the conversation
    public var id: String

    /// Unix timestamp (in seconds) of when this conversation was created
    public var createdAt: Int?

    /// An error object returned when the model fails to generate a Response
    public var error: ErrorObject?

    /// Details about why the response is incomplete
    public var incompleteDetails: IncompleteDetails?

    enum CodingKeys: String, CodingKey {
      case id
      case createdAt = "created_at"
      case error
      case incompleteDetails = "incomplete_details"
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
