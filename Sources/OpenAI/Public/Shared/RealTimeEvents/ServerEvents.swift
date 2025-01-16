//
//  ServerEvents.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/5/25.
//

import Foundation

// MARK: - Server Events

public enum ServerEventType: String {
   case error = "error"
   case sessionCreated = "session.created"
   case sessionUpdated = "session.updated"
   case conversationCreated = "conversation.created"
   case conversationItemCreated = "conversation.item.created"
   case inputAudioTranscriptionCompleted = "conversation.item.input_audio_transcription.completed"
   case inputAudioTranscriptionFailed = "conversation.item.input_audio_transcription.failed"
   case conversationItemTruncated = "conversation.item.truncated"
   case conversationItemDeleted = "conversation.item.deleted"
   case inputAudioBufferCommitted = "input_audio_buffer.committed"
   case inputAudioBufferCleared = "input_audio_buffer.cleared"
   case inputAudioBufferSpeechStarted = "input_audio_buffer.speech_started"
   case inputAudioBufferSpeechStopped = "input_audio_buffer.speech_stopped" /// missing
   case responseCreated = "response.created"
   case responseDone = "response.done"
   case responseOutputItemAdded = "response.output_item.added"
   case responseOutputItemDone = "response.output_item.done"
   case responseContentPartAdded = "response.content_part.added"
   case responseContentPartDone = "response.content_part.done"
   case responseTextDelta = "response.text.delta"
   case responseTextDone = "response.text.done"
   case responseAudioTranscriptDelta = "response.audio_transcript.delta"
   case responseAudioTranscriptDone = "response.audio_transcript.done"
   case responseAudioDelta = "response.audio.delta"
   case responseAudioDone = "response.audio.done"
   case responseFunctionCallArgumentsDelta = "response.function_call_arguments.delta"
   case responseFunctionCallArgumentsDone = "response.function_call_arguments.done"
   case rateLimitsUpdated = "rate_limits.updated"
}

/// Returned when an error occurs, which could be a client problem or a server problem. Most errors are recoverable and the session will stay open, we recommend to implementors to monitor and log error messages by default.
public struct RealTimeError: Decodable {
   
   /// The unique ID of the server event.
   public let eventID: String
   /// The event type, must be error.
   public let type: String = ServerEventType.error.rawValue
   /// Details of the error.
   public let error: ErrorDetails
   
   enum CodingKeys: String, CodingKey {
      case eventID = "event_id"
      case type
      case error
   }
}

public struct ErrorDetails: Codable {
   /// The type of error (e.g., "invalid_request_error", "server_error").
   public let type: String
   /// Error code, if any.
   public let code: String?
   /// A human-readable error message.
   public let message: String?
   /// Parameter related to the error, if any.
   public let param: String?
   /// The event_id of the client event that caused the error, if applicable.
   public let eventID: String?
   
   enum CodingKeys: String, CodingKey {
      case type
      case code
      case message
      case param
      case eventID = "event_id"
   }
}

/// [session.created](https://platform.openai.com/docs/api-reference/realtime-server-events/session/created)
///
/// Returned when a Session is created. Emitted automatically when a new connection is established as the first server event. This event will contain the default Session configuration.
public struct SessionCreatedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be session.created.
   public let type: String = ServerEventType.sessionCreated.rawValue
   /// Realtime session object configuration.
   public let session: RealTimeSessionObject
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case session
   }
}

/// [session.updated](https://platform.openai.com/docs/api-reference/realtime-server-events/session/updated)
///
/// Returned when a session is updated with a session.update event, unless there is an error.
public struct SessionUpdatedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be session.updated.
   public let type: String = ServerEventType.sessionUpdated.rawValue
   /// Realtime session object configuration.
   public let session: RealTimeSessionObject
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case session
   }
}

/// [conversation.created](https://platform.openai.com/docs/api-reference/realtime-server-events/conversation/created)
///
/// Returned when a conversation is created. Emitted right after session creation.
public struct ConversationCreatedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be conversation.created.
   public let type: String = ServerEventType.conversationCreated.rawValue
   /// The conversation resource.
   public let conversation: ConversationResource
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case conversation
   }
}

/// [conversation.item.created](https://platform.openai.com/docs/api-reference/realtime-server-events/conversation/item/created)
///
/// Returned when a conversation item is created. There are several scenarios that produce this event:
///
/// The server is generating a Response, which if successful will produce either one or two Items, which will be of type message (role assistant) or type function_call.
/// The input audio buffer has been committed, either by the client or the server (in server_vad mode). The server will take the content of the input audio buffer and add it to a new user message Item.
/// The client has sent a conversation.item.create event to add a new Item to the Conversation.
public struct ConversationItemCreatedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   ///The event type, must be conversation.item.created.
   public let type: String = ServerEventType.conversationItemCreated.rawValue
   /// The ID of the preceding item in the Conversation context, allows the client to understand the order of the conversation.
   public let previousItemId: String
   /// The item to add to the conversation.
   public let item: ConversationItem
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case previousItemId = "previous_item_id"
      case item
   }
}

