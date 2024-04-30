//
//  VectorStoreFileObject.swift
//
//
//  Created by James Rochabrun on 4/28/24.
//

import Foundation

/// [The Vector store file object](https://platform.openai.com/docs/api-reference/vector-stores-files/file-object)
public struct VectorStoreFileObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   let id: String
   /// The object type, which is always vector_store.file.
   let object: String
   /// The total vector store usage in bytes. Note that this may be different from the original file size.
   let usageBytes: Int
   /// The Unix timestamp (in seconds) for when the vector store file was created.
   let createdAt: Int
   /// The ID of the [vector store](https://platform.openai.com/docs/api-reference/vector-stores/object) that the [File](https://platform.openai.com/docs/api-reference/files) is attached to.
   let vectorStoreID: String
   /// The status of the vector store file, which can be either in_progress, completed, cancelled, or failed. The status completed indicates that the vector store file is ready for use.
   let status: String
   /// The last error associated with this vector store file. Will be null if there are no errors.
   let lastError: LastError?
}
