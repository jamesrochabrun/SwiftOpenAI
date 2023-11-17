//
//  MessageFileObject.swift
//
//
//  Created by James Rochabrun on 11/16/23.
//

import Foundation

/// [A list of files attached to a message](https://platform.openai.com/docs/api-reference/messages/file-object)
public struct MessageFileObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.message.file.
   public let object: String
   /// The Unix timestamp (in seconds) for when the message file was created.
   public let createdAt: Int
   /// The ID of the [message](https://platform.openai.com/docs/api-reference/messages) that the [File](https://platform.openai.com/docs/api-reference/files) is attached to.
   public let messageID: String
   
   enum CodingKeys: String, CodingKey {
      case id
      case object
      case createdAt = "created_at"
      case messageID = "message_id"
   }
}
