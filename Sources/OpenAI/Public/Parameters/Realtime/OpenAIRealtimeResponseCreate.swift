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
    public let instructions: String?
    public let modalities: [String]?
    public let tools: [Tool]?

    public init(
      instructions: String? = nil,
      modalities: [String]? = nil,
      tools: [Tool]? = nil)
    {
      self.instructions = instructions
      self.modalities = modalities
      self.tools = tools
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
