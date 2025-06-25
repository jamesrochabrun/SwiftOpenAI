//
//  Endpoint.swift
//
//
//  Created by James Rochabrun on 10/11/23.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

// MARK: - HTTPMethod

public enum HTTPMethod: String {
  case post = "POST"
  case get = "GET"
  case delete = "DELETE"
}

// MARK: - Endpoint

protocol Endpoint {
  func path(
    in openAIEnvironment: OpenAIEnvironment)
    -> String
}

// MARK: Endpoint+Requests

extension Endpoint {

  func request(
    apiKey: Authorization,
    openAIEnvironment: OpenAIEnvironment,
    organizationID: String?,
    method: HTTPMethod,
    params: Encodable? = nil,
    queryItems: [URLQueryItem] = [],
    betaHeaderField: String? = nil,
    extraHeaders: [String: String]? = nil)
    throws -> URLRequest
  {
    let finalPath = path(in: openAIEnvironment)
    let components = urlComponents(base: openAIEnvironment.baseURL, path: finalPath, queryItems: queryItems)
    guard let url = components.url else {
      throw URLError(.badURL)
    }
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(apiKey.value, forHTTPHeaderField: apiKey.headerField)
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
      request.httpBody = try encodeWithExtraBody(params)
    }
    return request
  }

  func multiPartRequest(
    apiKey: Authorization,
    openAIEnvironment: OpenAIEnvironment,
    organizationID: String?,
    method: HTTPMethod,
    params: MultipartFormDataParameters,
    queryItems: [URLQueryItem] = [])
    throws -> URLRequest
  {
    let finalPath = path(in: openAIEnvironment)
    let components = urlComponents(base: openAIEnvironment.baseURL, path: finalPath, queryItems: queryItems)
    guard let url = components.url else {
      throw URLError(.badURL)
    }
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    let boundary = UUID().uuidString
    request.addValue(apiKey.value, forHTTPHeaderField: apiKey.headerField)
    if let organizationID {
      request.addValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
    }
    request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpBody = params.encode(boundary: boundary)
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
  
  /// Add extraBody handling through JSON merging
  private func encodeWithExtraBody(_ params: Encodable) throws -> Data {
    let encoder = JSONEncoder()
    let baseData = try encoder.encode(params)
    
    // Check if this is ChatCompletionParameters with extraBody
    if let chatParams = params as? ChatCompletionParameters,
       let extraBody = chatParams.extraBody,
       !extraBody.isEmpty {
      
      // Parse base JSON
      guard var baseJSON = try JSONSerialization.jsonObject(with: baseData) as? [String: Any] else {
        throw URLError(.cannotParseResponse)
      }
      
      // Merge extraBody into base JSON
      for (key, value) in extraBody {
        baseJSON[key] = value
      }
      
      // Re-encode merged JSON
      return try JSONSerialization.data(withJSONObject: baseJSON)
    }
    
    // Return standard encoding if no extraBody
    return baseData
  }

}