/// [conversation.item.input_audio_transcription.completed](https://platform.openai.com/docs/api-reference/realtime-server-events/conversation/item/input_audio_transcription/completed)
///
/// This event is the output of audio transcription for user audio written to the user audio buffer. Transcription begins when the input audio buffer is committed by the client or server (in server_vad mode). Transcription runs asynchronously with Response creation, so this event may come before or after the Response events.
///
/// Realtime API models accept audio natively, and thus input transcription is a separate process run on a separate ASR (Automatic Speech Recognition) model, currently always whisper-1. Thus the transcript may diverge somewhat from the model's interpretation, and should be treated as a rough guide.
public struct InputAudioTranscriptionCompletedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be conversation.item.input_audio_transcription.completed.
   public let type: String = ServerEventType.inputAudioTranscriptionCompleted.rawValue
   /// The ID of the user message item containing the audio.
   public let itemId: String
   /// The index of the content part containing the audio.
   public let contentIndex: Int
   /// The transcribed text.
   public let transcript: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case itemId = "item_id"
      case contentIndex = "content_index"
      case transcript
   }
}

/// [conversation.item.truncated](https://platform.openai.com/docs/api-reference/realtime-server-events/conversation/item/truncated)
///
/// Returned when an earlier assistant audio message item is truncated by the client with a `conversation.item.truncate` event.
/// This event is used to synchronize the server's understanding of the audio with the client's playback.
/// This action will truncate the audio and remove the server-side text transcript to ensure there is no text
/// in the context that hasn't been heard by the user.
public struct ConversationItemTruncatedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   
   /// The event type, must be conversation.item.truncated
   public let type: String = ServerEventType.conversationItemTruncated.rawValue
   
   /// The ID of the assistant message item that was truncated.
   public let itemId: String
   
   /// The index of the content part that was truncated.
   public let contentIndex: Int
   
   /// The duration up to which the audio was truncated, in milliseconds.
   public let audioEndMs: Int
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case itemId = "item_id"
      case contentIndex = "content_index"
      case audioEndMs = "audio_end_ms"
   }
}

/// [conversation.item.deleted](https://platform.openai.com/docs/api-reference/realtime-server-events/conversation/item/deleted)
///
/// Returned when an item in the conversation is deleted by the client with a `conversation.item.delete` event.
/// This event is used to synchronize the server's understanding of the conversation history with the client's view.
public struct ConversationItemDeletedEvent: RealTimeEvent, Decodable {
   /// The unique ID of the server event.
   public let eventId: String
   
   /// The event type, must be conversation.item.deleted
   public let type: String = ServerEventType.conversationItemDeleted.rawValue
   
   /// The ID of the item that was deleted.
   public let itemId: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case itemId = "item_id"
   }
}

/// [conversation.item.input_audio_transcription.failed](https://platform.openai.com/docs/api-reference/realtime-server-events/conversation/item/input_audio_transcription/failed)
///
/// Returned when input audio transcription is configured, and a transcription request for a user message failed. These events are separate from other error events so that the client can identify the related Item.
public struct InputAudioTranscriptionFailedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be conversation.item.input_audio_transcription.failed.
   public let type: String = ServerEventType.inputAudioTranscriptionFailed.rawValue
   /// The ID of the user message item.
   public let itemId: String
   /// The index of the content part containing the audio.
   public let contentIndex: Int
   /// The index of the content part containing the audio.
   public let error: ErrorDetails
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case itemId = "item_id"
      case contentIndex = "content_index"
      case error
   }
}

///  [input_audio_buffer.committed](https://platform.openai.com/docs/api-reference/realtime-server-events/input_audio_buffer/committed)
///
/// Returned when an input audio buffer is committed, either by the client or automatically in server VAD mode. The item_id property is the ID of the user message item that will be created, thus a conversation.item.created event will also be sent to the client.
public struct InputAudioBufferCommittedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be input_audio_buffer.committed.
   public let type: String = ServerEventType.inputAudioBufferCommitted.rawValue
   /// The ID of the preceding item after which the new item will be inserted.
   public let previousItemId: String
   /// The ID of the user message item that will be created.
   public let itemId: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case previousItemId = "previous_item_id"
      case itemId = "item_id"
   }
}

/// [input_audio_buffer.cleared](https://platform.openai.com/docs/api-reference/realtime-server-events/input_audio_buffer/cleared)
///
/// Returned when the input audio buffer is cleared by the client with a input_audio_buffer.clear event.
public struct InputAudioBufferClearedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be input_audio_buffer.cleared.
   public let type: String = ServerEventType.inputAudioBufferCleared.rawValue
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
   }
}

/// [input_audio_buffer.speech_started](https://platform.openai.com/docs/api-reference/realtime-server-events/input_audio_buffer/speech_started)
///
/// Sent by the server when in server_vad mode to indicate that speech has been detected in the audio buffer. This can happen any time audio is added to the buffer (unless speech is already detected). The client may want to use this event to interrupt audio playback or provide visual feedback to the user.
/// The client should expect to receive a input_audio_buffer.speech_stopped event when speech stops. The item_id property is the ID of the user message item that will be created when speech stops and will also be included in the input_audio_buffer.speech_stopped event (unless the client manually commits the audio buffer during VAD activation).
public struct InputAudioBufferSpeechStartedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be input_audio_buffer.speech_started.
   public let type: String = ServerEventType.inputAudioBufferSpeechStarted.rawValue
   /// Milliseconds from the start of all audio written to the buffer during the session when speech was first detected. This will correspond to the beginning of audio sent to the model, and thus includes the prefix_padding_ms configured in the Session.
   public let audioStartMs: Int
   /// The ID of the user message item that will be created when speech stops.
   public let itemId: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case audioStartMs = "audio_start_ms"
      case itemId = "item_id"
   }
}

