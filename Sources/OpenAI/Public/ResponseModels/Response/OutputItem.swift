//
//  OutputItem.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.

import Foundation

/// An output item from the model response
public enum OutputItem: Decodable {
   /// An output message from the model
   case message(Message)
   /// The results of a file search tool call
   case fileSearchCall(FileSearchToolCall)
   /// A tool call to run a function
   case functionCall(FunctionToolCall)
   /// The results of a web search tool call
   case webSearchCall(WebSearchToolCall)
   /// A tool call to a computer use tool
   case computerCall(ComputerToolCall)
   /// A description of the chain of thought used by a reasoning model
   case reasoning(Reasoning)
   
   private enum CodingKeys: String, CodingKey {
      case type
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let type = try container.decode(String.self, forKey: .type)
      
      switch type {
      case "message":
         let message = try Message(from: decoder)
         self = .message(message)
      case "file_search_call":
         let fileSearch = try FileSearchToolCall(from: decoder)
         self = .fileSearchCall(fileSearch)
      case "function_call":
         let functionCall = try FunctionToolCall(from: decoder)
         self = .functionCall(functionCall)
      case "web_search_call":
         let webSearch = try WebSearchToolCall(from: decoder)
         self = .webSearchCall(webSearch)
      case "computer_call":
         let computerCall = try ComputerToolCall(from: decoder)
         self = .computerCall(computerCall)
      case "reasoning":
         let reasoning = try Reasoning(from: decoder)
         self = .reasoning(reasoning)
      default:
         throw DecodingError.dataCorruptedError(
            forKey: .type,
            in: container,
            debugDescription: "Unknown output item type: \(type)"
         )
      }
   }
   
   // MARK: - Output Message
   
   /// An output message from the model
   public struct Message: Decodable {
      /// The content of the output message
      public let content: [ContentItem]
      /// The unique ID of the output message
      public let id: String
      /// The role of the output message. Always "assistant"
      public let role: String
      /// The status of the message input. One of "in_progress", "completed", or "incomplete"
      public let status: String
      /// The type of the output message. Always "message"
      public let type: String
      
      enum CodingKeys: String, CodingKey {
         case content, id, role, status, type
      }
   }
   
   /// Content item in an output message
   public enum ContentItem: Decodable {
      /// Text output from the model
      case outputText(OutputText)
      /// Other content types could be added here as they are defined
      
      private enum CodingKeys: String, CodingKey {
         case type
      }
      
      public init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         let type = try container.decode(String.self, forKey: .type)
         
         switch type {
         case "output_text":
            let text = try OutputText(from: decoder)
            self = .outputText(text)
         default:
            throw DecodingError.dataCorruptedError(
               forKey: .type,
               in: container,
               debugDescription: "Unknown content item type: \(type)"
            )
         }
      }
      
      /// Text output from the model
      public struct OutputText: Decodable {
         /// The text content
         public let text: String
         /// Annotations in the text, if any
         public let annotations: [Annotation]
         /// The type of the content. Always "output_text"
         public let type: String
         
         enum CodingKeys: String, CodingKey {
            case text, annotations, type
         }
      }
      
