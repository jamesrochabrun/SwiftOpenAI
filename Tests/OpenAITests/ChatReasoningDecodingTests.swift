import XCTest
@testable import SwiftOpenAI

final class ChatReasoningDecodingTests: XCTestCase {
  func testStreamingOpenRouterReasoningIsPreserved() throws {
    let delta = try decodeDelta(["reasoning": "  Thinking...\n理由"])
    XCTAssertEqual(delta.reasoningContent, "  Thinking...\n理由")
  }

  func testNonStreamingOpenRouterReasoningIsPreserved() throws {
    let message = try decodeMessage(["reasoning": "  Thinking...\n理由"])
    XCTAssertEqual(message.reasoningContent, "  Thinking...\n理由")
  }

  func testExistingReasoningContentAndAliasPrecedence() throws {
    let cases: [(fields: [String: Any], expected: String)] = [
      (["reasoning_content": "Existing reasoning"], "Existing reasoning"),
      (["reasoning_content": "Existing reasoning", "reasoning": "Alias"], "Existing reasoning"),
      (["reasoning_content": "", "reasoning": "Alias"], ""),
      (["reasoning_content": NSNull(), "reasoning": "Alias"], "Alias"),
    ]
    for (fields, expected) in cases {
      XCTAssertEqual(try decodeDelta(fields).reasoningContent, expected)
      XCTAssertEqual(try decodeMessage(fields).reasoningContent, expected)
    }
  }

  func testReasoningRemainsOptional() throws {
    for fields: [String: Any] in [[:], ["reasoning": NSNull()], ["reasoning_content": NSNull()]] {
      XCTAssertNil(try decodeDelta(fields).reasoningContent)
      XCTAssertNil(try decodeMessage(fields).reasoningContent)
    }
  }

  func testStreamingOtherFieldsArePreserved() throws {
    let delta = try decodeDelta([
      "content": "Answer",
      "reasoning": "Reasoning",
      "role": "assistant",
      "refusal": "Refusal",
      "tool_calls": [["id": "call_1", "type": "function", "function": ["name": "lookup", "arguments": "{}"]]],
      "function_call": ["name": "legacy", "arguments": "{}"],
    ])
    XCTAssertEqual(delta.content, "Answer")
    XCTAssertEqual(delta.role, "assistant")
    XCTAssertEqual(delta.refusal, "Refusal")
    XCTAssertEqual(delta.toolCalls?.first?.id, "call_1")
    XCTAssertEqual(delta.functionCall?.name, "legacy")
  }

  func testNonStreamingOtherFieldsArePreserved() throws {
    let message = try decodeMessage([
      "content": "Answer",
      "reasoning": "Reasoning",
      "role": "assistant",
      "refusal": "Refusal",
      "tool_calls": [["id": "call_1", "type": "function", "function": ["name": "lookup", "arguments": "{}"]]],
      "function_call": ["name": "legacy", "arguments": "{}"],
      "finish_details": ["type": "stop"],
      "audio": ["id": "audio_1", "expires_at": 123, "data": "YQ==", "transcript": "Answer"],
    ])
    XCTAssertEqual(message.content, "Answer")
    XCTAssertEqual(message.role, "assistant")
    XCTAssertEqual(message.refusal, "Refusal")
    XCTAssertEqual(message.toolCalls?.first?.id, "call_1")
    XCTAssertEqual(message.functionCall?.name, "legacy")
    XCTAssertEqual(message.finishDetails?.type, "stop")
    XCTAssertEqual(message.audio?.id, "audio_1")
    XCTAssertEqual(message.audio?.expiresAt, 123)
    XCTAssertEqual(message.audio?.data, "YQ==")
    XCTAssertEqual(message.audio?.transcript, "Answer")
  }

  func testInvalidReasoningTypesAreRejected() {
    for fields in [["reasoning": 42], ["reasoning_content": 42]] {
      XCTAssertThrowsError(try decodeDelta(fields))
      XCTAssertThrowsError(try decodeMessage(fields))
    }
  }

  private func decodeDelta(_ fields: [String: Any]) throws -> ChatCompletionChunkObject.ChatChoice.Delta {
    let data = try JSONSerialization.data(withJSONObject: ["choices": [["delta": fields]]])
    let response = try JSONDecoder().decode(ChatCompletionChunkObject.self, from: data)
    return try XCTUnwrap(response.choices?.first?.delta)
  }

  private func decodeMessage(_ fields: [String: Any]) throws -> ChatCompletionObject.ChatChoice.ChatMessage {
    let data = try JSONSerialization.data(withJSONObject: ["choices": [["message": fields]]])
    let response = try JSONDecoder().decode(ChatCompletionObject.self, from: data)
    return try XCTUnwrap(response.choices?.first?.message)
  }
}
