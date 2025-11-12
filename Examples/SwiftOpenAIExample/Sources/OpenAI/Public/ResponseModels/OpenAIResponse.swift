//
//  OpenAIResponse.swift
//
//
//  Created by James Rochabrun on 10/13/23.
//

import Foundation

/// A generic structure for OpenAI API responses.
/// e.g:
/// ```json
/// {
/// "object": "list",
/// "data": [
///  {
///    "object": "embedding",
///    "embedding": [
///      0.0023064255,
///      -0.009327292,
///      .... (1536 floats total for ada-002)
///      -0.0028842222,
///    ],
///    "index": 0
///  }
/// ],
/// "model": "text-embedding-ada-002",
/// "usage": {
///  "prompt_tokens": 8,
///  "total_tokens": 8
/// }
/// }
public struct OpenAIResponse<T: Decodable>: Decodable {
  public struct Usage: Decodable {
    public let promptTokens: Int
    public let totalTokens: Int

    enum CodingKeys: String, CodingKey {
      case promptTokens = "prompt_tokens"
      case totalTokens = "total_tokens"
    }
  }

  public let object: String?
  public let data: [T]
  public let model: String?
  public let usage: Usage?
  public let hasMore: Bool?
  public let created: Int?
  public let firstID: String?
  public let lastID: String?

  enum CodingKeys: String, CodingKey {
    case object
    case data
    case model
    case usage
    case hasMore = "has_more"
    case created
    case firstID = "first_id"
    case lastID = "last_id"
  }
}
