//
//  ToolChoice.swift
//
//
//  Created by James Rochabrun on 4/13/24.
//

import Foundation

/// string `none` means the model will not call a function and instead generates a message.
///
/// `auto` means the model can pick between generating a message or calling a function.
///
/// `object` Specifies a tool the model should use. Use to force the model to call a specific function. The type of the tool. Currently, only` function` is supported. `{"type: "function", "function": {"name": "my_function"}}`
///
/// `required` To force the model to always call one or more functions, you can set tool_choice: "required". The model will then select which function(s) to call.
///
/// [Function Calling](https://platform.openai.com/docs/guides/function-calling)
public enum ToolChoice: Codable, Equatable {
  case none
  case auto
  case required
  case function(type: String = "function", name: String)

  public init(from decoder: Decoder) throws {
    // Handle the 'function' case:
    if
      let container = try? decoder.container(keyedBy: CodingKeys.self),
      let functionContainer = try? container.nestedContainer(keyedBy: FunctionCodingKeys.self, forKey: .function)
    {
      let name = try functionContainer.decode(String.self, forKey: .name)
      self = .function(type: "function", name: name)
      return
    }

    // Handle the 'auto' and 'none' cases
    let container = try decoder.singleValueContainer()
    switch try container.decode(String.self) {
    case "none":
      self = .none
    case "auto":
      self = .auto
    case "required":
      self = .required
    default:
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid tool_choice structure")
    }
  }

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .none:
      var container = encoder.singleValueContainer()
      try container.encode(CodingKeys.none.rawValue)

    case .auto:
      var container = encoder.singleValueContainer()
      try container.encode(CodingKeys.auto.rawValue)

    case .required:
      var container = encoder.singleValueContainer()
      try container.encode(CodingKeys.required.rawValue)

    case .function(let type, let name):
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(type, forKey: .type)
      var functionContainer = container.nestedContainer(keyedBy: FunctionCodingKeys.self, forKey: .function)
      try functionContainer.encode(name, forKey: .name)
    }
  }

  enum CodingKeys: String, CodingKey {
    case none
    case auto
    case required
    case type
    case function
  }

  enum FunctionCodingKeys: String, CodingKey {
    case name
  }
}
