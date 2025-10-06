//
//  StreamOptions.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

// MARK: StreamOptions

/// Defaults to null
/// Options for streaming responses. Only set this when you set stream: true.
public struct StreamOptions: Codable {
  /// When true, stream obfuscation will be enabled. Stream obfuscation adds random characters to an obfuscation field on streaming delta events to normalize payload sizes as a mitigation to certain side-channel attacks. These obfuscation fields are included by default, but add a small amount of overhead to the data stream. You can set include_obfuscation to false to optimize for bandwidth if you trust the network links between your application and the OpenAI API.
  public var includeObfuscation: Bool?

  public init(includeObfuscation: Bool? = nil) {
    self.includeObfuscation = includeObfuscation
  }

  enum CodingKeys: String, CodingKey {
    case includeObfuscation = "include_obfuscation"
  }
}
