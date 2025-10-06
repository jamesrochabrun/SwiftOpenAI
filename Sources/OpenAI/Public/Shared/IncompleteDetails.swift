//
//  IncompleteDetails.swift
//
//
//  Created by James Rochabrun on 4/25/24.
//

import Foundation

/// Message: On an incomplete message, details about why the message is incomplete.
/// Run: Details on why the run is incomplete. Will be null if the run is not incomplete.
public struct IncompleteDetails: Codable {
  /// Message: The reason the message is incomplete.
  /// Run: The reason why the run is incomplete. This will point to which specific token limit was reached over the course of the run.
  let reason: String
}
