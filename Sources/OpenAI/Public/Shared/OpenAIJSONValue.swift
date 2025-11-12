//
//  OpenAIJSONValue.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

import Foundation

// MARK: - OpenAIJSONValue

/// Use OpenAIJSONValue when an Encodable or Decodable model has JSON members with types that are not known
/// ahead of time.
///
/// For example, AI providers often include 'tool use' functionality, where the request to the provider
/// contains a JSON schema defining the contract that the tool should conform to.  With OpenAIJSONValue, the
/// user may supply a schema that makes sense for them, unencumbered by strict codable compiler requirements.
///
/// Example usage:
///
///     let toolSchema: [String: OpenAIJSONValue] = [
///         "properties": [
///             "ticker": [
///                 "type": "string",
///                 "description": "The stock ticker symbol, e.g. AAPL for Apple Inc."
///             ]
///         ],
///         "required": ["ticker"]
///     ]
///
///     let encoder = JSONEncoder()
///     try encoder.encode(toolSchema) // Compiler is happy
///
nonisolated public enum OpenAIJSONValue: Codable, Sendable {
  case null(NSNull)
  case bool(Bool)
  case int(Int)
  case double(Double)
  case string(String)
  case array([OpenAIJSONValue])
  case object([String: OpenAIJSONValue])

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      self = .null(NSNull())
    } else if let bool = try? container.decode(Bool.self) {
      self = .bool(bool)
    } else if let int = try? container.decode(Int.self) {
      self = .int(int)
    } else if let double = try? container.decode(Double.self) {
      self = .double(double)
    } else if let string = try? container.decode(String.self) {
      self = .string(string)
    } else if let array = try? container.decode([OpenAIJSONValue].self) {
      self = .array(array)
    } else if let object = try? container.decode([String: OpenAIJSONValue].self) {
      self = .object(object)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Unexpected JSON value")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .null:
      try container.encodeNil()
    case .bool(let bool):
      try container.encode(bool)
    case .int(let int):
      try container.encode(int)
    case .double(let double):
      try container.encode(double)
    case .string(let string):
      try container.encode(string)
    case .array(let array):
      try container.encode(array)
    case .object(let object):
      try container.encode(object)
    }
  }

}

extension [String: OpenAIJSONValue] {
  nonisolated public var untypedDictionary: [String: any Sendable] {
    convertToUntypedDictionary(self)
  }
}

// MARK: - OpenAIJSONValue + ExpressibleByNilLiteral

extension OpenAIJSONValue: ExpressibleByNilLiteral {
  public init(nilLiteral _: ()) {
    self = .null(NSNull())
  }
}

// MARK: - OpenAIJSONValue + ExpressibleByBooleanLiteral

extension OpenAIJSONValue: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value)
  }
}

// MARK: - OpenAIJSONValue + ExpressibleByIntegerLiteral

extension OpenAIJSONValue: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self = .int(value)
  }
}

// MARK: - OpenAIJSONValue + ExpressibleByFloatLiteral

extension OpenAIJSONValue: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self = .double(value)
  }
}

// MARK: - OpenAIJSONValue + ExpressibleByStringLiteral

extension OpenAIJSONValue: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }
}

// MARK: - OpenAIJSONValue + ExpressibleByArrayLiteral

extension OpenAIJSONValue: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: OpenAIJSONValue...) {
    self = .array(elements)
  }
}

// MARK: - OpenAIJSONValue + ExpressibleByDictionaryLiteral

extension OpenAIJSONValue: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, OpenAIJSONValue)...) {
    self = .object(.init(uniqueKeysWithValues: elements))
  }
}

nonisolated private func convertToUntyped(_ input: OpenAIJSONValue) -> any Sendable {
  switch input {
  case .null:
    NSNull()
  case .bool(let bool):
    bool
  case .int(let int):
    int
  case .double(let double):
    double
  case .string(let string):
    string
  case .array(let array):
    array.map { convertToUntyped($0) }
  case .object(let dictionary):
    convertToUntypedDictionary(dictionary)
  }
}

nonisolated private func convertToUntypedDictionary(
  _ input: [String: OpenAIJSONValue])
  -> [String: any Sendable]
{
  input.mapValues { v in
    switch v {
    case .null:
      NSNull()
    case .bool(let bool):
      bool
    case .int(let int):
      int
    case .double(let double):
      double
    case .string(let string):
      string
    case .array(let array):
      array.map { convertToUntyped($0) }
    case .object(let dictionary):
      convertToUntypedDictionary(dictionary)
    }
  }
}
