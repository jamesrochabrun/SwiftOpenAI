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
public struct RunObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.run.
   public let object: String
   /// The Unix timestamp (in seconds) for when the run was created.
   public let createdAt: Int
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
   public let expiresAt: Int
   /// The Unix timestamp (in seconds) for when the run was started.
   public let startedAt: Int?
   /// The Unix timestamp (in seconds) for when the run was cancelled.
   public let cancelledAt: Int?
   /// The Unix timestamp (in seconds) for when the run failed.
   public let failedAt: Int?
   /// The Unix timestamp (in seconds) for when the run was completed.
   public let completedAt: Int?
   /// The model that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let model: String
   /// The instructions that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let instructions: String?
   /// The list of tools that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let tools: [AssistantObject.Tool]
   /// The list of [File](https://platform.openai.com/docs/api-reference/files) IDs the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let fileIDS: [String]
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
   
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
      
      /// For now, this is always submit_tool_outputs.
      public let type: String
      /// Details on the tool outputs needed for this run to continue.
      public let submitToolsOutputs: SubmitToolOutput
      
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
      
      private enum CodingKeys: String, CodingKey {
         case type
         case submitToolsOutputs = "submit_tool_outputs"
      }
   }
   
   public struct LastError: Codable {
      
      /// One of server_error or rate_limit_exceeded.
      let code: String
      /// A human-readable description of the error.
      let message: String
      
   }
   
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
      case model
      case instructions
      case fileIDS = "file_ids"
      case tools
      case metadata
   }
   
   public init(
      id: String,
      object: String,
      createdAt: Int,
      threadID: String,
      assistantID: String,
      status: String,
      requiredAction: RequiredAction?,
      lastError: LastError?,
      expiresAt: Int,
      startedAt: Int?,
      cancelledAt: Int?,
      failedAt: Int?,
      completedAt: Int?,
      model: String,
      instructions: String?,
      tools: [AssistantObject.Tool],
      fileIDS: [String],
      metadata: [String : String])
   {
      self.id = id
      self.object = object
      self.createdAt = createdAt
      self.threadID = threadID
      self.assistantID = assistantID
      self.status = status
      self.requiredAction = requiredAction
      self.lastError = lastError
      self.expiresAt = expiresAt
      self.startedAt = startedAt
      self.cancelledAt = cancelledAt
      self.failedAt = failedAt
      self.completedAt = completedAt
      self.model = model
      self.instructions = instructions
      self.tools = tools
      self.fileIDS = fileIDS
      self.metadata = metadata
   }
}
