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
      request.httpBody = try JSONEncoder().encode(params)
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

}
