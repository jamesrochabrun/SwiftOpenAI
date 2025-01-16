//
//  ClientEvents.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/5/25.
//

import Foundation

// MARK: - Client Events

public enum ClientEventType: String {
   case sessionUpdate = "session.update"
   case inputAudioBufferAppend = "input_audio_buffer.append"
   case inputAudioBufferCommit = "input_audio_buffer.commit"
   case inputAudioBufferClear = "input_audio_buffer.clear"
   case conversationItemCreate = "conversation.item.create"
   case conversationItemTruncate = "conversation.item.truncate"
   case conversationItemDelete = "conversation.item.delete"
   case responseCreate = "response.create"
   case responseCancel = "response.cancel"
}

/// [session.update](https://platform.openai.com/docs/api-reference/realtime-client-events/session)
///
/// Send this event to update the session’s default configuration. The client may send this event at any time to update the session configuration, and any field may be updated at any time, except for "voice". The server will respond with a session.updated event that shows the full effective configuration. Only fields that are present are updated, thus the correct way to clear a field like "instructions" is to pass an empty string.
public struct SessionUpdateEvent: RealTimeEvent, Encodable {
   
   /// Optional client-generated ID used to identify this event.
   public let eventId: String? // TODO: check if this can be optional
   // The event type, must be session.update.
   public let type: String = ClientEventType.sessionUpdate.rawValue
   public let session: RealTimeSessionParameters
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case session
   }
}

/// [input_audio_buffer.append](https://platform.openai.com/docs/api-reference/realtime-client-events/input_audio_buffer)
///
/// Send this event to append audio bytes to the input audio buffer. The audio buffer is temporary storage you can write to and later commit. In Server VAD mode, the audio buffer is used to detect speech and the server will decide when to commit. When Server VAD is disabled, you must commit the audio buffer manually.
///
///The client may choose how much audio to place in each event up to a maximum of 15 MiB, for example streaming smaller chunks from the client may allow the VAD to be more responsive. Unlike made other client events, the server will not send a confirmation response to this event.
public struct InputAudioBufferAppendEvent: RealTimeEvent, Encodable {
   
   /// Optional client-generated ID used to identify this event.
   public let eventId: String?
   /// The event type, must be input_audio_buffer.append.
   public let type: String = ClientEventType.inputAudioBufferAppend.rawValue
   /// Base64-encoded audio bytes. This must be in the format specified by the input_audio_format field in the session configuration.
   public let audio: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case audio
   }
}

/// [input_audio_buffer.commit](https://platform.openai.com/docs/api-reference/realtime-client-events/input_audio_buffer/commit)
///
/// Send this event to commit the user input audio buffer, which will create a new user message item in the conversation. This event will produce an error if the input audio buffer is empty. When in Server VAD mode, the client does not need to send this event, the server will commit the audio buffer automatically.
///
/// Committing the input audio buffer will trigger input audio transcription (if enabled in session configuration), but it will not create a response from the model. The server will respond with an input_audio_buffer.committed event.
public struct InputAudioBufferCommitEvent: RealTimeEvent, Encodable {
   
   /// Optional client-generated ID used to identify this event.
   public let eventId: String?
   //// The event type, must be input_audio_buffer.commit.
   public let type: String = ClientEventType.inputAudioBufferCommit.rawValue
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
   }
}

/// [input_audio_buffer.clear](https://platform.openai.com/docs/api-reference/realtime-client-events/input_audio_buffer/clear)
///
/// Send this event to clear the audio bytes in the buffer. The server will respond with an input_audio_buffer.cleared event.
public struct InputAudioBufferClearEvent: RealTimeEvent, Encodable {
   
   /// Optional client-generated ID used to identify this event.
   public let eventId: String?
   /// The event type, must be input_audio_buffer.clear.
   public let type: String = ClientEventType.inputAudioBufferClear.rawValue
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
   }
}

/// [conversation.item.create](https://platform.openai.com/docs/api-reference/realtime-client-events/conversation/item)
///
/// Add a new Item to the Conversation's context, including messages, function calls, and function call responses. This event can be used both to populate a "history" of the conversation and to add new items mid-stream, but has the current limitation that it cannot populate assistant audio messages.
///
/// If successful, the server will respond with a conversation.item.created event, otherwise an error event will be sent.
public struct ConversationItemCreateEvent: RealTimeEvent, Encodable {
   
