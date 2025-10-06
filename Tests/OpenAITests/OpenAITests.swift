import XCTest
@testable import SwiftOpenAI

final class OpenAITests: XCTestCase {
  /// OpenAI is loose with their API contract, unfortunately.
  /// Here we test that `tool_choice` is decodable from a string OR an object,
  /// which is required for deserializing responses from assistants:
  /// https://platform.openai.com/docs/api-reference/runs/createRun#runs-createrun-tool_choice
  func testToolChoiceIsDecodableFromStringOrObject() throws {
    let expectedResponseMappings: [(String, ToolChoice)] = [
      ("\"auto\"", .auto),
      ("\"none\"", .none),
      ("{\"type\": \"function\", \"function\": {\"name\": \"my_function\"}}", .function(type: "function", name: "my_function")),
    ]
    let decoder = JSONDecoder()
    for (response, expectedToolChoice) in expectedResponseMappings {
      print(response)
      guard let jsonData = response.data(using: .utf8) else {
        XCTFail("Could not create json from sample response")
        return
      }
      let toolChoice = try decoder.decode(ToolChoice.self, from: jsonData)
      XCTAssertEqual(toolChoice, expectedToolChoice, "Mapping from \(response) did not yield expected result")
    }
  }

  /// Here we test that `response_format` is decodable from a string OR an object,
  /// which is required for deserializing responses from assistants:
  /// https://platform.openai.com/docs/api-reference/runs/createRun#runs-createrun-response_format
  func testResponseFormatIsDecodableFromStringOrObject() throws {
    let expectedResponseMappings: [(String, ResponseFormat)] = [
      ("{\"type\": \"json_object\"}", .jsonObject),
      ("{\"type\": \"text\"}", .text),
    ]
    let decoder = JSONDecoder()
    for (response, expectedResponseFormat) in expectedResponseMappings {
      print(response)
      guard let jsonData = response.data(using: .utf8) else {
        XCTFail("Could not create json from sample response")
        return
      }
      let responseFormat = try decoder.decode(ResponseFormat.self, from: jsonData)
      XCTAssertEqual(responseFormat, expectedResponseFormat, "Mapping from \(response) did not yield expected result")
    }
  }

  /// ResponseFormat is used in other places, and in those places it can *only* be populated with an object.
  /// OpenAI really suffers in API consistency.
  /// If a client sets the ResponseFormat to `auto` (which is now a valid case in the codebase), we
  /// encode to {"type": "text"} to satisfy when response_format can only be an object, such as:
  /// https://platform.openai.com/docs/api-reference/chat/create#chat-create-response_format
  func testAutoResponseFormatEncodesToText() throws {
    let jsonData = try JSONEncoder().encode(ResponseFormat.text)
    XCTAssertEqual(String(data: jsonData, encoding: .utf8), "{\"type\":\"text\"}")
  }

  /// Verifies that our custom encoding of ResponseFormat supports the 'text' type:
  func testTextResponseFormatIsEncodable() throws {
    let jsonData = try JSONEncoder().encode(ResponseFormat.text)
    XCTAssertEqual(String(data: jsonData, encoding: .utf8), "{\"type\":\"text\"}")
  }

  /// Verifies that our custom encoding of ResponseFormat supports the 'json_object' type:
  func testJSONResponseFormatIsEncodable() throws {
    let jsonData = try JSONEncoder().encode(ResponseFormat.jsonObject)
    XCTAssertEqual(String(data: jsonData, encoding: .utf8), "{\"type\":\"json_object\"}")
  }

  /// Regression test for decoding assistant runs. Thank you to Martin Brian for the repro:
  /// https://gist.github.com/mbrian23/6863ffa705ccbb5097bd07efb2355a30
  func testThreadRunResponseIsDecodable() throws {
    let response = """
      {
        "id": "run_ZWntP0jJr391lwVu3JqFZbKV",
        "object": "thread.run",
        "created_at": 1713979538,
        "assistant_id": "asst_qxhQxXsecIjqw9cBjFTB6yvd",
        "thread_id": "thread_CT4hxsN5N0A5vXg4FeR4pOPD",
        "status": "queued",
        "started_at": null,
        "expires_at": 1713980138,
        "cancelled_at": null,
        "failed_at": null,
        "completed_at": null,
        "required_action": null,
        "last_error": null,
        "model": "gpt-4-1106-preview",
        "instructions": "You answer ever question with ‘hello world’",
        "tools": [],
        "file_ids": [],
        "metadata": {},
        "temperature": 1.0,
        "top_p": 1.0,
        "max_completion_tokens": null,
        "max_prompt_tokens": null,
        "truncation_strategy": {
          "type": "auto",
          "last_messages": null
        },
        "incomplete_details": null,
        "usage": null,
        "response_format": "auto",
        "tool_choice": "auto"
      }
      """

    guard let jsonData = response.data(using: .utf8) else {
      XCTFail("Could not create json from sample response")
      return
    }
    let decoder = JSONDecoder()
    let runObject = try decoder.decode(RunObject.self, from: jsonData)
    XCTAssertEqual(runObject.id, "run_ZWntP0jJr391lwVu3JqFZbKV")
  }

