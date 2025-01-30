//
//  OpenAIRealtimeResponseCreate.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/18/25.
//

import Foundation

public struct OpenAIRealtimeResponseCreate: Encodable {
   public let type = "response.create"
   public let response: Response?
   
   public init(response: Response? = nil) {
      self.response = response
   }
}

// MARK: - ResponseCreate.Response

extension OpenAIRealtimeResponseCreate {
   
   public struct Response: Encodable {
      public let instructions: String?
      public let modalities: [String]?
      
      public init(
         instructions: String? = nil,
         modalities: [String]? = nil
      ) {
         self.modalities = modalities
         self.instructions = instructions
      }
   }
}
