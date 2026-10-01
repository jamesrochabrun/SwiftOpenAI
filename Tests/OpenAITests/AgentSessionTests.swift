import XCTest
@testable import SwiftOpenAI

final class AgentSessionTests: XCTestCase {

  // MARK: Parameters encoding

  func testSessionParametersEncodeDocumentedShape() throws {
    let parameters = AgentSessionParameters(
      agent: .init(
        model: .gpt6Astra,
        instructions: "Write clean code, run it, and report the actual output.",
        tools: [.computerUse(includeScreenshots: true), .webSearch]),
      environment: .init(type: .openAIHosted, desktop: .init(enabled: true)),
      input: "Create tree.py and run it.",
      stream: true)

    let json = try encodeToDictionary(parameters)

    let agent = try XCTUnwrap(json["agent"] as? [String: Any])
    XCTAssertEqual(agent["model"] as? String, "gpt-6-astra")
    XCTAssertEqual(agent["instructions"] as? String, "Write clean code, run it, and report the actual output.")
    let tools = try XCTUnwrap(agent["tools"] as? [[String: Any]])
    XCTAssertEqual(tools[0]["type"] as? String, "computer_use")
    XCTAssertEqual(tools[0]["include_screenshots"] as? Bool, true)
    XCTAssertEqual(tools[1]["type"] as? String, "web_search")

    let environment = try XCTUnwrap(json["environment"] as? [String: Any])
    XCTAssertEqual(environment["type"] as? String, "openai_hosted")
    let desktop = try XCTUnwrap(environment["desktop"] as? [String: Any])
    XCTAssertEqual(desktop["enabled"] as? Bool, true)

    XCTAssertEqual(json["input"] as? String, "Create tree.py and run it.")
    XCTAssertEqual(json["stream"] as? Bool, true)
  }

  func testCustomToolEncodesVerbatim() throws {
    let parameters = AgentSessionParameters(
      agent: .init(
        model: .gpt6Astra,
        tools: [.custom(["type": "mcp", "server_url": "https://example.com/mcp"])]))

    let json = try encodeToDictionary(parameters)
    let agent = try XCTUnwrap(json["agent"] as? [String: Any])
    let tools = try XCTUnwrap(agent["tools"] as? [[String: Any]])
    XCTAssertEqual(tools[0]["type"] as? String, "mcp")
    XCTAssertEqual(tools[0]["server_url"] as? String, "https://example.com/mcp")
  }

  func testClientEventsEncodeDocumentedShapes() throws {
    let parameters = AgentSessionEventsParameter(events: [
      .message("Now add unit tests."),
      .cancel,
      .custom(["type": "approval", "request_id": "req_123", "response": "approve"]),
    ])

    let json = try encodeToDictionary(parameters)
    let events = try XCTUnwrap(json["events"] as? [[String: Any]])
    XCTAssertEqual(events.count, 3)

    XCTAssertEqual(events[0]["type"] as? String, "agent.session.input.message")
    let input = try XCTUnwrap(events[0]["input"] as? [[String: Any]])
    XCTAssertEqual(input[0]["role"] as? String, "user")
    let content = try XCTUnwrap(input[0]["content"] as? [[String: Any]])
    XCTAssertEqual(content[0]["type"] as? String, "input_text")
    XCTAssertEqual(content[0]["text"] as? String, "Now add unit tests.")

    XCTAssertEqual(events[1]["type"] as? String, "agent.session.input.cancel")

    XCTAssertEqual(events[2]["type"] as? String, "approval")
    XCTAssertEqual(events[2]["request_id"] as? String, "req_123")
    XCTAssertEqual(events[2]["response"] as? String, "approve")
  }

  // MARK: Stream event decoding

  func testStreamEventDecodesDocumentedTypes() throws {
    let fixtures: [(String, AgentSessionStreamEvent.Kind)] = [
      ("agent.session.idle", .sessionIdle),
      ("agent.session.failed", .sessionFailed),
      ("agent.session.requires_action", .requiresAction),
      ("agent.session.turn.output_text.done", .turnOutputTextDone),
      ("agent.session.turn.completed", .turnCompleted),
      ("agent.session.turn.failed", .turnFailed),
      ("agent.session.turn.cancelled", .turnCancelled),
    ]
    for (type, kind) in fixtures {
      let data = Data("{\"type\":\"\(type)\",\"session_id\":\"sess_1\"}".utf8)
      let event = try JSONDecoder().decode(AgentSessionStreamEvent.self, from: data)
      XCTAssertEqual(event.kind, kind, type)
      XCTAssertEqual(event.sessionId, "sess_1", type)
    }
  }

  func testUnknownStreamEventTypeDoesNotFailDecoding() throws {
    let data = Data("{\"type\":\"agent.session.some.future.event\",\"turn_id\":\"turn_9\"}".utf8)
    let event = try JSONDecoder().decode(AgentSessionStreamEvent.self, from: data)
    XCTAssertEqual(event.kind, .unknown("agent.session.some.future.event"))
    XCTAssertEqual(event.turnId, "turn_9")
  }

  func testOutputTextEventExposesTextAndRawPayload() throws {
    let data = Data("""
      {"type":"agent.session.turn.output_text.done","session_id":"sess_1","turn_id":"turn_1","text":"All done.","extra":{"tokens":42}}
      """.utf8)
    let event = try JSONDecoder().decode(AgentSessionStreamEvent.self, from: data)
    XCTAssertEqual(event.text, "All done.")
    guard
      case .object(let root) = event.raw,
      case .object(let extra)? = root["extra"],
      case .int(let tokens)? = extra["tokens"]
    else {
      return XCTFail("raw payload should retain undocumented members")
    }
    XCTAssertEqual(tokens, 42)
  }

  // MARK: Item decoding

  func testComputerUseCallItemDecodes() throws {
    let data = Data("""
      {"id":"item_1","turn_id":"turn_1","type":"computer_use_call","title":"Open browser","status":"completed","output":"aGVsbG8="}
      """.utf8)
    let item = try JSONDecoder().decode(AgentSessionItem.self, from: data)
    XCTAssertEqual(item.id, "item_1")
    XCTAssertEqual(item.turnId, "turn_1")
    XCTAssertEqual(item.type, "computer_use_call")
    XCTAssertEqual(item.title, "Open browser")
    XCTAssertEqual(item.status, "completed")
    guard case .object(let root) = item.raw, case .string(let output)? = root["output"] else {
      return XCTFail("raw payload should retain the output member")
    }
    XCTAssertEqual(output, "aGVsbG8=")
  }

  func testSessionObjectDecodesWithPartialSchema() throws {
    let data = Data("{\"id\":\"sess_1\",\"object\":\"agent.session\",\"status\":\"idle\",\"created_at\":1790000000}".utf8)
    let session = try JSONDecoder().decode(AgentSessionObject.self, from: data)
    XCTAssertEqual(session.id, "sess_1")
    XCTAssertEqual(session.object, "agent.session")
    XCTAssertEqual(session.status, "idle")
    XCTAssertEqual(session.createdAt, 1790000000)
  }

  // MARK: Helpers

  private func encodeToDictionary(_ value: some Encodable) throws -> [String: Any] {
    let data = try JSONEncoder().encode(value)
    return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
  }
}
