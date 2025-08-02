import XCTest
@testable import SwiftOpenAI

final class ModelResponseParameterTests: XCTestCase {
  // MARK: - Basic Parameter Tests

  func testModelResponseParameterWithStringInput() throws {
    // Create parameter with string input
    let parameter = ModelResponseParameter(
      input: .string("Tell me about the weather"),
      model: .gpt4)

    // Test encoding
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let data = try encoder.encode(parameter)
    let json = String(data: data, encoding: .utf8)!

    // Verify JSON contains expected fields
    XCTAssertTrue(json.contains("\"input\":\"Tell me about the weather\""))
    XCTAssertTrue(json.contains("\"model\":\"gpt-4\""))
  }

  func testModelResponseParameterWithArrayInput() throws {
    // Create parameter with array input
    let inputMessage = InputMessage(
      role: "user",
      content: .text("What's the capital of France?"))

    let parameter = ModelResponseParameter(
      input: .array([
        .message(inputMessage),
      ]),
      model: .gpt4o)

    // Test encoding
    let encoder = JSONEncoder()
    let data = try encoder.encode(parameter)
    let json = String(data: data, encoding: .utf8)!

    // Verify JSON structure
    XCTAssertTrue(json.contains("\"role\":\"user\""))
    XCTAssertTrue(json.contains("\"content\":\"What's the capital of France?\""))
    XCTAssertTrue(json.contains("\"model\":\"gpt-4o\""))
  }

  // MARK: - Complex Input Tests

  func testModelResponseParameterWithMultimodalInput() throws {
    // Create multimodal input with text and image content
    let textContent = TextContent(text: "What's in this image?")
    let imageContent = ImageContent(
      detail: "high",
      imageUrl: "https://example.com/image.jpg")

    let inputMessage = InputMessage(
      role: "user",
      content: .array([
        .text(textContent),
        .image(imageContent),
      ]))

    let parameter = ModelResponseParameter(
      input: .array([
        .message(inputMessage),
      ]),
      model: .gpt4o,
      maxOutputTokens: 500,
      temperature: 0.7)

    // Test encoding
    let encoder = JSONEncoder()
    let data = try encoder.encode(parameter)
    let json = String(data: data, encoding: .utf8)!

    // Print JSON for debugging
    print("Generated JSON: \(json)")

    // Verify all fields
    XCTAssertTrue(json.contains("\"text\":\"What's in this image?\""), "Text not found in JSON")
    XCTAssertTrue(
      json.contains("https:\\/\\/example.com\\/image.jpg") ||
        json.contains("https://example.com/image.jpg"),
      "Image URL not found in JSON")
    XCTAssertTrue(json.contains("\"detail\":\"high\""), "Detail not found in JSON")
    XCTAssertTrue(json.contains("\"max_output_tokens\":500"), "Max output tokens not found in JSON")
    XCTAssertTrue(json.contains("\"temperature\":0.7"), "Temperature not found in JSON")
  }

  func testModelResponseParameterWithFunctionCalling() throws {
    // Create function tool
    let functionTool = Tool.function(
      Tool.FunctionTool(
        name: "get_weather",
        parameters: JSONSchema(
          type: .object,
          properties: [
            "location": JSONSchema(
              type: .string,
              description: "The city and state"),
          ],
          required: ["location"]),
        strict: true,
        description: "Get the weather for a location"))

    // Create function call in conversation history
    let functionCall = FunctionToolCall(
      arguments: "{\"location\": \"Boston, MA\"}",
      callId: "call_123",
      name: "get_weather",
      id: "fc_456",
      status: "completed")

    let functionOutput = FunctionToolCallOutput(
      callId: "call_123",
      output: "{\"temperature\": \"72°F\", \"condition\": \"sunny\"}")

    let parameter = ModelResponseParameter(
      input: .array([
        .message(InputMessage(role: "user", content: .text("What's the weather in Boston?"))),
        .functionToolCall(functionCall),
        .functionToolCallOutput(functionOutput),
        .message(InputMessage(role: "assistant", content: .text("The weather in Boston is 72°F and sunny."))),
      ]),
      model: .gpt4o,
      toolChoice: .auto,
      tools: [functionTool])

    // Test encoding
    let encoder = JSONEncoder()
    let data = try encoder.encode(parameter)
    let json = String(data: data, encoding: .utf8)!

    // Verify function-related fields
    XCTAssertTrue(json.contains("\"function_call\""))
    XCTAssertTrue(json.contains("\"function_call_output\""))
    XCTAssertTrue(json.contains("\"get_weather\""))
    XCTAssertTrue(json.contains("\"tool_choice\":\"auto\""))
  }

