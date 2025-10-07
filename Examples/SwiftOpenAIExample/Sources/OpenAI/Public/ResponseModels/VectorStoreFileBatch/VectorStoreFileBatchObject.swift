//
//  VectorStoreFileBatchObject.swift
//
//
//  Created by James Rochabrun on 4/29/24.
//

import Foundation

/// [The vector store files batch objectBeta](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/batch-object)
public struct VectorStoreFileBatchObject: Decodable {
  /// The identifier, which can be referenced in API endpoints.
  public let id: String
  /// The object type, which is always vector_store.file_batch.
  public let object: String
  /// The Unix timestamp (in seconds) for when the vector store files batch was created.
  public let createdAt: Int
  /// The ID of the [vector store](https://platform.openai.com/docs/api-reference/vector-stores/object) that the [File](https://platform.openai.com/docs/api-reference/files) is attached to.
  public let vectorStoreID: String
  /// The status of the vector store files batch, which can be either in_progress, completed, cancelled or failed.
  public let status: String

  public let fileCounts: FileCount

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case createdAt = "created_at"
    case vectorStoreID = "vector_store_id"
    case status
    case fileCounts = "file_counts"
  }
}
