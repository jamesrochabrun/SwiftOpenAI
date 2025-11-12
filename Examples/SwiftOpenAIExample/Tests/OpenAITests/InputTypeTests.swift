import XCTest
@testable import SwiftOpenAI

final class InputTypeTests: XCTestCase {
  // MARK: - Basic InputType Tests

  func testStringInput() throws {
    // Test simple string input
    let json = """
      "Tell me a story about a unicorn"
      """

    let decoder = JSONDecoder()
    let input = try decoder.decode(InputType.self, from: json.data(using: .utf8)!)

    switch input {
    case .string(let text):
      XCTAssertEqual(text, "Tell me a story about a unicorn")
    case .array:
      XCTFail("Expected string input, got array")
    }

    // Test encoding
    let encoder = JSONEncoder()
    let encoded = try encoder.encode(input)
    let decodedString = String(data: encoded, encoding: .utf8)
    XCTAssertEqual(decodedString, "\"Tell me a story about a unicorn\"")
  }

  func testArrayInputWithMessage() throws {
    // Test array input with message
    let json = """
      [
        {
          "type": "message",
          "role": "user",
          "content": "Hello, how are you?"
        }
      ]
      """

    let decoder = JSONDecoder()
    let input = try decoder.decode(InputType.self, from: json.data(using: .utf8)!)

    switch input {
    case .string:
      XCTFail("Expected array input, got string")
    case .array(let items):
      XCTAssertEqual(items.count, 1)
      if case .message(let message) = items[0] {
        XCTAssertEqual(message.role, "user")
        if case .text(let text) = message.content {
          XCTAssertEqual(text, "Hello, how are you?")
        } else {
          XCTFail("Expected text content")
        }
      } else {
        XCTFail("Expected message input item")
      }
    }
  }

  // MARK: - Message Content Tests

  func testMessageWithStringContent() throws {
    let json = """
      {
        "type": "message",
        "role": "user",
        "content": "What is the weather today?"
      }
      """

    let decoder = JSONDecoder()
    let item = try decoder.decode(InputItem.self, from: json.data(using: .utf8)!)

    if case .message(let message) = item {
      XCTAssertEqual(message.role, "user")
      if case .text(let text) = message.content {
        XCTAssertEqual(text, "What is the weather today?")
      } else {
        XCTFail("Expected text content")
      }
    } else {
      XCTFail("Expected message item")
    }
  }

  func testMessageWithArrayContent() throws {
    let json = """
      {
        "type": "message",
        "role": "user",
        "content": [
          {
            "type": "input_text",
            "text": "Describe this image:"
          },
          {
            "type": "input_image",
            "detail": "high",
            "image_url": "https://example.com/image.jpg"
          }
        ]
      }
      """

    let decoder = JSONDecoder()
    let item = try decoder.decode(InputItem.self, from: json.data(using: .utf8)!)

    if case .message(let message) = item {
      XCTAssertEqual(message.role, "user")
      if case .array(let contentItems) = message.content {
        XCTAssertEqual(contentItems.count, 2)

        // Check text content
        if case .text(let textContent) = contentItems[0] {
          XCTAssertEqual(textContent.text, "Describe this image:")
        } else {
          XCTFail("Expected text content")
        }

        // Check image content
        if case .image(let imageContent) = contentItems[1] {
          XCTAssertEqual(imageContent.detail, "high")
          XCTAssertEqual(imageContent.imageUrl, "https://example.com/image.jpg")
        } else {
          XCTFail("Expected image content")
        }
      } else {
        XCTFail("Expected array content")
      }
    } else {
      XCTFail("Expected message item")
    }
  }

  // MARK: - Content Item Tests

  func testInputTextContent() throws {
    let json = """
      {
        "type": "input_text",
        "text": "Hello, world!"
      }
      """

    let decoder = JSONDecoder()
    let content = try decoder.decode(ContentItem.self, from: json.data(using: .utf8)!)

    if case .text(let textContent) = content {
      XCTAssertEqual(textContent.text, "Hello, world!")
      XCTAssertEqual(textContent.type, "input_text")
    } else {
      XCTFail("Expected text content")
    }
  }

  func testInputImageContent() throws {
    let json = """
      {
        "type": "input_image",
        "detail": "auto",
        "file_id": "file-123"
      }
      """

    let decoder = JSONDecoder()
    let content = try decoder.decode(ContentItem.self, from: json.data(using: .utf8)!)

    if case .image(let imageContent) = content {
      XCTAssertEqual(imageContent.detail, "auto")
      XCTAssertEqual(imageContent.fileId, "file-123")
      XCTAssertNil(imageContent.imageUrl)
    } else {
      XCTFail("Expected image content")
    }
  }