/// [input_audio_buffer.speech_stopped](https://platform.openai.com/docs/api-reference/realtime-server-events/input_audio_buffer/speech_stopped)
///
/// Returned in `server_vad` mode when the server detects the end of speech in the audio buffer.
/// The server will also send an `conversation.item.created` event with the user message item
/// that is created from the audio buffer.
public struct InputAudioBufferSpeechStoppedEvent: RealTimeEvent, Decodable {
   /// The unique ID of the server event.
   public let eventId: String
   
   /// The event type, must be input_audio_buffer.speech_stopped
   public let type: String = ServerEventType.inputAudioBufferSpeechStopped.rawValue
   
   /// Milliseconds since the session started when speech stopped.
   /// This will correspond to the end of audio sent to the model,
   /// and thus includes the `min_silence_duration_ms` configured in the Session.
   public let audioEndMs: Int
   
   /// The ID of the user message item that will be created.
   public let itemId: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case audioEndMs = "audio_end_ms"
      case itemId = "item_id"
   }
}

/// [response.created](https://platform.openai.com/docs/api-reference/realtime-server-events/response/created)
///
/// Returned when a new Response is created. The first event of response creation, where the response is in an initial state of in_progress.
public struct ResponseCreatedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.created.
   public let type: String = ServerEventType.responseCreated.rawValue
   /// The response resource.
   public let response: ResponseResource
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case response
   }
}

/// [response.done](https://platform.openai.com/docs/api-reference/realtime-server-events/response/done)
///
/// Returned when a Response is done streaming. Always emitted, no matter the final state. The Response object included in the response.done event will include all output Items in the Response but will omit the raw audio data.
public struct ResponseDoneEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.done.
   public let type: String = ServerEventType.responseDone.rawValue
   /// The response resource.
   public let response: ResponseResource
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case response
   }
}

/// [response.output_item.added](https://platform.openai.com/docs/api-reference/realtime-server-events/response/output_item/added)
///
/// Returned when a new Item is created during Response generation.
public struct ResponseOutputItemAddedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.output_item.added.
   public let type: String = ServerEventType.responseOutputItemAdded.rawValue
   /// The ID of the Response to which the item belongs.
   public let responseId: String
   /// The index of the output item in the Response.
   public let outputIndex: Int
   /// The item to add to the conversation.
   public let item: ConversationItem
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case outputIndex = "output_index"
      case item
   }
}

/// [response.output_item.done](https://platform.openai.com/docs/api-reference/realtime-server-events/response/output_item/done)
///
/// Returned when an Item is done streaming. Also emitted when a Response is interrupted, incomplete, or cancelled.
public struct ResponseOutputItemDoneEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.output_item.done.
   public let type: String = ServerEventType.responseOutputItemDone.rawValue
   /// The ID of the Response to which the item belongs.
   public let responseId: String
   /// The index of the output item in the Response.
   public let outputIndex: Int
   /// The item to add to the conversation.
   public let item: ConversationItem
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case outputIndex = "output_index"
      case item
   }
}

/// [response.content_part.added](https://platform.openai.com/docs/api-reference/realtime-server-events/response/content_part/added)
///
/// Returned when a new content part is added to an assistant message item during response generation.
public struct ResponseContentPartAddedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.content_part.added.
   public let type: String = ServerEventType.responseContentPartAdded.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the item to which the content part was added.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The index of the content part in the item's content array.
   public let contentIndex: Int
   /// The content part that was added.
   public let part: ContentPart
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case contentIndex = "content_index"
      case part
   }
}

/// [response.content_part.done](https://platform.openai.com/docs/api-reference/realtime-server-events/response/content_part/done)
///
/// Returned when a content part is done streaming in an assistant message item. Also emitted when a Response is interrupted, incomplete, or cancelled.
public struct ResponseContentPartDoneEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.content_part.done
   public let type: String = ServerEventType.responseContentPartDone.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the item.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The index of the content part in the item's content array.
   public let contentIndex: Int
   /// The content part that is done.
   public let part: ContentPart
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case contentIndex = "content_index"
      case part
   }
}

/// [response.text.delta](https://platform.openai.com/docs/api-reference/realtime-server-events/response/text/delta)
///
/// Returned when the text value of a "text" content part is updated.
public struct ResponseTextDeltaEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.text.delta.
   public let type: String = ServerEventType.responseTextDelta.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the item.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The index of the content part in the item's content array.
   public let contentIndex: Int
   /// The text delta.
   public let delta: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case contentIndex = "content_index"
      case delta
   }
}

/// [response.text.done](https://platform.openai.com/docs/api-reference/realtime-server-events/response/text/done)
///
/// Returned when the text value of a "text" content part is done streaming. Also emitted when a Response is interrupted, incomplete, or cancelled.
public struct ResponseTextDoneEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.text.done.
   public let type: String = ServerEventType.responseTextDone.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the item.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The index of the content part in the item's content array.
   public let contentIndex: Int
   /// The final text content.
   public let text: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case contentIndex = "content_index"
      case text
   }
}

