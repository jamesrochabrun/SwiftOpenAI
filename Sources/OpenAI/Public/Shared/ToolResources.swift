//
//  ToolResources.swift
//
//
//  Created by James Rochabrun on 4/25/24.
//

import Foundation

/// tool_resources
/// object or null
///
/// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
///
/// code_interpreter
/// properties
/// file_ids (array)
/// A list of file IDs made available to the `code_interpreter`` tool. There can be a maximum of 20 files associated with the tool.
///
/// file_search
/// properties
/// vector_store_id (array)
/// The ID of the vector store attached to this assistant. There can be a maximum of 1 vector store attached to the assistant.

// MARK: ToolResources

public struct ToolResources: Codable {
  // MARK: ToolResources+Initializer

  public init(
    fileSearch: FileSearch? = nil,
    codeInterpreter: CodeInterpreter? = nil)
  {
    self.fileSearch = fileSearch
    self.codeInterpreter = codeInterpreter
  }

  // MARK: FileSearch

  public struct FileSearch: Codable {
    public init(
      vectorStoreIds: [String]?,
      vectorStores: [VectorStore]?)
    {
      self.vectorStoreIds = vectorStoreIds
      self.vectorStores = vectorStores
    }

    public struct VectorStore: Codable {
      public init(
        fileIDS: [String]?,
        chunkingStrategy: ChunkingStrategy?,
        metadata: [String: String]?)
      {
        self.fileIDS = fileIDS
        self.chunkingStrategy = chunkingStrategy
        self.metadata = metadata
      }

      public enum ChunkingStrategy: Codable {
        case auto

        /// `maxChunkSizeTokens`: The maximum number of tokens in each chunk. The default value is 800. The minimum value is 100 and the maximum value is 4096.
        /// `chunk_overlap_tokens`: The number of tokens that overlap between chunks. The default value is 400.
        /// Note that the overlap must not exceed half of max_chunk_size_tokens.
        case `static`(maxChunkSizeTokens: Int, chunkOverlapTokens: Int)

        public init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          let type = try container.decode(String.self, forKey: .type)
          switch type {
          case "auto":
            self = .auto

          case "static":
            let maxChunkSizeTokens = try container.decode(Int.self, forKey: .maxChunkSizeTokens)
            let chunkOverlapTokens = try container.decode(Int.self, forKey: .chunkOverlapTokens)
            self = .static(maxChunkSizeTokens: maxChunkSizeTokens, chunkOverlapTokens: chunkOverlapTokens)

          default:
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.type, in: container, debugDescription: "Invalid type value")
          }
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          switch self {
          case .auto:
            try container.encode("auto", forKey: .type)
          case .static(let maxChunkSizeTokens, let chunkOverlapTokens):
            try container.encode("static", forKey: .type)
            try container.encode(maxChunkSizeTokens, forKey: .maxChunkSizeTokens)
            try container.encode(chunkOverlapTokens, forKey: .chunkOverlapTokens)
          }
        }

        enum CodingKeys: String, CodingKey {
          case type
          case maxChunkSizeTokens = "max_chunk_size_tokens"
          case chunkOverlapTokens = "chunk_overlap_tokens"
        }
      }

      /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs to add to the vector store. There can be a maximum of 10000 files in a vector store.
      public let fileIDS: [String]?
      /// The chunking strategy used to chunk the file(s). If not set, will use the auto strategy.
      public let chunkingStrategy: ChunkingStrategy?
      /// Set of 16 key-value pairs that can be attached to a vector store. This can be useful for storing additional information about the vector store in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
      public let metadata: [String: String]?

      enum CodingKeys: String, CodingKey {
        case fileIDS = "file_ids"
        case chunkingStrategy = "chunking_strategy"
        case metadata
      }
    }

    /// The [vector store](https://platform.openai.com/docs/api-reference/vector-stores/object) attached to this assistant. There can be a maximum of 1 vector store attached to the assistant.
    public let vectorStoreIds: [String]?

    /// A helper to create a [vector store](https://platform.openai.com/docs/api-reference/vector-stores/object) with file_ids and attach it to this assistant. There can be a maximum of 1 vector store attached to the assistant.
    public let vectorStores: [VectorStore]?

    enum CodingKeys: String, CodingKey {
      case vectorStoreIds = "vector_store_ids"
      case vectorStores = "vector_stores"
    }
  }

  // MARK: CodeInterpreter

  public struct CodeInterpreter: Codable {
    public let fileIds: [String]

    enum CodingKeys: String, CodingKey {
      case fileIds = "file_ids"
    }

    public init(fileIds: [String]) {
      self.fileIds = fileIds
    }
  }

  public let fileSearch: FileSearch?
  public let codeInterpreter: CodeInterpreter?

  enum CodingKeys: String, CodingKey {
    case fileSearch = "file_search"
    case codeInterpreter = "code_interpreter"
  }
}
