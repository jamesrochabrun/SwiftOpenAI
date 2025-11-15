//
//  OpenAIRealtimeMessage.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

public enum OpenAIRealtimeMessage: Sendable {
  case error(String?)
  case sessionCreated // "session.created"
  case sessionUpdated // "session.updated"
  case responseCreated // "response.created"
  case responseAudioDelta(String) // "response.audio.delta"
  case inputAudioBufferSpeechStarted // "input_audio_buffer.speech_started"
  case responseFunctionCallArgumentsDone(String, String, String) // "response.function_call_arguments.done"

  // Add new cases for transcription
  case responseTranscriptDelta(String) // "response.audio_transcript.delta"
  case responseTranscriptDone(String) // "response.audio_transcript.done"
  case inputAudioBufferTranscript(String) // "input_audio_buffer.transcript"
  case inputAudioTranscriptionDelta(String) // "conversation.item.input_audio_transcription.delta"
  case inputAudioTranscriptionCompleted(String) // "conversation.item.input_audio_transcription.completed"

  // MCP (Model Context Protocol) messages
  case mcpListToolsInProgress // "mcp_list_tools.in_progress"
  case mcpListToolsCompleted([String: Any]) // "mcp_list_tools.completed" with tools data
  case mcpListToolsFailed(String?) // "mcp_list_tools.failed" with error details
}
