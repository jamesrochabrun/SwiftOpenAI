//
//  RealTimeSessionObject.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/3/25.
//

import Foundation

/// Ephemeral key details with a default TTL of one minute
public struct ClientSecret: Decodable {
    /// Ephemeral key usable in client environments to authenticate connections to the Realtime API. Use this in client-side environments rather than a standard API token, which should only be used server-side.
    public let value: String
    /// Timestamp for when the token expires. Currently, all tokens expire after one minute.
    public let expiresAt: Int
    
    enum CodingKeys: String, CodingKey {
        case value
        case expiresAt = "expires_at"
    }
}

/// https://platform.openai.com/docs/api-reference/realtime-sessions/session_object
public struct RealTimeSessionObject: Decodable {
   
    /// Ephemeral key configuration for authentication
    public let clientSecret: ClientSecret
    /// The set of modalities the model can respond with
    public let modalities: [String]?
    /// Default system instructions for model calls
    public let instructions: String?
    /// The voice model uses to respond
    public let voice: String?
    /// Format of input audio
    public let inputAudioFormat: String?
    /// Format of output audio
    public let outputAudioFormat: String?
    /// Configuration for input audio transcription
    public let inputAudioTranscription: AudioTranscription?
    /// Configuration for turn detection
    public let turnDetection: TurnDetection?
    /// Available tools/functions for the model
    public let tools: [Tool]?
    /// How the model chooses tools
    public let toolChoice: String?
    /// Sampling temperature for the model (0.6 to 1.2)
    public let temperature: Double?
    /// Maximum tokens for assistant response
    public let maxResponseOutputTokens: TokenLimit?
    
    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
        case modalities
        case instructions
        case voice
        case inputAudioFormat = "input_audio_format"
        case outputAudioFormat = "output_audio_format"
        case inputAudioTranscription = "input_audio_transcription"
        case turnDetection = "turn_detection"
        case tools
        case toolChoice = "tool_choice"
        case temperature
        case maxResponseOutputTokens = "max_response_output_tokens"
    }
}
