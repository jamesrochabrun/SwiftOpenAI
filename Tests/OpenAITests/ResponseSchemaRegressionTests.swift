#if compiler(>=6.0)
import Foundation
import SwiftOpenAI
import Testing

@Suite("Responses schema regressions")
struct ResponseSchemaRegressionTests {
  @Test("A response accepts explicitly null metadata")
  func nullMetadata() throws {
    let data = Data(
      #"{"id":"r","object":"response","created_at":1,"model":"test","output":[],"parallel_tool_calls":true,"metadata":null}"#
        .utf8)
    let response = try JSONDecoder().decode(ResponseModel.self, from: data)
    #expect(response.metadata == nil)
  }

  @Test("Documented web-search fields survive decoding")
  func searchFields() throws {
    let data = Data(
      #"{"id":"w","type":"web_search_call","status":"completed","action":{"type":"search","query":"weather","queries":["weather","forecast"]}}"#
        .utf8)
    let item = try JSONDecoder().decode(OutputItem.self, from: data)
    guard case .webSearchCall(let search) = item else {
      Issue.record("Expected web search")
      return
    }
    let action = try #require(search.action)
    #expect(action.type == "search")
    #expect(action.queries == ["weather", "forecast"])
    #expect(action.query == "weather")
    let event = try JSONDecoder().decode(ResponseStreamEvent.self, from: Data(
      (#"{"type":"response.output_item.done","output_index":0,"item":"# + String(decoding: data, as: UTF8.self) + "}").utf8))
    guard case .outputItemDone(let done) = event, case .webSearchCall(let streamed) = done.item else {
      Issue.record("Expected streamed web search")
      return
    }
    #expect(streamed.action?.queries == ["weather", "forecast"])
  }

  @Test("Documented generated-image format survives decoding", arguments: ["png", "jpeg", "webp"])
  func imageFormat(format: String) throws {
    let data = Data(
      #"{"id":"i","type":"image_generation_call","status":"completed","result":"aW1hZ2U=","output_format":"\#(format)"}"#
        .utf8)
    let item = try JSONDecoder().decode(OutputItem.self, from: data)
    guard case .imageGenerationCall(let image) = item else {
      Issue.record("Expected generated image")
      return
    }
    #expect(image.outputFormat == format)
    #expect(image.result == "aW1hZ2U=")
    let streamed = try JSONDecoder().decode(StreamOutputItem.self, from: data)
    guard case .imageGenerationCall(let streamImage) = streamed else {
      Issue.record("Expected streamed generated image")
      return
    }
    #expect(streamImage.outputFormat == format)
  }

  @Test("Web search preserves page and find actions")
  func pageActions() throws {
    for type in ["open_page", "find_in_page"] {
      let data = Data(#"{"type":"\#(type)","url":"https://example.com/","pattern":"forecast"}"#.utf8)
      let action = try JSONDecoder().decode(OutputItem.WebSearchToolCall.Action.self, from: data)
      #expect(action.type == type)
      #expect(action.url == "https://example.com/")
      #expect(action.pattern == "forecast")
      #expect(action.queries == nil)
    }
  }

  @Test("Optional tool fields may be absent or null")
  func optionalToolFields() throws {
    for body in ["{}", #"{"type":null,"query":null,"queries":null,"url":null,"pattern":null}"#] {
      let action = try JSONDecoder().decode(OutputItem.WebSearchToolCall.Action.self, from: Data(body.utf8))
      #expect(action.query == nil)
      #expect(action.queries == nil)
    }
    for extra in ["", #", "output_format":null"#] {
      let body = #"{"id":"i","type":"image_generation_call"\#(extra)}"#
      let image = try JSONDecoder().decode(OutputItem.ImageGenerationCall.self, from: Data(body.utf8))
      #expect(image.outputFormat == nil)
    }
  }

  @Test("Wrong field types remain decoding errors")
  func invalidFieldTypes() {
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(OutputItem.WebSearchToolCall.Action.self, from: Data(#"{"queries":17}"#.utf8))
    }
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(
        OutputItem.ImageGenerationCall.self,
        from: Data(#"{"id":"i","type":"image_generation_call","output_format":17}"#.utf8))
    }
  }

  @Test(
    "Accepting null metadata does not relax other required response fields",
    arguments: ["id", "object", "created_at", "model", "output", "parallel_tool_calls"])
  func requiredResponseFields(field: String) throws {
    var json: [String: Any] = [
      "id": "r",
      "object": "response",
      "created_at": 1,
      "model": "test",
      "output": [],
      "parallel_tool_calls": true,
      "metadata": NSNull(),
    ]
    json.removeValue(forKey: field)
    let data = try JSONSerialization.data(withJSONObject: json)
    #expect(throws: DecodingError.self) { try JSONDecoder().decode(ResponseModel.self, from: data) }
  }
}
#endif
