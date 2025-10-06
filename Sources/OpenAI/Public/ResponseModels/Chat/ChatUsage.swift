//
//  ChatUsage.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/3/25.
//

import Foundation

// MARK: - ChatUsage

public struct ChatUsage: Decodable {
  /// Number of tokens in the prompt
  public let promptTokens: Int?
  /// Number of tokens in the generated completion
  public let completionTokens: Int?
  /// Total number of tokens used in the request (prompt + completion)
  public let totalTokens: Int?
  /// Detailed breakdown of prompt tokens
  public let promptTokensDetails: PromptTokenDetails?
  /// Detailed breakdown of completion tokens
  public let completionTokensDetails: CompletionTokenDetails?

  enum CodingKeys: String, CodingKey {
    case promptTokens = "prompt_tokens"
    case completionTokens = "completion_tokens"
    case totalTokens = "total_tokens"
    case promptTokensDetails = "prompt_tokens_details"
    case completionTokensDetails = "completion_tokens_details"
  }
}

// MARK: - PromptTokenDetails

public struct PromptTokenDetails: Decodable {
  /// Number of tokens retrieved from cache
  public let cachedTokens: Int?
  /// Number of tokens used for audio processing
  public let audioTokens: Int?

  enum CodingKeys: String, CodingKey {
    case cachedTokens = "cached_tokens"
    case audioTokens = "audio_tokens"
  }
}

// MARK: - CompletionTokenDetails

public struct CompletionTokenDetails: Decodable {
  /// Number of tokens used for reasoning
  public let reasoningTokens: Int?
  /// Number of tokens used for audio processing
  public let audioTokens: Int?
  /// Number of tokens in accepted predictions
  public let acceptedPredictionTokens: Int?
  /// Number of tokens in rejected predictions
  public let rejectedPredictionTokens: Int?

  enum CodingKeys: String, CodingKey {
    case reasoningTokens = "reasoning_tokens"
    case audioTokens = "audio_tokens"
    case acceptedPredictionTokens = "accepted_prediction_tokens"
    case rejectedPredictionTokens = "rejected_prediction_tokens"
  }
}
