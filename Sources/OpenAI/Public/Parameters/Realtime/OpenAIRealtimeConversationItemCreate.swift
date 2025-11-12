//
//  OpenAIRealtimeConversationItemCreate.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

import Foundation

// MARK: - OpenAIRealtimeConversationItemCreate

/// https://platform.openai.com/docs/api-reference/realtime-client-events/conversation/item/create
public struct OpenAIRealtimeConversationItemCreate: Encodable {
  public let type = "conversation.item.create"
  public let item: Item

  public init(item: Item) {
    self.item = item
  }
}

// MARK: OpenAIRealtimeConversationItemCreate.Item

extension OpenAIRealtimeConversationItemCreate {
  public struct Item: Encodable {
    public let type = "message"
    public let role: String
    public let content: [Content]

    public init(role: String, text: String) {
      self.role = role
      content = [.init(text: text)]
    }
  }
}

// MARK: - OpenAIRealtimeConversationItemCreate.Item.Content

extension OpenAIRealtimeConversationItemCreate.Item {
  public struct Content: Encodable {
    public let type = "input_text"
    public let text: String

    public init(text: String) {
      self.text = text
    }
  }
}
