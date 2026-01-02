//
//  Endpoint+ProxLock.swift
//  SwiftOpenAI
//
//  Created by Morris Richman on 1/2/26.
//

#if !os(Linux)
import DeviceCheck
import Foundation

extension Endpoint {
  func request(
    apiKey: Authorization,
    assosiationID: String,
    openAIEnvironment: OpenAIEnvironment,
    organizationID: String?,
    method: HTTPMethod,
    params: Encodable? = nil,
    queryItems: [URLQueryItem] = [],
    betaHeaderField: String? = nil,
    extraHeaders: [String: String]? = nil)
    async throws -> URLRequest
  {
    let finalPath = path(in: openAIEnvironment)
    let components = urlComponents(base: openAIEnvironment.baseURL, path: finalPath, queryItems: queryItems)
    guard let url = components.url else {
      throw URLError(.badURL)
    }
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer %ProxLock_PARTIAL_KEY:\(apiKey.value)%", forHTTPHeaderField: "Authorization")
    if let organizationID {
      request.addValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
    }
    if let betaHeaderField {
      request.addValue(betaHeaderField, forHTTPHeaderField: "OpenAI-Beta")
    }
    if let extraHeaders {
      for header in extraHeaders {
        request.addValue(header.value, forHTTPHeaderField: header.key)
      }
    }
    request.httpMethod = method.rawValue
    if let params {
      request.httpBody = try JSONEncoder().encode(params)
    }

    request = try await processURLRequest(request, associationID: assosiationID)
    return request
  }

  func multiPartRequest(
    apiKey: Authorization,
    assosiationID: String,
    openAIEnvironment: OpenAIEnvironment,
    organizationID: String?,
    method: HTTPMethod,
    params: MultipartFormDataParameters,
    queryItems: [URLQueryItem] = [])
    async throws -> URLRequest
  {
    let finalPath = path(in: openAIEnvironment)
    let components = urlComponents(base: openAIEnvironment.baseURL, path: finalPath, queryItems: queryItems)
    guard let url = components.url else {
      throw URLError(.badURL)
    }
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    let boundary = UUID().uuidString
    request.addValue("Bearer %ProxLock_PARTIAL_KEY:\(apiKey.value)%", forHTTPHeaderField: "Authorization")
    if let organizationID {
      request.addValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
    }
    request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpBody = params.encode(boundary: boundary)
    request = try await processURLRequest(request, associationID: assosiationID)
    return request
  }

  private func urlComponents(
    base: String,
    path: String,
    queryItems: [URLQueryItem])
    -> URLComponents
  {
    guard var components = URLComponents(string: base) else {
      fatalError("Invalid base URL: \(base)")
    }
    components.path = path
    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }
    return components
  }
}

// MARK: - Private
/// Translates your `URLRequest` into an object for ProxLock.
///
/// - Important: This does not include any form of authorization header. To use the bearer token, simply call ``bearerToken`` where you would like the real token to be constructed.
private func processURLRequest(_ request: URLRequest, associationID: String) async throws -> URLRequest {
  var request = request

  guard let destinationURL = request.url, let destinationMethod = request.httpMethod else {
    throw URLError(.badURL)
  }

  // Set proxy components
  request.url = URL(string: "https://api.proxlock.dev/proxy")
  request.httpMethod = "POST"

  // Update headers
  request.setValue(destinationURL.absoluteString, forHTTPHeaderField: "ProxLock_DESTINATION")
  request.setValue("device-check", forHTTPHeaderField: "ProxLock_VALIDATION_MODE")
  request.setValue(destinationMethod.uppercased(), forHTTPHeaderField: "ProxLock_HTTP_METHOD")
  request.setValue(associationID, forHTTPHeaderField: "ProxLock_ASSOCIATION_ID")
  if let deviceCheckToken = try await getDeviceCheckToken() {
    request.setValue(deviceCheckToken.base64EncodedString(), forHTTPHeaderField: "X-Apple-Device-Token")
  }

  return request
}

/// Generated token used for Apple Device Check
private func getDeviceCheckToken() async throws -> Data? {
  #if targetEnvironment(simulator)
  guard let bypassToken = ProcessInfo.processInfo.environment["PROXLOCK_DEVICE_CHECK_BYPASS"] else {
    throw DCError(.featureUnsupported)
  }

  return bypassToken.data(using: .utf8)
  #else
  guard DCDevice.current.isSupported else {
    throw DCError(.featureUnsupported)
  }

  return try await withCheckedThrowingContinuation { continuation in
    DCDevice.current.generateToken { token, error in
      if let error {
        continuation.resume(throwing: error)
        return
      }

      continuation.resume(returning: token)
    }
  }
  #endif
}
#endif
