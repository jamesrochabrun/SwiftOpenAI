//
//  AudioSpeechObject.swift
//
//
//  Created by James Rochabrun on 11/14/23.
//

import Foundation

/// The [audio speech](https://platform.openai.com/docs/api-reference/audio/createSpeech) response.
public struct AudioSpeechObject: Decodable {
  /// The audio file content.
  public let output: Data
}
