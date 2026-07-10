//
//  OpenAIRealtimeMCPApprovalResponse.swift
//  SwiftOpenAI
//

import Foundation

// MARK: - OpenAIRealtimeMCPApprovalResponse

/// Approves or rejects an MCP tool approval request in a Realtime session.
public struct OpenAIRealtimeMCPApprovalResponse: Encodable, Sendable {
  public init(
    approvalRequestID: String,
    approve: Bool,
    id: String,
    reason: String? = nil)
  {
    item = .init(
      approvalRequestID: approvalRequestID,
      approve: approve,
      id: id,
      reason: reason)
  }

  public let type = "conversation.item.create"
  public let item: Item
}

// MARK: OpenAIRealtimeMCPApprovalResponse.Item

extension OpenAIRealtimeMCPApprovalResponse {
  public struct Item: Encodable, Sendable {
    public init(
      approvalRequestID: String,
      approve: Bool,
      id: String,
      reason: String? = nil)
    {
      self.approvalRequestID = approvalRequestID
      self.approve = approve
      self.id = id
      self.reason = reason
    }

    public let type = "mcp_approval_response"
    public let approvalRequestID: String
    public let approve: Bool
    public let id: String
    public let reason: String?

    private enum CodingKeys: String, CodingKey {
      case approvalRequestID = "approval_request_id"
      case approve
      case id
      case reason
      case type
    }
  }
}
