//
//  ConversationModel.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/5/25.
//

import Foundation

/// A conversation object returned from the Conversations API
public struct ConversationModel: Decodable {
  /// The unique ID of the conversation
  public let id: String

  /// The object type, which is always "conversation"
  public let object: String

  /// The time at which the conversation was created, measured in seconds since the Unix epoch
  public let createdAt: Int

  /// Set of 16 key-value pairs that can be attached to an object
  /// Keys: max 64 characters, Values: max 512 characters
  public let metadata: [String: String]

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case createdAt = "created_at"
    case metadata
  }
}