   /// Optional client-generated ID used to identify this event.
   public let eventId: String?
   /// The event type, must be conversation.item.create.
   public let type: String = ClientEventType.conversationItemCreate.rawValue
   /// The ID of the preceding item after which the new item will be inserted. If not set, the new item will be appended to the end of the conversation. If set, it allows an item to be inserted mid-conversation. If the ID cannot be found, an error will be returned and the item will not be added.
   public let previousItemId: String?
   /// The item to add to the conversation.
   public let item: ConversationItem
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case previousItemId = "previous_item_id"
      case item
   }
}

/// [conversation.item.truncate](https://platform.openai.com/docs/api-reference/realtime-client-events/conversation/item/truncate)
///
/// Send this event to truncate a previous assistant message’s audio. The server will produce audio faster than realtime, so this event is useful when the user interrupts to truncate audio that has already been sent to the client but not yet played. This will synchronize the server's understanding of the audio with the client's playback.
///
/// Truncating audio will delete the server-side text transcript to ensure there is not text in the context that hasn't been heard by the user.
/// If successful, the server will respond with a conversation.item.truncated event.
public struct ConversationItemTruncateEvent: RealTimeEvent, Encodable {
   
   /// Optional client-generated ID used to identify this event.
   public let eventId: String?
   /// The event type, must be conversation.item.truncate.
   public let type: String = ClientEventType.conversationItemTruncate.rawValue
   /// The ID of the assistant message item to truncate. Only assistant message items can be truncated.
   public let itemId: String
   /// The index of the content part to truncate. Set this to 0.
   public let contentIndex: Int
   /// Inclusive duration up to which audio is truncated, in milliseconds. If the audio_end_ms is greater than the actual audio duration, the server will respond with an error.
   public let audioEndMs: Int
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case itemId = "item_id"
      case contentIndex = "content_index"
      case audioEndMs = "audio_end_ms"
   }
}

/// [conversation.item.delete](https://platform.openai.com/docs/api-reference/realtime-client-events/conversation/item/delete)
///
/// Send this event when you want to remove any item from the conversation history. The server will respond with a conversation.item.deleted event, unless the item does not exist in the conversation history, in which case the server will respond with an error.
public struct ConversationItemDeleteEvent: RealTimeEvent, Encodable {
   
   /// Optional client-generated ID used to identify this event.
   public let eventId: String?
   /// The event type, must be conversation.item.delete.
   public let type: String = ClientEventType.conversationItemDelete.rawValue
   /// The ID of the item to delete.
   public let itemId: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case itemId = "item_id"
   }
}

/// [response.create](https://platform.openai.com/docs/api-reference/realtime-client-events/response/create)
///
/// This event instructs the server to create a Response, which means triggering model inference. When in Server VAD mode, the server will create Responses automatically.
///
/// A Response will include at least one Item, and may have two, in which case the second will be a function call. These Items will be appended to the conversation history.
///
/// The server will respond with a response.created event, events for Items and content created, and finally a response.done event to indicate the Response is complete.
///
/// The response.create event includes inference configuration like instructions, and temperature. These fields will override the Session's configuration for this Response only.
public struct ResponseCreateEvent: RealTimeEvent, Encodable {
   
   /// Optional client-generated ID used to identify this event.
   public let eventId: String?
   /// The event type, must be response.create.
   public let type: String = ClientEventType.responseCreate.rawValue
   /// Create a new Realtime response with these parameters
   public let response: RealTimeResponse
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case response
   }
}

/// [response.cancel](https://platform.openai.com/docs/api-reference/realtime-client-events/response/cancel)
///
///Send this event to cancel an in-progress response. The server will respond with a response.cancelled event or an error if there is no response to cancel.
public struct ResponseCancelEvent: RealTimeEvent, Encodable {
   
   /// Optional client-generated ID used to identify this event.
   public let eventId: String?
   /// The event type, must be response.cancel.
   public let type: String = ClientEventType.responseCancel.rawValue
   /// A specific response ID to cancel - if not provided, will cancel an in-progress response in the default conversation.
   public let responseId: String?
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
   }
}
