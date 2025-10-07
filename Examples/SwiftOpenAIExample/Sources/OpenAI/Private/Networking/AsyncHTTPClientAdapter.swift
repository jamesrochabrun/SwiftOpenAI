//
//  AsyncHTTPClientAdapter.swift
//  SwiftOpenAI
//
//  Created by Joe Fabisevich on 5/18/25.
//

#if os(Linux)
import AsyncHTTPClient
import Foundation
import NIOCore
import NIOFoundationCompat
import NIOHTTP1

/// Adapter that implements HTTPClient protocol using AsyncHTTPClient
public class AsyncHTTPClientAdapter: HTTPClient {
  /// Initializes a new AsyncHTTPClientAdapter with the provided AsyncHTTPClient
  /// - Parameter client: The AsyncHTTPClient instance to use
  public init(client: AsyncHTTPClient.HTTPClient) {
    self.client = client
  }

  deinit {
    shutdown()
  }

  /// Creates a new AsyncHTTPClientAdapter with a default configuration
  /// - Returns: A new AsyncHTTPClientAdapter instance
  public static func createDefault() -> AsyncHTTPClientAdapter {
    let httpClient = AsyncHTTPClient.HTTPClient(
      eventLoopGroupProvider: .singleton,
      configuration: AsyncHTTPClient.HTTPClient.Configuration(
        certificateVerification: .fullVerification,
        timeout: .init(
          connect: .seconds(30),
          read: .seconds(30)),
        backgroundActivityLogger: nil))
    return AsyncHTTPClientAdapter(client: httpClient)
  }

  /// Fetches data for a given HTTP request
  /// - Parameter request: The HTTP request to perform
  /// - Returns: A tuple containing the data and HTTP response
  public func data(for request: HTTPRequest) async throws -> (Data, HTTPResponse) {
    let asyncHTTPClientRequest = try createAsyncHTTPClientRequest(from: request)

    let response = try await client.execute(asyncHTTPClientRequest, deadline: .now() + .seconds(60))
    let body = try await response.body.collect(upTo: 100 * 1024 * 1024) // 100 MB max

    let data = Data(buffer: body)
    let httpResponse = HTTPResponse(
      statusCode: Int(response.status.code),
      headers: convertHeaders(response.headers))

    return (data, httpResponse)
  }

  /// Fetches a byte stream for a given HTTP request
  /// - Parameter request: The HTTP request to perform
  /// - Returns: A tuple containing the byte stream and HTTP response
  public func bytes(for request: HTTPRequest) async throws -> (HTTPByteStream, HTTPResponse) {
    let asyncHTTPClientRequest = try createAsyncHTTPClientRequest(from: request)

    let response = try await client.execute(asyncHTTPClientRequest, deadline: .now() + .seconds(60))
    let httpResponse = HTTPResponse(
      statusCode: Int(response.status.code),
      headers: convertHeaders(response.headers))

    let stream = AsyncThrowingStream<String, Error> { continuation in
      Task {
        do {
          for try await byteBuffer in response.body {
            if let string = byteBuffer.getString(at: 0, length: byteBuffer.readableBytes) {
              let lines = string.split(separator: "\n", omittingEmptySubsequences: false)
              for line in lines {
                continuation.yield(String(line))
              }
            }
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }

    return (.lines(stream), httpResponse)
  }

  /// Properly shutdown the HTTP client
  public func shutdown() {
    try? client.shutdown().wait()
  }

  /// The underlying AsyncHTTPClient instance
  private let client: AsyncHTTPClient.HTTPClient

  /// Converts our HTTPRequest to AsyncHTTPClient's Request
  /// - Parameter request: Our HTTPRequest
  /// - Returns: AsyncHTTPClient Request
  private func createAsyncHTTPClientRequest(from request: HTTPRequest) throws -> HTTPClientRequest {
    var asyncHTTPClientRequest = HTTPClientRequest(url: request.url.absoluteString)
    asyncHTTPClientRequest.method = NIOHTTP1.HTTPMethod(rawValue: request.method.rawValue)

    // Add headers
    for (key, value) in request.headers {
      asyncHTTPClientRequest.headers.add(name: key, value: value)
    }

    // Add body if present
    if let body = request.body {
      asyncHTTPClientRequest.body = .bytes(body)
    }

    return asyncHTTPClientRequest
  }

  /// Converts NIOHTTP1 headers to a dictionary
  /// - Parameter headers: NIOHTTP1 HTTPHeaders
  /// - Returns: Dictionary of header name-value pairs
  private func convertHeaders(_ headers: HTTPHeaders) -> [String: String] {
    var result = [String: String]()
    for header in headers {
      result[header.name] = header.value
    }
    return result
  }
}
#endif
