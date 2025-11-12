//
//  ModerationObject.swift
//
//
//  Created by James Rochabrun on 10/13/23.
//

import Foundation

/// The [moderation object](https://platform.openai.com/docs/api-reference/moderations/object). Represents policy compliance report by OpenAI's content moderation model against a given input.
public struct ModerationObject: Decodable {
  public struct Moderation: Decodable {
    public struct Category<T: Decodable>: Decodable {
      /// Content that expresses, incites, or promotes hate based on race, gender, ethnicity, religion, nationality, sexual orientation, disability status, or caste. Hateful content aimed at non-protected groups (e.g., chess players) is harrassment.
      public let hate: T
      /// Hateful content that also includes violence or serious harm towards the targeted group based on race, gender, ethnicity, religion, nationality, sexual orientation, disability status, or caste.
      public let hateThreatening: T
      /// Content that expresses, incites, or promotes harassing language towards any target.
      public let harassment: T
      /// Harassment content that also includes violence or serious harm towards any target.
      public let harassmentThreatening: T
      /// Content that promotes, encourages, or depicts acts of self-harm, such as suicide, cutting, and eating disorders.
      public let selfHarm: T
      /// Content where the speaker expresses that they are engaging or intend to engage in acts of self-harm, such as suicide, cutting, and eating disorders.
      public let selfHarmIntent: T
      /// Content that encourages performing acts of self-harm, such as suicide, cutting, and eating disorders, or that gives instructions or advice on how to commit such acts.
      public let selfHarmInstructions: T
      /// Content meant to arouse sexual excitement, such as the description of sexual activity, or that promotes sexual services (excluding sex education and wellness).
      public let sexual: T
      /// Sexual content that includes an individual who is under 18 years old.
      public let sexualMinors: T
      /// Content that depicts death, violence, or physical injury.
      public let violence: T
      /// Content that depicts death, violence, or physical injury in graphic detail.
      public let violenceGraphic: T

      enum CodingKeys: String, CodingKey {
        case hate
        case hateThreatening = "hate/threatening"
        case harassment
        case harassmentThreatening = "harassment/threatening"
        case selfHarm = "self-harm"
        case selfHarmIntent = "self-harm/intent"
        case selfHarmInstructions = "self-harm/instructions"
        case sexual
        case sexualMinors = "sexual/minors"
        case violence
        case violenceGraphic = "violence/graphic"
      }
    }

    /// Whether the content violates OpenAI's usage policies.
    public let flagged: Bool
    /// A list of the categories, and whether they are flagged or not.
    public let categories: Category<Bool>
    /// A list of the categories along with their scores as predicted by model.
    public let categoryScores: Category<Double>

    enum CodingKeys: String, CodingKey {
      case categories
      case categoryScores = "category_scores"
      case flagged
    }
  }

  /// The unique identifier for the moderation request.
  public let id: String
  /// The model used to generate the moderation results.
  public let model: String
  /// A list of moderation objects.
  public let results: [Moderation]

  public var isFlagged: Bool {
    results.map(\.flagged).contains(true)
  }
}
