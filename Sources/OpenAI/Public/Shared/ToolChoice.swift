//
//  ToolChoice.swift
//  
//
//  Created by James Rochabrun on 4/13/24.
//

import Foundation

/// string `none` means the model will not call a function and instead generates a message.
/// `auto` means the model can pick between generating a message or calling a function.
/// `object` Specifies a tool the model should use. Use to force the model to call a specific function. The type of the tool. Currently, only` function` is supported. `{"type: "function", "function": {"name": "my_function"}}`
public enum ToolChoice: Codable, Equatable {
   case none
   case auto
   case function(type: String = "function", name: String)
   
   enum CodingKeys: String, CodingKey {
      case none = "none"
      case auto = "auto"
      case type = "type"
      case function = "function"
   }
   
   enum FunctionCodingKeys: String, CodingKey {
      case name = "name"
   }
   
   public func encode(to encoder: Encoder) throws {
      switch self {
      case .none:
         var container = encoder.singleValueContainer()
         try container.encode(CodingKeys.none.rawValue)
      case .auto:
         var container = encoder.singleValueContainer()
         try container.encode(CodingKeys.auto.rawValue)
      case .function(let type, let name):
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(type, forKey: .type)
         var functionContainer = container.nestedContainer(keyedBy: FunctionCodingKeys.self, forKey: .function)
         try functionContainer.encode(name, forKey: .name)
      }
   }
   
   public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       if let _ = try? container.decode(String.self, forKey: .none) {
           self = .none
           return
       }
       if let _ = try? container.decode(String.self, forKey: .auto) {
           self = .auto
           return
       }
       let functionContainer = try container.nestedContainer(keyedBy: FunctionCodingKeys.self, forKey: .function)
       let name = try functionContainer.decode(String.self, forKey: .name)
       // Assuming the type is always "function" as default if decoding this case.
       self = .function(type: "function", name: name)
   }
}
