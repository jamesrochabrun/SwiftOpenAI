//
//  File.swift
//  
//
//  Created by James Rochabrun on 11/16/23.
//

import Foundation

/// [Create a message.](https://platform.openai.com/docs/api-reference/messages/createMessage)
public struct MessageParameter: Encodable {
   
   /// The role of the entity that is creating the message. Currently only user is supported.
   let role: String
   /// The content of the message.
   let content: String
   /// A list of [File](https://platform.openai.com/docs/api-reference/files) IDs that the message should use. There can be a maximum of 10 files attached to a message. Useful for tools like retrieval and code_interpreter that can access and use files. Defaults to []
   let fileIDS: [String]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
   
   enum CodingKeys: String, CodingKey {
      case role
      case content
      case fileIDS = "file_ids"
      case metadata
   }
   
   public init(
      role: String,
      content: String,
      fileIDS: [String]? = nil,
      metadata: [String : String]? = nil)
   {
      self.role = role
      self.content = content
      self.fileIDS = fileIDS
      self.metadata = metadata
   }
}
