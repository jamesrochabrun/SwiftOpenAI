//
//  MicrophonePCMSampleVendorError.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

import Foundation

public enum MicrophonePCMSampleVendorError: LocalizedError, Sendable {
  case couldNotConfigureAudioUnit(String)

  public var errorDescription: String? {
    switch self {
    case .couldNotConfigureAudioUnit(let message):
      message
    }
  }
}
