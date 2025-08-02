//
//  AudioTranslationParameters.swift
//
//
//  Created by James Rochabrun on 10/10/23.
//

import Foundation

// MARK: - AudioTranslationParameters

/// Translates audio into English. [Create translation](https://platform.openai.com/docs/api-reference/audio/createTranslation).
public struct AudioTranslationParameters: Encodable {
  public init(
    fileName: String,
    file: Data,
    model: Model = .whisperOne,
    prompt: String? = nil,
    responseFormat: String? = nil,
    temperature: Double? = nil)
  {
    self.fileName = fileName
    self.file = file
    self.model = model.value
    self.prompt = prompt
    self.responseFormat = responseFormat
    self.temperature = temperature
  }

  public enum Model {
    case whisperOne
    case custom(model: String)

    var value: String {
      switch self {
      case .whisperOne:
        "whisper-1"
      case .custom(let model):
        model
      }
    }
  }

  enum CodingKeys: String, CodingKey {
    case file
    case model
    case prompt
    case responseFormat = "response_format"
    case temperature
  }

  /// The name of the file asset is not documented in OpenAI's official documentation; however, it is essential for constructing the multipart request.
  let fileName: String
  /// The audio file object (not file name) translate, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
  let file: Data
  /// ID of the model to use. Only whisper-1 is currently available.
  let model: String
  /// An optional text to guide the model's style or continue a previous audio segment. The [prompt](https://platform.openai.com/docs/guides/speech-to-text/prompting) should match the audio language.
  let prompt: String?
  /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt. Defaults to json
  let responseFormat: String?
  /// The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use [log probability](https://en.wikipedia.org/wiki/Log_probability) to automatically increase the temperature until certain thresholds are hit. Defaults to 0
  let temperature: Double?
}

// MARK: MultipartFormDataParameters

extension AudioTranslationParameters: MultipartFormDataParameters {
  public func encode(boundary: String) -> Data {
    MultipartFormDataBuilder(boundary: boundary, entries: [
      .file(paramName: Self.CodingKeys.file.rawValue, fileName: fileName, fileData: file, contentType: "audio/mpeg"),
      .string(paramName: Self.CodingKeys.model.rawValue, value: model),
      .string(paramName: Self.CodingKeys.prompt.rawValue, value: prompt),
      .string(paramName: Self.CodingKeys.responseFormat.rawValue, value: responseFormat),
      .string(paramName: Self.CodingKeys.temperature.rawValue, value: temperature),
    ]).build()
  }
}
