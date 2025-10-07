//
//  MessageObject.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// BETA.
/// Represents a [message](https://platform.openai.com/docs/api-reference/messages) within a [thread](https://platform.openai.com/docs/api-reference/threads).
/// [Message Object](https://platform.openai.com/docs/api-reference/messages/object)
public struct MessageObject: Codable {
  public init(
    id: String,
    object: String,
    createdAt: Int,
    threadID: String,
    status: String?,
    incompleteDetails: IncompleteDetails?,
    completedAt: Int?,
    role: String,
    content: [MessageContent],
    assistantID: String?,
    runID: String?,
    attachments: [MessageAttachment]?,
    metadata: [String: String]?)
  {
    self.id = id
    self.object = object
    self.createdAt = createdAt
    self.threadID = threadID
    self.status = status
    self.incompleteDetails = incompleteDetails
    self.completedAt = completedAt
    self.role = role
    self.content = content
    self.assistantID = assistantID
    self.runID = runID
    self.attachments = attachments
    self.metadata = metadata
  }

  /// The identifier, which can be referenced in API endpoints.
  public let id: String
  /// The object type, which is always thread.message.
  public let object: String
  /// The Unix timestamp (in seconds) for when the message was created.
  public let createdAt: Int
  /// The [thread](https://platform.openai.com/docs/api-reference/threads) ID that this message belongs to.
  public let threadID: String
  /// The status of the message, which can be either in_progress, incomplete, or completed.
  public let status: String?
  /// On an incomplete message, details about why the message is incomplete.
  public let incompleteDetails: IncompleteDetails?
  /// The Unix timestamp (in seconds) for when the message was completed.
  public let completedAt: Int?
  /// The entity that produced the message. One of user or assistant.
  public let role: String
  /// The content of the message in array of text and/or images.
  public let content: [MessageContent]
  /// If applicable, the ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) that authored this message.
  public let assistantID: String?
  /// If applicable, the ID of the [run](https://platform.openai.com/docs/api-reference/runs) associated with the authoring of this message.
  public let runID: String?
  /// A list of files attached to the message, and the tools they were added to.
  public let attachments: [MessageAttachment]?
  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  public let metadata: [String: String]?

  enum Role: String {
    case user
    case assistant
  }

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case createdAt = "created_at"
    case threadID = "thread_id"
    case status
    case incompleteDetails = "incomplete_details"
    case completedAt = "completed_at"
    case role
    case content
    case assistantID = "assistant_id"
    case runID = "run_id"
    case attachments
    case metadata
  }
}
