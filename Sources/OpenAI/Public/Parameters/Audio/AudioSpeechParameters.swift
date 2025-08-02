//
//  AudioSpeechParameters.swift
//
//
//  Created by James Rochabrun on 11/14/23.
//

import Foundation

/// [Generates audio from the input text.](https://platform.openai.com/docs/api-reference/audio/createSpeech)
public struct AudioSpeechParameters: Encodable {
  public init(
    model: TTSModel,
    input: String,
    voice: Voice,
    responseFormat: ResponseFormat? = nil,
    speed: Double? = nil)
  {
    self.model = model.rawValue
    self.input = input
    self.voice = voice.rawValue
    self.responseFormat = responseFormat?.rawValue
    self.speed = speed
  }

  public enum TTSModel {
    case tts1
    case tts1HD
    case custom(model: String)

    var rawValue: String {
      switch self {
      case .tts1:
        "tts-1"
      case .tts1HD:
        "tts-1-hd"
      case .custom(let model):
        model
      }
    }
  }

  public enum Voice: String {
    case alloy
    case echo
    case fable
    case onyx
    case nova
    case shimmer
    case ash
    case coral
    case sage
  }

  public enum ResponseFormat: String {
    case mp3
    case opus
    case aac
    case flac
  }

  enum CodingKeys: String, CodingKey {
    case model
    case input
    case voice
    case responseFormat = "response_format"
    case speed
  }

  /// One of the available [TTS models](https://platform.openai.com/docs/models/tts): tts-1 or tts-1-hd
  let model: String
  /// The text to generate audio for. The maximum length is 4096 characters.
  let input: String
  /// The voice to use when generating the audio. Supported voices are alloy, echo, fable, onyx, nova, and shimmer. Previews of the voices are available in the [Text to speech guide.](https://platform.openai.com/docs/guides/text-to-speech/voice-options)
  let voice: String
  /// Defaults to mp3, The format to audio in. Supported formats are mp3, opus, aac, and flac.
  let responseFormat: String?
  /// Defaults to 1,  The speed of the generated audio. Select a value from 0.25 to 4.0. 1.0 is the default.
  let speed: Double?
}
