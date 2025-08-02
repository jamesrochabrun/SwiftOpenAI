//
//  JSONSchema.swift
//
//
//  Created by James Rochabrun on 8/10/24.
//

import Foundation

// MARK: - JSONSchemaType

/// Supported schemas
///
/// Structured Outputs supports a subset of the JSON Schema language.
///
/// Supported types
///
/// The following types are supported for Structured Outputs:
///
/// String
/// Number
/// Boolean
/// Object
/// Array
/// Enum
/// anyOf
public enum JSONSchemaType: Codable, Equatable {
  case string
  case number
  case integer
  case boolean
  case object
  case array
  case null
  case union([JSONSchemaType])

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let string = try? container.decode(String.self) {
      switch string {
      case "string": self = .string
      case "number": self = .number
      case "integer": self = .integer
      case "boolean": self = .boolean
      case "object": self = .object
      case "array": self = .array
      case "null": self = .null
      default: throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown type: \(string)")
      }
    } else if let array = try? container.decode([String].self) {
      let types = try array.map { typeString -> JSONSchemaType in
        guard let type = JSONSchemaType(rawValue: typeString) else {
          throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown type in union: \(typeString)")
        }
        return type
      }
      self = .union(types)
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected a string or an array of strings")
    }
  }

  private init?(rawValue: String) {
    switch rawValue {
    case "string": self = .string
    case "number": self = .number
    case "integer": self = .integer
    case "boolean": self = .boolean
    case "object": self = .object
    case "array": self = .array
    case "null": self = .null
    default: return nil
    }
  }

  public static func optional(_ type: JSONSchemaType) -> JSONSchemaType {
    .union([type, .null])
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string: try container.encode("string")
    case .number: try container.encode("number")
    case .integer: try container.encode("integer")
    case .boolean: try container.encode("boolean")
    case .object: try container.encode("object")
    case .array: try container.encode("array")
    case .null: try container.encode("null")
    case .union(let types): try container.encode(types.map(\.rawValue))
    }
  }

  private var rawValue: String {
    switch self {
    case .string: "string"
    case .number: "number"
    case .integer: "integer"
    case .boolean: "boolean"
    case .object: "object"
    case .array: "array"
    case .null: "null"
    case .union: fatalError("Union type doesn't have a single raw value")
    }
  }
}

// MARK: - JSONSchema

public class JSONSchema: Codable, Equatable {
  public init(
    type: JSONSchemaType? = nil,
    description: String? = nil,
    properties: [String: JSONSchema]? = nil,
    items: JSONSchema? = nil,
    required: [String]? = nil,
    additionalProperties: Bool = false,
    enum: [String]? = nil,
    ref: String? = nil)
  {
    self.type = type
    self.description = description
    self.properties = properties
    self.items = items
    self.required = required
    self.additionalProperties = additionalProperties
    self.enum = `enum`
    self.ref = ref
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let ref = try? container.decode(String.self, forKey: .ref) {
      self.ref = ref
      type = nil
      description = nil
      properties = nil
      items = nil
      required = nil
      additionalProperties = false
      `enum` = nil
      return
    }

    type = try container.decodeIfPresent(JSONSchemaType.self, forKey: .type)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    properties = try container.decodeIfPresent([String: JSONSchema].self, forKey: .properties)
    items = try container.decodeIfPresent(JSONSchema.self, forKey: .items)
    required = try container.decodeIfPresent([String].self, forKey: .required)
    additionalProperties = try container.decodeIfPresent(Bool.self, forKey: .additionalProperties)
    `enum` = try container.decodeIfPresent([String].self, forKey: .enum)
    ref = nil
  }

  public let type: JSONSchemaType?
  public let description: String?
  public var properties: [String: JSONSchema]?
  public var items: JSONSchema?
  /// To use Structured Outputs, all fields or function parameters [must be specified as required.](https://platform.openai.com/docs/guides/structured-outputs/all-fields-must-be-required)
  /// Although all fields must be required (and the model will return a value for each parameter), it is possible to emulate an optional parameter by using a union type with null.
  public let required: [String]?
  /// Structured Outputs only supports generating specified keys / values, so we require developers to set additionalProperties: false to opt into Structured Outputs.
  public let additionalProperties: Bool?
  public let `enum`: [String]?
  public var ref: String?

  public static func ==(lhs: JSONSchema, rhs: JSONSchema) -> Bool {
    lhs.type == rhs.type &&
      lhs.description == rhs.description &&
      lhs.properties == rhs.properties &&
      lhs.items == rhs.items &&
      lhs.required == rhs.required &&
      lhs.additionalProperties == rhs.additionalProperties &&
      lhs.enum == rhs.enum &&
      lhs.ref == rhs.ref
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    if let ref {
      try container.encode(ref, forKey: .ref)
      return
    }

    try container.encodeIfPresent(type, forKey: .type)
    try container.encodeIfPresent(description, forKey: .description)
    try container.encodeIfPresent(properties, forKey: .properties)
    try container.encodeIfPresent(items, forKey: .items)
    try container.encodeIfPresent(required, forKey: .required)
    try container.encodeIfPresent(additionalProperties, forKey: .additionalProperties)
    try container.encodeIfPresent(`enum`, forKey: .enum)
  }

  private enum CodingKeys: String, CodingKey {
    case type, description, properties, items, required, additionalProperties, `enum`, ref = "$ref"
  }
}