      /// Annotation in text output
      public struct Annotation: Decodable {
         // Properties would be defined based on different annotation types
         // Such as file_citation, etc.
      }
   }
   
   // MARK: - File Search Tool Call
   
   /// The results of a file search tool call
   public struct FileSearchToolCall: Decodable {
      /// The unique ID of the file search tool call
      public let id: String
      /// The queries used to search for files
      public let queries: [String]
      /// The status of the file search tool call
      public let status: String
      /// The type of the file search tool call. Always "file_search_call"
      public let type: String
      /// The results of the file search tool call
      public let results: [SearchResult]?
      
      /// A search result from a file search
      public struct SearchResult: Decodable {
         // Properties for search results would be defined here
      }
      
      enum CodingKeys: String, CodingKey {
         case id, queries, status, type, results
      }
   }
   
   // MARK: - Function Tool Call
   
   /// A tool call to run a function
   public struct FunctionToolCall: Decodable {
      /// A JSON string of the arguments to pass to the function
      public let arguments: String
      /// The unique ID of the function tool call generated by the model
      public let callId: String
      /// The name of the function to run
      public let name: String
      /// The type of the function tool call. Always "function_call"
      public let type: String
      /// The unique ID of the function tool call
      public let id: String
      /// The status of the item. One of "in_progress", "completed", or "incomplete"
      public let status: String
      
      enum CodingKeys: String, CodingKey {
         case arguments, callId = "call_id", name, type, id, status
      }
   }
   
   // MARK: - Web Search Tool Call
   
   /// The results of a web search tool call
   public struct WebSearchToolCall: Decodable {
      /// The unique ID of the web search tool call
      public let id: String
      /// The status of the web search tool call
      public let status: String
      /// The type of the web search tool call. Always "web_search_call"
      public let type: String
      
      enum CodingKeys: String, CodingKey {
         case id, status, type
      }
   }
   
   // MARK: - Computer Tool Call
   
   /// A tool call to a computer use tool
   public struct ComputerToolCall: Decodable {
      /// The action to perform with the computer tool
      public let action: ComputerAction
      /// An identifier used when responding to the tool call with output
      public let callId: String
      /// The unique ID of the computer call
      public let id: String
      /// The pending safety checks for the computer call
      public let pendingSafetyChecks: [SafetyCheck]
      /// The status of the item
      public let status: String
      /// The type of the computer call. Always "computer_call"
      public let type: String
      
      /// Computer action to perform
      public struct ComputerAction: Decodable {
         /// The type of computer action to perform
         public let type: String
         /// Additional parameters for the action, varies by action type
         private let parameters: [String: AnyCodable]
         
         /// Initialize with type and parameters
         public init(type: String, parameters: [String: AnyCodable]) {
            self.type = type
            self.parameters = parameters
         }
         
         private enum CodingKeys: String, CodingKey {
            case type
         }
         
         public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            
            // Decode remaining keys as parameters
            let additionalInfo = try decoder.singleValueContainer()
            let allData = try additionalInfo.decode([String: AnyCodable].self)
            
            // Filter out the 'type' key to get just the parameters
            var params = allData
            params.removeValue(forKey: "type")
            parameters = params
         }
      }
      
      /// A type that can hold any decodable value
      public struct AnyCodable: Codable {
         private let value: Any
         
         public init(_ value: Any) {
            self.value = value
         }
         
         public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if container.decodeNil() {
               value = Optional<Any>.none as Any
            } else if let bool = try? container.decode(Bool.self) {
               value = bool
            } else if let int = try? container.decode(Int.self) {
               value = int
            } else if let double = try? container.decode(Double.self) {
               value = double
            } else if let string = try? container.decode(String.self) {
               value = string
            } else if let array = try? container.decode([AnyCodable].self) {
               value = array
            } else if let dictionary = try? container.decode([String: AnyCodable].self) {
               value = dictionary
            } else {
               throw DecodingError.dataCorruptedError(
                  in: container,
                  debugDescription: "AnyCodable cannot decode value"
               )
            }
         }
         
         public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            // Handle special cases first
            if value is NSNull {
               try container.encodeNil()
               return
            }
            
            // Special handling for nil optional values
            // This is a safe way to check if the value is a nil optional
            let mirror = Mirror(reflecting: value)
            if mirror.displayStyle == .optional && mirror.children.isEmpty {
               try container.encodeNil()
               return
            }
            
            // Handle other value types
            switch value {
            case let bool as Bool:
               try container.encode(bool)
            case let int as Int:
               try container.encode(int)
            case let double as Double:
               try container.encode(double)
            case let string as String:
               try container.encode(string)
            case let array as [AnyCodable]:
               try container.encode(array)
            case let dictionary as [String: AnyCodable]:
               try container.encode(dictionary)
            default:
               let context = EncodingError.Context(
                  codingPath: container.codingPath,
                  debugDescription: "AnyCodable cannot encode value \(value)"
               )
               throw EncodingError.invalidValue(value, context)
            }
         }
      }
      
      /// Safety check for computer actions
      public struct SafetyCheck: Decodable {
         /// The type of the pending safety check
         public let code: String
         /// The ID of the pending safety check
         public let id: String
         /// Details about the pending safety check
         public let message: String
      }
      
      enum CodingKeys: String, CodingKey {
         case action, callId = "call_id", id, pendingSafetyChecks = "pending_safety_checks", status, type
      }
   }
   
   // MARK: - Reasoning
   
   /// A description of the chain of thought used by a reasoning model
   public struct Reasoning: Decodable {
      /// The unique identifier of the reasoning content
      public let id: String
      /// Reasoning text contents
      public let summary: [SummaryItem]
      /// The type of the object. Always "reasoning"
      public let type: String
      /// The status of the item
      public let status: String
      
      /// Summary content in reasoning
      public struct SummaryItem: Decodable {
         /// A short summary of the reasoning used by the model
         public let text: String
         /// The type of the object. Always "summary_text"
         public let type: String
      }
      
      enum CodingKeys: String, CodingKey {
         case id, summary, type, status
      }
   }
}
