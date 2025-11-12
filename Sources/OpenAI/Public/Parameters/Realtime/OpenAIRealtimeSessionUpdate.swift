//
//  OpenAIRealtimeSessionUpdate.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

/// Send this event to update the session's default configuration.
///
/// Docstrings from:
/// https://platform.openai.com/docs/api-reference/realtime-client-events/session/update
nonisolated public struct OpenAIRealtimeSessionUpdate: Encodable {
  public init(
    eventId: String? = nil,
    session: OpenAIRealtimeSessionConfiguration)
  {
    self.eventId = eventId
    self.session = session
  }

  /// Optional client-generated ID used to identify this event.
  public let eventId: String?

  /// Session configuration to update
  public let session: OpenAIRealtimeSessionConfiguration

  /// The event type, must be "session.update".
  public let type = "session.update"

  private enum CodingKeys: String, CodingKey {
    case eventId = "event_id"
    case session
    case type
  }

}
