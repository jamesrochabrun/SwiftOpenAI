//
//  AgentSessionItem.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/1/26.
//

import Foundation

/// An item produced during an agent session: saved messages, tool call responses,
/// and activity items such as `computer_use_call`.
///
/// The Agents API is in public beta and OpenAI has not published the complete item
/// schemas, so the commonly observed fields are decoded as optionals and the full
/// payload is retained in `raw` for forward compatibility.
public struct AgentSessionItem: Decodable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    turnId = try container.decodeIfPresent(String.self, forKey: .turnId)
    title = try container.decodeIfPresent(String.self, forKey: .title)
    status = try container.decodeIfPresent(String.self, forKey: .status)
    raw = try OpenAIJSONValue(from: decoder)
  }

  /// The item identifier.
  public let id: String?
  /// The item type, e.g. `computer_use_call`.
  public let type: String?
  /// The identifier of the turn that produced this item.
  public let turnId: String?
  /// A human-readable title for activity items.
  public let title: String?
  /// The item status.
  public let status: String?
  /// The complete payload as returned by the API. For `computer_use_call` items the
  /// `output` member holds base64-encoded JPEG screenshots when screenshots are enabled.
  public let raw: OpenAIJSONValue

  private enum CodingKeys: String, CodingKey {
    case id
    case type
    case turnId = "turn_id"
    case title
    case status
  }
}
