//
//  Prompt.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

// MARK: - Prompt

/// Reference to a prompt template and its variables. Learn more.
public struct Prompt: Codable {
  public init(id: String, variables: [String: PromptVariableValue]? = nil, version: String? = nil) {
    self.id = id
    self.variables = variables
    self.version = version
  }

  /// The unique identifier of the prompt template to use.
  public var id: String

  /// Optional map of values to substitute in for variables in your prompt. The substitution values can either be strings, or other Response input types like images or files.
  public var variables: [String: PromptVariableValue]?

  /// Optional version of the prompt template.
  public var version: String?

  enum CodingKeys: String, CodingKey {
    case id
    case variables
    case version
  }
}

// MARK: - PromptVariableValue

/// A value for a prompt variable that can be either a string or an input item (image, file, etc.)
public enum PromptVariableValue: Codable {
  /// String value
  case string(String)

  /// Input item value (image, file, etc.)
  case inputItem(InputItem)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let stringValue = try? container.decode(String.self) {
      self = .string(stringValue)
    } else if let inputItem = try? container.decode(InputItem.self) {
      self = .inputItem(inputItem)
    } else {
      throw DecodingError.typeMismatch(
        PromptVariableValue.self,
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Expected String or InputItem"))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let value):
      try container.encode(value)
    case .inputItem(let item):
      try container.encode(item)
    }
  }
}
