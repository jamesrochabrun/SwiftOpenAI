//
//  ModifyRunParameters.swift
//
//
//  Created by James Rochabrun on 11/29/23.
//

import Foundation

/// Modifies a [Run](https://platform.openai.com/docs/api-reference/runs/modifyRun)
/// Only the metadata can be modified.
public struct ModifyRunParameters: Encodable {
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public var metadata: [String: String]

  public init(
    metadata: [String: String])
  {
    self.metadata = metadata
  }
}
