//
//  CreateConversationItemsParameter.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/05/25.
//

import Foundation

// MARK: CreateConversationItemsParameter

/// [Create items in a conversation](https://platform.openai.com/docs/api-reference/conversations/create-items)
public struct CreateConversationItemsParameter: Codable {
  /// Initialize a new CreateConversationItemsParameter
  public init(
    items: [InputItem],
    include: [ResponseInclude]? = nil)
  {
    self.items = items
    self.include = include?.map(\.rawValue)
  }

  /// The items to add to the conversation. You may add up to 20 items at a time.
  public var items: [InputItem]

  /// Additional fields to include in the response.
  /// Note: This becomes a query parameter, not a body parameter
  public var include: [String]?

  enum CodingKeys: String, CodingKey {
    case items
    case include
  }
}
