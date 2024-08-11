//
//  JSONSchema.swift
//  
//
//  Created by James Rochabrun on 8/10/24.
//

import Foundation

// MARK: JSONSchemaType

/// Supported schemas
///
/// Structured Outputs supports a subset of the JSON Schema language.
///
/// Supported types
///
/// The following types are supported for Structured Outputs:
///
/// String
/// Number
/// Boolean
/// Object
/// Array
/// Enum
/// anyOf
public enum JSONSchemaType: String, Codable {
   case string, integer, number, boolean, object, array, `enum`, anyOf
}

public class JSONSchema: Codable, Equatable {
   public init(
      type: JSONSchemaType,
      description: String? = nil,
      properties: [String: JSONSchema]? = nil,
      items: JSONSchema? = nil,
      required: [String]? = nil,
      additionalProperties: Bool = false,
      enum: [String]? = nil
   ) {
      self.type = type
      self.description = description
      self.properties = properties
      self.items = items
      self.required = required
      self.additionalProperties = additionalProperties
      self.enum = `enum`
   }
   
   public static func == (lhs: JSONSchema, rhs: JSONSchema) -> Bool {
      lhs.type == rhs.type &&
      lhs.description == rhs.description &&
      lhs.properties == rhs.properties &&
      lhs.items == rhs.items &&
      lhs.required == rhs.required &&
      lhs.additionalProperties == rhs.additionalProperties &&
      lhs.enum == rhs.enum
   }
   
   let type: JSONSchemaType
   let description: String?
   let properties: [String: JSONSchema]?
   let items: JSONSchema?
   /// To use Structured Outputs, all fields or function parameters [must be specified as required.](https://platform.openai.com/docs/guides/structured-outputs/all-fields-must-be-required)
   /// Although all fields must be required (and the model will return a value for each parameter), it is possible to emulate an optional parameter by using a union type with null.
   let required: [String]?
   /// [additionalProperties](https://platform.openai.com/docs/guides/structured-outputs/additionalproperties-false-must-always-be-set-in-objects) controls whether it is allowable for an object to contain additional keys / values that were not defined in the JSON Schema.
   /// Structured Outputs only supports generating specified keys / values, so we require developers to set additionalProperties: false to opt into Structured Outputs.
   let additionalProperties: Bool?
   let `enum`: [String]?
   
   enum CodingKeys: String, CodingKey {
      case type, description, properties, items, required, additionalProperties, `enum`
   }
}
