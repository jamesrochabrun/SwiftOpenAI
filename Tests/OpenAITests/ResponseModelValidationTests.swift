import XCTest
@testable import SwiftOpenAI

final class ResponseModelValidationTests: XCTestCase {
  // MARK: - Comprehensive Validation Test

  func testAllResponseSchemasAreValid() throws {
    // This test validates that all provided response schemas can be decoded
    let schemas: [(name: String, json: String)] = [
      ("Text Input Response", textInputResponseJSON),
      ("Image Input Response", imageInputResponseJSON),
      ("Web Search Response", webSearchResponseJSON),
      ("File Search Response", fileSearchResponseJSON),
      ("Function Call Response", functionCallResponseJSON),
      ("Reasoning Response", reasoningResponseJSON),
    ]

    let decoder = JSONDecoder()

    for (name, json) in schemas {
      do {
        let responseModel = try decoder.decode(ResponseModel.self, from: json.data(using: .utf8)!)

        // Basic validation that the response was decoded
        XCTAssertNotNil(responseModel.id, "\(name): ID should not be nil")
        XCTAssertEqual(responseModel.object, "response", "\(name): Object type should be 'response'")
        XCTAssertNotNil(responseModel.createdAt, "\(name): Created at should not be nil")
        XCTAssertNotNil(responseModel.status, "\(name): Status should not be nil")

        print("✅ \(name) validated successfully")
      } catch {
        XCTFail("\(name) failed to decode: \(error)")
      }
    }
  }

  // MARK: - Individual Schema Tests

  func testTextInputResponseSchemaValidation() throws {
    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: textInputResponseJSON.data(using: .utf8)!)

    // Validate all fields are properly decoded
    XCTAssertEqual(responseModel.id, "resp_67ccd2bed1ec8190b14f964abc0542670bb6a6b452d3795b")
    XCTAssertEqual(responseModel.object, "response")
    XCTAssertEqual(responseModel.createdAt, 1_741_476_542)
    XCTAssertEqual(responseModel.status, .completed)
    XCTAssertNil(responseModel.error)
    XCTAssertNil(responseModel.incompleteDetails)
    XCTAssertNil(responseModel.instructions)
    XCTAssertNil(responseModel.maxOutputTokens)
    XCTAssertEqual(responseModel.model, "gpt-4.1-2025-04-14")
    XCTAssertEqual(responseModel.parallelToolCalls, true)
    XCTAssertNil(responseModel.previousResponseId)
    XCTAssertNotNil(responseModel.reasoning)
    XCTAssertNil(responseModel.reasoning?.effort)
    XCTAssertNil(responseModel.reasoning?.summary)
    XCTAssertEqual(responseModel.store, true)
    XCTAssertEqual(responseModel.temperature, 1.0)
    XCTAssertEqual(responseModel.topP, 1.0)
    XCTAssertEqual(responseModel.truncation, "disabled")
    XCTAssertNil(responseModel.user)
    XCTAssertTrue(responseModel.metadata.isEmpty)

    // Validate usage
    XCTAssertNotNil(responseModel.usage)
    XCTAssertEqual(responseModel.usage?.inputTokens, 36)
    XCTAssertEqual(responseModel.usage?.outputTokens, 87)
    XCTAssertEqual(responseModel.usage?.totalTokens, 123)
    XCTAssertEqual(responseModel.usage?.inputTokensDetails?.cachedTokens, 0)
    XCTAssertEqual(responseModel.usage?.outputTokensDetails?.reasoningTokens, 0)

