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
   /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs attached to this assistant. There can be a maximum of 20 files attached to the assistant. Files are ordered by their creation date in ascending order.
   public let fileIDS: [String]
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
   
   public struct Tool: Codable {
      
      /// The type of tool being defined.
      public let type: String
      public let function: ChatCompletionParameters.ChatFunction?
      
      public enum ToolType: String, CaseIterable {
         case codeInterpreter = "code_interpreter"
         case retrieval
         case function
      }
      
      /// Helper.
      public var displayToolType: ToolType? { .init(rawValue: type) }
      
      public init(
         type: ToolType,
         function: ChatCompletionParameters.ChatFunction? = nil)
      {
         self.type = type.rawValue
         self.function = function
      }
   }
   
   enum CodingKeys: String, CodingKey {
      case id
      case object
      case createdAt = "created_at"
      case name
      case description
      case model
      case instructions
      case tools
      case fileIDS = "file_ids"
      case metadata
   }
   
   public struct DeletionStatus: Decodable {
      public let id: String
      public let object: String
      public let deleted: Bool
   }
   
   public init(
       id: String,
       object: String,
       createdAt: Int,
       name: String?,
       description: String?,
       model: String,
       instructions: String?,
       tools: [Tool],
       fileIDS: [String],
       metadata: [String: String]
   ) {
       self.id = id
       self.object = object
       self.createdAt = createdAt
       self.name = name
       self.description = description
       self.model = model
       self.instructions = instructions
       self.tools = tools
       self.fileIDS = fileIDS
       self.metadata = metadata
   }
}