/// [response.audio_transcript.delta](https://platform.openai.com/docs/api-reference/realtime-server-events/response/audio_transcript/delta)
///
/// Returned when the model-generated transcription of audio output is updated.
public struct ResponseAudioTranscriptDeltaEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.audio_transcript.delta.
   public let type: String = ServerEventType.responseAudioTranscriptDelta.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the item.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The index of the content part in the item's content array.
   public let contentIndex: Int
   /// The transcript delta.
   public let delta: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case contentIndex = "content_index"
      case delta
   }
}

/// [response.audio_transcript.done](https://platform.openai.com/docs/api-reference/realtime-server-events/response/audio_transcript/done)
///
/// Returned when the model-generated transcription of audio output is done streaming. Also emitted when a Response is interrupted, incomplete, or cancelled.
public struct ResponseAudioTranscriptDoneEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.audio_transcript.done.
   public let type: String = ServerEventType.responseAudioTranscriptDone.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the item.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The index of the content part in the item's content array.
   public let contentIndex: Int
   /// The final transcript of the audio.
   public let transcript: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case contentIndex = "content_index"
      case transcript
   }
}

/// [response.audio.delta](https://platform.openai.com/docs/api-reference/realtime-server-events/response/audio/delta)
///
/// Returned when the model-generated audio is updated.
public struct ResponseAudioDeltaEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.audio.delta.
   public let type: String = ServerEventType.responseAudioDelta.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the item.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The index of the content part in the item's content array.
   public let contentIndex: Int
   /// Base64-encoded audio data delta.
   public let delta: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case contentIndex = "content_index"
      case delta
   }
}

/// [response.audio.done](https://platform.openai.com/docs/api-reference/realtime-server-events/response/audio/done)
///
/// Returned when the model-generated audio is done. Also emitted when a Response is interrupted, incomplete, or cancelled.
public struct ResponseAudioDoneEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.audio.done.
   public let type: String = ServerEventType.responseAudioDone.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the item.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The index of the content part in the item's content array.
   public let contentIndex: Int
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case contentIndex = "content_index"
   }
}

/// [response.function_call_arguments.delta](https://platform.openai.com/docs/api-reference/realtime-server-events/response/function_call_arguments/delta)
///
/// Returned when the model-generated function call arguments are updated.
public struct ResponseFunctionCallArgumentsDeltaEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.function_call_arguments.delta.
   public let type: String = ServerEventType.responseFunctionCallArgumentsDelta.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the function call item.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The ID of the function call.
   public let callId: String
   /// The arguments delta as a JSON string.
   public let delta: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case callId = "call_id"
      case delta
   }
}

/// [response.function_call_arguments.done](https://platform.openai.com/docs/api-reference/realtime-server-events/response/function_call_arguments/done)
///
/// Returned when the model-generated function call arguments are done streaming. Also emitted when a Response is interrupted, incomplete, or cancelled.
public struct ResponseFunctionCallArgumentsDoneEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be response.function_call_arguments.done.
   public let type: String = ServerEventType.responseFunctionCallArgumentsDone.rawValue
   /// The ID of the response.
   public let responseId: String
   /// The ID of the function call item.
   public let itemId: String
   /// The index of the output item in the response.
   public let outputIndex: Int
   /// The ID of the function call.
   public let callId: String
   /// The final arguments as a JSON string.
   public let arguments: String
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case responseId = "response_id"
      case itemId = "item_id"
      case outputIndex = "output_index"
      case callId = "call_id"
      case arguments
   }
}

/// [rate_limits.updated](https://platform.openai.com/docs/api-reference/realtime-server-events/rate_limits/updated)
///
/// Emitted at the beginning of a Response to indicate the updated rate limits. When a Response is created some tokens will be "reserved" for the output tokens, the rate limits shown here reflect that reservation, which is then adjusted accordingly once the Response is completed.
public struct RateLimitsUpdatedEvent: RealTimeEvent, Decodable {
   
   /// The unique ID of the server event.
   public let eventId: String
   /// The event type, must be rate_limits.updated.
   public let type: String = ServerEventType.rateLimitsUpdated.rawValue
   /// List of rate limit information.
   public let rateLimits: [RateLimit]
   
   enum CodingKeys: String, CodingKey {
      case eventId = "event_id"
      case type
      case rateLimits = "rate_limits"
   }
}

public struct RateLimit: Decodable {
   
   /// The name of the rate limit (requests, tokens).
   public let name: String
   /// The maximum allowed value for the rate limit.
   public let limit: Int
   /// The remaining value before the limit is reached.
   public let remaining: Int
   /// Seconds until the rate limit resets.
   public let resetSeconds: Double
   
   enum CodingKeys: String, CodingKey {
      case name
      case limit
      case remaining
      case resetSeconds = "reset_seconds"
   }
}

import Foundation
import AVFoundation

public class RealTimeAudioHandler: NSObject {
   // Audio Engine components
   private var audioEngine: AVAudioEngine?
   private var playerNode: AVAudioPlayerNode?
   private var timePitchNode: AVAudioUnitTimePitch?
   private var isRecording = false
   
   // Audio format settings - matching OpenAI's requirements
   private let sampleRate: Double = 24000.0  // Must be 24000 for OpenAI
   private let channels: Int = 1
   
   // Audio processing queue
   private var audioQueue: [[String: Any]] = []
   private var isProcessingQueue = false
   
   // Callback handlers
   private var onAudioData: ((Data) -> Void)?
   private var onRecordingStateChange: ((Bool) -> Void)?
   private var onError: ((Error) -> Void)?
   
