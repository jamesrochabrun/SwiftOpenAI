//
//  FineTuningJobEventObject.swift
//
//
//  Created by James Rochabrun on 10/17/23.
//

import Foundation

/// [Fine-tuning job event object](https://platform.openai.com/docs/api-reference/fine-tuning/event-object)
struct FineTuningJobEventObject: Decodable {
   
   let id: String
   
   let createdAt: Int
   
   let level: String
   
   let message: String
   
   let object: String
   
   let type: String?
   
   let data: Data?
   
   struct Data: Decodable {
      let step: Int
      let trainLoss: Double
      let trainMeanTokenAccuracy: Double
      
      enum CodingKeys: String, CodingKey {
         case step
         case trainLoss = "train_loss"
         case trainMeanTokenAccuracy = "train_mean_token_accuracy"
      }
   }
   
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