  func testInputFileContent() throws {
    let json = """
      {
        "type": "input_file",
        "file_id": "file-456",
        "filename": "document.pdf"
      }
      """

    let decoder = JSONDecoder()
    let content = try decoder.decode(ContentItem.self, from: json.data(using: .utf8)!)

    if case .file(let fileContent) = content {
      XCTAssertEqual(fileContent.fileId, "file-456")
      XCTAssertEqual(fileContent.filename, "document.pdf")
      XCTAssertNil(fileContent.fileData)
    } else {
      XCTFail("Expected file content")
    }
  }

  func testOutputTextContent() throws {
    let json = """
      {
        "type": "output_text",
        "text": "The weather today is sunny with a high of 75°F.",
        "annotations": []
      }
      """

    let decoder = JSONDecoder()
    let content = try decoder.decode(ContentItem.self, from: json.data(using: .utf8)!)

    if case .outputText(let outputContent) = content {
      XCTAssertEqual(outputContent.text, "The weather today is sunny with a high of 75°F.")
      XCTAssertEqual(outputContent.type, "output_text")
    } else {
      XCTFail("Expected output text content")
    }
  }

  func testRefusalContent() throws {
    let json = """
      {
        "type": "refusal",
        "refusal": "I cannot help with that request."
      }
      """

    let decoder = JSONDecoder()
    let content = try decoder.decode(ContentItem.self, from: json.data(using: .utf8)!)

    if case .refusal(let refusalContent) = content {
      XCTAssertEqual(refusalContent.refusal, "I cannot help with that request.")
      XCTAssertEqual(refusalContent.type, "refusal")
    } else {
      XCTFail("Expected refusal content")
    }
  }

  // MARK: - Tool Call Tests

  func testFunctionToolCall() throws {
    let json = """
      {
        "type": "function_call",
        "id": "fc_123",
        "call_id": "call_abc",
        "name": "get_weather",
        "arguments": "{\\"location\\": \\"San Francisco\\"}",
        "status": "completed"
      }
      """

    let decoder = JSONDecoder()
    let item = try decoder.decode(InputItem.self, from: json.data(using: .utf8)!)

    if case .functionToolCall(let call) = item {
      XCTAssertEqual(call.id, "fc_123")
      XCTAssertEqual(call.callId, "call_abc")
      XCTAssertEqual(call.name, "get_weather")
      XCTAssertEqual(call.arguments, "{\"location\": \"San Francisco\"}")
      XCTAssertEqual(call.status, "completed")
    } else {
      XCTFail("Expected function tool call")
    }
  }

  func testFunctionToolCallOutput() throws {
    let json = """
      {
        "type": "function_call_output",
        "call_id": "call_abc",
        "output": "{\\"temperature\\": \\"72°F\\", \\"condition\\": \\"sunny\\"}"
      }
      """

    let decoder = JSONDecoder()
    let item = try decoder.decode(InputItem.self, from: json.data(using: .utf8)!)

    if case .functionToolCallOutput(let output) = item {
      XCTAssertEqual(output.callId, "call_abc")
      XCTAssertEqual(output.output, "{\"temperature\": \"72°F\", \"condition\": \"sunny\"}")
    } else {
      XCTFail("Expected function tool call output")
    }
  }

  // MARK: - Complex Conversation Test

  func testComplexConversation() throws {
    let json = """
      [
        {
          "type": "message",
          "role": "system",
          "content": "You are a helpful assistant."
        },
        {
          "type": "message",
          "role": "user",
          "content": "What's the weather in Boston?"
        },
        {
          "type": "function_call",
          "id": "fc_1",
          "call_id": "call_1",
          "name": "get_weather",
          "arguments": "{\\"location\\": \\"Boston\\"}",
          "status": "completed"
        },
        {
          "type": "function_call_output",
          "call_id": "call_1",
          "output": "{\\"temperature\\": \\"65°F\\", \\"condition\\": \\"cloudy\\"}"
        },
        {
          "type": "message",
          "role": "assistant",
          "content": [
            {
              "type": "output_text",
              "text": "The weather in Boston is currently 65°F and cloudy."
            }
          ],
          "id": "msg_1",
          "status": "completed"
        }
      ]
      """

    let decoder = JSONDecoder()
    let input = try decoder.decode(InputType.self, from: json.data(using: .utf8)!)

    switch input {
    case .string:
      XCTFail("Expected array input")
    case .array(let items):
      XCTAssertEqual(items.count, 5)

      // Verify system message
      if case .message(let systemMsg) = items[0] {
        XCTAssertEqual(systemMsg.role, "system")
      } else {
        XCTFail("Expected system message")
      }

      // Verify user message
      if case .message(let userMsg) = items[1] {
        XCTAssertEqual(userMsg.role, "user")
      } else {
        XCTFail("Expected user message")
      }

      // Verify function call
      if case .functionToolCall(let call) = items[2] {
        XCTAssertEqual(call.name, "get_weather")
      } else {
        XCTFail("Expected function call")
      }

      // Verify function output
      if case .functionToolCallOutput = items[3] {
        // Success
      } else {
        XCTFail("Expected function output")
      }
      // Note: OutputMessage is not yet supported in InputItem enum
      // This would need to be added to fully support conversation history
    }
  }
}
