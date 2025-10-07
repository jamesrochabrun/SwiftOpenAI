//
//  MessageAttachment.swift
//
//
//  Created by James Rochabrun on 4/25/24.
//

import Foundation

/// Messages have attachments instead of file_ids. attachments are helpers that add files to the Thread’s tool_resources.
/// [V2](https://platform.openai.com/docs/assistants/migration/what-has-changed)
public struct MessageAttachment: Codable {
  let fileID: String
  let tools: [AssistantObject.Tool]

  enum CodingKeys: String, CodingKey {
    case fileID = "file_id"
    case tools
  }

  public init(fileID: String, tools: [AssistantObject.Tool]) {
    self.fileID = fileID
    self.tools = tools
  }
}