  // MARK: - Text Input Response Test

  func testTextInputResponse() throws {
    // Text input response JSON
    let json = """
      {
        "id": "resp_67ccd2bed1ec8190b14f964abc0542670bb6a6b452d3795b",
        "object": "response",
        "created_at": 1741476542,
        "status": "completed",
        "error": null,
        "incomplete_details": null,
        "instructions": null,
        "max_output_tokens": null,
        "model": "gpt-4o-2024-08-06",
        "output": [
          {
            "type": "message",
            "id": "msg_67ccd2bf17f0819081ff3bb2cf6508e60bb6a6b452d3795b",
            "status": "completed",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "In a peaceful grove beneath a silver moon, a unicorn named Lumina discovered a hidden pool that reflected the stars. As she dipped her horn into the water, the pool began to shimmer, revealing a pathway to a magical realm of endless night skies. Filled with wonder, Lumina whispered a wish for all who dream to find their own hidden magic, and as she glanced back, her hoofprints sparkled like stardust.",
                "annotations": []
              }
            ]
          }
        ],
        "parallel_tool_calls": true,
        "previous_response_id": null,
        "reasoning": {
          "effort": null,
          "summary": null
        },
        "store": true,
        "temperature": 1.0,
        "text": {
          "format": {
            "type": "text"
          }
        },
        "tool_choice": "auto",
        "tools": [],
        "top_p": 1.0,
        "truncation": "disabled",
        "usage": {
          "input_tokens": 36,
          "input_tokens_details": {
            "cached_tokens": 0
          },
          "output_tokens": 87,
          "output_tokens_details": {
            "reasoning_tokens": 0
          },
          "total_tokens": 123
        },
        "user": null,
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test basic properties
    XCTAssertEqual(responseModel.id, "resp_67ccd2bed1ec8190b14f964abc0542670bb6a6b452d3795b")
    XCTAssertEqual(responseModel.object, "response")
    XCTAssertEqual(responseModel.createdAt, 1_741_476_542)
    XCTAssertEqual(responseModel.status, .completed)
    XCTAssertNil(responseModel.error)
    XCTAssertNil(responseModel.incompleteDetails)
    XCTAssertNil(responseModel.instructions)
    XCTAssertNil(responseModel.maxOutputTokens)
    XCTAssertEqual(responseModel.model, "gpt-4o-2024-08-06")
    XCTAssertEqual(responseModel.parallelToolCalls, true)
    XCTAssertNil(responseModel.previousResponseId)
    XCTAssertNotNil(responseModel.reasoning)
    XCTAssertEqual(responseModel.temperature, 1.0)
    XCTAssertEqual(responseModel.tools.count, 0)
    XCTAssertEqual(responseModel.topP, 1.0)
    XCTAssertEqual(responseModel.truncation, "disabled")

    // Test usage details
    XCTAssertNotNil(responseModel.usage)
    XCTAssertEqual(responseModel.usage?.inputTokens, 36)
    XCTAssertEqual(responseModel.usage?.outputTokens, 87)
    XCTAssertEqual(responseModel.usage?.totalTokens, 123)
    XCTAssertEqual(responseModel.usage?.inputTokensDetails?.cachedTokens, 0)
    XCTAssertEqual(responseModel.usage?.outputTokensDetails?.reasoningTokens, 0)

    // Test new fields
    XCTAssertNil(responseModel.background)
    XCTAssertNil(responseModel.serviceTier)
    XCTAssertEqual(responseModel.store, true)

    // Test output content
    XCTAssertEqual(responseModel.output.count, 1)

    if case .message(let message) = responseModel.output[0] {
      XCTAssertEqual(message.id, "msg_67ccd2bf17f0819081ff3bb2cf6508e60bb6a6b452d3795b")
      XCTAssertEqual(message.status, "completed")
      XCTAssertEqual(message.role, "assistant")
      XCTAssertEqual(message.content.count, 1)

      if case .outputText(let outputText) = message.content[0] {
        XCTAssertEqual(outputText.type, "output_text")
        XCTAssertTrue(outputText.text.starts(with: "In a peaceful grove beneath a silver moon"))
        XCTAssertEqual(outputText.annotations.count, 0)
      } else {
        XCTFail("Expected output text content")
      }
    } else {
      XCTFail("Expected message output type")
    }

    // Test outputText convenience property
    let expectedText =
      "In a peaceful grove beneath a silver moon, a unicorn named Lumina discovered a hidden pool that reflected the stars. As she dipped her horn into the water, the pool began to shimmer, revealing a pathway to a magical realm of endless night skies. Filled with wonder, Lumina whispered a wish for all who dream to find their own hidden magic, and as she glanced back, her hoofprints sparkled like stardust."
    XCTAssertEqual(responseModel.outputText, expectedText)
  }

  // MARK: - Image Input Response Test

  func testImageInputResponse() throws {
    // Image input response JSON
    let json = """
      {
        "id": "resp_67ccd3a9da748190baa7f1570fe91ac604becb25c45c1d41",
        "object": "response",
        "created_at": 1741476777,
        "status": "completed",
        "error": null,
        "incomplete_details": null,
        "instructions": null,
        "max_output_tokens": null,
        "model": "gpt-4o-2024-08-06",
        "output": [
          {
            "type": "message",
            "id": "msg_67ccd3acc8d48190a77525dc6de64b4104becb25c45c1d41",
            "status": "completed",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "The image depicts a scenic landscape with a wooden boardwalk or pathway leading through lush, green grass under a blue sky with some clouds. The setting suggests a peaceful natural area, possibly a park or nature reserve. There are trees and shrubs in the background.",
                "annotations": []
              }
            ]
          }
        ],
        "parallel_tool_calls": true,
        "previous_response_id": null,
        "reasoning": {
          "effort": null,
          "summary": null
        },
        "store": true,
        "temperature": 1.0,
        "text": {
          "format": {
            "type": "text"
          }
        },
        "tool_choice": "auto",
        "tools": [],
        "top_p": 1.0,
        "truncation": "disabled",
        "usage": {
          "input_tokens": 328,
          "input_tokens_details": {
            "cached_tokens": 0
          },
          "output_tokens": 52,
          "output_tokens_details": {
            "reasoning_tokens": 0
          },
          "total_tokens": 380
        },
        "user": null,
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test basic properties
    XCTAssertEqual(responseModel.id, "resp_67ccd3a9da748190baa7f1570fe91ac604becb25c45c1d41")
    XCTAssertEqual(responseModel.object, "response")
    XCTAssertEqual(responseModel.createdAt, 1_741_476_777)
    XCTAssertEqual(responseModel.status, .completed)
    XCTAssertNil(responseModel.error)
    XCTAssertNil(responseModel.incompleteDetails)
    XCTAssertNil(responseModel.instructions)
    XCTAssertNil(responseModel.maxOutputTokens)
    XCTAssertEqual(responseModel.model, "gpt-4o-2024-08-06")
    XCTAssertEqual(responseModel.parallelToolCalls, true)
    XCTAssertNil(responseModel.previousResponseId)
    XCTAssertNotNil(responseModel.reasoning)
    XCTAssertEqual(responseModel.temperature, 1.0)
    XCTAssertEqual(responseModel.tools.count, 0)
    XCTAssertEqual(responseModel.topP, 1.0)
    XCTAssertEqual(responseModel.truncation, "disabled")

