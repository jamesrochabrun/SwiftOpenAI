//
//  ModifyMessageParameters.swift
//
//
//  Created by James Rochabrun on 11/25/23.
//

import Foundation

/// Modifies a [Message](https://platform.openai.com/docs/api-reference/messages/modifyMessage)
/// Only the metadata can be modified.
public struct ModifyMessageParameters: Encodable {
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public var metadata: [String: String]

  public init(
    metadata: [String: String])
  {
    self.metadata = metadata
  }
}
