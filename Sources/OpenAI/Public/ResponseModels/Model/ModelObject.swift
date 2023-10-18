//
//  ModelObject.swift
//
//
//  Created by James Rochabrun on 10/13/23.
//

import Foundation

/// Describes an OpenAI [model](https://platform.openai.com/docs/api-reference/models/object) offering that can be used with the API.
public struct ModelObject: Decodable {
   
   /// The model identifier, which can be referenced in the API endpoints.
   let id: String
   /// The Unix timestamp (in seconds) when the model was created.
   let created: Int
   /// The object type, which is always "model".
   let object: String
   /// The organization that owns the model.
   let ownedBy: String
   /// An array representing the current permissions of a model. Each element in the array corresponds to a specific permission setting. If there are no permissions or if the data is unavailable, the array may be nil.
   let permission: [Permission]?
   
   enum CodingKeys: String, CodingKey {
      case id
      case created
      case object
      case ownedBy = "owned_by"
      case permission
   }
   
   struct Permission: Decodable {
       let id: String?
       let object: String?
       let created: Int?
       let allowCreateEngine: Bool?
       let allowSampling: Bool?
       let allowLogprobs: Bool?
       let allowSearchIndices: Bool?
       let allowView: Bool?
       let allowFineTuning: Bool?
       let organization: String?
       let group: String?
       let isBlocking: Bool?

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

   /// Represents the response from the [delete](https://platform.openai.com/docs/api-reference/models/delete) fine-tuning API
   public struct DeletionStatus: Decodable {
      
      let id: String
      let object: String
      let deleted: Bool
   }
}
