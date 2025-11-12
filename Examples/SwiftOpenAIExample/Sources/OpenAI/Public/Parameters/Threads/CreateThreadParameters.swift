//
//  CreateThreadParameters.swift
//
//
//  Created by James Rochabrun on 11/16/23.
//

import Foundation

/// Create a [Thread](https://platform.openai.com/docs/api-reference/threads/createThread)
public struct CreateThreadParameters: Encodable {
  public init(
    messages: [MessageObject]? = nil,
    toolResources: ToolResources? = nil,
    metadata: [String: String]? = nil)
  {
    self.messages = messages
    self.toolResources = toolResources
    self.metadata = metadata
  }

  /// A list of [messages](https://platform.openai.com/docs/api-reference/messages) to start the thread with.
  public var messages: [MessageObject]?
  /// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
  public var toolResources: ToolResources?
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public var metadata: [String: String]?

  enum CodingKeys: String, CodingKey {
    case messages
    case toolResources = "tool_resources"
    case metadata
  }
}
