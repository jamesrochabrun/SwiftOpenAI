//
//  RunStepObject.swift
//
//
//  Created by James Rochabrun on 11/17/23.
//

import Foundation

/// Represents a [step](https://platform.openai.com/docs/api-reference/runs/step-object) in execution of a run.
public struct RunStepObject: Decodable {
   
   /// The identifier of the run step, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always `thread.run.step``.
   public let object: String
   /// The Unix timestamp (in seconds) for when the run step was created.
   public let createdAt: Int
   /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) associated with the run step.
   public let assistantId: String
   /// The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) that was run.
   public let threadId: String
   ///The ID of the [run](https://platform.openai.com/docs/api-reference/runs) that this run step is a part of.
   public let runId: String
   /// The type of run step, which can be either message_creation or tool_calls.
   public let type: String
   /// The status of the run step, which can be either in_progress, cancelled, failed, completed, or expired.
   public let status: String
   /// The details of the run step.
   public let stepDetails: StepDetail
   /// The last error associated with this run step. Will be null if there are no errors.
   public let lastError: RunObject.LastError?
   /// The Unix timestamp (in seconds) for when the run step expired. A step is considered expired if the parent run is expired.
   public let expiredAt: Int?
   /// The Unix timestamp (in seconds) for when the run step was cancelled.
   public let cancelledAt: Int?
   /// The Unix timestamp (in seconds) for when the run step failed.
   public let failedAt: Int?
   /// The Unix timestamp (in seconds) for when the run step completed.
   public let completedAt: Int?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
   
   public enum Status: String {
      case inProgress = "in_progress"
      case cancelled
      case failed
      case completed
      case expired
   }
   
   public struct StepDetail: Decodable {
      /// Always `message_creation``.
      public let type: String
      /// Details of the message creation by the run step.
      public let messageCreation: MessageCreation
      /// Details of the tool call.
      public let toolCalls: [ToolCalls]
      
      enum CodingKeys: String, CodingKey {
         case type
         case messageCreation = "message_creation"
         case toolCalls = "tool_calls"
      }
   }
   
   public struct MessageCreation: Decodable {
      /// The ID of the message that was created by this run step.
      public let messageID: String
      
      enum CodingKeys: String, CodingKey {
         case messageID = "message_id"
      }
   }
   
   public struct ToolCalls: Decodable {
      
      /// Always tool_calls.
      public let type: String
      /// An array of tool calls the run step was involved in. These can be associated with one of three types of tools: code_interpreter, retrieval, or function.
      public let toolCalls: [RunStepToolCall]
      
      enum CodingKeys: String, CodingKey {
         case type
         case toolCalls = "tool_calls"
      }
   }
   
   enum CodingKeys: String, CodingKey {
      case id
      case object
      case createdAt = "created_at"
      case assistantId = "assistant_id"
      case threadId = "thread_id"
      case runId = "run_id"
      case type
      case status
      case stepDetails = "step_details"
      case lastError = "last_error"
      case expiredAt = "expired_at"
      case cancelledAt = "cancelled_at"
      case failedAt = "failed_at"
      case completedAt = "completed_at"
      case metadata
   }
   
   public init(
      id: String,
      object: String,
      createdAt: Int,
      assistantId: String,
      threadId: String,
      runId: String,
      type: String,
      status: Status, 
      stepDetails: StepDetail,
      lastError: RunObject.LastError?,
      expiredAt: Int?,
      cancelledAt: Int?,
      failedAt: Int?,
      completedAt: Int?,
      metadata: [String : String])
   {
      self.id = id
      self.object = object
      self.createdAt = createdAt
      self.assistantId = assistantId
      self.threadId = threadId
      self.runId = runId
      self.type = type
      self.status = status.rawValue
      self.stepDetails = stepDetails
      self.lastError = lastError
      self.expiredAt = expiredAt
      self.cancelledAt = cancelledAt
      self.failedAt = failedAt
      self.completedAt = completedAt
      self.metadata = metadata
   }
}

// MARK: RunStepToolCall

