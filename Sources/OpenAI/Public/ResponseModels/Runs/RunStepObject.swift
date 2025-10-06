//
//  RunStepObject.swift
//
//
//  Created by James Rochabrun on 11/17/23.
//

import Foundation

/// Represents a [step](https://platform.openai.com/docs/api-reference/runs/step-object) in execution of a run.
public struct RunStepObject: Codable {
  public init(
    id: String,
    object: String,
    createdAt: Int,
    assistantId: String,
    threadId: String,
    runId: String,
    type: String,
    status: Status,
    stepDetails: RunStepDetails,
    lastError: LastError?,
    expiredAt: Int?,
    cancelledAt: Int?,
    failedAt: Int?,
    completedAt: Int?,
    metadata: [String: String],
    usage: Usage?)
  {
    self.id = id
    self.object = object
    self.createdAt = createdAt
    self.assistantId = assistantId
    self.threadId = threadId
    self.runId = runId
    self.type = type
    self.status = status.rawValue
    self.stepDetails = stepDetails
    self.lastError = lastError
    self.expiredAt = expiredAt
    self.cancelledAt = cancelledAt
    self.failedAt = failedAt
    self.completedAt = completedAt
    self.metadata = metadata
    self.usage = usage
  }

  public enum Status: String {
    case inProgress = "in_progress"
    case cancelled
    case failed
    case completed
    case expired
  }

  /// The identifier of the run step, which can be referenced in API endpoints.
  public let id: String
  /// The object type, which is always `thread.run.step``.
  public let object: String
  /// The Unix timestamp (in seconds) for when the run step was created.
  public let createdAt: Int
  /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) associated with the run step.
  public let assistantId: String
  /// The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) that was run.
  public let threadId: String
  /// The ID of the [run](https://platform.openai.com/docs/api-reference/runs) that this run step is a part of.
  public let runId: String
  /// The type of run step, which can be either message_creation or tool_calls.
  public let type: String
  /// The status of the run step, which can be either in_progress, cancelled, failed, completed, or expired.
  public let status: String
  /// The details of the run step.
  public let stepDetails: RunStepDetails
  /// The last error associated with this run step. Will be null if there are no errors.
  public let lastError: LastError?
  /// The Unix timestamp (in seconds) for when the run step expired. A step is considered expired if the parent run is expired.
  public let expiredAt: Int?
  /// The Unix timestamp (in seconds) for when the run step was cancelled.
  public let cancelledAt: Int?
  /// The Unix timestamp (in seconds) for when the run step failed.
  public let failedAt: Int?
  /// The Unix timestamp (in seconds) for when the run step completed.
  public let completedAt: Int?
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public let metadata: [String: String]?
  /// Usage statistics related to the run step. This value will be null while the run step's status is in_progress.
  public let usage: Usage?

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    // Encode all properties
    try container.encode(id, forKey: .id)
    try container.encode(object, forKey: .object)
    try container.encode(createdAt, forKey: .createdAt)
    try container.encode(assistantId, forKey: .assistantId)
    try container.encode(threadId, forKey: .threadId)
    try container.encode(runId, forKey: .runId)
    try container.encode(type, forKey: .type)
    try container.encode(status, forKey: .status)
    try container.encode(stepDetails, forKey: .stepDetails)

    // Encode optional properties only if they are not nil
    try container.encodeIfPresent(lastError, forKey: .lastError)
    try container.encodeIfPresent(expiredAt, forKey: .expiredAt)
    try container.encodeIfPresent(cancelledAt, forKey: .cancelledAt)
    try container.encodeIfPresent(failedAt, forKey: .failedAt)
    try container.encodeIfPresent(completedAt, forKey: .completedAt)
    try container.encodeIfPresent(usage, forKey: .usage)

    // For the metadata dictionary, you can encode it directly if it is not nil
    try container.encodeIfPresent(metadata, forKey: .metadata)
  }

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case createdAt = "created_at"
    case assistantId = "assistant_id"
    case threadId = "thread_id"
    case runId = "run_id"
    case type
    case status
    case stepDetails = "step_details"
    case lastError = "last_error"
    case expiredAt = "expired_at"
    case cancelledAt = "cancelled_at"
    case failedAt = "failed_at"
    case completedAt = "completed_at"
    case metadata
    case usage
  }
}
