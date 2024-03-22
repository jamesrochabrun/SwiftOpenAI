//
//  CreateThreadAndRunParameter.swift
//
//
//  Created by James Rochabrun on 11/17/23.
//

import Foundation

/// [Create a thread and run it in one request.](https://platform.openai.com/docs/api-reference/runs/createThreadAndRun)
public struct CreateThreadAndRunParameter: Encodable {
   
   /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) to use to execute this run.
   let assistantId: String
   /// A thread to create.
   let thread: CreateThreadParameters?
   /// The ID of the [Model](https://platform.openai.com/docs/api-reference/models) to be used to execute this run. If a value is provided here, it will override the model associated with the assistant. If not, the model associated with the assistant will be used.
   let model: String?
   /// Override the default system message of the assistant. This is useful for modifying the behavior on a per-run basis.
   let instructions: String?
   /// Override the tools the assistant can use for this run. This is useful for modifying the behavior on a per-run basis.
   let tools: [AssistantObject.Tool]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
   /// If true, returns a stream of events that happen during the Run as server-sent events, terminating when the Run enters a terminal state with a data: [DONE] message.
   var stream: Bool = false
   
   enum CodingKeys: String, CodingKey {
      case assistantId = "assistant_id"
      case thread
      case model
      case instructions
      case tools
      case metadata
      case stream
   }
   
   public init(
      assistantId: String,
      thread: CreateThreadParameters?,
      model: String?, 
      instructions: String?,
      tools: [AssistantObject.Tool]?,
      metadata: [String : String]? = nil)
   {
      self.assistantId = assistantId
      self.thread = thread
      self.model = model
      self.instructions = instructions
      self.tools = tools
      self.metadata = metadata
   }
}

