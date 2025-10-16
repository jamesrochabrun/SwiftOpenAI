//
//  GetConversationItemParameter.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/05/25.
//

import Foundation

// MARK: GetConversationItemParameter

/// [Retrieve an item from a conversation](https://platform.openai.com/docs/api-reference/conversations/retrieve-item)
public struct GetConversationItemParameter: Codable {
  /// Initialize a new GetConversationItemParameter
  public init(
    include: [ResponseInclude]? = nil)
  {
    self.include = include?.map(\.rawValue)
  }

  /// Additional fields to include in the response.
  /// Supported values: web_search_call.action.sources, code_interpreter_call.outputs,
  /// computer_call_output.output.image_url, file_search_call.results,
  /// message.input_image.image_url, message.output_text.logprobs, reasoning.encrypted_content
  public var include: [String]?

  enum CodingKeys: String, CodingKey {
    case include
  }
}
