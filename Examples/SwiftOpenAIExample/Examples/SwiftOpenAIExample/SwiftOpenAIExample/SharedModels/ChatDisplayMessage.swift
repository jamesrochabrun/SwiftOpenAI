//
//  ChatDisplayMessage.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/4/23.
//

import Foundation
import SwiftOpenAI

struct ChatDisplayMessage: Identifiable {
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
      case (.images(let a), .images(let b)):
        a == b
      case (.content(let a), .content(let b)):
        a == b
      case (.error(let a), .error(let b)):
        a == b
      default:
        false
      }
    }
  }

  enum DisplayMessageType {
    case received, sent
  }

  let id: UUID
  let content: DisplayContent
  let type: DisplayMessageType
  let delta: Delta?
}
