//
//  VectorStoreObject.swift
//
//
//  Created by James Rochabrun on 4/27/24.
//

import Foundation

public struct VectorStoreObject: Decodable {
  /// The identifier, which can be referenced in API endpoints.
  public let id: String
  /// The object type, which is always vector_store.
  public let object: String
  /// The Unix timestamp (in seconds) for when the vector store was created.
  public let createdAt: Int
  /// The name of the vector store.
  public let name: String
  /// The total number of bytes used by the files in the vector store.
  public let usageBytes: Int

  public let fileCounts: FileCount
  /// The status of the vector store, which can be either expired, in_progress, or completed. A status of completed indicates that the vector store is ready for use.
  public let status: String
  /// The expiration policy for a vector store.
  public let expiresAfter: ExpirationPolicy?
  /// The Unix timestamp (in seconds) for when the vector store will expire.
  public let expiresAt: Int?
  /// The Unix timestamp (in seconds) for when the vector store was last active.
  public let lastActiveAt: Int?
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public let metadata: [String: String]

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
