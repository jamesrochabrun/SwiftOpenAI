import XCTest
@testable import SwiftOpenAI

final class OutputItemTests: XCTestCase {
  // MARK: - Message Tests

  func testOutputItemMessage() throws {
    let json = """
      {
        "type": "message",
        "id": "msg_123",
        "role": "assistant",
        "status": "completed",
        "content": [
          {
            "type": "output_text",
            "text": "Hello, world!",
            "annotations": []
          }
        ]
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .message(let message) = outputItem {
      XCTAssertEqual(message.id, "msg_123")
      XCTAssertEqual(message.role, "assistant")
      XCTAssertEqual(message.status, "completed")
      XCTAssertEqual(message.type, "message")
      XCTAssertEqual(message.content.count, 1)
    } else {
      XCTFail("Expected message output item")
    }
  }

  // MARK: - File Search Tests

  func testOutputItemFileSearchCall() throws {
    let json = """
      {
        "type": "file_search_call",
        "id": "fs_123",
        "queries": ["search term"],
        "status": "completed",
        "results": []
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .fileSearchCall(let fileSearch) = outputItem {
      XCTAssertEqual(fileSearch.id, "fs_123")
      XCTAssertEqual(fileSearch.queries, ["search term"])
      XCTAssertEqual(fileSearch.status, "completed")
      XCTAssertEqual(fileSearch.type, "file_search_call")
    } else {
      XCTFail("Expected file search call output item")
    }
  }

  // MARK: - Function Call Tests

  func testOutputItemFunctionCall() throws {
    let json = """
      {
        "type": "function_call",
        "id": "func_123",
        "call_id": "call_456",
        "name": "get_weather",
        "arguments": "{\\"location\\": \\"San Francisco\\"}",
        "status": "completed"
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .functionCall(let functionCall) = outputItem {
      XCTAssertEqual(functionCall.id, "func_123")
      XCTAssertEqual(functionCall.callId, "call_456")
      XCTAssertEqual(functionCall.name, "get_weather")
      XCTAssertEqual(functionCall.arguments, "{\"location\": \"San Francisco\"}")
      XCTAssertEqual(functionCall.status, "completed")
      XCTAssertEqual(functionCall.type, "function_call")
    } else {
      XCTFail("Expected function call output item")
    }
  }

  // MARK: - Web Search Tests

  func testOutputItemWebSearchCall() throws {
    let json = """
      {
        "type": "web_search_call",
        "id": "ws_123",
        "status": "completed"
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .webSearchCall(let webSearch) = outputItem {
      XCTAssertEqual(webSearch.id, "ws_123")
      XCTAssertEqual(webSearch.status, "completed")
      XCTAssertEqual(webSearch.type, "web_search_call")
    } else {
      XCTFail("Expected web search call output item")
    }
  }

  // MARK: - Computer Call Tests

  func testOutputItemComputerCall() throws {
    let json = """
      {
        "type": "computer_call",
        "id": "comp_123",
        "call_id": "call_789",
        "action": {
          "type": "screenshot"
        },
        "status": "completed",
        "pending_safety_checks": []
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .computerCall(let computerCall) = outputItem {
      XCTAssertEqual(computerCall.id, "comp_123")
      XCTAssertEqual(computerCall.callId, "call_789")
      XCTAssertEqual(computerCall.action.type, "screenshot")
      XCTAssertEqual(computerCall.status, "completed")
      XCTAssertEqual(computerCall.type, "computer_call")
    } else {
      XCTFail("Expected computer call output item")
    }
  }

  // MARK: - Reasoning Tests

  func testOutputItemReasoning() throws {
    let json = """
      {
        "type": "reasoning",
        "id": "reason_123",
        "status": "completed",
        "summary": [
          {
            "type": "summary_text",
            "text": "Thinking about the problem..."
          }
        ]
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .reasoning(let reasoning) = outputItem {
      XCTAssertEqual(reasoning.id, "reason_123")
      XCTAssertEqual(reasoning.status, "completed")
      XCTAssertEqual(reasoning.type, "reasoning")
      XCTAssertEqual(reasoning.summary.count, 1)
      XCTAssertEqual(reasoning.summary[0].text, "Thinking about the problem...")
    } else {
      XCTFail("Expected reasoning output item")
    }
  }

  // MARK: - Image Generation Tests

  func testOutputItemImageGenerationCall() throws {
    let json = """
      {
        "type": "image_generation_call",
        "id": "img_123",
        "status": "completed",
        "result": "base64_encoded_image_data"
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .imageGenerationCall(let imageGen) = outputItem {
      XCTAssertEqual(imageGen.id, "img_123")
      XCTAssertEqual(imageGen.status, "completed")
      XCTAssertEqual(imageGen.result, "base64_encoded_image_data")
      XCTAssertEqual(imageGen.type, "image_generation_call")
    } else {
      XCTFail("Expected image generation call output item")
    }
  }

  // MARK: - Code Interpreter Tests

  func testOutputItemCodeInterpreterCall() throws {
    let json = """
      {
        "type": "code_interpreter_call",
        "id": "code_123",
        "container_id": "container_456",
        "code": "print('Hello, world!')",
        "status": "completed",
        "outputs": [
          {
            "type": "logs",
            "logs": "Hello, world!"
          }
        ]
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .codeInterpreterCall(let codeInterpreter) = outputItem {
      XCTAssertEqual(codeInterpreter.id, "code_123")
      XCTAssertEqual(codeInterpreter.containerId, "container_456")
      XCTAssertEqual(codeInterpreter.code, "print('Hello, world!')")
      XCTAssertEqual(codeInterpreter.status, "completed")
      XCTAssertEqual(codeInterpreter.type, "code_interpreter_call")
      XCTAssertEqual(codeInterpreter.outputs?.count, 1)

      if case .log(let logOutput) = codeInterpreter.outputs?[0] {
        XCTAssertEqual(logOutput.logs, "Hello, world!")
      } else {
        XCTFail("Expected log output")
      }
    } else {
      XCTFail("Expected code interpreter call output item")
    }
  }

  func testCodeInterpreterImageOutput() throws {
    let json = """
      {
        "type": "code_interpreter_call",
        "id": "code_123",
        "container_id": "container_456",
        "status": "completed",
        "outputs": [
          {
            "type": "image",
            "image": {
              "file_id": "file_123"
            }
          }
        ]
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .codeInterpreterCall(let codeInterpreter) = outputItem {
      XCTAssertEqual(codeInterpreter.outputs?.count, 1)

      if case .image(let imageOutput) = codeInterpreter.outputs?[0] {
        XCTAssertEqual(imageOutput.image.fileId, "file_123")
      } else {
        XCTFail("Expected image output")
      }
    } else {
      XCTFail("Expected code interpreter call output item")
    }
  }

  // MARK: - Local Shell Tests

  func testOutputItemLocalShellCall() throws {
    let json = """
      {
        "type": "local_shell_call",
        "id": "shell_123",
        "call_id": "call_789",
        "action": {
          "type": "execute",
          "command": "ls -la"
        },
        "status": "completed"
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .localShellCall(let localShell) = outputItem {
      XCTAssertEqual(localShell.id, "shell_123")
      XCTAssertEqual(localShell.callId, "call_789")
      XCTAssertEqual(localShell.action.type, "execute")
      XCTAssertEqual(localShell.action.command, "ls -la")
      XCTAssertEqual(localShell.status, "completed")
      XCTAssertEqual(localShell.type, "local_shell_call")
    } else {
      XCTFail("Expected local shell call output item")
    }
  }

  // MARK: - MCP Call Tests

  func testOutputItemMCPCall() throws {
    let json = """
      {
        "type": "mcp_call",
        "id": "mcp_123",
        "name": "get_data",
        "server_label": "my_server",
        "arguments": "{\\"key\\": \\"value\\"}",
        "output": "result data"
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .mcpCall(let mcpCall) = outputItem {
      XCTAssertEqual(mcpCall.id, "mcp_123")
      XCTAssertEqual(mcpCall.name, "get_data")
      XCTAssertEqual(mcpCall.serverLabel, "my_server")
      XCTAssertEqual(mcpCall.arguments, "{\"key\": \"value\"}")
      XCTAssertEqual(mcpCall.output, "result data")
      XCTAssertEqual(mcpCall.type, "mcp_call")
      XCTAssertNil(mcpCall.error)
    } else {
      XCTFail("Expected MCP call output item")
    }
  }

  func testOutputItemMCPCallWithError() throws {
    let json = """
      {
        "type": "mcp_call",
        "id": "mcp_123",
        "name": "get_data",
        "server_label": "my_server",
        "arguments": "{\\"key\\": \\"value\\"}",
        "error": "Tool execution failed"
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .mcpCall(let mcpCall) = outputItem {
      XCTAssertEqual(mcpCall.error, "Tool execution failed")
      XCTAssertNil(mcpCall.output)
    } else {
      XCTFail("Expected MCP call output item")
    }
  }

  // MARK: - MCP List Tools Tests

  func testOutputItemMCPListTools() throws {
    let json = """
      {
        "type": "mcp_list_tools",
        "id": "list_123",
        "server_label": "my_server",
        "tools": [
          {
            "name": "tool1",
            "description": "First tool"
          },
          {
            "name": "tool2",
            "description": "Second tool",
            "input_schema": {
              "type": "object"
            }
          }
        ]
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .mcpListTools(let mcpListTools) = outputItem {
      XCTAssertEqual(mcpListTools.id, "list_123")
      XCTAssertEqual(mcpListTools.serverLabel, "my_server")
      XCTAssertEqual(mcpListTools.tools.count, 2)
      XCTAssertEqual(mcpListTools.tools[0].name, "tool1")
      XCTAssertEqual(mcpListTools.tools[0].description, "First tool")
      XCTAssertEqual(mcpListTools.tools[1].name, "tool2")
      XCTAssertEqual(mcpListTools.type, "mcp_list_tools")
      XCTAssertNil(mcpListTools.error)
    } else {
      XCTFail("Expected MCP list tools output item")
    }
  }

  // MARK: - MCP Approval Request Tests

  func testOutputItemMCPApprovalRequest() throws {
    let json = """
      {
        "type": "mcp_approval_request",
        "id": "approval_123",
        "name": "sensitive_operation",
        "server_label": "my_server",
        "arguments": "{\\"action\\": \\"delete_all\\"}"
      }
      """

    let decoder = JSONDecoder()
    let outputItem = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)

    if case .mcpApprovalRequest(let approval) = outputItem {
      XCTAssertEqual(approval.id, "approval_123")
      XCTAssertEqual(approval.name, "sensitive_operation")
      XCTAssertEqual(approval.serverLabel, "my_server")
      XCTAssertEqual(approval.arguments, "{\"action\": \"delete_all\"}")
      XCTAssertEqual(approval.type, "mcp_approval_request")
    } else {
      XCTFail("Expected MCP approval request output item")
    }
  }

  // MARK: - Error Tests

  func testUnknownOutputItemType() throws {
    let json = """
      {
        "type": "unknown_type",
        "data": "some data"
      }
      """

    let decoder = JSONDecoder()

    do {
      _ = try decoder.decode(OutputItem.self, from: json.data(using: .utf8)!)
      XCTFail("Should have thrown an error for unknown output item type")
    } catch {
      // Expected error
      XCTAssertTrue(error is DecodingError)
    }
  }
}
