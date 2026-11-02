import XCTest
@testable import SwiftOpenAI

// MARK: - VectorStoreFileObjectTests

final class VectorStoreFileObjectTests: XCTestCase {
  func testDecodesSnakeCaseFieldsAndZeroUsage() throws {
    let file = try JSONDecoder().decode(VectorStoreFileObject.self, from: fixture(usage: 0))
    XCTAssertEqual(file.id, "file_fixture")
    XCTAssertEqual(file.object, "vector_store.file")
    XCTAssertEqual(file.usageBytes, 0)
    XCTAssertEqual(file.createdAt, 1_711_027_402)
    XCTAssertEqual(file.vectorStoreID, "vs_fixture")
    XCTAssertEqual(file.status, "in_progress")
    XCTAssertNil(file.lastError)
  }

  func testDecodesNonNullLastError() throws {
    let file = try JSONDecoder().decode(VectorStoreFileObject.self, from: fixture(usage: 19, failed: true))
    XCTAssertEqual(file.usageBytes, 19)
    XCTAssertEqual(file.status, "failed")
    XCTAssertEqual(file.lastError?.code, "server_error")
    XCTAssertEqual(file.lastError?.message, "fixture error")
  }

  func testMissingLastErrorRemainsOptional() throws {
    var json = try XCTUnwrap(JSONSerialization.jsonObject(with: fixture(usage: 0)) as? [String: Any])
    json.removeValue(forKey: "last_error")
    let file = try JSONDecoder().decode(VectorStoreFileObject.self, from: JSONSerialization.data(withJSONObject: json))
    XCTAssertNil(file.lastError)
  }

  func testRequiredFieldsAndTypesRemainStrict() throws {
    let original = try XCTUnwrap(JSONSerialization.jsonObject(with: fixture(usage: 0)) as? [String: Any])
    for key in ["id", "object", "usage_bytes", "created_at", "vector_store_id", "status"] {
      var missing = original
      missing.removeValue(forKey: key)
      XCTAssertThrowsError(
        try JSONDecoder().decode(VectorStoreFileObject.self, from: JSONSerialization.data(withJSONObject: missing)),
        key)
      var null = original
      null[key] = NSNull()
      XCTAssertThrowsError(
        try JSONDecoder().decode(VectorStoreFileObject.self, from: JSONSerialization.data(withJSONObject: null)),
        key)
    }
    for key in ["usage_bytes", "created_at", "last_error"] {
      var invalid = original
      invalid[key] = "invalid"
      XCTAssertThrowsError(
        try JSONDecoder().decode(VectorStoreFileObject.self, from: JSONSerialization.data(withJSONObject: invalid)),
        key)
    }
  }

  func testDefaultServiceDecodesSingleAndListResponses() async throws {
    for failed in [false, true] {
      let client = try VectorStoreFixtureClient(payload: fixture(usage: failed ? 19 : 0, failed: failed))
      let service = OpenAIServiceFactory.service(apiKey: "fixture-not-a-real-key", httpClient: client)
      let created = try await service.createVectorStoreFile(
        vectorStoreID: "vs_fixture", parameters: VectorStoreFileParameter(fileID: "file_fixture"))
      let retrieved = try await service.retrieveVectorStoreFile(vectorStoreID: "vs_fixture", fileID: "file_fixture")
      let listed = try await service.listVectorStoreFiles(
        vectorStoreID: "vs_fixture", limit: nil, order: nil, after: nil, before: nil, filter: nil)
      let batch = try await service.listVectorStoreFilesInABatch(
        vectorStoreID: "vs_fixture", batchID: "batch_fixture", limit: nil, order: nil, after: nil, before: nil, filter: nil)
      XCTAssertEqual(listed.data.count, 1)
      XCTAssertEqual(batch.data.count, 1)
      for file in [created, retrieved] + listed.data + batch.data {
        XCTAssertEqual(file.usageBytes, failed ? 19 : 0)
        XCTAssertEqual(file.createdAt, 1_711_027_402)
        XCTAssertEqual(file.vectorStoreID, "vs_fixture")
        XCTAssertEqual(file.status, failed ? "failed" : "in_progress")
        XCTAssertEqual(file.lastError?.message, failed ? "fixture error" : nil)
      }
    }
  }

  private func fixture(usage: Int, failed: Bool = false) throws -> Data {
    try JSONSerialization.data(withJSONObject: [
      "id": "file_fixture",
      "object": "vector_store.file",
      "usage_bytes": usage,
      "created_at": 1_711_027_402,
      "vector_store_id": "vs_fixture",
      "status": failed ? "failed" : "in_progress",
      "last_error": failed ? ["code": "server_error", "message": "fixture error"] : NSNull(),
    ] as [String: Any])
  }
}

// MARK: - VectorStoreFixtureClient

private final class VectorStoreFixtureClient: HTTPClient {
  init(payload: Data) {
    self.payload = payload
  }

  let payload: Data

  func data(for request: HTTPRequest) async throws -> (Data, HTTPResponse) {
    let body: Data
    if request.method == .get, request.url.path.hasSuffix("/files") {
      let file = try JSONSerialization.jsonObject(with: payload)
      body = try JSONSerialization.data(withJSONObject: ["object": "list", "data": [file], "has_more": false])
    } else {
      body = payload
    }
    return (body, HTTPResponse(statusCode: 200, headers: [:]))
  }

  func bytes(for _: HTTPRequest) async throws -> (HTTPByteStream, HTTPResponse) {
    throw URLError(.unsupportedURL)
  }
}
