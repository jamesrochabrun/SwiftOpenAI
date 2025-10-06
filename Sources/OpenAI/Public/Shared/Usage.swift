//
//  Usage.swift
//
//
//  Created by James Rochabrun on 4/13/24.
//

import Foundation

/// Represents token usage details including input tokens, output tokens, a breakdown of output tokens, and the total tokens used.
public struct Usage: Codable {
  /// Details about input tokens
  public struct InputTokensDetails: Codable {
    /// Number of cached tokens
    public let cachedTokens: Int?

    enum CodingKeys: String, CodingKey {
      case cachedTokens = "cached_tokens"
    }
  }

  /// A detailed breakdown of the output tokens.
  public struct OutputTokensDetails: Codable {
    /// The number of reasoning tokens.
    public let reasoningTokens: Int?

    enum CodingKeys: String, CodingKey {
      case reasoningTokens = "reasoning_tokens"
    }
  }

  /// Number of completion tokens used over the course of the run step.
  public let completionTokens: Int?

  /// Number of prompt tokens used over the course of the run step.
  public let promptTokens: Int?

  /// The number of input tokens.
  public let inputTokens: Int?

  /// Details about input tokens
  public let inputTokensDetails: InputTokensDetails?

  /// The number of output tokens.
  public let outputTokens: Int?

  /// A detailed breakdown of the output tokens.
  public let outputTokensDetails: OutputTokensDetails?

  /// The total number of tokens used.
  public let totalTokens: Int?

  enum CodingKeys: String, CodingKey {
    case completionTokens = "completion_tokens"
    case promptTokens = "prompt_tokens"
    case inputTokens = "input_tokens"
    case inputTokensDetails = "input_tokens_details"
    case outputTokens = "output_tokens"
    case outputTokensDetails = "output_tokens_details"
    case totalTokens = "total_tokens"
  }
}
