//
//  AgentSessionObject.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/1/26.
//

import Foundation

/// An agent session: a durable instance maintaining agent state across multiple interactions.
///
/// The Agents API is in public beta and OpenAI has not published the complete session object
/// schema, so the commonly observed fields are decoded as optionals and the full payload is
/// retained in `raw` for forward compatibility.
public struct AgentSessionObject: Decodable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    object = try container.decodeIfPresent(String.self, forKey: .object)
    status = try container.decodeIfPresent(String.self, forKey: .status)
    createdAt = try container.decodeIfPresent(Int.self, forKey: .createdAt)
    raw = try OpenAIJSONValue(from: decoder)
  }

  /// The session identifier, used for follow-up input, event streams, and deletion.
  public let id: String?
  /// The object type.
  public let object: String?
  /// The session status.
  public let status: String?
  /// The Unix timestamp (in seconds) for when the session was created.
  public let createdAt: Int?
  /// The complete payload as returned by the API.
  public let raw: OpenAIJSONValue

  private enum CodingKeys: String, CodingKey {
    case id
    case object
    case status
    case createdAt = "created_at"
  }
}
