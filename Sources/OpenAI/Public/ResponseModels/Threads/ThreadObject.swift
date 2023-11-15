//
//  ThreadObject.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// BETA
/// A [thread object](https://platform.openai.com/docs/api-reference/threads) represents a thread that contains [messages](https://platform.openai.com/docs/api-reference/messages).
public struct ThreadObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.
   public let object: String
   /// The Unix timestamp (in seconds) for when the thread was created.
   public let createdAt: Int
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
   
   enum CodingKeys: String, CodingKey {
       case id
       case object
       case createdAt = "created_at"
       case metadata
   }
}
