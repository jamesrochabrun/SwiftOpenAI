//
//  OpenAIRealtimeInputAudioBufferSpeechStarted.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

import Foundation

/// This is sent from server to client when vad detects that speech started.
nonisolated public struct OpenAIRealtimeInputAudioBufferSpeechStarted: Decodable, Sendable {
    public let type = "input_audio_buffer.speech_started"
    public let audioStartMs: Int

    public init(audioStartMs: Int) {
        self.audioStartMs = audioStartMs
    }

    private enum CodingKeys: String, CodingKey {
        case audioStartMs = "audio_start_ms"
    }
}
