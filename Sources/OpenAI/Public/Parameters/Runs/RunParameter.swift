//
//  RunParameter.swift
//
//
//  Created by James Rochabrun on 11/16/23.
//

import Foundation

/// [Create a run.](https://platform.openai.com/docs/api-reference/runs/createRun)
public struct RunParameter: Encodable {
   
   /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) to use to execute this run.
   public let assistantID: String
   /// The ID of the [Model](https://platform.openai.com/docs/api-reference/models) to be used to execute this run. If a value is provided here, it will override the model associated with the assistant. If not, the model associated with the assistant will be used.
   let model: String?
   /// Override the default system message of the assistant. This is useful for modifying the behavior on a per-run basis.
   let instructions: String?
   /// Appends additional instructions at the end of the instructions for the run. This is useful for modifying the behavior on a per-run basis without overriding other instructions.
   let additionalInstructions: String?
   /// Override the tools the assistant can use for this run. This is useful for modifying the behavior on a per-run basis.
   let tools: [AssistantObject.Tool]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
   /// If true, returns a stream of events that happen during the Run as server-sent events, terminating when the Run enters a terminal state with a data: [DONE] message.
   var stream: Bool = false
   
   enum CodingKeys: String, CodingKey {
      case assistantID = "assistant_id"
      case model
      case instructions
      case additionalInstructions = "additional_instructions"
      case tools
      case metadata
      case stream
   }
   
   public init(
      assistantID: String,
      model: String? = nil,
      instructions: String? = nil,
      additionalInstructions: String? = nil,
      tools: [AssistantObject.Tool]? = nil,
      metadata: [String : String]? = nil)
   {
      self.assistantID = assistantID
      self.model = model
      self.instructions = instructions
      self.additionalInstructions = additionalInstructions
      self.tools = tools
      self.metadata = metadata
   }
}
