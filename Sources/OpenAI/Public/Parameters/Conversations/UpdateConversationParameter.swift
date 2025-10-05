//
//  UpdateConversationParameter.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/05/25.
//

import Foundation

// MARK: UpdateConversationParameter

/// [Update a conversation](https://platform.openai.com/docs/api-reference/conversations/update)
public struct UpdateConversationParameter: Codable {
  /// Initialize a new UpdateConversationParameter
  public init(
    metadata: [String: String])
  {
    self.metadata = metadata
  }

  /// Set of 16 key-value pairs that can be attached to an object.
  /// Keys: max 64 characters, Values: max 512 characters
  public var metadata: [String: String]

  enum CodingKeys: String, CodingKey {
    case metadata
  }
}
