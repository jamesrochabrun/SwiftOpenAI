//
//  File.swift
//  
//
//  Created by James Rochabrun on 4/27/24.
//

import Foundation

/// Vector stores are used to store files for use by the file_search tool.
///
/// Related guide: [File Search](https://platform.openai.com/docs/assistants/tools/file-search)
///
/// Create a [vector store](https://platform.openai.com/docs/api-reference/vector-stores).
public struct VectorStoreParameter: Encodable {
   
   /// A list of [File](https://platform.openai.com/docs/api-reference/files) IDs that the vector store should use. Useful for tools like file_search that can access files.
   let fileIDS: [String]?
   /// The name of the vector store.
   let name: String?
   /// The expiration policy for a vector store.
   let expiresAfter: ExpirationPolicy?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
   
   public init(
      fileIDS: [String]? = nil,
      name: String? = nil,
      expiresAfter: ExpirationPolicy? = nil,
      metadata: [String : String]? = nil)
   {
      self.fileIDS = fileIDS
      self.name = name
      self.expiresAfter = expiresAfter
      self.metadata = metadata
   }
}

