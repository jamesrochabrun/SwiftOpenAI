//
//  RunStepDetails.swift
//
//
//  Created by James Rochabrun on 3/17/24.
//

import Foundation

public struct RunStepDetails: Codable {
   
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
   
   public struct MessageCreation: Codable {
      /// The ID of the message that was created by this run step.
      public let messageID: String
      
      enum CodingKeys: String, CodingKey {
         case messageID = "message_id"
      }
   }

   public struct ToolCall: Codable {
      
      public let index: Int?
      public let id: String?
      public let type: String
      public let toolCall: RunStepToolCall
      
      enum CodingKeys: String, CodingKey {
         case index, id, type
         case codeInterpreter = "code_interpreter"
         case retrieval, function
      }
      
      public init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         index = try container.decodeIfPresent(Int.self, forKey: .index)
         id = try container.decodeIfPresent(String.self, forKey: .id)
         type = try container.decode(String.self, forKey: .type)
         
         // Based on the type, decode the corresponding tool call
         switch type {
         case "code_interpreter":
            let codeInterpreter = try container.decode(CodeInterpreterToolCall.self, forKey: .codeInterpreter)
            toolCall = .codeInterpreterToolCall(codeInterpreter)
         case "retrieval":
            // Assuming you have a retrieval key in your JSON that corresponds to this type
            let retrieval = try container.decode(RetrievalToolCall.self, forKey: .retrieval)
            toolCall = .retrieveToolCall(retrieval)
         case "function":
            // Assuming you have a function key in your JSON that corresponds to this type
            let function = try container.decode(FunctionToolCall.self, forKey: .function)
            toolCall = .functionToolCall(function)
         default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unrecognized tool call type")
         }
      }
      
      public func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(id, forKey: .id)
         try container.encode(type, forKey: .type)
         
         // Based on the toolCall type, encode the corresponding object
         switch toolCall {
         case .codeInterpreterToolCall(let codeInterpreter):
            try container.encode(codeInterpreter, forKey: .codeInterpreter)
         case .retrieveToolCall(let retrieval):
            // Encode retrieval if it's not nil
            try container.encode(retrieval, forKey: .retrieval)
         case .functionToolCall(let function):
            // Encode function if it's not nil
            try container.encode(function, forKey: .function)
         }
      }
   }
}

// MARK: RunStepToolCall

/// Details of the tool call.
public enum RunStepToolCall: Codable {
   
   case codeInterpreterToolCall(CodeInterpreterToolCall)
   case retrieveToolCall(RetrievalToolCall)
   case functionToolCall(FunctionToolCall)
   
   private enum TypeEnum: String, Decodable {
      case codeInterpreter = "code_interpreter"
      case retrieval
      case function
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      
      // Decode the `type` property to determine which case to decode
      let type = try container.decode(TypeEnum.self)
      
      // Switch to the appropriate case based on the type
      switch type {
      case .codeInterpreter:
         let value = try CodeInterpreterToolCall(from: decoder)
         self = .codeInterpreterToolCall(value)
      case .retrieval:
         let value = try RetrievalToolCall(from: decoder)
         self = .retrieveToolCall(value)
      case .function:
         let value = try FunctionToolCall(from: decoder)
         self = .functionToolCall(value)
      }
   }
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      
      switch self {
      case .codeInterpreterToolCall(let value):
         try container.encode(value)
      case .retrieveToolCall(let value):
         try container.encode(value)
      case .functionToolCall(let value):
         try container.encode(value)
      }
   }
}

// MARK: CodeInterpreterToolCall

public struct CodeInterpreterToolCall: Codable {
   public var input: String?
   public let outputs: [CodeInterpreterOutput]?
   
   enum CodingKeys: String, CodingKey {
      case input, outputs
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      input = try container.decodeIfPresent(String.self, forKey: .input)
      // This is neede as the input is retrieved as ""input": "# Calculate the square root of 500900\nmath.sqrt(500900)"
      input = input?.replacingOccurrences(of: "\\n", with: "\n")
      outputs = try container.decodeIfPresent([CodeInterpreterOutput].self, forKey: .outputs)
   }
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      // Revert the newline characters to their escaped form
      let encodedInput = input?.replacingOccurrences(of: "\n", with: "\\n")
      try container.encode(encodedInput, forKey: .input)
      try container.encode(outputs, forKey: .outputs)
   }
}

public enum CodeInterpreterOutput: Codable {
   
   case logs(CodeInterpreterLogOutput)
   case images(CodeInterpreterImageOutput)
   
   private enum CodingKeys: String, CodingKey {
      case type
   }
   
   private enum OutputType: String, Decodable {
      case logs, images
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let outputType = try container.decode(OutputType.self, forKey: .type)
      
      switch outputType {
      case .logs:
         let logOutput = try CodeInterpreterLogOutput(from: decoder)
         self = .logs(logOutput)
      case .images:
         let imageOutput = try CodeInterpreterImageOutput(from: decoder)
         self = .images(imageOutput)
      }
   }
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      switch self {
      case .logs(let logOutput):
         try container.encode(OutputType.logs.rawValue, forKey: .type)
         try logOutput.encode(to: encoder)
      case .images(let imageOutput):
         try container.encode(OutputType.images.rawValue, forKey: .type)
         try imageOutput.encode(to: encoder)
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
      public let fileID: String
      
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
   
   /// The name of the function.
   public let name: String
   /// The arguments passed to the function.
   public let arguments: String
   /// The output of the function. This will be null if the outputs have not been [submitted](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs) yet.
   public let output: String?
}
