//
//  OpenAIErrorResponse.swift
//
//
//  Created by James Rochabrun on 11/13/23.
//

import Foundation

// {
//  "error": {
//    "message": "Invalid parameter: messages with role 'tool' must be a response to a preceeding message with 'tool_calls'.",
//    "type": "invalid_request_error",
//    "param": "messages.[2].role",
//    "code": null
//  }
// }

public struct OpenAIErrorResponse: Decodable {
  public let error: Error

  public struct Error: Decodable {
    public let message: String?
    public let type: String?
    public let param: String?
    public let code: String?

    enum CodingKeys: String, CodingKey {
      case message, type, param, code
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      message = try container.decodeIfPresent(String.self, forKey: .message)
      type = try container.decodeIfPresent(String.self, forKey: .type)
      param = try container.decodeIfPresent(String.self, forKey: .param)

      // Some OpenAI-compatible providers (e.g. OpenRouter) provide literal response status codes in the "code" field (e.g., 403)
      // Try decoding "code" first as an Int, then fallback to a String
      if let intCode = try? container.decodeIfPresent(Int.self, forKey: .code) {
        code = String(intCode)
      } else if let stringCode = try? container.decodeIfPresent(String.self, forKey: .code) {
        code = stringCode
      } else {
        code = nil
      }
    }
  }
}