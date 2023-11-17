//
//  AssistantFileObject.swift
//
//
//  Created by James Rochabrun on 11/16/23.
//

import Foundation

/// BETA.
///
/// The [assistant file object.](https://platform.openai.com/docs/api-reference/assistants/file-object)
/// A list of [Files](https://platform.openai.com/docs/api-reference/files) attached to an assistant.
public struct AssistantFileObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   let id: String
   /// The object type, which is always assistant.file.
   let object: String
   /// The Unix timestamp (in seconds) for when the assistant file was created.
   let createdAt: Int
   /// The assistant ID that the file is attached to.
   let assistantID: String
   
   
   enum CodingKeys: String, CodingKey {
      case id
      case object
      case createdAt = "created_at"
      case assistantID = "assistant_id"
   }
   
   public struct DeletionStatus: Decodable {
      public let id: String
      public let object: String
      public let deleted: Bool
   }
}
