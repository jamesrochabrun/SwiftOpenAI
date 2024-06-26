//
//  Endpoint+AIProxy.swift
//
//
//  Created by Lou Zell on 3/26/24.
//

import Foundation
import OSLog
import DeviceCheck
#if canImport(UIKit)
    import UIKit
#endif
#if canImport(IOKit)
    import IOKit
#endif
#if os(watchOS)
import WatchKit
#endif

private let aiproxyLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnknownApp",
                                   category: "SwiftOpenAI+AIProxy")

private let deviceCheckWarning = """
    AIProxy warning: DeviceCheck is not available on this device.

    To use AIProxy on an iOS simulator, set an AIPROXY_DEVICE_CHECK_BYPASS environment variable.

    See the AIProxy section of the README at https://github.com/jamesrochabrun/SwiftOpenAI for instructions.
    """


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
      clientID: String?,
      organizationID: String?,
      method: HTTPMethod,
      params: Encodable? = nil,
      queryItems: [URLQueryItem] = [],
      betaHeaderField: String? = nil)
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
      if let clientID = clientID ?? getClientID() {
          request.addValue(clientID, forHTTPHeaderField: "aiproxy-client-id")
      }
      if let deviceCheckToken = await getDeviceCheckToken() {
          request.addValue(deviceCheckToken, forHTTPHeaderField: "aiproxy-devicecheck")
      }
#if DEBUG && targetEnvironment(simulator)
      if let deviceCheckBypass = ProcessInfo.processInfo.environment["AIPROXY_DEVICE_CHECK_BYPASS"] {
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
      clientID: String?,
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
      if let clientID = clientID ?? getClientID() {
          request.addValue(clientID, forHTTPHeaderField: "aiproxy-client-id")
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
private func getDeviceCheckToken() async -> String? {
    guard DCDevice.current.isSupported else {
        if ProcessInfo.processInfo.environment["AIPROXY_DEVICE_CHECK_BYPASS"] == nil {
            aiproxyLogger.warning("\(deviceCheckWarning, privacy: .public)")
        }
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

/// Get a unique ID for this client
private func getClientID() -> String? {
#if os(watchOS)
    return WKInterfaceDevice.current().identifierForVendor?.uuidString
#elseif canImport(UIKit)
    return UIDevice.current.identifierForVendor?.uuidString
#elseif canImport(IOKit)
    return getIdentifierFromIOKit()
#else
    return nil
#endif
}


// MARK: IOKit conditional dependency
/// These functions are used on macOS for creating a client identifier.
/// Unfortunately, macOS does not have a straightforward helper like UIKit's `identifierForVendor`
#if canImport(IOKit)
private func getIdentifierFromIOKit() -> String? {
    guard let macBytes = copy_mac_address() as? Data else {
        return nil
    }
    let macHex = macBytes.map { String(format: "%02X", $0) }
    return macHex.joined(separator: ":")
}

// This function is taken from the Apple sample code at:
// https://developer.apple.com/documentation/appstorereceipts/validating_receipts_on_the_device#3744656
private func io_service(named name: String, wantBuiltIn: Bool) -> io_service_t? {
    let default_port = kIOMainPortDefault
    var iterator = io_iterator_t()
    defer {
        if iterator != IO_OBJECT_NULL {
            IOObjectRelease(iterator)
        }
    }

    guard let matchingDict = IOBSDNameMatching(default_port, 0, name),
        IOServiceGetMatchingServices(default_port,
                                     matchingDict as CFDictionary,
                                     &iterator) == KERN_SUCCESS,
        iterator != IO_OBJECT_NULL
    else {
        return nil
    }

    var candidate = IOIteratorNext(iterator)
    while candidate != IO_OBJECT_NULL {
        if let cftype = IORegistryEntryCreateCFProperty(candidate,
                                                        "IOBuiltin" as CFString,
                                                        kCFAllocatorDefault,
                                                        0) {
            let isBuiltIn = cftype.takeRetainedValue() as! CFBoolean
            if wantBuiltIn == CFBooleanGetValue(isBuiltIn) {
                return candidate
            }
        }

        IOObjectRelease(candidate)
        candidate = IOIteratorNext(iterator)
    }

    return nil
}

// This function is taken from the Apple sample code at:
// https://developer.apple.com/documentation/appstorereceipts/validating_receipts_on_the_device#3744656
private func copy_mac_address() -> CFData? {
    // Prefer built-in network interfaces.
    // For example, an external Ethernet adaptor can displace
    // the built-in Wi-Fi as en0.
    guard let service = io_service(named: "en0", wantBuiltIn: true)
            ?? io_service(named: "en1", wantBuiltIn: true)
            ?? io_service(named: "en0", wantBuiltIn: false)
        else { return nil }
    defer { IOObjectRelease(service) }

    if let cftype = IORegistryEntrySearchCFProperty(
        service,
        kIOServicePlane,
        "IOMACAddress" as CFString,
        kCFAllocatorDefault,
        IOOptionBits(kIORegistryIterateRecursively | kIORegistryIterateParents)) {
            return (cftype as! CFData)
    }

    return nil
}
#endif