    // Test usage details
    XCTAssertNotNil(responseModel.usage)
    XCTAssertEqual(responseModel.usage?.inputTokens, 328)
    XCTAssertEqual(responseModel.usage?.outputTokens, 52)
    XCTAssertEqual(responseModel.usage?.totalTokens, 380)
    XCTAssertEqual(responseModel.usage?.inputTokensDetails?.cachedTokens, 0)
    XCTAssertEqual(responseModel.usage?.outputTokensDetails?.reasoningTokens, 0)

    // Test output content
    XCTAssertEqual(responseModel.output.count, 1)

    if case .message(let message) = responseModel.output[0] {
      XCTAssertEqual(message.id, "msg_67ccd3acc8d48190a77525dc6de64b4104becb25c45c1d41")
      XCTAssertEqual(message.status, "completed")
      XCTAssertEqual(message.role, "assistant")
      XCTAssertEqual(message.content.count, 1)

      if case .outputText(let outputText) = message.content[0] {
        XCTAssertEqual(outputText.type, "output_text")
        XCTAssertTrue(outputText.text.starts(with: "The image depicts a scenic landscape"))
        XCTAssertEqual(outputText.annotations.count, 0)
      } else {
        XCTFail("Expected output text content")
      }
    } else {
      XCTFail("Expected message output type")
    }

