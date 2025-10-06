//
//  CreateConversationParameter.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/05/25.
//

import Foundation

// MARK: CreateConversationParameter

/// [Create a conversation](https://platform.openai.com/docs/api-reference/conversations/create)
public struct CreateConversationParameter: Codable {
  /// Initialize a new CreateConversationParameter
  public init(
    items: [InputItem]? = nil,
    metadata: [String: String]? = nil)
  {
    self.items = items
    self.metadata = metadata
  }

  /// Initial items to include in the conversation context. You may add up to 20 items at a time.
  public var items: [InputItem]?

  /// Set of 16 key-value pairs that can be attached to an object.
  /// Keys: max 64 characters, Values: max 512 characters
  public var metadata: [String: String]?

  enum CodingKeys: String, CodingKey {
    case items
    case metadata
  }
}
