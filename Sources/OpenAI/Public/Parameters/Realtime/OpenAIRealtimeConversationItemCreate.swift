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
      content = [.text(text)]
    }

    public init(role: String, content: [Content]) {
      self.role = role
      self.content = content
    }
  }
}

// MARK: - OpenAIRealtimeConversationItemCreate.Item.Content

extension OpenAIRealtimeConversationItemCreate.Item {
  public enum Content: Encodable {
    case text(String)
    case image(String) // base64 data URL: "data:image/{format};base64,{bytes}"

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .text(let text):
        try container.encode("input_text", forKey: .type)
        try container.encode(text, forKey: .text)
      case .image(let imageUrl):
        try container.encode("input_image", forKey: .type)
        try container.encode(imageUrl, forKey: .imageUrl)
      }
    }

    private enum CodingKeys: String, CodingKey {
      case type
      case text
      case imageUrl = "image_url"
    }
  }
}
