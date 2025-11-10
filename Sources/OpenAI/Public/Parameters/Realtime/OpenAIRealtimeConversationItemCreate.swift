//
//  OpenAIRealtimeConversationItemCreate.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

import Foundation

/// https://platform.openai.com/docs/api-reference/realtime-client-events/conversation/item/create
nonisolated public struct OpenAIRealtimeConversationItemCreate: Encodable {
    public let type = "conversation.item.create"
    public let item: Item

    public init(item: Item) {
        self.item = item
    }
}

// MARK: -
public extension OpenAIRealtimeConversationItemCreate {
    struct Item: Encodable {
        public let type = "message"
        public let role: String
        public let content: [Content]

        public init(role: String, text: String) {
            self.role = role
            self.content = [.init(text: text)]
        }
    }
}

// MARK: -
public extension OpenAIRealtimeConversationItemCreate.Item {
    struct Content: Encodable {
        public let type = "input_text"
        public let text: String

        public init(text: String) {
            self.text = text
        }
    }
}
