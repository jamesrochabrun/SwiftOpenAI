//
//  Usage.swift
//
//
//  Created by James Rochabrun on 4/13/24.
//

import Foundation


/// Usage statistics related to the run. This value will be null if the run is not in a terminal state (i.e. in_progress, queued, etc.).
public struct Usage: Codable {
   
   /// Number of completion tokens used over the course of the run step.
   public let completionTokens: Int
   /// Number of prompt tokens used over the course of the run step.
   public let promptTokens: Int
   /// Total number of tokens used (prompt + completion).
   public let totalTokens: Int
   
   enum CodingKeys: String, CodingKey {
      case completionTokens = "completion_tokens"
      case promptTokens = "prompt_tokens"
      case totalTokens = "total_tokens"
   }
}
