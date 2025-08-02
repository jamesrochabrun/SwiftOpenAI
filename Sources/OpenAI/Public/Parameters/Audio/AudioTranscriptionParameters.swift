//
//  AudioTranscriptionParameters.swift
//
//
//  Created by James Rochabrun on 10/10/23.
//

import Foundation

// MARK: - AudioTranscriptionParameters

/// [Transcribes audio into the input language.](https://platform.openai.com/docs/api-reference/audio/createTranscription)
public struct AudioTranscriptionParameters: Encodable {
  public init(
    fileName: String,
    file: Data,
    model: Model = .whisperOne,
    prompt: String? = nil,
    responseFormat: String? = nil,
    temperature: Double? = nil,
    language: String? = nil,
    timestampGranularities: [String]? = nil)
  {
    self.fileName = fileName
    self.file = file
    self.model = model.value
    self.prompt = prompt
    self.responseFormat = responseFormat
    self.temperature = temperature
    self.language = language
    self.timestampGranularities = timestampGranularities
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
    case language
    case timestampGranularities = "timestamp_granularities[]"
  }

  /// The name of the file asset is not documented in OpenAI's official documentation; however, it is essential for constructing the multipart request.
  let fileName: String
  /// The audio file object (not file name) translate, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
  let file: Data
  /// ID of the model to use. Only whisper-1 is currently available.
  let model: String
  /// The language of the input audio. Supplying the input language in [ISO-639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) format will improve accuracy and latency.
  let language: String?
  /// An optional text to guide the model's style or continue a previous audio segment. The [prompt](https://platform.openai.com/docs/guides/speech-to-text/prompting) should match the audio language.
  let prompt: String?
  /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt. Defaults to json
  let responseFormat: String?
  /// The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use [log probability](https://en.wikipedia.org/wiki/Log_probability) to automatically increase the temperature until certain thresholds are hit. Defaults to 0
  let temperature: Double?
  /// Defaults to segment
  /// The timestamp granularities to populate for this transcription. response_format must be set verbose_json to use timestamp granularities. Either or both of these options are supported: word, or segment. Note: There is no additional latency for segment timestamps, but generating word timestamps incurs additional latency.
  let timestampGranularities: [String]?
}

// MARK: MultipartFormDataParameters

extension AudioTranscriptionParameters: MultipartFormDataParameters {
  public func encode(boundary: String) -> Data {
    MultipartFormDataBuilder(boundary: boundary, entries: [
      .file(paramName: Self.CodingKeys.file.rawValue, fileName: fileName, fileData: file, contentType: "audio/mpeg"),
      .string(paramName: Self.CodingKeys.model.rawValue, value: model),
      .string(paramName: Self.CodingKeys.language.rawValue, value: language),
      .string(paramName: Self.CodingKeys.prompt.rawValue, value: prompt),
      .string(paramName: Self.CodingKeys.responseFormat.rawValue, value: responseFormat),
      .string(paramName: Self.CodingKeys.temperature.rawValue, value: temperature),
      .string(paramName: Self.CodingKeys.timestampGranularities.rawValue, value: timestampGranularities),
    ]).build()
  }
}
