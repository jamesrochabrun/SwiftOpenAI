//
//  LocalModelAPI.swift
//
//
//  Created by James Rochabrun on 6/30/24.
//

import Foundation

enum LocalModelAPI {
   
   static var overrideBaseURL: String? = nil
   
   case chat
}

extension LocalModelAPI: Endpoint {
   
   var base: String {
      Self.overrideBaseURL ?? "http://localhost:11434"
   }
   
   var path: String {
      switch self {
      case .chat: "/v1/chat/completions"
      }
   }
}
