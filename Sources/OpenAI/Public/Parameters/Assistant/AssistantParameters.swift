//
//  CreateAssistantParameters.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// Create an [assistant](https://platform.openai.com/docs/api-reference/assistants/createAssistant) with a model and instructions.
/// Modifies an [assistant](https://platform.openai.com/docs/api-reference/assistants/modifyAssistant).
public struct AssistantParameters: Encodable {
   
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
   /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs attached to this assistant. There can be a maximum of 20 files attached to the assistant. Files are ordered by their creation date in ascending order.
   public var fileIDS: [String]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public var metadata: [String: String]?
   
   enum CodingKeys: String, CodingKey {
      case model
      case name
      case description
      case instructions
      case tools
      case fileIDS = "file_ids"
      case metadata
   }
   
   public enum Action {
      case create(model: String) // model is required on creation of assistant.
      case modify(model: String?) // model is optional on modification of assistant.
      
      var model: String? {
         switch self {
         case .create(let model): return model
         case .modify(let model): return model
         }
      }
   }
   
   public init(
      action: Action,
      name: String? = nil,
      description: String? = nil,
      instructions: String? = nil,
      tools: [AssistantObject.Tool] = [],
      fileIDS: [String]? = nil,
      metadata: [String : String]? = nil)
   {
      self.model = action.model
      self.name = name
      self.description = description
      self.instructions = instructions
      self.tools = tools
      self.fileIDS = fileIDS
      self.metadata = metadata
   }
}
