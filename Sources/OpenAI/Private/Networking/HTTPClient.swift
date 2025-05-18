import Foundation

/// Protocol that abstracts HTTP client functionality
public protocol HTTPClient {
  /// Fetches data for a given HTTP request
  /// - Parameter request: The HTTP request to perform
  /// - Returns: A tuple containing the data and HTTP response
  func data(for request: HTTPRequest) async throws -> (Data, HTTPResponse)

  /// Fetches a byte stream for a given HTTP request
  /// - Parameter request: The HTTP request to perform
  /// - Returns: A tuple containing the byte stream and HTTP response
  func bytes(for request: HTTPRequest) async throws -> (HTTPByteStream, HTTPResponse)
}

/// Represents an HTTP request with platform-agnostic properties
public struct HTTPRequest {
  /// The URL for the request
  var url: URL
  /// The HTTP method for the request
  var method: HTTPMethod
  /// The HTTP headers for the request
  var headers: [String: String]
  /// The body of the request, if any
  var body: Data?

  public init(url: URL, method: HTTPMethod, headers: [String: String], body: Data? = nil) {
    self.url = url
    self.method = method
    self.headers = headers
    self.body = body
  }
}

/// Represents an HTTP response with platform-agnostic properties
public struct HTTPResponse {
  /// The HTTP status code of the response
  var statusCode: Int
  /// The HTTP headers in the response
  var headers: [String: String]

  public init(statusCode: Int, headers: [String: String]) {
    self.statusCode = statusCode
    self.headers = headers
  }
}

/// Represents a stream of bytes or lines from an HTTP response
public enum HTTPByteStream {
  /// A stream of bytes
  case bytes(AsyncThrowingStream<UInt8, Error>)
  /// A stream of lines (strings)
  case lines(AsyncThrowingStream<String, Error>)
}
