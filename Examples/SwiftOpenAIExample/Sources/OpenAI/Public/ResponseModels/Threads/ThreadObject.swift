//
//  ThreadObject.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// BETA
/// A [thread object](https://platform.openai.com/docs/api-reference/threads) represents a thread that contains [messages](https://platform.openai.com/docs/api-reference/messages).
public struct ThreadObject: Decodable {
  public init(
    id: String,
    object: String,
    createdAt: Int,
    metadata: [String: String])
  {
    self.id = id
    self.object = object
    self.createdAt = createdAt
    self.metadata = metadata
  }

  /// The identifier, which can be referenced in API endpoints.
  public let id: String
  /// The object type, which is always thread.
  public let object: String
  /// The Unix timestamp (in seconds) for when the thread was created.
  public let createdAt: Int
  /// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
  public var toolResources: ToolResources?
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public let metadata: [String: String]

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case createdAt = "created_at"
    case toolResources = "tool_resources"
    case metadata
  }
}
