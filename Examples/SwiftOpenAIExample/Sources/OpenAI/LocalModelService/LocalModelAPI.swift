//
//  LocalModelAPI.swift
//
//
//  Created by James Rochabrun on 6/30/24.
//

import Foundation

// MARK: - LocalModelAPI

enum LocalModelAPI {
  case chat
}

// MARK: Endpoint

extension LocalModelAPI: Endpoint {
  /// Builds the final path that includes:
  ///   - optional proxy path (e.g. "/my-proxy")
  ///   - version if non-nil (e.g. "/v1")
  ///   - then the specific endpoint path (e.g. "/assistants")
  func path(in openAIEnvironment: OpenAIEnvironment) -> String {
    // 1) Potentially prepend proxy path if `proxyPath` is non-empty
    let proxyPart =
      if let envProxyPart = openAIEnvironment.proxyPath, !envProxyPart.isEmpty {
        "/\(envProxyPart)"
      } else {
        ""
      }
    let mainPart = openAIPath(in: openAIEnvironment)

    return proxyPart + mainPart // e.g. "/my-proxy/v1/assistants"
  }

  func openAIPath(in openAIEnvironment: OpenAIEnvironment) -> String {
    let version =
      if let envOverrideVersion = openAIEnvironment.version, !envOverrideVersion.isEmpty {
        "/\(envOverrideVersion)"
      } else {
        ""
      }
    switch self {
    case .chat: return "\(version)/chat/completions"
    }
  }
}