   public override init() {
      super.init()
      setupAudioSession()
      setupAudioEngine()
   }
   
   private func setupAudioSession() {
      do {
         let audioSession = AVAudioSession.sharedInstance()
         try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
         try audioSession.setPreferredSampleRate(sampleRate)
         try audioSession.setPreferredIOBufferDuration(0.02) // 20ms buffer
         try audioSession.setActive(true)
      } catch {
         onError?(error)
      }
   }
   
   private func setupAudioEngine() {
      audioEngine = AVAudioEngine()
      playerNode = AVAudioPlayerNode()
      timePitchNode = AVAudioUnitTimePitch()
      
      guard let audioEngine = audioEngine,
            let playerNode = playerNode,
            let timePitchNode = timePitchNode else { return }
      
      // Setup components
      audioEngine.attach(playerNode)
      audioEngine.attach(timePitchNode)
      
      // Configure format
      let format = AVAudioFormat(
         commonFormat: .pcmFormatFloat32,
         sampleRate: sampleRate,
         channels: AVAudioChannelCount(channels),
         interleaved: false)!
      
      // Connect nodes
      audioEngine.connect(playerNode, to: timePitchNode, format: format)
      audioEngine.connect(timePitchNode, to: audioEngine.mainMixerNode, format: format)
      
      // Setup recording tap
      let input = audioEngine.inputNode
      let inputFormat = input.outputFormat(forBus: 0)
      
      input.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
         self?.processMicrophoneBuffer(buffer)
      }
      
      // Start engine
      do {
         try audioEngine.start()
         playerNode.play()
      } catch {
         onError?(error)
      }
   }
   
   private func processMicrophoneBuffer(_ buffer: AVAudioPCMBuffer) {
      guard isRecording,
            let pcmBuffer = convertToInt16Buffer(buffer) else { return }
      
      let channelData = pcmBuffer.int16ChannelData![0]
      let channelSize = Int(pcmBuffer.frameLength) * MemoryLayout<Int16>.size
      let data = Data(bytes: channelData, count: channelSize)
      onAudioData?(data)
   }
   
   private func convertToInt16Buffer(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
      let format = AVAudioFormat(
         commonFormat: .pcmFormatInt16,
         sampleRate: sampleRate,
         channels: AVAudioChannelCount(channels),
         interleaved: true)!
      
      guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                             frameCapacity: buffer.frameLength) else {
         return nil
      }
      
      pcmBuffer.frameLength = buffer.frameLength
      
      // Convert Float32 to Int16
      let floatData = buffer.floatChannelData![0]
      let int16Data = pcmBuffer.int16ChannelData![0]
      for frame in 0..<Int(buffer.frameLength) {
         int16Data[frame] = Int16(floatData[frame] * Float(Int16.max))
      }
      
      return pcmBuffer
   }
   
   public func playAudio(_ audioData: Data) {
      // Add to queue
      let event: [String: Any] = [
         "audio": audioData,
         "timestamp": Date().timeIntervalSince1970
      ]
      audioQueue.append(event)
      
      // Start processing if not already
      if !isProcessingQueue {
         processNextAudio()
      }
   }
   
   private func processNextAudio() {
      guard !audioQueue.isEmpty,
            let audioEngine = audioEngine,
            audioEngine.isRunning else {
         isProcessingQueue = false
         return
      }
      
      isProcessingQueue = true
      let event = audioQueue.removeFirst()
      
      guard let audioData = event["audio"] as? Data else {
         processNextAudio()
         return
      }
      
      let format = AVAudioFormat(
         commonFormat: .pcmFormatFloat32,
         sampleRate: sampleRate,
         channels: AVAudioChannelCount(channels),
         interleaved: false)!
      
      let frameCount = UInt32(audioData.count) / UInt32(channels * MemoryLayout<Int16>.size)
      guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
         processNextAudio()
         return
      }
      
      buffer.frameLength = frameCount
      let floatData = buffer.floatChannelData![0]
      
      // Convert Int16 to Float32 with amplification
      audioData.withUnsafeBytes { rawBufferPointer in
         guard let int16Pointer = rawBufferPointer.baseAddress?.assumingMemoryBound(to: Int16.self) else { return }
         
         let amplificationFactor: Float = 2.0
         for frame in 0..<Int(frameCount) {
            let sample = Float(int16Pointer[frame]) / Float(Int16.max)
            floatData[frame] = min(max(sample * amplificationFactor, -1.0), 1.0)
         }
      }
      
      playerNode?.scheduleBuffer(buffer) { [weak self] in
         self?.processNextAudio()
      }
   }
   
   public func requestPermissionAndSetup(completion: @escaping (Bool) -> Void) {
      AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
         DispatchQueue.main.async {
            completion(granted)
         }
      }
   }
   
   public func startRecording() {
      guard !isRecording else { return }
      isRecording = true
      onRecordingStateChange?(true)
   }
   
   public func stopRecording() {
      guard isRecording else { return }
      isRecording = false
      onRecordingStateChange?(false)
   }
   
   public func base64EncodedPCM16(_ data: Data) -> String {
      return data.base64EncodedString()
   }
   
   // MARK: - Callback Setters
   
   public func setAudioDataHandler(_ handler: @escaping (Data) -> Void) {
      self.onAudioData = handler
   }
   
   public func setRecordingStateHandler(_ handler: @escaping (Bool) -> Void) {
      self.onRecordingStateChange = handler
   }
   
   public func setErrorHandler(_ handler: @escaping (Error) -> Void) {
      self.onError = handler
   }
   
   public func cleanup() {
      if isRecording {
         stopRecording()
      }
      
      audioEngine?.inputNode.removeTap(onBus: 0)
      playerNode?.stop()
      audioEngine?.stop()
      
      audioEngine = nil
      playerNode = nil
      timePitchNode = nil
      
      do {
         try AVAudioSession.sharedInstance().setActive(false)
      } catch {
         onError?(error)
      }
   }
   
   deinit {
      cleanup()
   }
}