    // Validate output
    XCTAssertEqual(responseModel.output.count, 1)
    if case .message(let message) = responseModel.output[0] {
      XCTAssertEqual(message.id, "msg_67ccd2bf17f0819081ff3bb2cf6508e60bb6a6b452d3795b")
      XCTAssertEqual(message.status, "completed")
      XCTAssertEqual(message.role, "assistant")
    } else {
      XCTFail("Expected message output type")
    }
  }

  func testImageInputResponseSchemaValidation() throws {
    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: imageInputResponseJSON.data(using: .utf8)!)

    // Specific validations for image response
    XCTAssertEqual(responseModel.model, "gpt-4.1-2025-04-14")
    XCTAssertEqual(responseModel.usage?.inputTokens, 328)
    XCTAssertEqual(responseModel.usage?.outputTokens, 52)
    XCTAssertEqual(responseModel.usage?.totalTokens, 380)
  }

  func testWebSearchResponseSchemaValidation() throws {
    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: webSearchResponseJSON.data(using: .utf8)!)

    // Validate web search specific features
    XCTAssertEqual(responseModel.output.count, 2)

    // First output should be web search call
    if case .webSearchCall(let webSearch) = responseModel.output[0] {
      XCTAssertEqual(webSearch.id, "ws_67ccf18f64008190a39b619f4c8455ef087bb177ab789d5c")
      XCTAssertEqual(webSearch.status, "completed")
      XCTAssertEqual(webSearch.type, "web_search_call")
    } else {
      XCTFail("Expected web search call as first output")
    }

    // Validate tools
    XCTAssertEqual(responseModel.tools.count, 1)
    if case .webSearch(let webSearchTool) = responseModel.tools[0] {
      // Check that the type is webSearchPreview
      if case .webSearchPreview = webSearchTool.type {
        // Type is correct
      } else {
        XCTFail("Expected web search preview type")
      }
      XCTAssertNotNil(webSearchTool.searchContextSize)
      XCTAssertNotNil(webSearchTool.userLocation)
    } else {
      XCTFail("Expected web search tool")
    }
  }

  func testFileSearchResponseSchemaValidation() throws {
    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: fileSearchResponseJSON.data(using: .utf8)!)

    // Validate file search specific features
    XCTAssertEqual(responseModel.output.count, 2)

    // First output should be file search call
    if case .fileSearchCall(let fileSearch) = responseModel.output[0] {
      XCTAssertEqual(fileSearch.id, "fs_67ccf4c63cd08190887ef6464ba5681609504fb6872380d7")
      XCTAssertEqual(fileSearch.queries.count, 1)
      XCTAssertEqual(fileSearch.queries[0], "attributes of an ancient brown dragon")
    } else {
      XCTFail("Expected file search call as first output")
    }

    // Validate tools
    XCTAssertEqual(responseModel.tools.count, 1)
    if case .fileSearch(let fileSearchTool) = responseModel.tools[0] {
      XCTAssertEqual(fileSearchTool.type, "file_search")
      XCTAssertEqual(fileSearchTool.maxNumResults, 20)
      XCTAssertNotNil(fileSearchTool.rankingOptions)
      XCTAssertEqual(fileSearchTool.vectorStoreIds.count, 1)
    } else {
      XCTFail("Expected file search tool")
    }
  }

  func testFunctionCallResponseSchemaValidation() throws {
    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: functionCallResponseJSON.data(using: .utf8)!)

    // Validate function call specific features
    XCTAssertEqual(responseModel.output.count, 1)

    // Output should be function call
    if case .functionCall(let functionCall) = responseModel.output[0] {
      XCTAssertEqual(functionCall.id, "fc_67ca09c6bedc8190a7abfec07b1a1332096610f474011cc0")
      XCTAssertEqual(functionCall.callId, "call_unLAR8MvFNptuiZK6K6HCy5k")
      XCTAssertEqual(functionCall.name, "get_current_weather")
      XCTAssertEqual(functionCall.arguments, "{\"location\":\"Boston, MA\",\"unit\":\"celsius\"}")
      XCTAssertEqual(functionCall.status, "completed")
    } else {
      XCTFail("Expected function call output")
    }

    // Validate tools
    XCTAssertEqual(responseModel.tools.count, 1)
    if case .function(let functionTool) = responseModel.tools[0] {
      XCTAssertEqual(functionTool.name, "get_current_weather")
      XCTAssertEqual(functionTool.strict, true)
    } else {
      XCTFail("Expected function tool")
    }
  }

  func testReasoningResponseSchemaValidation() throws {
    let decoder = JSONDecoder()
    let responseModel = try decoder.decode(ResponseModel.self, from: reasoningResponseJSON.data(using: .utf8)!)

    // Validate reasoning specific features
    XCTAssertEqual(responseModel.model, "o1-2024-12-17")
    XCTAssertNotNil(responseModel.reasoning)
    XCTAssertEqual(responseModel.reasoning?.effort, "high")

    // Validate reasoning tokens
    XCTAssertEqual(responseModel.usage?.outputTokensDetails?.reasoningTokens, 832)
    XCTAssertEqual(responseModel.usage?.outputTokens, 1035)
  }

  // MARK: - Test Data

  private let textInputResponseJSON = """
    {
      "id": "resp_67ccd2bed1ec8190b14f964abc0542670bb6a6b452d3795b",
      "object": "response",
      "created_at": 1741476542,
      "status": "completed",
      "error": null,
      "incomplete_details": null,
      "instructions": null,
      "max_output_tokens": null,
      "model": "gpt-4.1-2025-04-14",
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

  private let imageInputResponseJSON = """
    {
      "id": "resp_67ccd3a9da748190baa7f1570fe91ac604becb25c45c1d41",
      "object": "response",
      "created_at": 1741476777,
      "status": "completed",
      "error": null,
      "incomplete_details": null,
      "instructions": null,
      "max_output_tokens": null,
      "model": "gpt-4.1-2025-04-14",
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

  private let webSearchResponseJSON = """
    {
      "id": "resp_67ccf18ef5fc8190b16dbee19bc54e5f087bb177ab789d5c",
      "object": "response",
      "created_at": 1741484430,
      "status": "completed",
      "error": null,
      "incomplete_details": null,
      "instructions": null,
      "max_output_tokens": null,
      "model": "gpt-4.1-2025-04-14",
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

  private let fileSearchResponseJSON = """
    {
      "id": "resp_67ccf4c55fc48190b71bd0463ad3306d09504fb6872380d7",
      "object": "response",
      "created_at": 1741485253,
      "status": "completed",
      "error": null,
      "incomplete_details": null,
      "instructions": null,
      "max_output_tokens": null,
      "model": "gpt-4.1-2025-04-14",
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

  private let functionCallResponseJSON = """
    {
      "id": "resp_67ca09c5efe0819096d0511c92b8c890096610f474011cc0",
      "object": "response",
      "created_at": 1741294021,
      "status": "completed",
      "error": null,
      "incomplete_details": null,
      "instructions": null,
      "max_output_tokens": null,
      "model": "gpt-4.1-2025-04-14",
      "output": [
        {
          "type": "function_call",
          "id": "fc_67ca09c6bedc8190a7abfec07b1a1332096610f474011cc0",
          "call_id": "call_unLAR8MvFNptuiZK6K6HCy5k",
          "name": "get_current_weather",
          "arguments": "{\\"location\\":\\"Boston, MA\\",\\"unit\\":\\"celsius\\"}",
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

  private let reasoningResponseJSON = """
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
}
