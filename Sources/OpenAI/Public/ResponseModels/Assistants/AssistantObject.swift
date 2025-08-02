//
//  AssistantObject.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// BETA.
/// Represents an [assistant](https://platform.openai.com/docs/api-reference/assistants) that can call the model and use tools.
public struct AssistantObject: Decodable {
  public init(
    id: String,
    object: String,
    createdAt: Int,
    name: String?,
    description: String?,
    model: String,
    instructions: String?,
    tools: [Tool],
    toolResources: ToolResources?,
    metadata: [String: String]?,
    temperature: Double?,
    topP: Double?,
    responseFormat: ResponseFormat?)
  {
    self.id = id
    self.object = object
    self.createdAt = createdAt
    self.name = name
    self.description = description
    self.model = model
    self.instructions = instructions
    self.tools = tools
    self.toolResources = toolResources
    self.metadata = metadata
    self.temperature = temperature
    self.topP = topP
    self.responseFormat = responseFormat
  }

  public struct Tool: Codable {
    public init(
      type: ToolType,
      function: ChatCompletionParameters.ChatFunction? = nil)
    {
      self.type = type.rawValue
      self.function = function
    }

    public enum ToolType: String, CaseIterable {
      case codeInterpreter = "code_interpreter"
      case fileSearch = "file_search"
      case function
    }

    /// The type of tool being defined.
    public let type: String
    public let function: ChatCompletionParameters.ChatFunction?

    /// Helper.
    public var displayToolType: ToolType? { .init(rawValue: type) }
  }

  /// The identifier, which can be referenced in API endpoints.
  public let id: String
  /// The object type, which is always "assistant".
  public let object: String
  /// The Unix timestamp (in seconds) for when the assistant was created.
  public let createdAt: Int
  /// The name of the assistant. The maximum length is 256 characters.
  public let name: String?
  /// The description of the assistant. The maximum length is 512 characters.
  public let description: String?
  /// ID of the model to use. You can use the [List models](https://platform.openai.com/docs/api-reference/models/list) API to see all of your available models, or see our [Model overview](https://platform.openai.com/docs/models/overview) for descriptions of them.
  public let model: String
  /// The system instructions that the assistant uses. The maximum length is 32768 characters.
  public let instructions: String?
  /// A list of tool enabled on the assistant. There can be a maximum of 128 tools per assistant. Tools can be of types code_interpreter, retrieval, or function.
  public let tools: [Tool]
  /// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
  public let toolResources: ToolResources?
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public let metadata: [String: String]?
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

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case createdAt = "created_at"
    case name
    case description
    case model
    case instructions
    case tools
    case toolResources = "tool_resources"
    case metadata
    case temperature
    case topP = "top_p"
    case responseFormat = "response_format"
  }
}
