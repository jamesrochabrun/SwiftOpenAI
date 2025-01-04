//
//  TokenLimit.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/3/25.
//

import Foundation

/// Token limit representation for max response tokens. Used in Real time API

public enum TokenLimit: Codable {
   case finite(Int)
   case infinite
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .finite(let value):
         try container.encode(value)
      case .infinite:
         try container.encode("inf")
      }
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let intValue = try? container.decode(Int.self) {
         self = .finite(intValue)
      } else if let stringValue = try? container.decode(String.self), stringValue == "inf" {
         self = .infinite
      } else {
         throw DecodingError.typeMismatch(
            TokenLimit.self,
            DecodingError.Context(
               codingPath: decoder.codingPath,
               debugDescription: "Expected either an integer or 'inf' string"
            )
         )
      }
   }
}
