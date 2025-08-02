//
//  AssistantParameters.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// Create an [assistant](https://platform.openai.com/docs/api-reference/assistants/createAssistant) with a model and instructions.
/// Modifies an [assistant](https://platform.openai.com/docs/api-reference/assistants/modifyAssistant).
public struct AssistantParameters: Encodable {
  public init(
    action: Action? = nil,
    name: String? = nil,
    description: String? = nil,
    instructions: String? = nil,
    tools: [AssistantObject.Tool] = [],
    toolResources: ToolResources? = nil,
    metadata: [String: String]? = nil,
    temperature: Double? = nil,
    topP: Double? = nil,
    responseFormat: ResponseFormat? = nil)
  {
    model = action?.model
    self.name = name
    self.description = description
    self.instructions = instructions
    self.tools = tools
    self.toolResources = toolResources
    self.metadata = metadata
    self.temperature = temperature
    self.topP = topP
    self.responseFormat = responseFormat
  }

  public enum Action {
    case create(model: String) // model is required on creation of assistant.
    case modify(model: String?) // model is optional on modification of assistant.

    var model: String? {
      switch self {
      case .create(let model): model
      case .modify(let model): model
      }
    }
  }

  /// ID of the model to use. You can use the [List models](https://platform.openai.com/docs/api-reference/models/list) API to see all of your available models, or see our [Model overview](https://platform.openai.com/docs/models/overview) for descriptions of them.
  public var model: String?
  /// The name of the assistant. The maximum length is 256 characters.
  public var name: String?
  /// The description of the assistant. The maximum length is 512 characters.
  public var description: String?
  /// The system instructions that the assistant uses. The maximum length is 32768 characters.
  public var instructions: String?
  /// A list of tool enabled on the assistant. There can be a maximum of 128 tools per assistant. Tools can be of types code_interpreter, retrieval, or function. Defaults to []
  public var tools: [AssistantObject.Tool] = []
  /// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
  public var toolResources: ToolResources?
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public var metadata: [String: String]?
  /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  /// Defaults to 1
  public var temperature: Double?
  /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
  /// We generally recommend altering this or temperature but not both.
  /// Defaults to 1
  public var topP: Double?
  /// Specifies the format that the model must output. Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models since gpt-3.5-turbo-1106.
  /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
  /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
  /// Defaults to `auto`
  public var responseFormat: ResponseFormat?

  /// Encoding only no nil or non empty parameters, this will avoid sending nil values when using this parameter in the "modifyAssistant" request.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    if let model {
      try container.encode(model, forKey: .model)
    }
    if let name {
      try container.encode(name, forKey: .name)
    }
    if let description {
      try container.encode(description, forKey: .description)
    }
    if let instructions {
      try container.encode(instructions, forKey: .instructions)
    }
    if !tools.isEmpty {
      try container.encode(tools, forKey: .tools)
    }
    if let toolResources {
      try container.encode(toolResources, forKey: .toolResources)
    }
    if let metadata {
      try container.encode(metadata, forKey: .metadata)
    }
    if let temperature {
      try container.encode(temperature, forKey: .temperature)
    }
    if let topP {
      try container.encode(topP, forKey: .topP)
    }
    if let responseFormat {
      try container.encode(responseFormat, forKey: .responseFormat)
    }
  }

  enum CodingKeys: String, CodingKey {
    case model
    case name
    case description
    case instructions
    case tools
    case metadata
    case temperature
    case topP = "top_p"
    case responseFormat = "response_format"
    case toolResources = "tool_resources"
  }
}
