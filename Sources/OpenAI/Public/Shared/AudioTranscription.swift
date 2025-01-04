//
//  AudioTranscription.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/3/25.
//

import Foundation

public struct AudioTranscription: Codable {
   
   /// The model to use for transcription, whisper-1 is the only currently supported model.
   public let model: String
   
   public init(model: String = "whisper-1") {
      self.model = model
   }
}
