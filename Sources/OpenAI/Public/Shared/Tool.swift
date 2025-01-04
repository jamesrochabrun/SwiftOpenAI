//
//  Tool.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/3/25.
//

import Foundation

/// Used in Real time API
public struct Tool: Codable {
   /// The type of the tool, i.e. `function`
   public let type: String?
   
   /// The name of the function
   public let name: String?
   
   /// The description of the function
   public let description: String?
   
   /// Parameters of the function in JSON Schema
   public let parameters: JSONSchema?
   
   public init(
      type: String? = nil,
      name: String? = nil,
      description: String? = nil,
      parameters: JSONSchema? = nil
   ) {
      self.type = type
      self.name = name
      self.description = description
      self.parameters = parameters
   }
}
