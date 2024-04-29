//
//  File.swift
//  
//
//  Created by James Rochabrun on 4/28/24.
//

import Foundation

/// [Vector Store Files](https://platform.openai.com/docs/api-reference/vector-stores-files)
public struct VectorStoreFileParameter: Encodable {
   
   /// A [File](https://platform.openai.com/docs/api-reference/files) ID that the vector store should use. Useful for tools like file_search that can access files.
   let fileID: String
   
   enum CodingKeys: String, CodingKey {
      case fileID = "file_id"
   }
}
