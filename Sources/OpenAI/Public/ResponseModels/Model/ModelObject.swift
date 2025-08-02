//
//  ModelObject.swift
//
//
//  Created by James Rochabrun on 10/13/23.
//

import Foundation

/// Describes an OpenAI [model](https://platform.openai.com/docs/api-reference/models/object) offering that can be used with the API.
public struct ModelObject: Decodable {
  public struct Permission: Decodable {
    public let id: String?
    public let object: String?
    public let created: Int?
    public let allowCreateEngine: Bool?
    public let allowSampling: Bool?
    public let allowLogprobs: Bool?
    public let allowSearchIndices: Bool?
    public let allowView: Bool?
    public let allowFineTuning: Bool?
    public let organization: String?
    public let group: String?
    public let isBlocking: Bool?

    enum CodingKeys: String, CodingKey {
      case id
      case object
      case created
      case allowCreateEngine = "allow_create_engine"
      case allowSampling = "allow_sampling"
      case allowLogprobs = "allow_logprobs"
      case allowSearchIndices = "allow_search_indices"
      case allowView = "allow_view"
      case allowFineTuning = "allow_fine_tuning"
      case organization
      case group
      case isBlocking = "is_blocking"
    }
  }

  /// The model identifier, which can be referenced in the API endpoints.
  public let id: String
  /// The Unix timestamp (in seconds) when the model was created.
  public let created: Int?
  /// The object type, which is always "model".
  public let object: String
  /// The organization that owns the model.
  public let ownedBy: String
  /// An array representing the current permissions of a model. Each element in the array corresponds to a specific permission setting. If there are no permissions or if the data is unavailable, the array may be nil.
  public let permission: [Permission]?

  enum CodingKeys: String, CodingKey {
    case id
    case created
    case object
    case ownedBy = "owned_by"
    case permission
  }
}
