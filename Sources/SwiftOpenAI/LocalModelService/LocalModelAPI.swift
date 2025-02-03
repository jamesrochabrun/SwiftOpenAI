//
//  LocalModelAPI.swift
//
//
//  Created by James Rochabrun on 6/30/24.
//

import Foundation

enum LocalModelAPI {
      
   case chat
}

extension LocalModelAPI: Endpoint {
   
   /// Builds the final path that includes:
   ///   - optional proxy path (e.g. "/my-proxy")
   ///   - version if non-nil (e.g. "/v1")
   ///   - then the specific endpoint path (e.g. "/assistants")
   func path(in openAIEnvironment: OpenAIEnvironment) -> String {
      // 1) Potentially prepend proxy path if `proxyPath` is non-empty
      let proxyPart: String
      if let envProxyPart = openAIEnvironment.proxyPath, !envProxyPart.isEmpty {
         proxyPart = "/\(envProxyPart)"
      } else {
         proxyPart = ""
      }
      let mainPart = openAIPath(in: openAIEnvironment)
      
      return proxyPart + mainPart // e.g. "/my-proxy/v1/assistants"
   }
   
   func openAIPath(in openAIEnvironment: OpenAIEnvironment) -> String {
      let version: String
      if let envOverrideVersion = openAIEnvironment.version, !envOverrideVersion.isEmpty {
         version = "/\(envOverrideVersion)"
      } else {
         version = ""
      }
      switch self {
      case .chat: return "\(version)/chat/completions"
      }
   }
}
