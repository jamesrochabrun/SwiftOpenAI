//
//  OpenAIRealtimeInputAudioBufferAppend.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/18/25.
//

import Foundation


public struct OpenAIRealtimeInputAudioBufferAppend: Encodable {
   
   public let type = "input_audio_buffer.append"
   
   /// base64 encoded PCM16 data
   public let audio: String
   
   public init(audio: String) {
      self.audio = audio
   }
}
