//
//  Reasoning.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

/// Reasoning configuration for o-series models
public struct Reasoning: Codable {
  public init(effort: String? = nil, summary: Summary? = nil) {
    self.effort = effort
    self.summary = summary?.rawValue
  }

  public enum Summary: String {
    case auto
    case concise
    case detailed
  }

  /// Defaults to medium
  /// Constrains effort on reasoning for [reasoning models](https://platform.openai.com/docs/guides/reasoning). Currently supported values are low, medium, high and minimal.
  /// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
  /// The new minimal setting produces very few reasoning tokens for cases where you need the fastest possible time-to-first-token. We often see better performance when the model can produce a few tokens when needed versus none. The default is medium.
  ///
  /// The minimal setting performs especially well in coding and instruction following scenarios, adhering closely to given directions. However, it may require prompting to act more proactively. To improve the model's reasoning quality, even at minimal effort, encourage it to “think” or outline its steps before answering.
  public var effort: String?

  /// A summary of the reasoning performed by the model. This can be useful for debugging and understanding the model's reasoning process. One of auto, concise, or detailed.
  public var summary: String?

  enum CodingKeys: String, CodingKey {
    case effort
    case summary
  }

}