/// Details of the tool call.
public enum RunStepToolCall: Decodable {
   
   case condeInterpreterToolCall(CodeInterpreterToolCall)
   case retrieveToolCall(RetrievalToolCall)
   case functionToolCall(FunctionToolCall)
   
   enum CodingKeys: String, CodingKey {
      case codeInterpreter = "code_interpreter"
      case retrieval
      case function
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      if let codeInterpreterCall = try container.decodeIfPresent(CodeInterpreterToolCall.self, forKey: .codeInterpreter) {
         self = .condeInterpreterToolCall(codeInterpreterCall)
      } else if let retrievalCall = try container.decodeIfPresent(RetrievalToolCall.self, forKey: .retrieval) {
         self = .retrieveToolCall(retrievalCall)
      } else if let functionCall = try container.decodeIfPresent(FunctionToolCall.self, forKey: .function) {
         self = .functionToolCall(functionCall)
      } else {
         throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode RunStepToolCall"))
      }
   }
}

// MARK: CodeInterpreterToolCall

public struct CodeInterpreterToolCall: Decodable {
   
   /// The ID of the tool call.
   public let id: String
   /// The type of tool call. This is always going to be code_interpreter for this type of tool call.
   public let type: String
   /// The Code Interpreter tool call definition.
   public let codeInterpreter: CodeInterpreter
   
   enum CodingKeys: String, CodingKey {
      case id
      case type
      case codeInterpreter = "code_interpreter"
   }
}

/// The Code Interpreter tool call definition.
public struct CodeInterpreter: Decodable {
   
   /// The input to the Code Interpreter tool call.
   public let input: String
   /// The outputs from the Code Interpreter tool call. Code Interpreter can output one or more items, including text (logs) or images (image). Each of these are represented by a different object type.
   public let outputs: [CodeInterpreterOutput]
}


public enum CodeInterpreterOutput: Decodable {
   
   /// The outputs from the Code Interpreter tool call. Code Interpreter can output one or more items,
   /// including text (logs) or images (image). Each of these are represented by a different object type.
   case logs(CodeInterpreterLogOutput)
   case images(CodeInterpreterImageOutput)
   
   enum CodingKeys: String, CodingKey {
      case logs
      case images
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      if let logOutput = try container.decodeIfPresent(CodeInterpreterLogOutput.self, forKey: .logs) {
         self = .logs(logOutput)
      } else if let imageOutput = try container.decodeIfPresent(CodeInterpreterImageOutput.self, forKey: .images) {
         self = .images(imageOutput)
      } else {
         throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The container does not have a matching key for logs or images"))
      }
   }
}

/// Text output from the Code Interpreter tool call as part of a run step.
public struct CodeInterpreterLogOutput: Decodable {
   
   /// Always logs.
   public let type: String
   /// The text output from the Code Interpreter tool call.
   public let logs: String
}

public struct CodeInterpreterImageOutput: Decodable {
   
   public let type: String
   public let image: Image
   
   public struct Image: Decodable {
      /// The [file](https://platform.openai.com/docs/api-reference/files) ID of the image.
      let fileID: String
      
      enum CodingKeys: String, CodingKey {
         case fileID = "file_id"
      }
   }
}

// MARK: RetrievalToolCall

public struct RetrievalToolCall: Decodable {
   
   /// The ID of the tool call object.
   public let id: String
   /// The type of tool call. This is always going to be retrieval for this type of tool call.
   public let type: String
   /// For now, this is always going to be an empty object.
   public let retrieval: [String: String]?
   
}

// MARK: FunctionToolCall

public struct FunctionToolCall: Decodable {
   
   /// The ID of the tool call object.
   let id: String
   /// The type of tool call. This is always going to be function for this type of tool call.
   let type: String
   /// The definition of the function that was called.
   let function: Function
   
   public struct Function: Decodable {
      
      /// The name of the function.
      public let name: String
      /// The arguments passed to the function.
      public let arguments: String
      /// The output of the function. This will be null if the outputs have not been [submitted](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs) yet.
      public let output: String
   }
}
