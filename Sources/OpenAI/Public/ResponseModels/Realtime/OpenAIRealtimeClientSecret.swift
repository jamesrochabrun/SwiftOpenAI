//
//  OpenAIRealtimeClientSecret.swift
//  SwiftOpenAI
//

import Foundation

// MARK: - OpenAIRealtimeClientSecret

public struct OpenAIRealtimeClientSecret: Decodable, Sendable {
  /// The generated ephemeral credential value.
  public let value: String

  /// Expiration timestamp in seconds since epoch.
  public let expiresAt: Int?

  /// The created session object returned by OpenAI.
  public let session: OpenAIJSONValue?

  private enum CodingKeys: String, CodingKey {
    case value
    case expiresAt = "expires_at"
    case session
  }
}
