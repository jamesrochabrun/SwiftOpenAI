//
//  TurnDetection.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/3/25.
//

import Foundation

/// Used in Real time API
public struct TurnDetection: Codable {
   /// Type of turn detection, only `server_vad` is currently supported
   public let type: String?
   
   /// Activation threshold for VAD (0.0 to 1.0), defaults to 0.5.
   /// A higher threshold will require louder audio to activate the model,
   /// and thus might perform better in noisy environments.
   public let threshold: Double?
   
   /// Amount of audio to include before the VAD detected speech (in milliseconds).
   /// Defaults to 300ms.
   public let prefixPaddingMs: Int?
   
   /// Duration of silence to detect speech stop (in milliseconds).
   /// Defaults to 500ms. With shorter values the model will respond more quickly,
   /// but may jump in on short pauses from the user.
   public let silenceDurationMs: Int?
   
   /// Whether or not to automatically generate a response when VAD is enabled.
   /// Defaults to true
   public let createResponse: Bool?
   
   enum CodingKeys: String, CodingKey {
      case type
      case threshold
      case prefixPaddingMs = "prefix_padding_ms"
      case silenceDurationMs = "silence_duration_ms"
      case createResponse = "create_response"
   }
   
   public init(
      type: String? = nil,
      threshold: Double? = nil,
      prefixPaddingMs: Int? = nil,
      silenceDurationMs: Int? = nil,
      createResponse: Bool? = nil
   ) {
      self.type = type
      self.threshold = threshold
      self.prefixPaddingMs = prefixPaddingMs
      self.silenceDurationMs = silenceDurationMs
      self.createResponse = createResponse
   }
}
