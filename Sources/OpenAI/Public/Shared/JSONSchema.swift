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
   
   public let type: JSONSchemaType?
   public let description: String?
   public var properties: [String: JSONSchema]?
   public var items: JSONSchema?
   /// To use Structured Outputs, all fields or function parameters [must be specified as required.](https://platform.openai.com/docs/guides/structured-outputs/all-fields-must-be-required)
   /// Although all fields must be required (and the model will return a value for each parameter), it is possible to emulate an optional parameter by using a union type with null.
   public let required: [String]?
   /// Structured Outputs only supports generating specified keys / values, so we require developers to set additionalProperties: false to opt into Structured Outputs.
   public let additionalProperties: Bool?
   public let `enum`: [String]?
   public var ref: String?
   
   public init(
      type: JSONSchemaType? = nil,
      description: String? = nil,
      properties: [String: JSONSchema]? = nil,
      items: JSONSchema? = nil,
      required: [String]? = nil,
      additionalProperties: Bool? = nil,
      enum: [String]? = nil,
      ref: String? = nil
   ) {
      self.type = type
      self.description = description
      self.properties = properties
      self.items = items
      self.required = required
      self.additionalProperties = additionalProperties
      self.enum = `enum`
      self.ref = ref
   }
   
   public static func == (lhs: JSONSchema, rhs: JSONSchema) -> Bool {
      lhs.type == rhs.type &&
      lhs.description == rhs.description &&
      lhs.properties == rhs.properties &&
      lhs.items == rhs.items &&
      lhs.required == rhs.required &&
      lhs.additionalProperties == rhs.additionalProperties &&
      lhs.enum == rhs.enum &&
      lhs.ref == rhs.ref
   }
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      // [Recursive schema support](https://platform.openai.com/docs/guides/structured-outputs/supported-schemas?context=without_parse)
      if let ref = ref {
         try container.encode(ref, forKey: .ref)
         return
      }
      
      try container.encodeIfPresent(type, forKey: .type)
      try container.encodeIfPresent(description, forKey: .description)
      try container.encodeIfPresent(properties, forKey: .properties)
      try container.encodeIfPresent(items, forKey: .items)
      try container.encodeIfPresent(required, forKey: .required)
      try container.encodeIfPresent(additionalProperties, forKey: .additionalProperties)
      try container.encodeIfPresent(`enum`, forKey: .enum)
   }
   
   public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      // [Recursive schema support](https://platform.openai.com/docs/guides/structured-outputs/supported-schemas?context=without_parse)
      if let ref = try? container.decode(String.self, forKey: .ref) {
         self.ref = ref
         type = nil
         description = nil
         properties = nil
         items = nil
         required = nil
         additionalProperties = nil
         `enum` = nil
         return
      }
      
      type = try container.decodeIfPresent(JSONSchemaType.self, forKey: .type)
      description = try container.decodeIfPresent(String.self, forKey: .description)
      properties = try container.decodeIfPresent([String: JSONSchema].self, forKey: .properties)
      items = try container.decodeIfPresent(JSONSchema.self, forKey: .items)
      required = try container.decodeIfPresent([String].self, forKey: .required)
      additionalProperties = try container.decodeIfPresent(Bool.self, forKey: .additionalProperties)
      `enum` = try container.decodeIfPresent([String].self, forKey: .enum)
      ref = nil
   }
   
   private enum CodingKeys: String, CodingKey {
      case type, description, properties, items, required, additionalProperties, `enum`, ref = "$ref"
   }
}
