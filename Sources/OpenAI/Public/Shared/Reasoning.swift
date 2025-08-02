//
//  Reasoning.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

/// Reasoning configuration for o-series models
public struct Reasoning: Codable {
  public init(effort: String? = nil, generateSummary: String? = nil, summary: String? = nil) {
    self.effort = effort
    self.generateSummary = generateSummary
    self.summary = summary
  }

  /// Defaults to medium
  /// Constrains effort on reasoning for [reasoning models](https://platform.openai.com/docs/guides/reasoning). Currently supported values are low, medium, and high.
  /// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
  public var effort: String?

  /// computer_use_preview only
  /// A summary of the reasoning performed by the model.
  /// This can be useful for debugging and understanding the model's reasoning process. One of concise or detailed.
  public var generateSummary: String?

  /// Summary field used in response objects (nullable)
  public var summary: String?

  enum CodingKeys: String, CodingKey {
    case effort
    case generateSummary = "generate_summary"
    case summary
  }
}
