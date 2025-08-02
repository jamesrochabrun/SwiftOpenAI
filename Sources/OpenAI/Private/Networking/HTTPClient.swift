import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - HTTPClient

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

// MARK: - HTTPRequest

/// Represents an HTTP request with platform-agnostic properties
public struct HTTPRequest {
  public init(url: URL, method: HTTPMethod, headers: [String: String], body: Data? = nil) {
    self.url = url
    self.method = method
    self.headers = headers
    self.body = body
  }

  /// Initializes an HTTPRequest from a URLRequest
  /// - Parameter urlRequest: The URLRequest to convert
  public init(from urlRequest: URLRequest) throws {
    guard let url = urlRequest.url else {
      throw URLError(.badURL)
    }

    guard
      let httpMethodString = urlRequest.httpMethod,
      let httpMethod = HTTPMethod(rawValue: httpMethodString)
    else {
      throw URLError(.unsupportedURL)
    }

    var headers: [String: String] = [:]
    if let allHTTPHeaderFields = urlRequest.allHTTPHeaderFields {
      headers = allHTTPHeaderFields
    }

    self.url = url
    method = httpMethod
    self.headers = headers
    body = urlRequest.httpBody
  }

  /// The URL for the request
  var url: URL
  /// The HTTP method for the request
  var method: HTTPMethod
  /// The HTTP headers for the request
  var headers: [String: String]
  /// The body of the request, if any
  var body: Data?
}

// MARK: - HTTPResponse

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

// MARK: - HTTPByteStream

/// Represents a stream of bytes or lines from an HTTP response
public enum HTTPByteStream {
  /// A stream of bytes
  case bytes(AsyncThrowingStream<UInt8, Error>)
  /// A stream of lines (strings)
  case lines(AsyncThrowingStream<String, Error>)
}

// MARK: - HTTPClientFactory

public enum HTTPClientFactory {
  /// Creates a default HTTPClient implementation appropriate for the current platform
  /// - Returns: URLSessionHTTPClientAdapter on Apple platforms, AsyncHTTPClientAdapter on Linux
  public static func createDefault() -> HTTPClient {
    #if os(Linux)
    return AsyncHTTPClientAdapter.createDefault()
    #else
    return URLSessionHTTPClientAdapter()
    #endif
  }
}
