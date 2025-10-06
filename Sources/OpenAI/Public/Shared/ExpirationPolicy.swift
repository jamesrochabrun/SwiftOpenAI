//
//  ExpirationPolicy.swift
//
//
//  Created by James Rochabrun on 4/27/24.
//

import Foundation

public struct ExpirationPolicy: Codable {
  /// Anchor timestamp after which the expiration policy applies. Supported anchors: last_active_at.
  let anchor: String
  /// The number of days after the anchor time that the vector store will expire.
  let days: Int
}
