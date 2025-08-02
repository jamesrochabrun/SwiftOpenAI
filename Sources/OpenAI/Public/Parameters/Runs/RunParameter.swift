//
//  RunParameter.swift
//
//
//  Created by James Rochabrun on 11/16/23.
//

import Foundation

/// [Create a run.](https://platform.openai.com/docs/api-reference/runs/createRun)
public struct RunParameter: Encodable {
  public init(
    assistantID: String,
    model: String? = nil,
    instructions: String? = nil,
    additionalInstructions: String? = nil,
    additionalMessages: [MessageParameter]? = nil,
    tools: [AssistantObject.Tool]? = nil,
    metadata: [String: String]? = nil,
    temperature: Double? = nil,
    maxPromptTokens: Int? = nil,
    maxCompletionTokens: Int? = nil,
    truncationStrategy: TruncationStrategy? = nil,
    toolChoice: ToolChoice? = nil,
    responseFormat: ResponseFormat? = nil)
  {
    self.assistantID = assistantID
    self.model = model
    self.instructions = instructions
    self.additionalInstructions = additionalInstructions
    self.additionalMessages = additionalMessages
    self.tools = tools
    self.metadata = metadata
    self.temperature = temperature
    self.maxPromptTokens = maxPromptTokens
    self.maxCompletionTokens = maxCompletionTokens
    self.truncationStrategy = truncationStrategy
    self.toolChoice = toolChoice
    self.responseFormat = responseFormat
  }

  /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) to use to execute this run.
  public let assistantID: String

  enum CodingKeys: String, CodingKey {
    case assistantID = "assistant_id"
    case model
    case instructions
    case additionalInstructions = "additional_instructions"
    case additionalMessages = "additional_messages"
    case tools
    case metadata
    case stream
    case temperature
    case maxPromptTokens = "max_prompt_tokens"
    case maxCompletionTokens = "max_completion_tokens"
    case truncationStrategy = "truncation_strategy"
    case toolChoice = "tool_choice"
    case responseFormat = "response_format"
  }

  /// The ID of the [Model](https://platform.openai.com/docs/api-reference/models) to be used to execute this run. If a value is provided here, it will override the model associated with the assistant. If not, the model associated with the assistant will be used.
  let model: String?
  /// Overrides the [instructions](https://platform.openai.com/docs/api-reference/assistants/createAssistant) of the assistant. This is useful for modifying the behavior on a per-run basis.
  let instructions: String?
  /// Appends additional instructions at the end of the instructions for the run. This is useful for modifying the behavior on a per-run basis without overriding other instructions.
  let additionalInstructions: String?
  /// Adds additional messages to the thread before creating the run.
  let additionalMessages: [MessageParameter]?
  /// Override the tools the assistant can use for this run. This is useful for modifying the behavior on a per-run basis.
  let tools: [AssistantObject.Tool]?
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  let metadata: [String: String]?
  /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  /// Optional Defaults to 1
  let temperature: Double?
  /// If true, returns a stream of events that happen during the Run as server-sent events, terminating when the Run enters a terminal state with a data: [DONE] message.
  var stream = false
  /// The maximum number of prompt tokens that may be used over the course of the run. The run will make a best effort to use only the number of prompt tokens specified, across multiple turns of the run. If the run exceeds the number of prompt tokens specified, the run will end with status complete. See incomplete_details for more info.
  let maxPromptTokens: Int?
  /// The maximum number of completion tokens that may be used over the course of the run. The run will make a best effort to use only the number of completion tokens specified, across multiple turns of the run. If the run exceeds the number of completion tokens specified, the run will end with status complete. See incomplete_details for more info.
  let maxCompletionTokens: Int?
  /// Controls for how a thread will be truncated prior to the run. Use this to control the intial context window of the run.
  let truncationStrategy: TruncationStrategy?
  /// Controls which (if any) tool is called by the model. none means the model will not call any tools and instead generates a message. auto is the default value and means the model can pick between generating a message or calling a tool. Specifying a particular tool like {"type": "file_search"} or {"type": "function", "function": {"name": "my_function"}} forces the model to call that tool.
  let toolChoice: ToolChoice?
  /// Specifies the format that the model must output. Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models newer than gpt-3.5-turbo-1106.
  /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
  /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
  let responseFormat: ResponseFormat?
}
