//
//  GetInputItemsParameter.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

// MARK: GetInputItemsParameter

/// [Get input items for a response](https://platform.openai.com/docs/api-reference/responses/input-items)
public struct GetInputItemsParameter: Codable {
  /// Initialize a new GetInputItemsParameter
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

  /// Additional fields to include in the response.
  public var include: [String]?

  /// A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  public var limit: Int?

  /// The order to return the input items in. Default is desc. One of 'asc' or 'desc'.
  public var order: String?

  enum CodingKeys: String, CodingKey {
    case after
    case include
    case limit
    case order
  }
}
