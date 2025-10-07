//
//  VectorStoreFileBatchParameter.swift
//
//
//  Created by James Rochabrun on 4/29/24.
//

import Foundation

/// [Create vector store file batchBeta](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/createBatch)
public struct VectorStoreFileBatchParameter: Encodable {
  /// A list of [File](https://platform.openai.com/docs/api-reference/files) IDs that the vector store should use. Useful for tools like file_search that can access files.
  public let fileIDS: [String]

  enum CodingKeys: String, CodingKey {
    case fileIDS = "file_ids"
  }

  public init(fileIDS: [String]) {
    self.fileIDS = fileIDS
  }
}