  // MARK: - Optional Parameters Tests

  func testModelResponseParameterWithAllOptionalFields() throws {
    let parameter = ModelResponseParameter(
      input: .string("Hello"),
      model: .gpt4o,
      include: ["file_search_call.results"],
      instructions: "You are a helpful assistant",
      maxOutputTokens: 1000,
      metadata: ["user_id": "123", "session": "abc"],
      parallelToolCalls: true,
      previousResponseId: "resp_previous",
      reasoning: Reasoning(effort: "high"),
      store: true,
      stream: false,
      temperature: 0.5,
      text: TextConfiguration(format: .text),
      toolChoice: ToolChoiceMode.none,
      tools: [],
      topP: 0.9,
      truncation: "auto",
      user: "user_123")

    // Test encoding
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let data = try encoder.encode(parameter)
    let json = String(data: data, encoding: .utf8)!

    // Verify all optional fields are present
    XCTAssertTrue(json.contains("\"include\":[\"file_search_call.results\"]"))
    XCTAssertTrue(json.contains("\"instructions\":\"You are a helpful assistant\""))
    XCTAssertTrue(json.contains("\"max_output_tokens\":1000"))
    XCTAssertTrue(json.contains("\"metadata\":{\"session\":\"abc\",\"user_id\":\"123\"}"))
    XCTAssertTrue(json.contains("\"parallel_tool_calls\":true"))
    XCTAssertTrue(json.contains("\"previous_response_id\":\"resp_previous\""))
    XCTAssertTrue(json.contains("\"reasoning\":{\"effort\":\"high\""))
    XCTAssertTrue(json.contains("\"store\":true"))
    XCTAssertTrue(json.contains("\"stream\":false"))
    XCTAssertTrue(json.contains("\"temperature\":0.5"))
    XCTAssertTrue(json.contains("\"tool_choice\":\"none\""))
    XCTAssertTrue(json.contains("\"top_p\":0.9"))
    XCTAssertTrue(json.contains("\"truncation\":\"auto\""))
    XCTAssertTrue(json.contains("\"user\":\"user_123\""))
  }

  // MARK: - Decoding Tests

  func testModelResponseParameterDecoding() throws {
    let json = """
      {
        "input": "Hello, how can I help?",
        "model": "gpt-4o",
        "temperature": 0.8,
        "max_output_tokens": 500,
        "metadata": {
          "request_id": "req_123"
        }
      }
      """

    let decoder = JSONDecoder()
    let parameter = try decoder.decode(ModelResponseParameter.self, from: json.data(using: .utf8)!)

    // Verify decoded values
    if case .string(let text) = parameter.input {
      XCTAssertEqual(text, "Hello, how can I help?")
    } else {
      XCTFail("Expected string input")
    }

    XCTAssertEqual(parameter.model, "gpt-4o")
    XCTAssertEqual(parameter.temperature, 0.8)
    XCTAssertEqual(parameter.maxOutputTokens, 500)
    XCTAssertEqual(parameter.metadata?["request_id"], "req_123")
  }

  func testModelResponseParameterDecodingWithArrayInput() throws {
    let json = """
      {
        "input": [
          {
            "type": "message",
            "role": "system",
            "content": "You are a helpful assistant."
          },
          {
            "type": "message", 
            "role": "user",
            "content": [
              {
                "type": "input_text",
                "text": "Analyze this data:"
              },
              {
                "type": "input_file",
                "file_id": "file-123"
              }
            ]
          }
        ],
        "model": "gpt-4o",
        "tools": [
          {
            "type": "file_search",
            "vector_store_ids": ["vs_123"]
          }
        ]
      }
      """

    let decoder = JSONDecoder()
    let parameter = try decoder.decode(ModelResponseParameter.self, from: json.data(using: .utf8)!)

    // Verify array input
    if case .array(let items) = parameter.input {
      XCTAssertEqual(items.count, 2)

      // Check system message
      if case .message(let systemMsg) = items[0] {
        XCTAssertEqual(systemMsg.role, "system")
        if case .text(let text) = systemMsg.content {
          XCTAssertEqual(text, "You are a helpful assistant.")
        }
      }

      // Check user message with array content
      if case .message(let userMsg) = items[1] {
        XCTAssertEqual(userMsg.role, "user")
        if case .array(let contentItems) = userMsg.content {
          XCTAssertEqual(contentItems.count, 2)
        }
      }
    } else {
      XCTFail("Expected array input")
    }

    // Verify tools
    XCTAssertEqual(parameter.tools?.count, 1)
  }
}
