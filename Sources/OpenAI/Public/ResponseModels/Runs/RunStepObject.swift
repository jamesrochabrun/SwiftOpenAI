//
//  RunStepObject.swift
//
//
//  Created by James Rochabrun on 11/17/23.
//

import Foundation

/// Represents a [step](https://platform.openai.com/docs/api-reference/runs/step-object) in execution of a run.
public struct RunStepObject: Codable {
   
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
   public let metadata: [String: String]?
   
   public enum Status: String {
      case inProgress = "in_progress"
      case cancelled
      case failed
      case completed
      case expired
   }
   
   public struct StepDetail: Codable {

      /// `message_creation` or `tool_calls`
      public let type: String
      /// Details of the message creation by the run step.
      public let messageCreation: MessageCreation?
      /// Details of the tool call.
      public let toolCalls: [ToolCall]?
      
      enum CodingKeys: String, CodingKey {
         case type
         case messageCreation = "message_creation"
         case toolCalls = "tool_calls"
      }
   }
   
   public struct MessageCreation: Codable {
      /// The ID of the message that was created by this run step.
      public let messageID: String
      
      enum CodingKeys: String, CodingKey {
         case messageID = "message_id"
      }
   }
   
   public struct ToolCall: Codable {

       public let id: String
       public let type: String
       public let toolCall: RunStepToolCall

       enum CodingKeys: String, CodingKey {
           case id
           case type
           // Add coding keys for the different tool call types
           case codeInterpreter = "code_interpreter"
           case retrieval
           case function
       }

       public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           id = try container.decode(String.self, forKey: .id)
           type = try container.decode(String.self, forKey: .type)

           // Decode based on the tool call type
           switch type {
           case "code_interpreter":
               let codeInterpreterCall = try container.decode(CodeInterpreterToolCall.self, forKey: .codeInterpreter)
               toolCall = .codeInterpreterToolCall(codeInterpreterCall)
           case "retrieval":
               let retrievalCall = try container.decode(RetrievalToolCall.self, forKey: .retrieval)
               toolCall = .retrieveToolCall(retrievalCall)
           case "function":
               let functionCall = try container.decode(FunctionToolCall.self, forKey: .function)
               toolCall = .functionToolCall(functionCall)
           default:
               throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unrecognized tool call type")
           }
       }

       public func encode(to encoder: Encoder) throws {
           var container = encoder.container(keyedBy: CodingKeys.self)
           try container.encode(id, forKey: .id)
           try container.encode(type, forKey: .type)

           // Encode toolCall based on its case
           switch toolCall {
           case .codeInterpreterToolCall(let call):
               try container.encode(call, forKey: .codeInterpreter)
           case .retrieveToolCall(let call):
               try container.encode(call, forKey: .retrieval)
           case .functionToolCall(let call):
               try container.encode(call, forKey: .function)
           }
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
   
   public func encode(to encoder: Encoder) throws {
       var container = encoder.container(keyedBy: CodingKeys.self)
       
       // Encode all properties
       try container.encode(id, forKey: .id)
       try container.encode(object, forKey: .object)
       try container.encode(createdAt, forKey: .createdAt)
       try container.encode(assistantId, forKey: .assistantId)
       try container.encode(threadId, forKey: .threadId)
       try container.encode(runId, forKey: .runId)
       try container.encode(type, forKey: .type)
       try container.encode(status, forKey: .status)
       try container.encode(stepDetails, forKey: .stepDetails)
       
       // Encode optional properties only if they are not nil
       try container.encodeIfPresent(lastError, forKey: .lastError)
       try container.encodeIfPresent(expiredAt, forKey: .expiredAt)
       try container.encodeIfPresent(cancelledAt, forKey: .cancelledAt)
       try container.encodeIfPresent(failedAt, forKey: .failedAt)
       try container.encodeIfPresent(completedAt, forKey: .completedAt)
       
       // For the metadata dictionary, you can encode it directly if it is not nil
       try container.encodeIfPresent(metadata, forKey: .metadata)
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
public enum RunStepToolCall: Codable {
   
   case codeInterpreterToolCall(CodeInterpreterToolCall)
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
         self = .codeInterpreterToolCall(codeInterpreterCall)
      } else if let retrievalCall = try container.decodeIfPresent(RetrievalToolCall.self, forKey: .retrieval) {
         self = .retrieveToolCall(retrievalCall)
      } else if let functionCall = try container.decodeIfPresent(FunctionToolCall.self, forKey: .function) {
         self = .functionToolCall(functionCall)
      } else {
         throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode RunStepToolCall"))
      }
   }
   
   public func encode(to encoder: Encoder) throws {
       var container = encoder.container(keyedBy: CodingKeys.self)
       
       switch self {
       case .codeInterpreterToolCall(let call):
           try container.encode(call, forKey: .codeInterpreter)
       case .retrieveToolCall(let call):
           try container.encode(call, forKey: .retrieval)
       case .functionToolCall(let call):
           try container.encode(call, forKey: .function)
       }
    }
}

// MARK: CodeInterpreterToolCall

public struct CodeInterpreterToolCall: Codable {

   /// The Code Interpreter tool call definition.
   public let codeInterpreter: CodeInterpreter
   
   enum CodingKeys: String, CodingKey {
      case codeInterpreter = "code_interpreter"
   }
}

/// The Code Interpreter tool call definition.
public struct CodeInterpreter: Codable {
   
   /// The input to the Code Interpreter tool call.
   public let input: String
   /// The outputs from the Code Interpreter tool call. Code Interpreter can output one or more items, including text (logs) or images (image). Each of these are represented by a different object type.
   public let outputs: [CodeInterpreterOutput]
}


public enum CodeInterpreterOutput: Codable {
   
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
public struct CodeInterpreterLogOutput: Codable {
   
   /// Always logs.
   public let type: String
   /// The text output from the Code Interpreter tool call.
   public let logs: String
}

public struct CodeInterpreterImageOutput: Codable {
   
   public let type: String
   public let image: Image
   
   public struct Image: Codable {
      /// The [file](https://platform.openai.com/docs/api-reference/files) ID of the image.
      let fileID: String
      
      enum CodingKeys: String, CodingKey {
         case fileID = "file_id"
      }
   }
}

// MARK: RetrievalToolCall

public struct RetrievalToolCall: Codable {

   /// For now, this is always going to be an empty object.
   public let retrieval: [String: String]?
   
}

// MARK: FunctionToolCall

public struct FunctionToolCall: Codable {
   
   /// The definition of the function that was called.
   let function: Function
   
   public struct Function: Codable {
      
      /// The name of the function.
      public let name: String
      /// The arguments passed to the function.
      public let arguments: String
      /// The output of the function. This will be null if the outputs have not been [submitted](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs) yet.
      public let output: String
   }
}

