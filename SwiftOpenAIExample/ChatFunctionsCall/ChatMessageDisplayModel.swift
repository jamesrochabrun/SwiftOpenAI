//
//  ChatMessageDisplayModel.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/13/23.
//

import Foundation
import SwiftOpenAI

struct ChatMessageDisplayModel: Identifiable {
   
   let id: UUID
   var content: DisplayContent
   let origin: MessageOrigin
   
   enum DisplayContent: Equatable {
      
      case content(DisplayMessageType)
      case error(String)
      
      static func ==(lhs: DisplayContent, rhs: DisplayContent) -> Bool {
         switch (lhs, rhs) {
         case let (.content(a), .content(b)):
             return a == b
         case let (.error(a), .error(b)):
            return a == b
         default:
            return false
         }
      }
      
      struct DisplayMessageType: Equatable {
         var text: String?
         var urls: [URL]? = nil
      }
   }
   
   init(
      id: UUID = UUID(),
      content: DisplayContent,
      origin: MessageOrigin)
   {
      self.id = id
      self.content = content
      self.origin = origin
   }
   
   enum MessageOrigin {
      
      case received(ReceivedSource)
      case sent
      
      enum ReceivedSource {
         case gpt
         case dalle
      }
   }
}
