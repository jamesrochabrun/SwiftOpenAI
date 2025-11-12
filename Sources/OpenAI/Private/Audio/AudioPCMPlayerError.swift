//
//  AudioPCMPlayerError.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

import Foundation

public enum AudioPCMPlayerError: LocalizedError, Sendable {
  case couldNotConfigureAudioEngine(String)

  public var errorDescription: String? {
    switch self {
    case .couldNotConfigureAudioEngine(let message):
      message
    }
  }
}
