//
//  VectorStoreObject.swift
//
//
//  Created by James Rochabrun on 4/27/24.
//

import Foundation

public struct VectorStoreObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   let id: String
   /// The object type, which is always vector_store.
   let object: String
   /// The Unix timestamp (in seconds) for when the vector store was created.
   let createdAt: Int
   /// The name of the vector store.
   let name: String
   /// The total number of bytes used by the files in the vector store.
   let usageBytes: Int
   
   let fileCounts: FileCount
   /// The status of the vector store, which can be either expired, in_progress, or completed. A status of completed indicates that the vector store is ready for use.
   let status: String
   /// The expiration policy for a vector store.
   let expiresAfter: ExpirationPolicy?
   /// The Unix timestamp (in seconds) for when the vector store will expire.
   let expiresAt: Int?
   /// The Unix timestamp (in seconds) for when the vector store was last active.
   let lastActiveAt: Int?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]
   
   public struct FileCount: Decodable {
      
      /// The number of files that are currently being processed.
      let inProgress: Int
      /// The number of files that have been successfully processed.
      let completed: Int
      /// The number of files that have failed to process.
      let failed: Int
      /// The number of files that were cancelled.
      let cancelled: Int
      /// The total number of files.
      let total: Int
      
      enum CodingKeys: String, CodingKey {
         case inProgress = "in_progress"
         case completed
         case failed
         case cancelled
         case total
      }
   }
   
   enum CodingKeys: String, CodingKey {
      case id
      case object
      case createdAt = "created_at"
      case name
      case usageBytes = "usage_bytes"
      case fileCounts = "file_counts"
      case status
      case expiresAfter = "expires_after"
      case expiresAt = "expires_at"
      case lastActiveAt = "last_active_at"
      case metadata
   }
}
