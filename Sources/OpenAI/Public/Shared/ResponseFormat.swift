//
//  ResponseFormat.swift
//  
//
//  Created by James Rochabrun on 4/13/24.
//

import Foundation


/// Defaults to text
/// Setting to `json_object` enables JSON mode. This guarantees that the message the model generates is valid JSON.
/// Note that your system prompt must still instruct the model to produce JSON, and to help ensure you don't forget, the API will throw an error if the string JSON does not appear in your system message.
/// Also note that the message content may be partial (i.e. cut off) if `finish_reason="length"`, which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
/// Must be one of `text `or `json_object`.
public enum ResponseFormat: Codable, Equatable {
   case auto
   case type(String)

   enum CodingKeys: String, CodingKey {
      case type = "type"
   }

   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .auto:
         try container.encode("text", forKey: .type)
      case .type(let responseType):
         try container.encode(responseType, forKey: .type)
      }
   }

   public init(from decoder: Decoder) throws {
      // Handle the 'type' case:
      if let container = try? decoder.container(keyedBy: CodingKeys.self),
         let responseType = try? container.decode(String.self, forKey: .type) {
         self = .type(responseType)
         return
      }

      // Handle the 'auto' case:
      let container = try decoder.singleValueContainer()
      switch try container.decode(String.self) {
      case "auto":
         self = .auto
      default:
         throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid response_format structure")
      }
   }
}
