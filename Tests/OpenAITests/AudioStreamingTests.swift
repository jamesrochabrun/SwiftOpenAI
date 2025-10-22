import XCTest
@testable import SwiftOpenAI

// MARK: - AudioStreamingTests

final class AudioStreamingTests: XCTestCase {
  func testAudioSpeechParametersSupportStreamingFlag() {
    let parameters = AudioSpeechParameters(
      model: .tts1,
      input: "Hello",
      voice: .alloy,
      stream: true)

    XCTAssertEqual(parameters.input, "Hello")
    XCTAssertEqual(parameters.voice, "alloy")
    XCTAssertEqual(parameters.stream, true)
  }

  func testAudioSpeechChunkObjectStoresMetadata() {
    let data = Data([0x01, 0x02])
    let chunk = AudioSpeechChunkObject(chunk: data, isLastChunk: false, chunkIndex: 3)

    XCTAssertEqual(chunk.chunk, data)
    XCTAssertFalse(chunk.isLastChunk)
    XCTAssertEqual(chunk.chunkIndex, 3)
  }

  func testCreateStreamingSpeechDecodesSSEAudio() async throws {
    let expectedAudio = Data([0x01, 0x02, 0x03])
    let base64Audio = expectedAudio.base64EncodedString()
    let events = [
      "data: {\"type\":\"response.output_audio.delta\",\"delta\":\"\(base64Audio)\"}",
      "data: {\"type\":\"response.output_audio.done\"}",
      "data: [DONE]",
    ]

    let mockHTTPClient = MockHTTPClient()
    mockHTTPClient.bytesResponse = (
      .lines(AsyncThrowingStream<String, Error> { continuation in
        for event in events {
          continuation.yield(event)
        }
        continuation.finish()
      }),
      HTTPResponse(statusCode: 200, headers: ["Content-Type": "text/event-stream"]))

    let service = DefaultOpenAIService(
      apiKey: "test",
      httpClient: mockHTTPClient,
      decoder: JSONDecoder(),
      debugEnabled: false)

    let stream = try await service.createStreamingSpeech(
      parameters: AudioSpeechParameters(
        model: .tts1,
        input: "Stream me",
        voice: .alloy))

    var collectedChunks: [AudioSpeechChunkObject] = []
    for try await chunk in stream {
      collectedChunks.append(chunk)
    }

    XCTAssertEqual(collectedChunks.count, 2)
    XCTAssertEqual(collectedChunks[0].chunk, expectedAudio)
    XCTAssertFalse(collectedChunks[0].isLastChunk)
    XCTAssertTrue(collectedChunks[1].isLastChunk)

    guard let body = mockHTTPClient.lastRequest?.body else {
      return XCTFail("Expected request body")
    }

    let json = try XCTUnwrap(
      JSONSerialization.jsonObject(with: body, options: []) as? [String: Any])
    XCTAssertEqual(json["stream"] as? Bool, true)
  }
}

// MARK: - MockHTTPClient

private final class MockHTTPClient: HTTPClient {
  var bytesResponse: (HTTPByteStream, HTTPResponse)?
  var lastRequest: HTTPRequest?

  func data(for _: HTTPRequest) async throws -> (Data, HTTPResponse) {
    XCTFail("Unexpected data(for:) call in mock")
    return (Data(), HTTPResponse(statusCode: 500, headers: [:]))
  }

  func bytes(for request: HTTPRequest) async throws -> (HTTPByteStream, HTTPResponse) {
    lastRequest = request
    if let bytesResponse {
      return bytesResponse
    }
    XCTFail("bytes(for:) response not stubbed")
    return (.bytes(AsyncThrowingStream { continuation in
      continuation.finish()
    }), HTTPResponse(statusCode: 500, headers: [:]))
  }
}
