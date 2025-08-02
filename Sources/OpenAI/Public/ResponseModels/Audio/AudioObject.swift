//
//  AudioObject.swift
//
//
//  Created by James Rochabrun on 10/10/23.
//

import Foundation

/// The [audio](https://platform.openai.com/docs/api-reference/audio) response.
public struct AudioObject: Decodable {
  public struct Word: Decodable {
    /// The text content of the word.
    public let word: String
    /// Start time of the word in seconds.
    public let start: Double
    /// End time of the word in seconds.
    public let end: Double
  }

  public struct Segment: Decodable {
    /// Unique identifier of the segment.
    public let id: Int
    /// Seek offset of the segment.
    public let seek: Int
    /// Start time of the segment in seconds.
    public let start: Double
    ///  End time of the segment in seconds.
    public let end: Double
    /// Text content of the segment.
    public let text: String
    /// Array of token IDs for the text content.
    public let tokens: [Int]
    /// Temperature parameter used for generating the segment.
    public let temperature: Double
    /// Average logprob of the segment. If the value is lower than -1, consider the logprobs failed.
    public let avgLogprob: Double
    /// Compression ratio of the segment. If the value is greater than 2.4, consider the compression failed.
    public let compressionRatio: Double
    /// Probability of no speech in the segment. If the value is higher than 1.0 and the avg_logprob is below -1, consider this segment silent.
    public let noSpeechProb: Double

    enum CodingKeys: String, CodingKey {
      case id
      case seek
      case start
      case end
      case text
      case tokens
      case temperature
      case avgLogprob = "avg_logprob"
      case compressionRatio = "compression_ratio"
      case noSpeechProb = "no_speech_prob"
    }
  }

  /// The language of the input audio.
  public let language: String?
  /// The duration of the input audio.
  public let duration: String?
  /// The transcribed text if the request uses the `transcriptions` API, or the translated text if the request uses the `translations` endpoint.
  public let text: String
  /// Extracted words and their corresponding timestamps.
  public let words: [Word]?
  /// Segments of the transcribed text and their corresponding details.
  public let segments: [Segment]?
}
