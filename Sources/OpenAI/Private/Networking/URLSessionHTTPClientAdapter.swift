import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if !os(Linux)
/// Adapter that implements HTTPClient protocol using URLSession
public class URLSessionHTTPClientAdapter: HTTPClient {
  /// Initializes a new URLSessionHTTPClientAdapter with the provided URLSession
  /// - Parameter urlSession: The URLSession instance to use. Defaults to `URLSession.shared`.
  public init(urlSession: URLSession = .shared) {
    self.urlSession = urlSession
  }

  /// Fetches data for a given HTTP request
  /// - Parameter request: The HTTP request to perform
  /// - Returns: A tuple containing the data and HTTP response
  public func data(for request: HTTPRequest) async throws -> (Data, HTTPResponse) {
    let urlRequest = try createURLRequest(from: request)

    let (data, urlResponse) = try await urlSession.data(for: urlRequest)

    guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
      throw URLError(.badServerResponse) // Or a custom error
    }

    let response = HTTPResponse(
      statusCode: httpURLResponse.statusCode,
      headers: convertHeaders(httpURLResponse.allHeaderFields))

    return (data, response)
  }

  /// Fetches a byte stream for a given HTTP request
  /// - Parameter request: The HTTP request to perform
  /// - Returns: A tuple containing the byte stream and HTTP response
  public func bytes(for request: HTTPRequest) async throws -> (HTTPByteStream, HTTPResponse) {
    let urlRequest = try createURLRequest(from: request)

    let (asyncBytes, urlResponse) = try await urlSession.bytes(for: urlRequest)

    guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
      throw URLError(.badServerResponse) // Or a custom error
    }

    let response = HTTPResponse(
      statusCode: httpURLResponse.statusCode,
      headers: convertHeaders(httpURLResponse.allHeaderFields))

    let stream = AsyncThrowingStream<String, Error> { continuation in
      Task {
        do {
          for try await line in asyncBytes.lines {
            continuation.yield(line)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }

    return (.lines(stream), response)
  }

  private let urlSession: URLSession

  /// Converts our HTTPRequest to URLRequest
  /// - Parameter request: Our HTTPRequest
  /// - Returns: URLRequest
  private func createURLRequest(from request: HTTPRequest) throws -> URLRequest {
    var urlRequest = URLRequest(url: request.url)
    urlRequest.httpMethod = request.method.rawValue

    for (key, value) in request.headers {
      urlRequest.setValue(value, forHTTPHeaderField: key)
    }

    urlRequest.httpBody = request.body

    return urlRequest
  }

  /// Converts HTTPURLResponse headers to a dictionary [String: String]
  /// - Parameter headers: The headers from HTTPURLResponse (i.e. `allHeaderFields`)
  /// - Returns: Dictionary of header name-value pairs
  private func convertHeaders(_ headers: [AnyHashable: Any]) -> [String: String] {
    var result = [String: String]()
    for (key, value) in headers {
      if let keyString = key as? String, let valueString = value as? String {
        result[keyString] = valueString
      }
    }
    return result
  }
}
#endif
