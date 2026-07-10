//
//  OpenAIRealtimeResponseCreate.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

import Foundation

// MARK: - OpenAIRealtimeResponseCreate

/// https://platform.openai.com/docs/api-reference/realtime-client-events/response
public struct OpenAIRealtimeResponseCreate: Encodable {
  public let type = "response.create"
  public let response: Response?

  public init(response: Response? = nil) {
    self.response = response
  }
}

// MARK: OpenAIRealtimeResponseCreate.Response

extension OpenAIRealtimeResponseCreate {
  public struct Response: Encodable {
    public init(
      instructions: String? = nil,
      modalities: [String]? = nil,
      maxResponseOutputTokens: OpenAIRealtimeSessionConfiguration.MaxResponseOutputTokens? = nil,
      parallelToolCalls: Bool? = nil,
      reasoning: OpenAIRealtimeSessionConfiguration.ReasoningConfiguration? = nil,
      tools: [OpenAIRealtimeSessionConfiguration.RealtimeTool]? = nil,
      toolChoice: OpenAIRealtimeSessionConfiguration.ToolChoice? = nil)
    {
      self.instructions = instructions
      self.modalities = modalities
      self.maxResponseOutputTokens = maxResponseOutputTokens
      self.parallelToolCalls = parallelToolCalls
      self.reasoning = reasoning
      self.tools = tools
      self.toolChoice = toolChoice
    }

    public init(
      instructions: String? = nil,
      modalities: [String]? = nil,
      tools: [Tool])
    {
      self.instructions = instructions
      self.modalities = modalities
      maxResponseOutputTokens = nil
      parallelToolCalls = nil
      reasoning = nil
      self.tools = tools.map {
        .function(.init(name: $0.name, description: $0.description, parameters: $0.parameters))
      }
      toolChoice = nil
    }

    public let instructions: String?
    public let modalities: [String]?
    public let maxResponseOutputTokens: OpenAIRealtimeSessionConfiguration.MaxResponseOutputTokens?
    public let parallelToolCalls: Bool?
    public let reasoning: OpenAIRealtimeSessionConfiguration.ReasoningConfiguration?
    public let tools: [OpenAIRealtimeSessionConfiguration.RealtimeTool]?
    public let toolChoice: OpenAIRealtimeSessionConfiguration.ToolChoice?

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(instructions, forKey: .instructions)
      try container.encodeIfPresent(modalities, forKey: .outputModalities)
      try container.encodeIfPresent(maxResponseOutputTokens, forKey: .maxOutputTokens)
      try container.encodeIfPresent(parallelToolCalls, forKey: .parallelToolCalls)
      try container.encodeIfPresent(reasoning, forKey: .reasoning)
      try container.encodeIfPresent(tools, forKey: .tools)
      try container.encodeIfPresent(toolChoice, forKey: .toolChoice)
    }

    private enum CodingKeys: String, CodingKey {
      case instructions
      case maxOutputTokens = "max_output_tokens"
      case outputModalities = "output_modalities"
      case parallelToolCalls = "parallel_tool_calls"
      case reasoning
      case tools
      case toolChoice = "tool_choice"
    }
  }
}

// MARK: - OpenAIRealtimeResponseCreate.Response.Tool

extension OpenAIRealtimeResponseCreate.Response {
  public struct Tool: Encodable {
    public let name: String
    public let description: String
    public let parameters: [String: OpenAIJSONValue]
    public let type = "function"

    public init(name: String, description: String, parameters: [String: OpenAIJSONValue]) {
      self.name = name
      self.description = description
      self.parameters = parameters
    }
  }
}
