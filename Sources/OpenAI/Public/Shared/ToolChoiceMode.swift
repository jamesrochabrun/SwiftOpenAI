//
//  ToolChoiceMode.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

// MARK: - ToolChoiceMode

/// Controls which (if any) tool is called by the model.
public enum ToolChoiceMode: Codable {
  /// Means the model will not call any tool and instead generates a message.
  case none

  /// Means the model can pick between generating a message or calling one or more tools.
  case auto

  /// Means the model must call one or more tools.
  case required

  /// Indicates that the model should use a built-in tool to generate a response.
  case hostedTool(HostedToolType)

  /// Use this option to force the model to call a specific function.
  case functionTool(FunctionTool)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let stringValue = try? container.decode(String.self) {
      switch stringValue {
      case "none":
        self = .none
      case "auto":
        self = .auto
      case "required":
        self = .required
      default:
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Unknown tool choice string value: \(stringValue)")
      }
    } else if let hostedTool = try? container.decode(HostedToolType.self) {
      self = .hostedTool(hostedTool)
    } else if let functionTool = try? container.decode(FunctionTool.self) {
      self = .functionTool(functionTool)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid tool choice value")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .none:
      try container.encode("none")
    case .auto:
      try container.encode("auto")
    case .required:
      try container.encode("required")
    case .hostedTool(let toolType):
      try container.encode(toolType)
    case .functionTool(let tool):
      try container.encode(tool)
    }
  }
}

// MARK: - HostedToolType

/// Hosted tool type enum
public enum HostedToolType: Codable {
  /// File search tool
  case fileSearch

  /// Web search tool
  case webSearchPreview

  /// Computer use tool
  case computerUsePreview

  /// Custom tool type for future compatibility
  case custom(String)

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    switch type {
    case "file_search":
      self = .fileSearch
    case "web_search_preview":
      self = .webSearchPreview
    case "computer_use_preview":
      self = .computerUsePreview
    default:
      self = .custom(type)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .fileSearch:
      try container.encode("file_search", forKey: .type)
    case .webSearchPreview:
      try container.encode("web_search_preview", forKey: .type)
    case .computerUsePreview:
      try container.encode("computer_use_preview", forKey: .type)
    case .custom(let value):
      try container.encode(value, forKey: .type)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case type
  }
}

// MARK: - FunctionTool

/// Function tool specification
public struct FunctionTool: Codable {
  /// The name of the function to call
  public var name: String

  /// For function calling, the type is always function
  public var type = "function"

  public init(name: String) {
    self.name = name
  }

  enum CodingKeys: String, CodingKey {
    case name
    case type
  }
}