public class RealTimeSessionManager {
    private let service: OpenAIService
    private var webSocketClient: RealTimeWebSocketClient?
    public private(set) var currentSession: RealTimeSessionObject?
    
    // Callback handlers
    private var onAudioData: ((String, String, Int) -> Void)?
    private var onTranscriptData: ((String, String, Int, String) -> Void)?
    private var onError: ((Error) -> Void)?
    private var onSessionState: ((RealTimeSessionObject) -> Void)?
    
    public init(service: OpenAIService) {
        self.service = service
    }
    
    public func createSession(
        parameters: RealTimeSessionParameters,
        completion: @escaping (Result<RealTimeSessionObject, Error>) -> Void
    ) {
        Task {
            do {
                print("Creating realtime session...")
                let session = try await service.createRealtimeSession(parameters: parameters)
                self.currentSession = session
                
                guard let secret = session.clientSecret?.value else {
                    completion(.failure(SessionError.invalidResponse))
                    return
                }
                
                print("Session created with ID: \(session.id ?? "unknown"), initializing WebSocket...")
                // Create WebSocket client with the ephemeral token
                self.webSocketClient = RealTimeWebSocketClient(clientSecret: secret)
                self.setupWebSocketHandlers()
                
                // Connect with retry mechanism
                self.connectWithRetry(maxAttempts: 3) { success in
                    if success {
                        print("WebSocket connection successful")
                        completion(.success(session))
                    } else {
                        print("WebSocket connection failed after retries")
                        completion(.failure(SessionError.connectionFailed))
                    }
                }
            } catch {
                print("Session creation failed: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    private func connectWithRetry(maxAttempts: Int, attempt: Int = 1, completion: @escaping (Bool) -> Void) {
        print("Attempting WebSocket connection (attempt \(attempt)/\(maxAttempts))...")
        
        // Create a background task to manage the connection attempt
        let task = Task {
            let connectionSucceeded = await withCheckedContinuation { continuation in
                webSocketClient?.connect()
                
                // Check connection after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else {
                        continuation.resume(returning: false)
                        return
                    }
                    
                    if self.webSocketClient?.isConnected == true {
                        print("Connection attempt \(attempt) succeeded")
                        continuation.resume(returning: true)
                    } else {
                        print("Connection attempt \(attempt) failed")
                        continuation.resume(returning: false)
                    }
                }
            }
            
            return connectionSucceeded
        }
        
        // Handle the connection result
        Task {
            let succeeded = await task.value
            
            if succeeded {
                completion(true)
            } else if attempt < maxAttempts {
                print("Retrying connection after delay...")
                // Add a delay between retries
                try? await Task.sleep(nanoseconds: UInt64(1.0 * Double(NSEC_PER_SEC)))
                connectWithRetry(maxAttempts: maxAttempts, attempt: attempt + 1, completion: completion)
            } else {
                print("All connection attempts failed")
                completion(false)
            }
        }
    }
    
    private func setupWebSocketHandlers() {
        webSocketClient?.onError { [weak self] error in
            print("WebSocket error: \(error)")
            
            // If we get a connection error, try to reconnect
            if (error as NSError).domain == NSURLErrorDomain {
                print("Connection error detected, initiating reconnection...")
                self?.reconnect()
            } else {
                self?.onError?(error)
            }
        }
        
        webSocketClient?.onSessionCreated { [weak self] session in
            print("Session created event received")
            self?.currentSession = session
            self?.onSessionState?(session)
        }
        
        webSocketClient?.onSessionUpdated { [weak self] session in
            print("Session updated event received")
            self?.currentSession = session
            self?.onSessionState?(session)
        }
        
        webSocketClient?.onAudioDelta { [weak self] itemId, audioData, contentIndex in
            print("Audio delta received for item: \(itemId)")
            self?.onAudioData?(itemId, audioData, contentIndex)
        }
        
        webSocketClient?.onAudioTranscriptDelta { [weak self] itemId, _, contentIndex, delta in
            print("Transcript delta received for item: \(itemId)")
            self?.onTranscriptData?(itemId, delta, contentIndex, delta)
        }
    }
    
    private func reconnect() {
        print("Initiating reconnection sequence...")
        connectWithRetry(maxAttempts: 3) { [weak self] success in
            if !success {
                print("Reconnection failed after all attempts")
                self?.onError?(SessionError.connectionFailed)
            } else {
                print("Reconnection successful")
            }
        }
    }
    
    public func updateSession(
        parameters: RealTimeSessionParameters,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard validateConnection() else {
            completion(.failure(SessionError.notConnected))
            return
        }
        webSocketClient?.updateSession(parameters)
        completion(.success(()))
    }
    
    // MARK: - Audio Buffer Management
    
    public func appendAudioBuffer(_ audio: Data) {
        guard validateConnection() else { return }
        let base64Audio = audio.base64EncodedString()
        webSocketClient?.appendAudioBuffer(base64Audio)
    }
    
    public func commitAudioBuffer() {
        guard validateConnection() else { return }
        webSocketClient?.commitAudioBuffer()
    }
    
    public func clearAudioBuffer() {
        guard validateConnection() else { return }
        webSocketClient?.clearAudioBuffer()
    }
    
    public func cancelResponse() {
        guard validateConnection() else { return }
        webSocketClient?.cancelResponse()
    }
    
    // MARK: - Voice Settings
    
    public func updateVoice(_ voice: Voice, completion: @escaping (Result<Void, Error>) -> Void) {
        guard validateConnection() else {
            completion(.failure(SessionError.notConnected))
            return
        }
        
        let parameters = RealTimeSessionParameters(
         model: .custom(currentSession?.model ?? ""),
            voice: voicex
        )
        updateSession(parameters: parameters, completion: completion)
    }
    
    public func updateServerVAD(enabled: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard validateConnection() else {
            completion(.failure(SessionError.notConnected))
            return
        }
        
        let turnDetection: TurnDetection? = enabled ?
            TurnDetection(type: "server_vad") : nil
        
        let parameters = RealTimeSessionParameters(
         model: .custom(currentSession?.model ?? ""),
            turnDetection: turnDetection
        )
        updateSession(parameters: parameters, completion: completion)
    }
    
    // MARK: - Connection Management
    
    public func disconnect() {
        webSocketClient?.disconnect()
        webSocketClient = nil
        currentSession = nil
    }
    
    public var isConnected: Bool {
        return currentSession != nil && webSocketClient != nil
    }
    
    // MARK: - Event Handlers
    
    public func setAudioDeltaHandler(_ handler: @escaping (String, String, Int) -> Void) {
        self.onAudioData = handler
    }
    
    public func setAudioTranscriptDeltaHandler(_ handler: @escaping (String, String, Int, String) -> Void) {
        self.onTranscriptData = handler
    }
    
    public func setErrorHandler(_ handler: @escaping (Error) -> Void) {
        self.onError = handler
    }
    
    public func setSessionStateHandler(_ handler: @escaping (RealTimeSessionObject) -> Void) {
        self.onSessionState = handler
    }
    
    // MARK: - Helper Methods
    
    private func validateConnection() -> Bool {
        guard isConnected else {
            onError?(SessionError.notConnected)
            return false
        }
        return true
    }
}


// MARK: - Errors
public enum SessionError: LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case notConnected
    case httpError(statusCode: Int)
   case connectionFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .invalidResponse:
            return "Invalid response from server"
        case .notConnected:
            return "Not connected to session"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .connectionFailed:
           return "Connection Failed"
        }
    }
}

