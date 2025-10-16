//
//  GetResponseParameter.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

// MARK: GetResponseParameter

/// [Get a model response](https://platform.openai.com/docs/api-reference/responses/get)
public struct GetResponseParameter: Codable {
  /// Initialize a new GetResponseParameter
  public init(
    include: [ResponseInclude]? = nil,
    includeObfuscation: Bool? = nil,
    startingAfter: Int? = nil,
    stream: Bool? = nil)
  {
    self.include = include?.map(\.rawValue)
    self.includeObfuscation = includeObfuscation
    self.startingAfter = startingAfter
    self.stream = stream
  }

  /// Additional fields to include in the response.
  public var include: [String]?

  /// When true, stream obfuscation will be enabled. Stream obfuscation adds random characters to an obfuscation field on streaming delta events to normalize payload sizes as a mitigation to certain side-channel attacks.
  public var includeObfuscation: Bool?

  /// The sequence number of the event after which to start streaming.
  public var startingAfter: Int?

  /// If set to true, the model response data will be streamed to the client as it is generated using server-sent events.
  public var stream: Bool?

  enum CodingKeys: String, CodingKey {
    case include
    case includeObfuscation = "include_obfuscation"
    case startingAfter = "starting_after"
    case stream
  }
}
