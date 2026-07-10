import XCTest
@testable import SwiftOpenAI

final class RealtimeParameterTests: XCTestCase {
  func testRealtimeSessionConfigurationEncodesGAShape() throws {
    let config = OpenAIRealtimeSessionConfiguration(
      inputAudioFormat: .pcm16,
      inputAudioTranscription: .init(model: Model.gptRealtimeWhisper.value, delay: .low, language: "en"),
      instructions: "Be brief.",
      maxResponseOutputTokens: .int(1024),
      modalities: [.audio],
      model: Model.gptRealtime21.value,
      outputAudioFormat: .pcm16,
      parallelToolCalls: true,
      reasoning: .init(effort: .low),
      tools: [.function(.init(
        name: "get_demo_context",
        description: "Get demo context.",
        parameters: ["type": "object"]))],
      toolChoice: .auto,
      turnDetection: .init(type: .semanticVAD(eagerness: .auto, createResponse: true, interruptResponse: true)),
      voice: "marin")

    let json = try decodeJSON(config)

    XCTAssertEqual(json["type"] as? String, "realtime")
    XCTAssertNil(json["modalities"])
    XCTAssertNil(json["input_audio_format"])
    XCTAssertNil(json["max_response_output_tokens"])
    XCTAssertEqual(json["output_modalities"] as? [String], ["audio"])
    XCTAssertEqual(json["max_output_tokens"] as? Int, 1024)
    XCTAssertEqual(json["model"] as? String, "gpt-realtime-2.1")
    XCTAssertEqual(json["parallel_tool_calls"] as? Bool, true)

    let audio = try XCTUnwrap(json["audio"] as? [String: Any])
    let input = try XCTUnwrap(audio["input"] as? [String: Any])
    let inputFormat = try XCTUnwrap(input["format"] as? [String: Any])
    XCTAssertEqual(inputFormat["type"] as? String, "audio/pcm")
    XCTAssertEqual(inputFormat["rate"] as? Int, 24_000)

    let transcription = try XCTUnwrap(input["transcription"] as? [String: Any])
    XCTAssertEqual(transcription["model"] as? String, "gpt-realtime-whisper")
    XCTAssertEqual(transcription["delay"] as? String, "low")

    let output = try XCTUnwrap(audio["output"] as? [String: Any])
    XCTAssertEqual(output["voice"] as? String, "marin")
  }

  func testFunctionCallOutputEncodesConversationItem() throws {
    let event = OpenAIRealtimeFunctionCallOutput(
      callID: "call_123",
      output: #"{"status":"ok"}"#)

    let json = try decodeJSON(event)
    XCTAssertEqual(json["type"] as? String, "conversation.item.create")

    let item = try XCTUnwrap(json["item"] as? [String: Any])
    XCTAssertEqual(item["type"] as? String, "function_call_output")
    XCTAssertEqual(item["call_id"] as? String, "call_123")
    XCTAssertEqual(item["output"] as? String, #"{"status":"ok"}"#)
  }

  func testConversationItemTruncateEncodesPlaybackPosition() throws {
    let event = OpenAIRealtimeConversationItemTruncate(
      itemID: "item_assistant_123",
      audioEndMS: 1_250)

    let json = try decodeJSON(event)
    XCTAssertEqual(json["type"] as? String, "conversation.item.truncate")
    XCTAssertEqual(json["item_id"] as? String, "item_assistant_123")
    XCTAssertEqual(json["content_index"] as? Int, 0)
    XCTAssertEqual(json["audio_end_ms"] as? Int, 1_250)
  }

  func testConversationItemPreservesClientGeneratedID() throws {
    let event = OpenAIRealtimeConversationItemCreate(
      item: .init(id: "item_local_123", role: "user", text: "Hello"))

    let json = try decodeJSON(event)
    let item = try XCTUnwrap(json["item"] as? [String: Any])
    XCTAssertEqual(item["id"] as? String, "item_local_123")
  }

  func testJSONSerializationConversionPreservesScalarTypes() throws {
    let data = Data(#"{"bool":true,"double":1.5,"int":1}"#.utf8)
    let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    guard case .bool(true)? = OpenAIJSONValue(jsonObject: object["bool"] as Any) else {
      return XCTFail("Expected a boolean JSON value")
    }
    guard case .double(1.5)? = OpenAIJSONValue(jsonObject: object["double"] as Any) else {
      return XCTFail("Expected a double JSON value")
    }
    guard case .int(1)? = OpenAIJSONValue(jsonObject: object["int"] as Any) else {
      return XCTFail("Expected an integer JSON value")
    }
  }

  func testRealtimeClientSecretParametersEncodeSession() throws {
    let parameters = OpenAIRealtimeClientSecretParameters(
      expiresAfter: .init(seconds: 600),
      session: .init(instructions: "Be brief.", model: Model.gptRealtime21.value))

    let json = try decodeJSON(parameters)
    let expiresAfter = try XCTUnwrap(json["expires_after"] as? [String: Any])
    XCTAssertEqual(expiresAfter["anchor"] as? String, "created_at")
    XCTAssertEqual(expiresAfter["seconds"] as? Int, 600)

    let session = try XCTUnwrap(json["session"] as? [String: Any])
    XCTAssertEqual(session["type"] as? String, "realtime")
    XCTAssertEqual(session["model"] as? String, "gpt-realtime-2.1")
  }

  func testRealtimeModelConstants() {
    XCTAssertEqual(Model.gptRealtime21.value, "gpt-realtime-2.1")
    XCTAssertEqual(Model.gptRealtime21Mini.value, "gpt-realtime-2.1-mini")
    XCTAssertEqual(Model.gptRealtime2.value, "gpt-realtime-2")
    XCTAssertEqual(Model.gptRealtime15.value, "gpt-realtime-1.5")
    XCTAssertEqual(Model.gptRealtime.value, "gpt-realtime")
    XCTAssertEqual(Model.gptRealtimeMini.value, "gpt-realtime-mini")
    XCTAssertEqual(Model.gptRealtimeTranslate.value, "gpt-realtime-translate")
    XCTAssertEqual(Model.gptRealtimeWhisper.value, "gpt-realtime-whisper")
  }

  private func decodeJSON(_ value: Encodable) throws -> [String: Any] {
    let data = try JSONEncoder().encode(value)
    return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
  }
}
