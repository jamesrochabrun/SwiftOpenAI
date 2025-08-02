//
//  RunObject.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// BETA.
/// A [run](https://platform.openai.com/docs/api-reference/runs) object, represents an execution run on a [thread](https://platform.openai.com/docs/api-reference/threads).
/// Related guide: [Assistants](https://platform.openai.com/docs/assistants/overview)
/// [Run Object](https://platform.openai.com/docs/api-reference/runs/object)
public struct RunObject: Decodable {
  public enum Status: String {
    case queued
    case inProgress = "in_progress"
    case requiresAction = "requires_action"
    case cancelling
    case cancelled
    case failed
    case completed
    case expired
  }

  public struct RequiredAction: Decodable {
    public struct SubmitToolOutput: Decodable {
      /// A list of the relevant tool calls.
      /// - Object: ToolCall
      /// - id: The ID of the tool call. This ID must be referenced when you submit the tool outputs in using the [Submit tool outputs to run](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs) endpoint.
      /// - type: The type of tool call the output is required for. For now, this is always function.
      /// - function: The function definition.
      public let toolCalls: [ToolCall]

      private enum CodingKeys: String, CodingKey {
        case toolCalls = "tool_calls"
      }
    }

    /// For now, this is always submit_tool_outputs.
    public let type: String
    /// Details on the tool outputs needed for this run to continue.
    public let submitToolsOutputs: SubmitToolOutput

    private enum CodingKeys: String, CodingKey {
      case type
      case submitToolsOutputs = "submit_tool_outputs"
    }
  }

  /// The identifier, which can be referenced in API endpoints.
  public let id: String
  /// The object type, which is always thread.run.
  public let object: String
  /// The Unix timestamp (in seconds) for when the run was created.
  public let createdAt: Int?
  /// The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) that was executed on as a part of this run.
  public let threadID: String
  /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for execution of this run.
  public let assistantID: String
  /// The status of the run, which can be either queued, in_progress, requires_action, cancelling, cancelled, failed, completed, or expired.
  public let status: String
  /// Details on the action required to continue the run. Will be null if no action is required.
  public let requiredAction: RequiredAction?
  /// The last error associated with this run. Will be null if there are no errors.
  public let lastError: LastError?
  /// The Unix timestamp (in seconds) for when the run will expire.
  public let expiresAt: Int?
  /// The Unix timestamp (in seconds) for when the run was started.
  public let startedAt: Int?
  /// The Unix timestamp (in seconds) for when the run was cancelled.
  public let cancelledAt: Int?
  /// The Unix timestamp (in seconds) for when the run failed.
  public let failedAt: Int?
  /// The Unix timestamp (in seconds) for when the run was completed.
  public let completedAt: Int?
  /// Details on why the run is incomplete. Will be null if the run is not incomplete.
  public let incompleteDetails: IncompleteDetails?
  /// The model that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
  public let model: String
  /// The instructions that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
  public let instructions: String?
  /// The list of tools that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
  public let tools: [AssistantObject.Tool]
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public let metadata: [String: String]
  /// Usage statistics related to the run. This value will be null if the run is not in a terminal state (i.e. in_progress, queued, etc.).
  public let usage: Usage?
  /// The sampling temperature used for this run. If not set, defaults to 1.
  public let temperature: Double?
  /// The nucleus sampling value used for this run. If not set, defaults to 1.
  public let topP: Double?
  /// The maximum number of prompt tokens specified to have been used over the course of the run.
  public let maxPromptTokens: Int?
  /// The maximum number of completion tokens specified to have been used over the course of the run.
  public let maxCompletionTokens: Int?
  /// Controls for how a thread will be truncated prior to the run. Use this to control the intial context window of the run.
  public let truncationStrategy: TruncationStrategy?
  /// Controls which (if any) tool is called by the model. none means the model will not call any tools and instead generates a message. auto is the default value and means the model can pick between generating a message or calling a tool. Specifying a particular tool like {"type": "TOOL_TYPE"} or {"type": "function", "function": {"name": "my_function"}} forces the model to call that tool.
  public let toolChoice: ToolChoice?
  /// Specifies the format that the model must output. Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models newer than gpt-3.5-turbo-1106.
  /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
  /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
  public let responseFormat: ResponseFormat?

  public var displayStatus: Status? { .init(rawValue: status) }

  private enum CodingKeys: String, CodingKey {
    case id
    case object
    case createdAt = "created_at"
    case threadID = "thread_id"
    case assistantID = "assistant_id"
    case status
    case requiredAction = "required_action"
    case lastError = "last_error"
    case expiresAt = "expires_at"
    case startedAt = "started_at"
    case cancelledAt = "cancelled_at"
    case failedAt = "failed_at"
    case completedAt = "completed_at"
    case incompleteDetails = "incomplete_details"
    case model
    case instructions
    case tools
    case metadata
    case usage
    case temperature
    case topP = "top_p"
    case maxPromptTokens = "max_prompt_tokens"
    case maxCompletionTokens = "max_completion_tokens"
    case truncationStrategy
    case toolChoice = "tool_choice"
    case responseFormat = "response_format"
  }
}
