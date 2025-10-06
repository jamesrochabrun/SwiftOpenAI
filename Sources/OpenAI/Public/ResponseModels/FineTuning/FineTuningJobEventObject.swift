//
//  FineTuningJobEventObject.swift
//
//
//  Created by James Rochabrun on 10/17/23.
//

import Foundation

/// [Fine-tuning job event object](https://platform.openai.com/docs/api-reference/fine-tuning/event-object)
public struct FineTuningJobEventObject: Decodable {
  public struct Data: Decodable {
    public let step: Int
    public let trainLoss: Double
    public let trainMeanTokenAccuracy: Double

    enum CodingKeys: String, CodingKey {
      case step
      case trainLoss = "train_loss"
      case trainMeanTokenAccuracy = "train_mean_token_accuracy"
    }
  }

  public let id: String

  public let createdAt: Int

  public let level: String

  public let message: String

  public let object: String

  public let type: String?

  public let data: Data?

  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case level
    case message
    case object
    case type
    case data
  }
}
