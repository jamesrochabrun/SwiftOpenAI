//
//  BatchObject.swift
//
//
//  Created by James Rochabrun on 4/27/24.
//

import Foundation

public struct BatchObject: Decodable {
  public struct Error: Decodable {
    let object: String
    let data: [Data]

    public struct Data: Decodable {
      /// An error code identifying the error type.
      let code: String
      /// A human-readable message providing more details about the error.
      let message: String
      /// The name of the parameter that caused the error, if applicable.
      let param: String?
      /// The line number of the input file where the error occurred, if applicable.
      let line: Int?
    }
  }

  public struct RequestCount: Decodable {
    /// Total number of requests in the batch.
    let total: Int
    /// Number of requests that have been completed successfully.
    let completed: Int
    /// Number of requests that have failed.
    let failed: Int
  }

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case endpoint
    case errors
    case inputFileID = "input_file_id"
    case completionWindow = "completion_window"
    case status
    case outputFileID = "output_file_id"
    case errorFileID = "error_file_id"
    case createdAt = "created_at"
    case inProgressAt = "in_progress_at"
    case expiresAt = "expires_at"
    case finalizingAt = "finalizing_at"
    case completedAt = "completed_at"
    case failedAt = "failed_at"
    case expiredAt = "expired_at"
    case cancellingAt = "cancelling_at"
    case cancelledAt = "cancelled_at"
    case requestCounts = "request_counts"
    case metadata
  }

  let id: String
  /// The object type, which is always batch.
  let object: String
  /// The OpenAI API endpoint used by the batch.
  let endpoint: String

  let errors: Error
  /// The ID of the input file for the batch.
  let inputFileID: String
  /// The time frame within which the batch should be processed.
  let completionWindow: String
  /// The current status of the batch.
  let status: String
  /// The ID of the file containing the outputs of successfully executed requests.
  let outputFileID: String
  /// The ID of the file containing the outputs of requests with errors.
  let errorFileID: String
  /// The Unix timestamp (in seconds) for when the batch was created.
  let createdAt: Int
  /// The Unix timestamp (in seconds) for when the batch started processing.
  let inProgressAt: Int
  /// The Unix timestamp (in seconds) for when the batch will expire.
  let expiresAt: Int
  /// The Unix timestamp (in seconds) for when the batch started finalizing.
  let finalizingAt: Int
  /// The Unix timestamp (in seconds) for when the batch was completed.
  let completedAt: Int
  /// The Unix timestamp (in seconds) for when the batch failed.
  let failedAt: Int
  /// The Unix timestamp (in seconds) for when the batch expired.
  let expiredAt: Int
  /// The Unix timestamp (in seconds) for when the batch started cancelling.
  let cancellingAt: Int
  /// The Unix timestamp (in seconds) for when the batch was cancelled.
  let cancelledAt: Int
  /// The request counts for different statuses within the batch.
  let requestCounts: RequestCount
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  let metadata: [String: String]
}
