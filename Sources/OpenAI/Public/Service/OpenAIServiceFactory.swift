//
//  OpenAIServiceFactory.swift
//
//
//  Created by James Rochabrun on 10/18/23.
//

import Foundation

public class OpenAIServiceFactory {
   
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
   
   /// Creates and returns an instance of `OpenAIService`.
   ///
   /// - Parameters:
   ///   - azureConfiguration: The AzureOpenAIConfiguration.
   ///   - urlSessionConfiguration: The URL session configuration to be used for network calls (default is `.default`).
   ///   - decoder: The JSON decoder to be used for parsing API responses (default is `JSONDecoder.init()`).
   ///
   /// - Returns: A fully configured object conforming to `OpenAIService`.
   public static func service(
      azureConfiguration: AzureOpenAIConfiguration,
      urlSessionConfiguration: URLSessionConfiguration = .default,
      decoder: JSONDecoder = .init())
   -> some OpenAIService
   {
      DefaultOpenAIAzureService(
         azureConfiguration: azureConfiguration,
         urlSessionConfiguration: urlSessionConfiguration,
         decoder: decoder)
   }

   /// Creates and returns an instance of `OpenAIService` for use with aiproxy.pro
   /// Use this service to protect your OpenAI API key before going to production.
   ///
   /// Please do not let a `deviceCheckBypass` slip into an archived version of your app that you distribute (including through TestFlight).
   /// Doing so would allow an attacker to use the bypass themselves.
   /// The bypass is intended to only be used by developers during development in the iOS simulator (where DeviceCheck does not exist).
   ///
   /// Please retain these conditional checks if you copy this example into your own code.
   /// Your integration code should look like this:
   ///
   ///     #if DEBUG && targetEnvironment(simulator)
   ///         OpenAIServiceFactory.service(
   ///             aiproxyPartialKey: "hardcode-partial-key-here",
   ///             aiproxyDeviceCheckBypass: "hardcode-device-check-bypass-here"
   ///         )
   ///     #else
   ///         OpenAIServiceFactory.service(aiproxyPartialKey: "hardcode-partial-key-here")
   ///     #endif
   ///
   /// - Parameters:
   ///   - aiproxyPartialKey: The partial key provided in the 'API Keys' section of the AI Proxy dashboard.
   ///                        Please see the integration guide for acquiring your key, at https://www.aiproxy.pro/docs
   ///   - aiproxyDeviceCheckBypass: The bypass token that is provided in the 'API Keys' section of the AI Proxy dashboard.
   ///                               Please see the integration guide for acquiring your key, at https://www.aiproxy.pro/docs
   ///   - configuration: The URL session configuration to be used for network calls (default is `.default`).
   ///   - decoder: The JSON decoder to be used for parsing API responses (default is `JSONDecoder.init()`).
   ///
   /// - Returns: A conformer of OpenAIService that proxies all requests through api.aiproxy.pro
   public static func service(
      aiproxyPartialKey: String,
      aiproxyDeviceCheckBypass: String? = nil,
      configuration: URLSessionConfiguration = .default,
      decoder: JSONDecoder = .init())
   -> some OpenAIService
   {
      var service = AIProxyService(partialKey: aiproxyPartialKey)
      #if DEBUG && targetEnvironment(simulator)
      service.deviceCheckBypass = aiproxyDeviceCheckBypass
      #endif
      return service
   }
}
