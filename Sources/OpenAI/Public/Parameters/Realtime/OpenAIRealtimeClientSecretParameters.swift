//
//  OpenAIRealtimeClientSecretParameters.swift
//  SwiftOpenAI
//

import Foundation

// MARK: - OpenAIRealtimeClientSecretParameters

/// Parameters for creating a Realtime client secret.
public struct OpenAIRealtimeClientSecretParameters: Encodable, Sendable {
  public init(
    expiresAfter: ExpiresAfter? = nil,
    session: OpenAIRealtimeSessionConfiguration? = nil)
  {
    self.expiresAfter = expiresAfter
    self.session = session
  }

  /// Configuration for when the generated client secret expires.
  public let expiresAfter: ExpiresAfter?

  /// Session configuration to bind to the generated client secret.
  public let session: OpenAIRealtimeSessionConfiguration?

  private enum CodingKeys: String, CodingKey {
    case expiresAfter = "expires_after"
    case session
  }
}

// MARK: OpenAIRealtimeClientSecretParameters.ExpiresAfter

extension OpenAIRealtimeClientSecretParameters {
  public struct ExpiresAfter: Encodable, Sendable {
    public init(anchor: Anchor = .createdAt, seconds: Int) {
      self.anchor = anchor
      self.seconds = seconds
    }

    public let anchor: Anchor
    public let seconds: Int

    public enum Anchor: String, Encodable, Sendable {
      case createdAt = "created_at"
    }
  }
}
