//
//  OpenAIRealtimeConversationItemTruncate.swift
//  SwiftOpenAI
//

/// Truncates unheard assistant audio after local playback is interrupted.
/// https://developers.openai.com/api/reference/resources/realtime/client-events/conversation/item/truncate
public struct OpenAIRealtimeConversationItemTruncate: Encodable, Sendable {
  public init(itemID: String, audioEndMS: Int, contentIndex: Int = 0) {
    self.itemID = itemID
    self.audioEndMS = audioEndMS
    self.contentIndex = contentIndex
  }

  public let type = "conversation.item.truncate"
  public let itemID: String
  public let audioEndMS: Int
  public let contentIndex: Int

  private enum CodingKeys: String, CodingKey {
    case type
    case itemID = "item_id"
    case audioEndMS = "audio_end_ms"
    case contentIndex = "content_index"
  }
}
