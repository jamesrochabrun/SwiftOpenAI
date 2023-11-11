//
//  ChatDisplayMessage.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/4/23.
//

import Foundation
import SwiftOpenAI

struct ChatDisplayMessage: Identifiable {
   
   let id: UUID
   let content: DisplayContent
   let type: DisplayMessageType
   let delta: Delta?
   
   struct Delta {
      var role: String
      var content: String
      var functionCallName: String?
      var functionCallArguments: String?
   }
   
   enum DisplayContent: Equatable {
      case text(String)
      case images([URL])
      case content([ChatCompletionParameters.Message.ContentType.MessageContent])
      case error(String)
      
      static func ==(lhs: DisplayContent, rhs: DisplayContent) -> Bool {
         switch (lhs, rhs) {
         case let (.images(a), .images(b)):
            return a == b
         case let (.content(a), .content(b)):
             return a == b
         case let (.error(a), .error(b)):
            return a == b
         default:
            return false
         }
      }
   }
   
   init(
      id: UUID = UUID(),
      content: DisplayContent,
      type: DisplayMessageType,
      delta: ChatDisplayMessage.Delta?)
   {
      self.id = id
      self.content = content
      self.type = type
      self.delta = delta
   }
   
   enum DisplayMessageType {
      case received, sent
   }
}
