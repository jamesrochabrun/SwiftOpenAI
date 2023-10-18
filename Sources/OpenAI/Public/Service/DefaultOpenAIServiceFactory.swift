//
//  DefaultOpenAIServiceFactory.swift.swift
//
//
//  Created by James Rochabrun on 10/18/23.
//

import Foundation

/// `DefaultOpenAIServiceFactory` is a factory class for creating instances of `OpenAIService`.
///
/// This class provides a static method for creating a service object configured with necessary dependencies like API key, organization ID, URL session configuration, and JSON decoder.
///
/// - Note: While consumers should interact with the `OpenAIService` protocol, this class provides the default implementation.
public class DefaultOpenAIServiceFactory {
   
   /// Creates and returns an instance of `OpenAIService`.
   ///
   /// - Parameters:
   ///   - apiKey: The API key required for authentication.
   ///   - organizationID: The optional organization ID for multi-tenancy (default is `nil`).
   ///   - configuration: The URL session configuration to be used for network calls (default is `.default`).
   ///   - decoder: The JSON decoder to be used for parsing API responses (default is `JSONDecoder.init()`).
   ///
   /// - Returns: A fully configured object conforming to `OpenAIService`.
   public static func service(
      apiKey: String,
      organizationID: String? = nil,
      configuration: URLSessionConfiguration = .default,
      decoder: JSONDecoder = .init())
      -> some OpenAIService
   {
      DefaultOpenAIService(
         apiKey: apiKey,
         organizationID: organizationID,
         configuration: configuration,
         decoder: decoder)
   }
}
