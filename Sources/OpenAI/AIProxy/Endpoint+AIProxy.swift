//
//  Endpoint+AIProxy.swift
//
//
//  Created by Lou Zell on 3/26/24.
//

import Foundation
import OSLog
import DeviceCheck
import UIKit

private let aiproxyLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnknownApp",
                                   category: "SwiftOpenAI+AIProxy")


// MARK: Endpoint+AIProxy

extension Endpoint {

    private func urlComponents(
       queryItems: [URLQueryItem])
       -> URLComponents
    {
       var components = URLComponents(string: "https://api.aiproxy.pro")!
       components.path = path
       if !queryItems.isEmpty {
          components.queryItems = queryItems
       }
       return components
    }

   func request(
      aiproxyPartialKey: String,
      organizationID: String?,
      method: HTTPMethod,
      params: Encodable? = nil,
      queryItems: [URLQueryItem] = [],
      betaHeaderField: String? = nil,
      deviceCheckBypass: String? = nil)
      async throws -> URLRequest
   {
      var request = URLRequest(url: urlComponents(queryItems: queryItems).url!)
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue(aiproxyPartialKey, forHTTPHeaderField: "aiproxy-partial-key")
      if let organizationID {
         request.addValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
      }
      if let betaHeaderField {
         request.addValue(betaHeaderField, forHTTPHeaderField: "OpenAI-Beta")
      }
      if let vendorID = getVendorID() {
          request.addValue(vendorID, forHTTPHeaderField: "aiproxy-vendor-id")
      }
      if let deviceCheckToken = await getDeviceCheckToken() {
          request.addValue(deviceCheckToken, forHTTPHeaderField: "aiproxy-devicecheck")
      }
#if DEBUG && targetEnvironment(simulator)
      if let deviceCheckBypass = deviceCheckBypass {
         request.addValue(deviceCheckBypass, forHTTPHeaderField: "aiproxy-devicecheck-bypass")
      }
#endif
      request.httpMethod = method.rawValue
      if let params {
         request.httpBody = try JSONEncoder().encode(params)
      }
      return request
   }

   func multiPartRequest(
      aiproxyPartialKey: String,
      organizationID: String?,
      method: HTTPMethod,
      params: MultipartFormDataParameters,
      queryItems: [URLQueryItem] = [],
      deviceCheckBypass: String? = nil)
      async throws -> URLRequest
   {
      var request = URLRequest(url: urlComponents(queryItems: queryItems).url!)
      request.httpMethod = method.rawValue
      request.addValue(aiproxyPartialKey, forHTTPHeaderField: "aiproxy-partial-key")
      if let organizationID {
         request.addValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
      }
      if let vendorID = getVendorID() {
          request.addValue(vendorID, forHTTPHeaderField: "aiproxy-vendor-id")
      }
      if let deviceCheckToken = await getDeviceCheckToken() {
          request.addValue(deviceCheckToken, forHTTPHeaderField: "aiproxy-devicecheck")
      }
#if DEBUG && targetEnvironment(simulator)
      if let deviceCheckBypass = deviceCheckBypass {
         request.addValue(deviceCheckBypass, forHTTPHeaderField: "aiproxy-devicecheck-bypass")
      }
#endif
      let boundary = UUID().uuidString
      request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
      request.httpBody = params.encode(boundary: boundary)
      return request
   }
}


// MARK: Private Helpers

/// Gets a device check token for use in your calls to aiproxy.
/// The device token may be nil when targeting the iOS simulator.
/// Ensure that you are conditionally compiling the `deviceCheckBypass` token for iOS simulation only.
/// Do not let the `deviceCheckBypass` token slip into your production codebase, or an attacker can easily use it themselves.
private func getDeviceCheckToken() async -> String? {
    guard DCDevice.current.isSupported else {
        aiproxyLogger.error("DeviceCheck is not available on this device. Are you on the simulator?")
        return nil
    }

    do {
        let data = try await DCDevice.current.generateToken()
        return data.base64EncodedString()
    } catch {
        aiproxyLogger.error("Could not create DeviceCheck token. Are you using an explicit bundle identifier?")
        return nil
    }
}

/// Get a unique ID for this user (scoped to the current vendor, and not personally identifiable):
private func getVendorID() -> String? {
    return UIDevice.current.identifierForVendor?.uuidString
}
