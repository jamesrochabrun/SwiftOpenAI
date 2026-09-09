import XCTest
@testable import SwiftOpenAI

final class HTTPLineDecoderTests: XCTestCase {
  func testJSONAndUTF8SurviveEveryPossibleNetworkSplit() {
    let text = "data: {\"choices\":[{\"delta\":{\"content\":\"café 😀\"}}]}\n\ndata: [DONE]\n\n"
    let bytes = Array(text.utf8)
    let expected = ["data: {\"choices\":[{\"delta\":{\"content\":\"café 😀\"}}]}", "", "data: [DONE]", ""]
    for split in 0...bytes.count {
      XCTAssertEqual(decode([Array(bytes[..<split]), Array(bytes[split...])]), expected, "split \(split)")
    }
    XCTAssertEqual(decode(bytes.map { [$0] }), expected)
  }

  func testEmptyChunksAndLineBoundariesDoNotInventBlankLines() {
    XCTAssertEqual(
      decode([[], Array("data: one\n".utf8), [], Array("\ndata: two\n\n".utf8), []]),
      ["data: one", "", "data: two", ""])
  }

  func testCRLFAcrossChunksAndBareCR() {
    XCTAssertEqual(decode(Array("a\r\nb\rc\n\r\n".utf8).map { [$0] }), ["a", "b", "c", ""])
  }

  func testEOFReturnsOnlyThePendingLineWithoutInventingDelimiter() {
    var decoder = HTTPLineDecoder()
    XCTAssertEqual(decoder.append(Array("data: {\"partial\":".utf8)), [])
    XCTAssertEqual(decoder.finish(), "data: {\"partial\":")
    XCTAssertNil(decoder.finish())
    XCTAssertEqual(decode([Array("complete\n".utf8)]), ["complete"])
    XCTAssertEqual(decode([]), [])
  }

  func testStreamPreservesMalformedPayloadForCallerToReject() async throws {
    let source = AsyncThrowingStream<[UInt8], Error> { continuation in
      for text in ["data: {bad", " JSON}\n", "\n"] { continuation.yield(Array(text.utf8)) }
      continuation.finish()
    }
    var lines = [String]()
    for try await line in HTTPLineStream.lines(from: source) { lines.append(line) }
    XCTAssertEqual(lines, ["data: {bad JSON}", ""])
  }

  func testConnectionFailureDoesNotFlushPartialBytesAsALine() async throws {
    enum FixtureError: Error { case disconnected }
    let source = AsyncThrowingStream<[UInt8], Error> { continuation in
      continuation.yield(Array("complete\npartial".utf8))
      continuation.finish(throwing: FixtureError.disconnected)
    }
    var lines = [String]()
    do {
      for try await line in HTTPLineStream.lines(from: source) { lines.append(line) }
      XCTFail("Expected connection failure")
    } catch FixtureError.disconnected { }
    XCTAssertEqual(lines, ["complete"])
  }

  func testConsumerCancellationTerminatesSource() async throws {
    let terminated = expectation(description: "source cancelled")
    let received = expectation(description: "first line received")
    let source = AsyncThrowingStream<[UInt8], Error> { continuation in
      continuation.onTermination = { _ in terminated.fulfill() }
      continuation.yield(Array("first\npending".utf8))
    }
    let consumer = Task {
      do {
        for try await _ in HTTPLineStream.lines(from: source) { received.fulfill() }
      } catch { }
    }
    await fulfillment(of: [received], timeout: 2)
    consumer.cancel()
    await fulfillment(of: [terminated], timeout: 2)
    _ = await consumer.result
  }

  private func decode(_ chunks: [[UInt8]]) -> [String] {
    var decoder = HTTPLineDecoder()
    var result = chunks.flatMap { decoder.append($0) }
    if let tail = decoder.finish() { result.append(tail) }
    return result
  }

}
