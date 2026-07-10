//
//  OpenAIRealtimeMessage.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

public enum OpenAIRealtimeMessage: Sendable {
  case error(String?)
  case disconnected(String?)
  case sessionCreated // "session.created"
  case sessionUpdated // "session.updated"
  case responseCreated(responseID: String?) // "response.created"
  case responseAudioDelta(itemID: String?, responseID: String?, delta: String) // "response.output_audio.delta"
  case responseAudioDone(itemID: String?, responseID: String?) // "response.output_audio.done"
  case inputAudioBufferSpeechStarted(itemID: String?, audioStartMS: Int?) // "input_audio_buffer.speech_started"
  case responseFunctionCallArgumentsDelta(
    delta: String,
    callID: String?,
    itemID: String?,
    responseID: String?) // "response.function_call_arguments.delta"
  case responseFunctionCallArgumentsDone(
    name: String,
    arguments: String,
    callID: String,
    itemID: String?,
    responseID: String?) // "response.function_call_arguments.done"

  // Add new cases for transcription
  case responseTranscriptDelta(itemID: String?, responseID: String?, delta: String) // "response.output_audio_transcript.delta"
  case responseTranscriptDone(itemID: String?, responseID: String?, transcript: String) // "response.output_audio_transcript.done"
  case inputAudioBufferTranscript(String) // "input_audio_buffer.transcript"
  case inputAudioTranscriptionDelta(itemID: String?, delta: String) // "conversation.item.input_audio_transcription.delta"
  case inputAudioTranscriptionCompleted(
    itemID: String?,
    transcript: String) // "conversation.item.input_audio_transcription.completed"

  // MCP (Model Context Protocol) messages
  case mcpListToolsInProgress // "mcp_list_tools.in_progress"
  case mcpListToolsCompleted([String: OpenAIJSONValue]) // "mcp_list_tools.completed" with tools data
  case mcpListToolsFailed(String?) // "mcp_list_tools.failed" with error details
  /// Response completion with potential errors
  case responseDone(responseID: String?, status: String, statusDetails: [String: OpenAIJSONValue]?) // "response.done"

  // Text streaming (for text-only responses)
  case responseTextDelta(itemID: String?, responseID: String?, delta: String) // "response.output_text.delta"
  case responseTextDone(itemID: String?, responseID: String?, text: String) // "response.output_text.done"

  // Output item lifecycle
  case responseOutputItemAdded(itemId: String, type: String) // "response.output_item.added"
  case responseOutputItemDone(itemId: String, type: String, content: [[String: OpenAIJSONValue]]?) // "response.output_item.done"

  // Content part lifecycle
  case responseContentPartAdded(type: String) // "response.content_part.added"
  case responseContentPartDone(type: String, text: String?) // "response.content_part.done"

  // MCP response
  case responseMcpCallCompleted(eventId: String?, itemId: String?, outputIndex: Int?)
  case responseMcpCallInProgress
  case responseMcpCallArgumentsDone(arguments: String, itemId: String?, outputIndex: Int?, responseId: String?)
  case mcpApprovalRequest(id: String, name: String, arguments: String, serverLabel: String)

  /// Conversation item
  case conversationItemCreated(
    itemID: String,
    type: String,
    role: String?,
    previousItemID: String?) // "conversation.item.created"
  case conversationItemDone(
    itemID: String,
    type: String,
    role: String?,
    previousItemID: String?,
    content: [[String: OpenAIJSONValue]]?) // "conversation.item.done"
  case rateLimitsUpdated // "rate_limits.updated"
}
