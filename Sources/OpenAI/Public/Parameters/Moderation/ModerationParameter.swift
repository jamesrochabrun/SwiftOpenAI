//
//  ModerationParameter.swift
//
//
//  Created by James Rochabrun on 10/13/23.
//

import Foundation

/// [Classifies if text violates OpenAI's Content Policy.](https://platform.openai.com/docs/api-reference/moderations/create)
public struct ModerationParameter<Input: Encodable>: Encodable {
  /// The input text to classify, string or array.
  let input: Input
  /// Two content moderations models are available: text-moderation-stable and text-moderation-latest.
  /// The default is text-moderation-latest which will be automatically upgraded over time. This ensures you are always using our most accurate model. If you use text-moderation-stable, we will provide advanced notice before updating the model. Accuracy of text-moderation-stable may be slightly lower than for text-moderation-latest.
  let model: String?

  public enum Model: String {
    case stable = "text-moderation-stable"
    case latest = "text-moderation-latest"
  }

  public init(
    input: Input,
    model: Model? = nil)
  {
    self.input = input
    self.model = model?.rawValue
  }
}
