//
//  FileCount.swift
//
//
//  Created by James Rochabrun on 4/29/24.
//

import Foundation

public struct FileCount: Decodable {
  /// The number of files that are currently being processed.
  let inProgress: Int
  /// The number of files that have been successfully processed.
  let completed: Int
  /// The number of files that have failed to process.
  let failed: Int
  /// The number of files that were cancelled.
  let cancelled: Int
  /// The total number of files.
  let total: Int

  enum CodingKeys: String, CodingKey {
    case inProgress = "in_progress"
    case completed
    case failed
    case cancelled
    case total
  }
}
