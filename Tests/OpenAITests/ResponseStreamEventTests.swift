import XCTest
@testable import SwiftOpenAI

final class ResponseStreamEventTests: XCTestCase {
  // MARK: - Response Events Tests

  func testResponseCreatedEvent() throws {
    let json = """
      {
        "type": "response.created",
        "sequence_number": 1,
        "response": {
          "id": "resp_123",
          "object": "model_response",
          "created_at": 1704067200,
          "model": "gpt-4o",
          "usage": {
            "prompt_tokens": 10,
            "completion_tokens": 20,
            "total_tokens": 30
          },
          "output": [],
          "status": "in_progress",
          "metadata": {},
          "parallel_tool_calls": true,
          "text": {
            "format": {
              "type": "text"
            }
          },
          "tool_choice": "none",
          "tools": []
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .responseCreated(let createdEvent) = event {
      XCTAssertEqual(createdEvent.type, "response.created")
      XCTAssertEqual(createdEvent.sequenceNumber, 1)
      XCTAssertEqual(createdEvent.response.id, "resp_123")
      XCTAssertEqual(createdEvent.response.status, .inProgress)
    } else {
      XCTFail("Expected responseCreated event")
    }
  }

  func testResponseCompletedEvent() throws {
    let json = """
      {
        "type": "response.completed",
        "sequence_number": 10,
        "response": {
          "id": "resp_123",
          "object": "model_response",
          "created_at": 1704067200,
          "model": "gpt-4o",
          "usage": {
            "prompt_tokens": 10,
            "completion_tokens": 20,
            "total_tokens": 30
          },
          "output": [],
          "status": "completed",
          "metadata": {},
          "parallel_tool_calls": true,
          "text": {
            "format": {
              "type": "text"
            }
          },
          "tool_choice": "none",
          "tools": []
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .responseCompleted(let completedEvent) = event {
      XCTAssertEqual(completedEvent.type, "response.completed")
      XCTAssertEqual(completedEvent.sequenceNumber, 10)
      XCTAssertEqual(completedEvent.response.status, .completed)
    } else {
      XCTFail("Expected responseCompleted event")
    }
  }

  // MARK: - Output Item Events Tests

  func testOutputItemAddedEvent() throws {
    let json = """
      {
        "type": "response.output_item.added",
        "output_index": 0,
        "sequence_number": 2,
        "item": {
          "id": "item_123",
          "type": "message",
          "status": "in_progress",
          "role": "assistant",
          "content": []
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputItemAdded(let addedEvent) = event {
      XCTAssertEqual(addedEvent.type, "response.output_item.added")
      XCTAssertEqual(addedEvent.outputIndex, 0)
      XCTAssertEqual(addedEvent.sequenceNumber, 2)

      if case .message(let message) = addedEvent.item {
        XCTAssertEqual(message.id, "item_123")
        XCTAssertEqual(message.type, "message")
        XCTAssertEqual(message.status, "in_progress")
        XCTAssertEqual(message.role, "assistant")
      } else {
        XCTFail("Expected message item")
      }
    } else {
      XCTFail("Expected outputItemAdded event")
    }
  }

  func testOutputItemAddedWithFunctionCall() throws {
    let json = """
      {
        "type": "response.output_item.added",
        "output_index": 0,
        "sequence_number": 2,
        "item": {
          "id": "func_123",
          "type": "function_call",
          "call_id": "call_456",
          "name": "get_weather",
          "arguments": "",
          "status": "in_progress"
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputItemAdded(let addedEvent) = event {
      if case .functionCall(let functionCall) = addedEvent.item {
        XCTAssertEqual(functionCall.id, "func_123")
        XCTAssertEqual(functionCall.callId, "call_456")
        XCTAssertEqual(functionCall.name, "get_weather")
        XCTAssertEqual(functionCall.status, "in_progress")
      } else {
        XCTFail("Expected function call item")
      }
    } else {
      XCTFail("Expected outputItemAdded event")
    }
  }

  func testOutputItemAddedWithImageGeneration() throws {
    let json = """
      {
        "type": "response.output_item.added",
        "output_index": 0,
        "sequence_number": 3,
        "item": {
          "id": "img_123",
          "type": "image_generation_call",
          "status": "in_progress"
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputItemAdded(let addedEvent) = event {
      if case .imageGenerationCall(let imageGen) = addedEvent.item {
        XCTAssertEqual(imageGen.id, "img_123")
        XCTAssertEqual(imageGen.type, "image_generation_call")
        XCTAssertEqual(imageGen.status, "in_progress")
      } else {
        XCTFail("Expected image generation call item")
      }
    } else {
      XCTFail("Expected outputItemAdded event")
    }
  }

  func testOutputItemAddedWithCodeInterpreter() throws {
    let json = """
      {
        "type": "response.output_item.added",
        "output_index": 0,
        "sequence_number": 4,
        "item": {
          "id": "code_123",
          "type": "code_interpreter_call",
          "container_id": "container_456",
          "status": "interpreting"
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputItemAdded(let addedEvent) = event {
      if case .codeInterpreterCall(let codeInterpreter) = addedEvent.item {
        XCTAssertEqual(codeInterpreter.id, "code_123")
        XCTAssertEqual(codeInterpreter.containerId, "container_456")
        XCTAssertEqual(codeInterpreter.status, "interpreting")
      } else {
        XCTFail("Expected code interpreter call item")
      }
    } else {
      XCTFail("Expected outputItemAdded event")
    }
  }

  func testOutputItemDoneWithMCPCall() throws {
    let json = """
      {
        "type": "response.output_item.done",
        "output_index": 0,
        "sequence_number": 5,
        "item": {
          "id": "mcp_123",
          "type": "mcp_call",
          "name": "get_data",
          "server_label": "my_server",
          "arguments": "{\\"key\\": \\"value\\"}",
          "output": "result data"
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputItemDone(let doneEvent) = event {
      if case .mcpCall(let mcpCall) = doneEvent.item {
        XCTAssertEqual(mcpCall.id, "mcp_123")
        XCTAssertEqual(mcpCall.name, "get_data")
        XCTAssertEqual(mcpCall.serverLabel, "my_server")
        XCTAssertEqual(mcpCall.output, "result data")
      } else {
        XCTFail("Expected MCP call item")
      }
    } else {
      XCTFail("Expected outputItemDone event")
    }
  }

  // MARK: - Text Events Tests

  func testOutputTextDeltaEvent() throws {
    let json = """
      {
        "type": "response.output_text.delta",
        "item_id": "item_123",
        "output_index": 0,
        "content_index": 0,
        "delta": "Hello, how can I ",
        "sequence_number": 3
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputTextDelta(let deltaEvent) = event {
      XCTAssertEqual(deltaEvent.type, "response.output_text.delta")
      XCTAssertEqual(deltaEvent.itemId, "item_123")
      XCTAssertEqual(deltaEvent.outputIndex, 0)
      XCTAssertEqual(deltaEvent.contentIndex, 0)
      XCTAssertEqual(deltaEvent.delta, "Hello, how can I ")
      XCTAssertEqual(deltaEvent.sequenceNumber, 3)
    } else {
      XCTFail("Expected outputTextDelta event")
    }
  }

  func testOutputTextDoneEvent() throws {
    let json = """
      {
        "type": "response.output_text.done",
        "item_id": "item_123",
        "output_index": 0,
        "content_index": 0,
        "text": "Hello, how can I help you today?",
        "sequence_number": 5
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputTextDone(let doneEvent) = event {
      XCTAssertEqual(doneEvent.type, "response.output_text.done")
      XCTAssertEqual(doneEvent.text, "Hello, how can I help you today?")
    } else {
      XCTFail("Expected outputTextDone event")
    }
  }

  // MARK: - Function Call Events Tests

  func testFunctionCallArgumentsDeltaEvent() throws {
    let json = """
      {
        "type": "response.function_call_arguments.delta",
        "item_id": "item_456",
        "output_index": 0,
        "delta": "{\\"location\\": \\"San ",
        "sequence_number": 4
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .functionCallArgumentsDelta(let deltaEvent) = event {
      XCTAssertEqual(deltaEvent.type, "response.function_call_arguments.delta")
      XCTAssertEqual(deltaEvent.itemId, "item_456")
      XCTAssertEqual(deltaEvent.delta, "{\"location\": \"San ")
    } else {
      XCTFail("Expected functionCallArgumentsDelta event")
    }
  }

  func testFunctionCallArgumentsDoneEvent() throws {
    let json = """
      {
        "type": "response.function_call_arguments.done",
        "item_id": "item_456",
        "output_index": 0,
        "arguments": "{\\"location\\": \\"San Francisco, CA\\"}",
        "sequence_number": 6
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .functionCallArgumentsDone(let doneEvent) = event {
      XCTAssertEqual(doneEvent.type, "response.function_call_arguments.done")
      XCTAssertEqual(doneEvent.arguments, "{\"location\": \"San Francisco, CA\"}")
    } else {
      XCTFail("Expected functionCallArgumentsDone event")
    }
  }

  // MARK: - File Search Events Tests

  func testFileSearchCallEvents() throws {
    // Test in progress event
    let inProgressJson = """
      {
        "type": "response.file_search_call.in_progress",
        "output_index": 0,
        "item_id": "fs_123",
        "sequence_number": 7
      }
      """

    let decoder = JSONDecoder()
    let inProgressEvent = try decoder.decode(ResponseStreamEvent.self, from: inProgressJson.data(using: .utf8)!)

    if case .fileSearchCallInProgress(let event) = inProgressEvent {
      XCTAssertEqual(event.type, "response.file_search_call.in_progress")
      XCTAssertEqual(event.itemId, "fs_123")
    } else {
      XCTFail("Expected fileSearchCallInProgress event")
    }

    // Test searching event
    let searchingJson = """
      {
        "type": "response.file_search_call.searching",
        "output_index": 0,
        "item_id": "fs_123",
        "sequence_number": 8
      }
      """

    let searchingEvent = try decoder.decode(ResponseStreamEvent.self, from: searchingJson.data(using: .utf8)!)

    if case .fileSearchCallSearching(let event) = searchingEvent {
      XCTAssertEqual(event.type, "response.file_search_call.searching")
    } else {
      XCTFail("Expected fileSearchCallSearching event")
    }

    // Test completed event
    let completedJson = """
      {
        "type": "response.file_search_call.completed",
        "output_index": 0,
        "item_id": "fs_123",
        "sequence_number": 9
      }
      """

    let completedEvent = try decoder.decode(ResponseStreamEvent.self, from: completedJson.data(using: .utf8)!)

    if case .fileSearchCallCompleted(let event) = completedEvent {
      XCTAssertEqual(event.type, "response.file_search_call.completed")
    } else {
      XCTFail("Expected fileSearchCallCompleted event")
    }
  }

  // MARK: - Web Search Events Tests

  func testWebSearchCallEvents() throws {
    let decoder = JSONDecoder()

    // Test all web search event types
    let eventTypes = [
      ("response.web_search_call.in_progress", "webSearchCallInProgress"),
      ("response.web_search_call.searching", "webSearchCallSearching"),
      ("response.web_search_call.completed", "webSearchCallCompleted"),
    ]

    for (eventType, expectedCase) in eventTypes {
      let json = """
        {
          "type": "\(eventType)",
          "output_index": 0,
          "item_id": "ws_123",
          "sequence_number": 10
        }
        """

      let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

      switch event {
      case .webSearchCallInProgress(let e) where expectedCase == "webSearchCallInProgress":
        XCTAssertEqual(e.type, eventType)
        XCTAssertEqual(e.itemId, "ws_123")

      case .webSearchCallSearching(let e) where expectedCase == "webSearchCallSearching":
        XCTAssertEqual(e.type, eventType)

      case .webSearchCallCompleted(let e) where expectedCase == "webSearchCallCompleted":
        XCTAssertEqual(e.type, eventType)

      default:
        XCTFail("Expected \(expectedCase) event for type \(eventType)")
      }
    }
  }

  // MARK: - Reasoning Events Tests

  func testReasoningSummaryTextDeltaEvent() throws {
    let json = """
      {
        "type": "response.reasoning_summary_text.delta",
        "item_id": "reason_123",
        "output_index": 0,
        "summary_index": 0,
        "delta": "Let me think about this problem step by step",
        "sequence_number": 11
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .reasoningSummaryTextDelta(let deltaEvent) = event {
      XCTAssertEqual(deltaEvent.type, "response.reasoning_summary_text.delta")
      XCTAssertEqual(deltaEvent.delta, "Let me think about this problem step by step")
      XCTAssertEqual(deltaEvent.summaryIndex, 0)
    } else {
      XCTFail("Expected reasoningSummaryTextDelta event")
    }
  }

  // MARK: - Error Event Test

  func testErrorEvent() throws {
    let json = """
      {
        "type": "error",
        "code": "rate_limit_exceeded",
        "message": "You have exceeded your rate limit",
        "param": "model",
        "sequence_number": 99
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .error(let errorEvent) = event {
      XCTAssertEqual(errorEvent.type, "error")
      XCTAssertEqual(errorEvent.code, "rate_limit_exceeded")
      XCTAssertEqual(errorEvent.message, "You have exceeded your rate limit")
      XCTAssertEqual(errorEvent.param, "model")
      XCTAssertEqual(errorEvent.sequenceNumber, 99)
    } else {
      XCTFail("Expected error event")
    }
  }

  // MARK: - Complex Streaming Sequence Test

  func testCompleteStreamingSequence() throws {
    // This test simulates a complete streaming sequence with multiple events
    let events = [
      """
      {"type": "response.created", "sequence_number": 1, "response": {"id": "resp_123", "object": "model_response", "created_at": 1704067200, "model": "gpt-4o", "usage": {"prompt_tokens": 10, "completion_tokens": 0, "total_tokens": 10}, "output": [], "status": "in_progress", "metadata": {}, "parallel_tool_calls": true, "text": {"format": {"type": "text"}}, "tool_choice": "none", "tools": []}}
      """,
      """
      {"type": "response.output_item.added", "output_index": 0, "sequence_number": 2, "item": {"id": "item_123", "type": "message", "status": "in_progress", "role": "assistant", "content": []}}
      """,
      """
      {"type": "response.content_part.added", "item_id": "item_123", "output_index": 0, "content_index": 0, "sequence_number": 3, "part": {"type": "text", "text": ""}}
      """,
      """
      {"type": "response.output_text.delta", "item_id": "item_123", "output_index": 0, "content_index": 0, "delta": "Hello", "sequence_number": 4}
      """,
      """
      {"type": "response.output_text.delta", "item_id": "item_123", "output_index": 0, "content_index": 0, "delta": ", world!", "sequence_number": 5}
      """,
      """
      {"type": "response.output_text.done", "item_id": "item_123", "output_index": 0, "content_index": 0, "text": "Hello, world!", "sequence_number": 6}
      """,
      """
      {"type": "response.content_part.done", "item_id": "item_123", "output_index": 0, "content_index": 0, "sequence_number": 7, "part": {"type": "text", "text": "Hello, world!"}}
      """,
      """
      {"type": "response.output_item.done", "output_index": 0, "sequence_number": 8, "item": {"id": "item_123", "type": "message", "status": "completed", "role": "assistant", "content": [{"type": "output_text", "text": "Hello, world!", "annotations": []}]}}
      """,
      """
      {"type": "response.completed", "sequence_number": 9, "response": {"id": "resp_123", "object": "model_response", "created_at": 1704067200, "model": "gpt-4o", "usage": {"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15}, "output": [], "status": "completed", "metadata": {}, "parallel_tool_calls": true, "text": {"format": {"type": "text"}}, "tool_choice": "none", "tools": []}}
      """,
    ]

    let decoder = JSONDecoder()
    var receivedEvents: [ResponseStreamEvent] = []

    // Decode all events
    for eventJson in events {
      let event = try decoder.decode(ResponseStreamEvent.self, from: eventJson.data(using: .utf8)!)
      receivedEvents.append(event)
    }

    // Verify we received all events
    XCTAssertEqual(receivedEvents.count, 9)

    // Verify the sequence
    if case .responseCreated = receivedEvents[0] {
      // Success
    } else {
      XCTFail("First event should be responseCreated")
    }

    if case .responseCompleted = receivedEvents[8] {
      // Success
    } else {
      XCTFail("Last event should be responseCompleted")
    }
  }

  // MARK: - Image Generation Events Tests

  func testImageGenerationEvents() throws {
    let decoder = JSONDecoder()

    // Test partial image event
    let partialImageJson = """
      {
        "type": "response.image_generation_call.partial_image",
        "output_index": 0,
        "item_id": "img_123",
        "sequence_number": 12,
        "partial_image_index": 0,
        "partial_image_b64": "iVBORw0KGgoAAAANS..."
      }
      """

    let partialImageEvent = try decoder.decode(ResponseStreamEvent.self, from: partialImageJson.data(using: .utf8)!)

    if case .imageGenerationCallPartialImage(let event) = partialImageEvent {
      XCTAssertEqual(event.type, "response.image_generation_call.partial_image")
      XCTAssertEqual(event.partialImageIndex, 0)
      XCTAssertEqual(event.partialImageB64, "iVBORw0KGgoAAAANS...")
    } else {
      XCTFail("Expected imageGenerationCallPartialImage event")
    }
  }

  // MARK: - Additional Output Item Type Tests

  func testOutputItemLocalShellCall() throws {
    let json = """
      {
        "type": "response.output_item.added",
        "output_index": 0,
        "sequence_number": 6,
        "item": {
          "id": "shell_123",
          "type": "local_shell_call",
          "call_id": "call_789",
          "action": {
            "type": "execute",
            "command": "ls -la"
          },
          "status": "in_progress"
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputItemAdded(let addedEvent) = event {
      if case .localShellCall(let shellCall) = addedEvent.item {
        XCTAssertEqual(shellCall.id, "shell_123")
        XCTAssertEqual(shellCall.callId, "call_789")
        XCTAssertEqual(shellCall.action.command, "ls -la")
        XCTAssertEqual(shellCall.status, "in_progress")
      } else {
        XCTFail("Expected local shell call item")
      }
    } else {
      XCTFail("Expected outputItemAdded event")
    }
  }

  func testOutputItemMCPListTools() throws {
    let json = """
      {
        "type": "response.output_item.done",
        "output_index": 0,
        "sequence_number": 7,
        "item": {
          "id": "list_123",
          "type": "mcp_list_tools",
          "server_label": "my_server",
          "tools": [
            {
              "name": "tool1",
              "description": "First tool"
            }
          ]
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputItemDone(let doneEvent) = event {
      if case .mcpListTools(let listTools) = doneEvent.item {
        XCTAssertEqual(listTools.id, "list_123")
        XCTAssertEqual(listTools.serverLabel, "my_server")
        XCTAssertEqual(listTools.tools.count, 1)
        XCTAssertEqual(listTools.tools[0].name, "tool1")
      } else {
        XCTFail("Expected MCP list tools item")
      }
    } else {
      XCTFail("Expected outputItemDone event")
    }
  }

  func testOutputItemMCPApprovalRequest() throws {
    let json = """
      {
        "type": "response.output_item.added",
        "output_index": 0,
        "sequence_number": 8,
        "item": {
          "id": "approval_123",
          "type": "mcp_approval_request",
          "name": "sensitive_operation",
          "server_label": "my_server",
          "arguments": "{\\"action\\": \\"delete_all\\"}"
        }
      }
      """

    let decoder = JSONDecoder()
    let event = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)

    if case .outputItemAdded(let addedEvent) = event {
      if case .mcpApprovalRequest(let approval) = addedEvent.item {
        XCTAssertEqual(approval.id, "approval_123")
        XCTAssertEqual(approval.name, "sensitive_operation")
        XCTAssertEqual(approval.serverLabel, "my_server")
        XCTAssertEqual(approval.arguments, "{\"action\": \"delete_all\"}")
      } else {
        XCTFail("Expected MCP approval request item")
      }
    } else {
      XCTFail("Expected outputItemAdded event")
    }
  }

  // MARK: - Unknown Event Type Test

  func testUnknownEventType() throws {
    let json = """
      {
        "type": "response.unknown_event",
        "data": "some data"
      }
      """

    let decoder = JSONDecoder()

    do {
      _ = try decoder.decode(ResponseStreamEvent.self, from: json.data(using: .utf8)!)
      XCTFail("Should have thrown an error for unknown event type")
    } catch {
      // Expected error
      XCTAssertTrue(error is DecodingError)
    }
  }
}
