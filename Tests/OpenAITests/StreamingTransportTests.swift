#if compiler(>=6.0)
import Foundation
import SwiftOpenAI
import Testing

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - StreamingTransportTests

@Suite("Streaming transport regressions")
struct StreamingTransportTests {
  enum Endpoint: CaseIterable { case responses, chat, assistants }

  @Test(
    "HTTP failures read the original body without repeating the POST",
    arguments: [400, 401, 403, 429, 500],
    Endpoint.allCases)
  func originalErrorResponse(status: Int, endpoint: Endpoint) async throws {
    let client = RecordingStreamClient(status: status, lines: [
      "{", #"  "error": {"message": "original failure"}"#, "}",
    ])
    let service = OpenAIServiceFactory.service(apiKey: "test", httpClient: client)
    do {
      switch endpoint {
      case .responses:
        _ = try await service.responseCreateStream(.init(input: .string("hello"), model: .custom("test")))
      case .chat:
        _ = try await service.startStreamedChat(parameters: .init(messages: [], model: .custom("test")))
      case .assistants:
        var request = URLRequest(url: URL(string: "https://example.invalid/stream")!)
        request.httpMethod = "POST"
        _ = try await service.fetchAssistantStreamEvents(with: request, debugEnabled: false)
      }
      Issue.record("Expected an HTTP error")
    } catch APIError.responseUnsuccessful(let description, let statusCode) {
      #expect(statusCode == status)
      #expect(description == "original failure")
    }
    #expect(await client.streamRequests == 1)
    #expect(await client.dataRequests == 0)
  }

  @Test("An SSE event joins data fields before decoding JSON")
  func multilineEvent() async throws {
    let values = try await collect([
      ": heartbeat", "event: message", "id: 1", "retry: 1000",
      #"data: {"value":"#,
      #"data: "café 😀"}"#, "",
      #"data:{"value":"second"}"#, "",
    ])
    #expect(values == ["café 😀", "second"])
  }

  @Test("HTTP error bodies support raw bytes and retain status for non-JSON bodies", arguments: [false, true])
  func errorBodyFormats(rawBytes: Bool) async throws {
    for (body, message) in [(#"{"error":{"message":"original failure"}}"#, "original failure"), ("not JSON", "status code 500")] {
      let client = RecordingStreamClient(status: 500, lines: [body], rawBytes: rawBytes)
      let service = OpenAIServiceFactory.service(apiKey: "test", httpClient: client)
      do {
        _ = try await service.responseCreateStream(.init(input: .string("hello"), model: .custom("test")))
        Issue.record("Expected an HTTP error")
      } catch APIError.responseUnsuccessful(let description, let statusCode) {
        #expect(description == message)
        #expect(statusCode == 500)
      }
      #expect(await client.streamRequests == 1)
      #expect(await client.dataRequests == 0)
    }
  }

  @Test("Leading BOM and empty data fields preserve the SSE payload")
  func eventFields() async throws {
    #expect(try await collect(["\u{FEFF}: heartbeat", "data", #"data: {"value":"ok"}"#, ""]) == ["ok"])
  }

  @Test("Chat Completions still emits text and usage chunks")
  func chatCompletions() async throws {
    let client = RecordingStreamClient(status: 200, lines: [
      #"data: {"id":"c","object":"chat.completion.chunk","created":1,"model":"test","choices":[{"index":0,"delta":{"content":"hello"}}]}"#,
      "",
      #"data: {"id":"c","object":"chat.completion.chunk","created":1,"model":"test","choices":[],"usage":{"prompt_tokens":1,"completion_tokens":2,"total_tokens":3}}"#,
      "",
      "data: [DONE]", "",
    ])
    let service = OpenAIServiceFactory.service(apiKey: "test", httpClient: client)
    let stream = try await service.startStreamedChat(parameters: .init(messages: [], model: .custom("test")))
    var chunks = [ChatCompletionChunkObject]()
    for try await chunk in stream { chunks.append(chunk) }
    #expect(chunks.count == 2)
    #expect(chunks.first?.choices?.first?.delta?.content == "hello")
    #expect(chunks.last?.usage?.totalTokens == 3)
  }

  @Test("DONE terminates consumption before trailing events")
  func doneTerminates() async throws {
    let values = try await collect([
      #"data: {"value":"first"}"#, "", "data: [DONE]", "",
      #"data: {"value":"must not be delivered"}"#, "",
    ])
    #expect(values == ["first"])
  }

  @Test("A final unterminated line keeps the existing EOF behavior")
  func finalLineAtEOF() async throws {
    #expect(try await collect([#"data: {"value":"last"}"#]) == ["last"])
  }

  @Test("Malformed known payloads fail the consumer")
  func malformedPayload() async throws {
    do {
      _ = try await collect([#"data: {"value":17}"#, ""])
      Issue.record("Expected a decoding error")
    } catch is DecodingError { }
  }

  private struct Payload: Decodable {
    let value: String
  }

  private func collect(_ lines: [String]) async throws -> [String] {
    let client = RecordingStreamClient(status: 200, lines: lines)
    let service = OpenAIServiceFactory.service(apiKey: "test", httpClient: client)
    var request = URLRequest(url: URL(string: "https://example.invalid/stream")!)
    request.httpMethod = "POST"
    let stream = try await service.fetchStream(debugEnabled: false, type: Payload.self, with: request)
    var values = [String]()
    for try await payload in stream { values.append(payload.value) }
    return values
  }
}

// MARK: - RecordingStreamClient

private actor RecordingStreamClient: HTTPClient {
  init(status: Int, lines: [String], rawBytes: Bool = false) {
    self.status = status
    self.lines = lines
    self.rawBytes = rawBytes
  }

  private(set) var streamRequests = 0
  private(set) var dataRequests = 0

  func data(for _: HTTPRequest) async throws -> (Data, HTTPResponse) {
    dataRequests += 1
    return (Data(#"{"error":{"message":"second request"}}"#.utf8), .init(statusCode: status, headers: [:]))
  }

  func bytes(for _: HTTPRequest) async throws -> (HTTPByteStream, HTTPResponse) {
    streamRequests += 1
    if rawBytes {
      let stream = AsyncThrowingStream<UInt8, Error> { continuation in
        for byte in lines.joined(separator: "\n").utf8 { continuation.yield(byte) }
        continuation.finish()
      }
      return (.bytes(stream), .init(statusCode: status, headers: [:]))
    }
    let stream = AsyncThrowingStream<String, Error> { continuation in
      for line in lines { continuation.yield(line) }
      continuation.finish()
    }
    return (.lines(stream), .init(statusCode: status, headers: [:]))
  }

  private let status: Int
  private let lines: [String]
  private let rawBytes: Bool

}
#endif