public class RealTimeWebSocketClient {
    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession
    private var clientSecret: String
   var isConnected: Bool = false
    private var messageQueue: [String] = []
    private var isProcessingQueue = false
    
    // Callback handlers
    private var onError: ((Error) -> Void)?
    private var onSessionCreated: ((RealTimeSessionObject) -> Void)?
    private var onSessionUpdated: ((RealTimeSessionObject) -> Void)?
    private var onMessageCreated: ((ConversationItem) -> Void)?
    private var onAudioDelta: ((String, String, Int) -> Void)?
    private var onAudioTranscriptDelta: ((String, String, Int, String) -> Void)?
    private var onResponseCancelled: (() -> Void)?
    
    public init(clientSecret: String) {
        self.clientSecret = clientSecret
        self.session = URLSession(configuration: .default)
    }
    
    public func connect() {
        guard let url = URL(string: "wss://api.openai.com/v1/realtime/ws") else {
            onError?(WebSocketError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(clientSecret)", forHTTPHeaderField: "Authorization")
        
        webSocket = session.webSocketTask(with: request)
        
        // Add ping timer to keep connection alive
        startPingTimer()
        
        webSocket?.resume()
        receiveMessage()
        
        // Wait brief moment to ensure connection is established
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isConnected = true
            self?.processMessageQueue()
        }
    }
    
    private var pingTimer: Timer?
    
    private func startPingTimer() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.ping()
        }
    }
    
    private func ping() {
        webSocket?.sendPing { [weak self] error in
            if let error = error {
                self?.onError?(error)
                self?.reconnect()
            }
        }
    }
    
    private func reconnect() {
        disconnect()
        connect()
    }
    
    public func disconnect() {
        isConnected = false
        pingTimer?.invalidate()
        pingTimer = nil
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        messageQueue.removeAll()
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleMessage(text)
                    }
                @unknown default:
                    break
                }
                
                // Continue receiving messages
                self.receiveMessage()
                
            case .failure(let error):
                self.onError?(error)
                self.disconnect()
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let eventType = json["type"] as? String else {
            return
        }
        
        switch eventType {
        case "session.created":
            handleSessionCreated(json)
        case "session.updated":
            handleSessionUpdated(json)
        case "conversation.item.created":
            handleConversationItemCreated(json)
        case "response.audio.delta":
            handleAudioDelta(json)
        case "response.audio_transcript.delta":
            handleAudioTranscriptDelta(json)
        case "response.cancelled":
            handleResponseCancelled(json)
        case "error":
            handleError(json)
        default:
            break
        }
    }
    
    private func handleSessionCreated(_ json: [String: Any]) {
        guard let sessionData = try? JSONSerialization.data(withJSONObject: json["session"] as Any),
              let session = try? JSONDecoder().decode(RealTimeSessionObject.self, from: sessionData) else {
            return
        }
        onSessionCreated?(session)
    }
    
    private func handleSessionUpdated(_ json: [String: Any]) {
        guard let sessionData = try? JSONSerialization.data(withJSONObject: json["session"] as Any),
              let session = try? JSONDecoder().decode(RealTimeSessionObject.self, from: sessionData) else {
            return
        }
        onSessionUpdated?(session)
    }
    
    private func handleAudioDelta(_ json: [String: Any]) {
        guard let itemId = json["item_id"] as? String,
              let contentIndex = json["content_index"] as? Int,
              let delta = json["delta"] as? String else {
            return
        }
        onAudioDelta?(itemId, delta, contentIndex)
    }
    
    private func handleAudioTranscriptDelta(_ json: [String: Any]) {
        guard let itemId = json["item_id"] as? String,
              let contentIndex = json["content_index"] as? Int,
              let delta = json["delta"] as? String else {
            return
        }
        onAudioTranscriptDelta?(itemId, delta, contentIndex, delta)
    }
    
    private func handleConversationItemCreated(_ json: [String: Any]) {
        guard let itemData = try? JSONSerialization.data(withJSONObject: json["item"] as Any),
              let item = try? JSONDecoder().decode(ConversationItem.self, from: itemData) else {
            return
        }
        onMessageCreated?(item)
    }
    
    private func handleResponseCancelled(_ json: [String: Any]) {
        onResponseCancelled?()
    }
    
    private func handleError(_ json: [String: Any]) {
        if let errorData = try? JSONSerialization.data(withJSONObject: json["error"] as Any),
           let error = try? JSONDecoder().decode(WebSocketError.self, from: errorData) {
            onError?(error)
        }
    }
    
    // MARK: - Message Sending
    
    public func updateSession(_ parameters: RealTimeSessionParameters) {
        let event: [String: Any] = [
            "type": "session.update",
            "session": parameters
        ]
        sendEvent(event)
    }
    
    public func appendAudioBuffer(_ audio: String) {
        let event: [String: Any] = [
            "type": "input_audio_buffer.append",
            "audio": audio
        ]
        sendEvent(event)
    }
    
    public func commitAudioBuffer() {
        let event: [String: Any] = [
            "type": "input_audio_buffer.commit"
        ]
        sendEvent(event)
    }
    
    public func clearAudioBuffer() {
        let event: [String: Any] = [
            "type": "input_audio_buffer.clear"
        ]
        sendEvent(event)
    }
    
    public func cancelResponse() {
        let event: [String: Any] = [
            "type": "response.cancel"
        ]
        sendEvent(event)
    }
    
    private func sendEvent(_ event: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: event),
              let string = String(data: data, encoding: .utf8) else {
            onError?(WebSocketError.encodingError)
            return
        }
        
        // Add to queue
        messageQueue.append(string)
        
        // Process queue if not already processing and connected
        if !isProcessingQueue && isConnected {
            processMessageQueue()
        }
    }
    
    private func processMessageQueue() {
        guard isConnected, !messageQueue.isEmpty, !isProcessingQueue,
              webSocket?.state == .running else {
            return
        }
        
        isProcessingQueue = true
        let message = messageQueue.removeFirst()
        
        webSocket?.send(.string(message)) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                // If we get a connection error, try to reconnect
                if (error as NSError).domain == NSURLErrorDomain {
                    self.messageQueue.insert(message, at: 0) // Put message back in queue
                    self.reconnect()
                } else {
                    self.onError?(error)
                }
            }
            
            self.isProcessingQueue = false
            
            // Process next message if any
            if !self.messageQueue.isEmpty {
                DispatchQueue.main.async {
                    self.processMessageQueue()
                }
            }
        }
    }
    
    // MARK: - Callback Setters
    
    public func onError(_ handler: @escaping (Error) -> Void) {
        self.onError = handler
    }
    
    public func onSessionCreated(_ handler: @escaping (RealTimeSessionObject) -> Void) {
        self.onSessionCreated = handler
    }
    
    public func onSessionUpdated(_ handler: @escaping (RealTimeSessionObject) -> Void) {
        self.onSessionUpdated = handler
    }
    
    public func onMessageCreated(_ handler: @escaping (ConversationItem) -> Void) {
        self.onMessageCreated = handler
    }
    
    public func onAudioDelta(_ handler: @escaping (String, String, Int) -> Void) {
        self.onAudioDelta = handler
    }
    
    public func onAudioTranscriptDelta(_ handler: @escaping (String, String, Int, String) -> Void) {
        self.onAudioTranscriptDelta = handler
    }
    
    public func onResponseCancelled(_ handler: @escaping () -> Void) {
        self.onResponseCancelled = handler
    }
}


// MARK: - WebSocket Error
public enum WebSocketError: LocalizedError, Decodable {
    case invalidURL
    case connectionFailed
    case disconnected
    case encodingError
    case decodingError
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .connectionFailed:
            return "Failed to connect to WebSocket"
        case .disconnected:
            return "WebSocket disconnected"
        case .encodingError:
            return "Failed to encode message"
        case .decodingError:
            return "Failed to decode message"
        }
    }
}

