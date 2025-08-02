//
//  ResponseFormat.swift
//
//
//  Created by James Rochabrun on 4/13/24.
//

import Foundation

// MARK: - ResponseFormat

/// An object specifying the format that the model must output. Compatible with GPT-4o, GPT-4o mini, GPT-4 Turbo and all GPT-3.5 Turbo models newer than gpt-3.5-turbo-1106.
///
/// Setting to { "type": "json_schema", "json_schema": {...} } enables Structured Outputs which ensures the model will match your supplied JSON schema. Learn more in the [Structured Outputs guide.](https://platform.openai.com/docs/guides/structured-outputs)
///
/// Setting to { "type": "json_object" } enables JSON mode, which ensures the message the model generates is valid JSON.
///
/// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
///
/// [OpenAI announcement](https://openai.com/index/introducing-structured-outputs-in-the-api/)
///
/// [Documentation](https://platform.openai.com/docs/api-reference/chat/create#chat-create-response_format)
public enum ResponseFormat: Codable, Equatable {
  case text // The type of response format being defined: text.
  case jsonObject // The type of response format being defined: json_object.
  case jsonSchema(JSONSchemaResponseFormat) // The type of response format being defined: json_schema.
  case unknown

  public init(from decoder: Decoder) throws {
    // Attempt to decode the response format as a single string
    if
      let singleValueContainer = try? decoder.singleValueContainer(),
      let typeString = try? singleValueContainer.decode(String.self)
    {
      switch typeString {
      case "text":
        self = .text
      case "json_object":
        self = .jsonObject
      default:
        self = .unknown
      }
      return
    }

    // If it’s not a single string, decode it as a dictionary
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    switch type {
    case "text":
      self = .text

    case "json_object":
      self = .jsonObject

    case "json_schema":
      let jsonSchema = try container.decode(JSONSchemaResponseFormat.self, forKey: .jsonSchema)
      self = .jsonSchema(jsonSchema)

    default:
      self = .unknown
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .text:
      try container.encode("text", forKey: .type)

    case .jsonObject:
      try container.encode("json_object", forKey: .type)

    case .jsonSchema(let jsonSchema):
      try container.encode("json_schema", forKey: .type)
      try container.encode(jsonSchema, forKey: .jsonSchema)

    case .unknown:
      try container.encode("unknown", forKey: .type)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case jsonSchema = "json_schema"
  }
}

// MARK: - JSONSchemaResponseFormat

/// [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs/structured-outputs)
/// Specifically to be used for Response format with structured outputs.
public struct JSONSchemaResponseFormat: Codable, Equatable {
  let name: String
  let description: String?
  let strict: Bool
  let schema: JSONSchema

  public init(name: String, description: String? = nil, strict: Bool, schema: JSONSchema) {
    self.name = name
    self.description = description
    self.strict = strict
    self.schema = schema
  }
}
