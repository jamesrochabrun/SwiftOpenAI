import XCTest
@testable import SwiftOpenAI

final class ChatCompletionParametersTests: XCTestCase {
  func testReasoningOverridesEncoding() throws {
    var parameters = ChatCompletionParameters(
      messages: [.init(role: .user, content: .text("hello"))],
      model: .gpt4o,
      reasoning: .init(effort: "medium", exclude: true, maxTokens: 256),
      streamOptions: .init(includeUsage: true))
    parameters.stream = true

    let encoder = JSONEncoder()
    let data = try encoder.encode(parameters)

    let root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(root["stream"] as? Bool, true)

    let streamOptions = try XCTUnwrap(root["stream_options"] as? [String: Any])
    XCTAssertEqual(streamOptions["include_usage"] as? Bool, true)

    let reasoning = try XCTUnwrap(root["reasoning"] as? [String: Any])
    XCTAssertEqual(reasoning["effort"] as? String, "medium")
    XCTAssertEqual(reasoning["exclude"] as? Bool, true)
    XCTAssertEqual(reasoning["max_tokens"] as? Int, 256)
  }
}
