//
//  OpenAIError.swift
//  SwiftOpenAI
//

import Foundation

public enum OpenAIError: LocalizedError {
  case audioConfigurationError(String)
  case assertion(String)

  public var errorDescription: String? {
    switch self {
    case .audioConfigurationError(let message):
      "Audio configuration error: \(message)"
    case .assertion(let message):
      "SwiftOpenAI - A library precondition was not met: \(message)"
    }
  }
}
