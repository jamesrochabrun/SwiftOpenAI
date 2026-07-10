//
//  OpenAIRealtimeFunctionCallOutput.swift
//  SwiftOpenAI
//

import Foundation

// MARK: - OpenAIRealtimeFunctionCallOutput

/// Sends a function call result back to a Realtime session.
public struct OpenAIRealtimeFunctionCallOutput: Encodable, Sendable {
  public init(callID: String, output: String) {
    item = .init(callID: callID, output: output)
  }

  public let type = "conversation.item.create"
  public let item: Item

  private enum CodingKeys: String, CodingKey {
    case item
    case type
  }
}

// MARK: OpenAIRealtimeFunctionCallOutput.Item

extension OpenAIRealtimeFunctionCallOutput {
  public struct Item: Encodable, Sendable {
    public init(callID: String, output: String) {
      self.callID = callID
      self.output = output
    }

    public let type = "function_call_output"
    public let callID: String
    public let output: String

    private enum CodingKeys: String, CodingKey {
      case callID = "call_id"
      case output
      case type
    }
  }
}
