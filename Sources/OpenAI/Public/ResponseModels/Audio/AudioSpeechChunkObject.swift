//
//  AudioSpeechChunkObject.swift
//
//
//  Created by SwiftOpenAI Community on 5/18/25.
//

import Foundation

/// Represents a single chunk of streaming audio data returned by the TTS API.
public struct AudioSpeechChunkObject {
  /// Raw audio data for this chunk.
  public let chunk: Data
  /// Indicates whether this is the final chunk in the stream.
  public let isLastChunk: Bool
  /// Optional sequential index for the chunk, useful for external bookkeeping.
  public let chunkIndex: Int?

  public init(
    chunk: Data,
    isLastChunk: Bool = false,
    chunkIndex: Int? = nil)
  {
    self.chunk = chunk
    self.isLastChunk = isLastChunk
    self.chunkIndex = chunkIndex
  }
}