    // Test outputText convenience property
    let expectedText =
      "The image depicts a scenic landscape with a wooden boardwalk or pathway leading through lush, green grass under a blue sky with some clouds. The setting suggests a peaceful natural area, possibly a park or nature reserve. There are trees and shrubs in the background."
    XCTAssertEqual(responseModel.outputText, expectedText)
  }

  // MARK: - Web Search Response Test

  func testWebSearchResponse() throws {
    // Web search response JSON
    let json = """
      {
        "id": "resp_67ccf18ef5fc8190b16dbee19bc54e5f087bb177ab789d5c",
        "object": "response",
        "created_at": 1741484430,
        "status": "completed",
        "error": null,
        "incomplete_details": null,
        "instructions": null,
        "max_output_tokens": null,
        "model": "gpt-4o-2024-08-06",
        "output": [
          {
            "type": "web_search_call",
            "id": "ws_67ccf18f64008190a39b619f4c8455ef087bb177ab789d5c",
            "status": "completed"
          },
          {
            "type": "message",
            "id": "msg_67ccf190ca3881909d433c50b1f6357e087bb177ab789d5c",
            "status": "completed",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "As of today, March 9, 2025, one notable positive news story...",
                "annotations": [
                  {
                    "type": "url_citation",
                    "start_index": 442,
                    "end_index": 557,
                    "url": "https://.../?utm_source=chatgpt.com",
                    "title": "..."
                  },
                  {
                    "type": "url_citation",
                    "start_index": 962,
                    "end_index": 1077,
                    "url": "https://.../?utm_source=chatgpt.com",
                    "title": "..."
                  },
                  {
                    "type": "url_citation",
                    "start_index": 1336,
                    "end_index": 1451,
                    "url": "https://.../?utm_source=chatgpt.com",
                    "title": "..."
                  }
                ]
              }
            ]
          }
        ],
        "parallel_tool_calls": true,
        "previous_response_id": null,
        "reasoning": {
          "effort": null,
          "summary": null
        },
        "store": true,
        "temperature": 1.0,
        "text": {
          "format": {
            "type": "text"
          }
        },
        "tool_choice": "auto",
        "tools": [
          {
            "type": "web_search_preview",
            "domains": [],
            "search_context_size": "medium",
            "user_location": {
              "type": "approximate",
              "city": null,
              "country": "US",
              "region": null,
              "timezone": null
            }
          }
        ],
        "top_p": 1.0,
        "truncation": "disabled",
        "usage": {
          "input_tokens": 328,
          "input_tokens_details": {
            "cached_tokens": 0
          },
          "output_tokens": 356,
          "output_tokens_details": {
            "reasoning_tokens": 0
          },
          "total_tokens": 684
        },
        "user": null,
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test basic properties
    XCTAssertEqual(responseModel.id, "resp_67ccf18ef5fc8190b16dbee19bc54e5f087bb177ab789d5c")
    XCTAssertEqual(responseModel.object, "response")
    XCTAssertEqual(responseModel.createdAt, 1_741_484_430)
    XCTAssertEqual(responseModel.status, .completed)
    XCTAssertNil(responseModel.error)
    XCTAssertNil(responseModel.incompleteDetails)
    XCTAssertNil(responseModel.instructions)
    XCTAssertNil(responseModel.maxOutputTokens)
    XCTAssertEqual(responseModel.model, "gpt-4o-2024-08-06")
    XCTAssertEqual(responseModel.parallelToolCalls, true)
    XCTAssertNil(responseModel.previousResponseId)
    XCTAssertNotNil(responseModel.reasoning)
    XCTAssertEqual(responseModel.temperature, 1.0)
    XCTAssertEqual(responseModel.tools.count, 1)
    XCTAssertEqual(responseModel.topP, 1.0)
    XCTAssertEqual(responseModel.truncation, "disabled")

    // Test usage details
    XCTAssertNotNil(responseModel.usage)
    XCTAssertEqual(responseModel.usage?.inputTokens, 328)
    XCTAssertEqual(responseModel.usage?.outputTokens, 356)
    XCTAssertEqual(responseModel.usage?.totalTokens, 684)
    XCTAssertEqual(responseModel.usage?.inputTokensDetails?.cachedTokens, 0)
    XCTAssertEqual(responseModel.usage?.outputTokensDetails?.reasoningTokens, 0)

    // Test output array - should have web search call and message
    XCTAssertEqual(responseModel.output.count, 2)

    // Test web search call
    if case .webSearchCall(let webSearch) = responseModel.output[0] {
      XCTAssertEqual(webSearch.id, "ws_67ccf18f64008190a39b619f4c8455ef087bb177ab789d5c")
      XCTAssertEqual(webSearch.status, "completed")
      XCTAssertEqual(webSearch.type, "web_search_call")
    } else {
      XCTFail("Expected web search call output type")
    }

    // Test message
    if case .message(let message) = responseModel.output[1] {
      XCTAssertEqual(message.id, "msg_67ccf190ca3881909d433c50b1f6357e087bb177ab789d5c")
      XCTAssertEqual(message.status, "completed")
      XCTAssertEqual(message.role, "assistant")
      XCTAssertEqual(message.content.count, 1)

      if case .outputText(let outputText) = message.content[0] {
        XCTAssertEqual(outputText.type, "output_text")
        XCTAssertTrue(outputText.text.starts(with: "As of today, March 9, 2025"))
        XCTAssertEqual(outputText.annotations.count, 3)
      } else {
        XCTFail("Expected output text content")
      }
    } else {
      XCTFail("Expected message output type")
    }

    // Test outputText convenience property
    let expectedText = "As of today, March 9, 2025, one notable positive news story..."
    XCTAssertEqual(responseModel.outputText, expectedText)
  }

  // MARK: - File Search Response Test

  func testFileSearchResponse() throws {
    // File search response JSON
    let json = """
      {
        "id": "resp_67ccf4c55fc48190b71bd0463ad3306d09504fb6872380d7",
        "object": "response",
        "created_at": 1741485253,
        "status": "completed",
        "error": null,
        "incomplete_details": null,
        "instructions": null,
        "max_output_tokens": null,
        "model": "gpt-4o-2024-08-06",
        "output": [
          {
            "type": "file_search_call",
            "id": "fs_67ccf4c63cd08190887ef6464ba5681609504fb6872380d7",
            "status": "completed",
            "queries": [
              "attributes of an ancient brown dragon"
            ],
            "results": null
          },
          {
            "type": "message",
            "id": "msg_67ccf4c93e5c81909d595b369351a9d309504fb6872380d7",
            "status": "completed",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "The attributes of an ancient brown dragon include...",
                "annotations": [
                  {
                    "type": "file_citation",
                    "index": 320,
                    "file_id": "file-4wDz5b167pAf72nx1h9eiN",
                    "filename": "dragons.pdf"
                  },
                  {
                    "type": "file_citation",
                    "index": 576,
                    "file_id": "file-4wDz5b167pAf72nx1h9eiN",
                    "filename": "dragons.pdf"
                  },
                  {
                    "type": "file_citation",
                    "index": 815,
                    "file_id": "file-4wDz5b167pAf72nx1h9eiN",
                    "filename": "dragons.pdf"
                  },
                  {
                    "type": "file_citation",
                    "index": 815,
                    "file_id": "file-4wDz5b167pAf72nx1h9eiN",
                    "filename": "dragons.pdf"
                  },
                  {
                    "type": "file_citation",
                    "index": 1030,
                    "file_id": "file-4wDz5b167pAf72nx1h9eiN",
                    "filename": "dragons.pdf"
                  },
                  {
                    "type": "file_citation",
                    "index": 1030,
                    "file_id": "file-4wDz5b167pAf72nx1h9eiN",
                    "filename": "dragons.pdf"
                  },
                  {
                    "type": "file_citation",
                    "index": 1156,
                    "file_id": "file-4wDz5b167pAf72nx1h9eiN",
                    "filename": "dragons.pdf"
                  },
                  {
                    "type": "file_citation",
                    "index": 1225,
                    "file_id": "file-4wDz5b167pAf72nx1h9eiN",
                    "filename": "dragons.pdf"
                  }
                ]
              }
            ]
          }
        ],
        "parallel_tool_calls": true,
        "previous_response_id": null,
        "reasoning": {
          "effort": null,
          "summary": null
        },
        "store": true,
        "temperature": 1.0,
        "text": {
          "format": {
            "type": "text"
          }
        },
        "tool_choice": "auto",
        "tools": [
          {
            "type": "file_search",
            "filters": null,
            "max_num_results": 20,
            "ranking_options": {
              "ranker": "auto",
              "score_threshold": 0.0
            },
            "vector_store_ids": [
              "vs_1234567890"
            ]
          }
        ],
        "top_p": 1.0,
        "truncation": "disabled",
        "usage": {
          "input_tokens": 18307,
          "input_tokens_details": {
            "cached_tokens": 0
          },
          "output_tokens": 348,
          "output_tokens_details": {
            "reasoning_tokens": 0
          },
          "total_tokens": 18655
        },
        "user": null,
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test basic properties
    XCTAssertEqual(responseModel.id, "resp_67ccf4c55fc48190b71bd0463ad3306d09504fb6872380d7")
    XCTAssertEqual(responseModel.object, "response")
    XCTAssertEqual(responseModel.createdAt, 1_741_485_253)
    XCTAssertEqual(responseModel.status, .completed)
    XCTAssertNil(responseModel.error)
    XCTAssertNil(responseModel.incompleteDetails)
    XCTAssertNil(responseModel.instructions)
    XCTAssertNil(responseModel.maxOutputTokens)
    XCTAssertEqual(responseModel.model, "gpt-4o-2024-08-06")
    XCTAssertEqual(responseModel.parallelToolCalls, true)
    XCTAssertNil(responseModel.previousResponseId)
    XCTAssertNotNil(responseModel.reasoning)
    XCTAssertEqual(responseModel.temperature, 1.0)
    XCTAssertEqual(responseModel.tools.count, 1)
    XCTAssertEqual(responseModel.topP, 1.0)
    XCTAssertEqual(responseModel.truncation, "disabled")

    // Test usage details
    XCTAssertNotNil(responseModel.usage)
    XCTAssertEqual(responseModel.usage?.inputTokens, 18307)
    XCTAssertEqual(responseModel.usage?.outputTokens, 348)
    XCTAssertEqual(responseModel.usage?.totalTokens, 18655)
    XCTAssertEqual(responseModel.usage?.inputTokensDetails?.cachedTokens, 0)
    XCTAssertEqual(responseModel.usage?.outputTokensDetails?.reasoningTokens, 0)

    // Test output array - should have file search call and message
    XCTAssertEqual(responseModel.output.count, 2)

    // Test file search call
    if case .fileSearchCall(let fileSearch) = responseModel.output[0] {
      XCTAssertEqual(fileSearch.id, "fs_67ccf4c63cd08190887ef6464ba5681609504fb6872380d7")
      XCTAssertEqual(fileSearch.status, "completed")
      XCTAssertEqual(fileSearch.type, "file_search_call")
      XCTAssertEqual(fileSearch.queries.count, 1)
      XCTAssertEqual(fileSearch.queries[0], "attributes of an ancient brown dragon")
      XCTAssertNil(fileSearch.results)
    } else {
      XCTFail("Expected file search call output type")
    }

    // Test message
    if case .message(let message) = responseModel.output[1] {
      XCTAssertEqual(message.id, "msg_67ccf4c93e5c81909d595b369351a9d309504fb6872380d7")
      XCTAssertEqual(message.status, "completed")
      XCTAssertEqual(message.role, "assistant")
      XCTAssertEqual(message.content.count, 1)

      if case .outputText(let outputText) = message.content[0] {
        XCTAssertEqual(outputText.type, "output_text")
        XCTAssertTrue(outputText.text.starts(with: "The attributes of an ancient brown dragon"))
        XCTAssertEqual(outputText.annotations.count, 8)

      } else {
        XCTFail("Expected output text content")
      }
    } else {
      XCTFail("Expected message output type")
    }

    // Test outputText convenience property
    let expectedText = "The attributes of an ancient brown dragon include..."
    XCTAssertEqual(responseModel.outputText, expectedText)
  }

  // MARK: - Multi-Message Output Test

  func testMultiMessageOutput() throws {
    // Create a test case with multiple messages in the output array
    let json = """
      {
        "id": "resp_test_multiple_messages",
        "object": "response",
        "created_at": 1741485253,
        "status": "completed",
        "model": "gpt-4o-2024-08-06",
        "output": [
          {
            "type": "message",
            "id": "msg_1",
            "status": "completed",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "First message text",
                "annotations": []
              }
            ]
          },
          {
            "type": "message",
            "id": "msg_2",
            "status": "completed",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "Second message text",
                "annotations": []
              }
            ]
          }
        ],
        "parallel_tool_calls": true,
        "text": { "format": { "type": "text" } },
        "tool_choice": "auto",
        "tools": [],
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test that both messages are found and their texts are joined
    XCTAssertEqual(responseModel.output.count, 2)
    XCTAssertEqual(responseModel.outputText, "First message textSecond message text")
  }

  // MARK: - Mixed Content Types Test

  func testMixedContentTypes() throws {
    // Create a test case with mixed content types
    let json = """
      {
        "id": "resp_test_mixed_content",
        "object": "response",
        "created_at": 1741485253,
        "status": "completed",
        "model": "gpt-4o-2024-08-06",
        "output": [
          {
            "type": "web_search_call",
            "id": "ws_test",
            "status": "completed"
          },
          {
            "type": "message",
            "id": "msg_test",
            "status": "completed",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "This is the main text",
                "annotations": []
              }
            ]
          },
          {
            "type": "file_search_call",
            "id": "fs_test",
            "status": "completed",
            "queries": ["test query"],
            "results": null
          }
        ],
        "parallel_tool_calls": true,
        "text": { "format": { "type": "text" } },
        "tool_choice": "auto",
        "tools": [],
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test that only message content is included in outputText
    XCTAssertEqual(responseModel.output.count, 3)
    XCTAssertEqual(responseModel.outputText, "This is the main text")
  }

  // MARK: - Error Response Test

  func testErrorResponse() throws {
    // Create a test case with an error
    let json = """
      {
        "id": "resp_test_error",
        "object": "response",
        "created_at": 1741485253,
        "status": "failed",
        "model": "gpt-4o-2024-08-06",
        "error": {
          "code": "server_error",
          "message": "The server encountered an error while processing your request."
        },
        "output": [],
        "parallel_tool_calls": true,
        "text": { "format": { "type": "text" } },
        "tool_choice": "auto",
        "tools": [],
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test error properties
    XCTAssertEqual(responseModel.status, .failed)
    XCTAssertNotNil(responseModel.error)
    XCTAssertEqual(responseModel.error?.code, "server_error")
    XCTAssertEqual(responseModel.error?.message, "The server encountered an error while processing your request.")

    // Test empty output
    XCTAssertEqual(responseModel.output.count, 0)
    XCTAssertNil(responseModel.outputText)
  }

  // MARK: - Incomplete Response Test

  func testIncompleteResponse() throws {
    // Create a test case with incomplete status
    let json = """
      {
        "id": "resp_test_incomplete",
        "object": "response",
        "created_at": 1741485253,
        "status": "incomplete",
        "model": "gpt-4o-2024-08-06",
        "incomplete_details": {
          "reason": "content_filter"
        },
        "output": [
          {
            "type": "message",
            "id": "msg_incomplete",
            "status": "incomplete",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "Partial response...",
                "annotations": []
              }
            ]
          }
        ],
        "parallel_tool_calls": true,
        "text": { "format": { "type": "text" } },
        "tool_choice": "auto",
        "tools": [],
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test incomplete properties
    XCTAssertEqual(responseModel.status, .incomplete)
    XCTAssertNotNil(responseModel.incompleteDetails)
    XCTAssertEqual(responseModel.incompleteDetails?.reason, "content_filter")

    // Test partial output
    XCTAssertEqual(responseModel.output.count, 1)
    if case .message(let message) = responseModel.output[0] {
      XCTAssertEqual(message.status, "incomplete")
    } else {
      XCTFail("Expected message output type")
    }

    // Partial text should still be extracted
    XCTAssertEqual(responseModel.outputText, "Partial response...")
  }

  // MARK: - Function Call Test

  func testFunctionCallResponse() throws {
    // Create a test case with a function call using real-world OpenAI response
    let json = """
      {
        "id": "resp_67ca09c5efe0819096d0511c92b8c890096610f474011cc0",
        "object": "response",
        "created_at": 1741294021,
        "status": "completed",
        "error": null,
        "incomplete_details": null,
        "instructions": null,
        "max_output_tokens": null,
        "model": "gpt-4o-2024-08-06",
        "output": [
          {
            "type": "function_call",
            "id": "fc_67ca09c6bedc8190a7abfec07b1a1332096610f474011cc0",
            "call_id": "call_unLAR8MvFNptuiZK6K6HCy5k",
            "name": "get_current_weather",
            "arguments": "{\\\"location\\\":\\\"Boston, MA\\\",\\\"unit\\\":\\\"celsius\\\"}",
            "status": "completed"
          }
        ],
        "parallel_tool_calls": true,
        "previous_response_id": null,
        "reasoning": {
          "effort": null,
          "summary": null
        },
        "store": true,
        "temperature": 1.0,
        "text": {
          "format": {
            "type": "text"
          }
        },
        "tool_choice": "auto",
        "tools": [
          {
            "type": "function",
            "description": "Get the current weather in a given location",
            "name": "get_current_weather",
            "parameters": {
              "type": "object",
              "properties": {
                "location": {
                  "type": "string",
                  "description": "The city and state, e.g. San Francisco, CA"
                },
                "unit": {
                  "type": "string",
                  "enum": [
                    "celsius",
                    "fahrenheit"
                  ]
                }
              },
              "required": [
                "location",
                "unit"
              ]
            },
            "strict": true
          }
        ],
        "top_p": 1.0,
        "truncation": "disabled",
        "usage": {
          "input_tokens": 291,
          "output_tokens": 23,
          "output_tokens_details": {
            "reasoning_tokens": 0
          },
          "total_tokens": 314
        },
        "user": null,
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test basic properties
    XCTAssertEqual(responseModel.id, "resp_67ca09c5efe0819096d0511c92b8c890096610f474011cc0")
    XCTAssertEqual(responseModel.object, "response")
    XCTAssertEqual(responseModel.createdAt, 1_741_294_021)
    XCTAssertEqual(responseModel.status, .completed)

    // Test tool configuration
    XCTAssertEqual(responseModel.tools.count, 1)
    if case .function(let functionTool) = responseModel.tools[0] {
      XCTAssertEqual(functionTool.name, "get_current_weather")
      XCTAssertEqual(functionTool.description, "Get the current weather in a given location")
      XCTAssertEqual(functionTool.type, "function")
      XCTAssertEqual(functionTool.strict, true)
    } else {
      XCTFail("Expected function tool")
    }

    // Test function call properties
    XCTAssertEqual(responseModel.output.count, 1)
    if case .functionCall(let functionCall) = responseModel.output[0] {
      XCTAssertEqual(functionCall.id, "fc_67ca09c6bedc8190a7abfec07b1a1332096610f474011cc0")
      XCTAssertEqual(functionCall.status, "completed")
      XCTAssertEqual(functionCall.callId, "call_unLAR8MvFNptuiZK6K6HCy5k")
      XCTAssertEqual(functionCall.name, "get_current_weather")
      XCTAssertEqual(functionCall.arguments, "{\"location\":\"Boston, MA\",\"unit\":\"celsius\"}")
    } else {
      XCTFail("Expected function call output type")
    }

    // Test outputText - should be nil since there's no message
    XCTAssertNil(responseModel.outputText)
  }

  func testReasoningResponse() throws {
    // Create a test case with reasoning effort
    let json = """
      {
        "id": "resp_67ccd7eca01881908ff0b5146584e408072912b2993db808",
        "object": "response",
        "created_at": 1741477868,
        "status": "completed",
        "error": null,
        "incomplete_details": null,
        "instructions": null,
        "max_output_tokens": null,
        "model": "o1-2024-12-17",
        "output": [
          {
            "type": "message",
            "id": "msg_67ccd7f7b5848190a6f3e95d809f6b44072912b2993db808",
            "status": "completed",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "The classic tongue twister...",
                "annotations": []
              }
            ]
          }
        ],
        "parallel_tool_calls": true,
        "previous_response_id": null,
        "reasoning": {
          "effort": "high",
          "summary": null
        },
        "store": true,
        "temperature": 1.0,
        "text": {
          "format": {
            "type": "text"
          }
        },
        "tool_choice": "auto",
        "tools": [],
        "top_p": 1.0,
        "truncation": "disabled",
        "usage": {
          "input_tokens": 81,
          "input_tokens_details": {
            "cached_tokens": 0
          },
          "output_tokens": 1035,
          "output_tokens_details": {
            "reasoning_tokens": 832
          },
          "total_tokens": 1116
        },
        "user": null,
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test basic properties
    XCTAssertEqual(responseModel.id, "resp_67ccd7eca01881908ff0b5146584e408072912b2993db808")
    XCTAssertEqual(responseModel.object, "response")
    XCTAssertEqual(responseModel.createdAt, 1_741_477_868)
    XCTAssertEqual(responseModel.status, .completed)
    XCTAssertEqual(responseModel.model, "o1-2024-12-17")

    // Test reasoning properties
    XCTAssertNotNil(responseModel.reasoning)
    XCTAssertEqual(responseModel.reasoning?.effort, "high")

    // Test usage details
    XCTAssertNotNil(responseModel.usage)
    XCTAssertEqual(responseModel.usage?.inputTokens, 81)
    XCTAssertEqual(responseModel.usage?.outputTokens, 1035)
    XCTAssertEqual(responseModel.usage?.totalTokens, 1116)
    XCTAssertEqual(responseModel.usage?.outputTokensDetails?.reasoningTokens, 832)

    // Test output content
    XCTAssertEqual(responseModel.output.count, 1)

    if case .message(let message) = responseModel.output[0] {
      XCTAssertEqual(message.id, "msg_67ccd7f7b5848190a6f3e95d809f6b44072912b2993db808")
      XCTAssertEqual(message.status, "completed")
      XCTAssertEqual(message.role, "assistant")
      XCTAssertEqual(message.content.count, 1)

      if case .outputText(let outputText) = message.content[0] {
        XCTAssertEqual(outputText.type, "output_text")
        XCTAssertEqual(outputText.text, "The classic tongue twister...")
        XCTAssertEqual(outputText.annotations.count, 0)
      } else {
        XCTFail("Expected output text content")
      }
    } else {
      XCTFail("Expected message output type")
    }

    // Test outputText convenience property
    XCTAssertEqual(responseModel.outputText, "The classic tongue twister...")
  }

  // MARK: - New Fields Test (background, serviceTier, store)

  func testResponseModelNewFields() throws {
    // Test response with new fields
    let json = """
      {
        "id": "resp_test_new_fields",
        "object": "response",
        "created_at": 1741485253,
        "status": "completed",
        "background": true,
        "service_tier": "flex",
        "store": false,
        "model": "gpt-4o-2024-08-06",
        "output": [
          {
            "type": "message",
            "id": "msg_test",
            "status": "completed",
            "role": "assistant",
            "content": [
              {
                "type": "output_text",
                "text": "Test response with new fields",
                "annotations": []
              }
            ]
          }
        ],
        "parallel_tool_calls": true,
        "text": { "format": { "type": "text" } },
        "tool_choice": "auto",
        "tools": [],
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test new fields
    XCTAssertEqual(responseModel.background, true)
    XCTAssertEqual(responseModel.serviceTier, "flex")
    XCTAssertEqual(responseModel.store, false)
    XCTAssertEqual(responseModel.status, .completed)
  }

  // MARK: - Status Enum Test

  func testResponseModelStatusEnum() throws {
    let statusValues: [(String, ResponseModel.Status)] = [
      ("completed", .completed),
      ("failed", .failed),
      ("in_progress", .inProgress),
      ("cancelled", .cancelled),
      ("queued", .queued),
      ("incomplete", .incomplete),
    ]

    for (jsonStatus, expectedStatus) in statusValues {
      let json = """
        {
          "id": "resp_status_test",
          "object": "response",
          "created_at": 1741485253,
          "status": "\(jsonStatus)",
          "model": "gpt-4o-2024-08-06",
          "output": [],
          "parallel_tool_calls": true,
          "text": { "format": { "type": "text" } },
          "tool_choice": "auto",
          "tools": [],
          "metadata": {}
        }
        """

      let decoder = JSONDecoder()
      let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

      XCTAssertEqual(responseModel.status, expectedStatus, "Status '\(jsonStatus)' should decode to \(expectedStatus)")
    }
  }

  // MARK: - Service Tier Values Test

  func testServiceTierValues() throws {
    let serviceTierValues = ["auto", "default", "flex", "scale"]

    for tier in serviceTierValues {
      let json = """
        {
          "id": "resp_service_tier_test",
          "object": "response",
          "created_at": 1741485253,
          "status": "completed",
          "service_tier": "\(tier)",
          "model": "gpt-4o-2024-08-06",
          "output": [],
          "parallel_tool_calls": true,
          "text": { "format": { "type": "text" } },
          "tool_choice": "auto",
          "tools": [],
          "metadata": {}
        }
        """

      let decoder = JSONDecoder()
      let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

      XCTAssertEqual(responseModel.serviceTier, tier, "Service tier '\(tier)' should be properly decoded")
    }
  }

  // MARK: - Null Fields Test

  func testResponseModelNullFields() throws {
    // Test that null/missing fields are properly handled
    let json = """
      {
        "id": "resp_null_fields_test",
        "object": "response",
        "created_at": 1741485253,
        "status": "completed",
        "background": null,
        "service_tier": null,
        "store": null,
        "model": "gpt-4o-2024-08-06",
        "output": [],
        "parallel_tool_calls": true,
        "text": { "format": { "type": "text" } },
        "tool_choice": "auto",
        "tools": [],
        "metadata": {}
      }
      """

    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

    // Test that null values are properly decoded as nil
    XCTAssertNil(responseModel.background)
    XCTAssertNil(responseModel.serviceTier)
    XCTAssertNil(responseModel.store)
  }
}
