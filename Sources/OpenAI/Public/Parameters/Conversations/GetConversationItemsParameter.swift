//
//  GetConversationItemsParameter.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/05/25.
//

import Foundation

// MARK: GetConversationItemsParameter

/// [List items for a conversation](https://platform.openai.com/docs/api-reference/conversations/list-items)
public struct GetConversationItemsParameter: Codable {
  /// Initialize a new GetConversationItemsParameter
  public init(
    after: String? = nil,
    include: [ResponseInclude]? = nil,
    limit: Int? = nil,
    order: String? = nil)
  {
    self.after = after
    self.include = include?.map(\.rawValue)
    self.limit = limit
    self.order = order
  }

  /// An item ID to list items after, used in pagination.
  public var after: String?

  /// Specify additional output data to include in the model response.
  /// Supported values: web_search_call.action.sources, code_interpreter_call.outputs,
  /// computer_call_output.output.image_url, file_search_call.results,
  /// message.input_image.image_url, message.output_text.logprobs, reasoning.encrypted_content
  public var include: [String]?

  /// A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  public var limit: Int?

  /// The order to return the items in. Default is desc. One of 'asc' or 'desc'.
  public var order: String?

  enum CodingKeys: String, CodingKey {
    case after
    case include
    case limit
    case order
  }
}
