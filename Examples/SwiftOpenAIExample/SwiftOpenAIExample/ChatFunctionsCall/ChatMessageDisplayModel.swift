//
//  ChatMessageDisplayModel.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/13/23.
//

import Foundation
import SwiftOpenAI

struct ChatMessageDisplayModel: Identifiable {
  init(
    id: UUID = UUID(),
    content: DisplayContent,
    origin: MessageOrigin)
  {
    self.id = id
    self.content = content
    self.origin = origin
  }

  enum DisplayContent: Equatable {
    case content(DisplayMessageType)
    case error(String)

    static func ==(lhs: DisplayContent, rhs: DisplayContent) -> Bool {
      switch (lhs, rhs) {
      case (.content(let a), .content(let b)):
        a == b
      case (.error(let a), .error(let b)):
        a == b
      default:
        false
      }
    }

    struct DisplayMessageType: Equatable {
      var text: String?
      var urls: [URL]? = nil
    }
  }

  enum MessageOrigin {
    case received(ReceivedSource)
    case sent

    enum ReceivedSource {
      case gpt
      case dalle
    }
  }

  let id: UUID
  var content: DisplayContent
  let origin: MessageOrigin
}
