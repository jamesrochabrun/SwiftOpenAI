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
public enum ToolChoice: Encodable, Equatable {
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
}
