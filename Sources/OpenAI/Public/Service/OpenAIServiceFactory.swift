//
//  OpenAIServiceFactory.swift
//
//
//  Created by James Rochabrun on 10/18/23.
//

import Foundation

public class OpenAIServiceFactory {
   
   // MARK: OpenAI
   
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
   
   // MARK: Azure

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
   
   // MARK: AIProxy

   /// Creates and returns an instance of `OpenAIService` for use with aiproxy.pro
   /// Use this service to protect your OpenAI API key before going to production.
   ///
   /// - Parameters:
   ///   - aiproxyPartialKey: The partial key provided in the 'API Keys' section of the AIProxy dashboard.
   ///                        Please see the integration guide for acquiring your key, at https://www.aiproxy.pro/docs
   ///   - aiproxyClientID: If your app already has client or user IDs that you want to annotate AIProxy requests
   ///                      with, you can pass a clientID here. If you do not have existing client or user IDs, leave
   ///                      the `clientID` argument out, and IDs will be generated automatically for you.
   ///
   /// - Returns: A conformer of OpenAIService that proxies all requests through api.aiproxy.pro
   public static func service(
      aiproxyPartialKey: String,
      aiproxyClientID: String? = nil)
   -> some OpenAIService
   {
      AIProxyService(
        partialKey: aiproxyPartialKey,
        clientID: aiproxyClientID
      )
   }
   
   // MARK: Custom URL

   /// Creates and returns an instance of `OpenAIService`.
   ///
   /// Use this service if you need to provide a custom URL, for example to run local models with OpenAI endpoints compatibility using Ollama.
   /// Check [Ollama blog post](https://ollama.com/blog/openai-compatibility) for more.
   ///
   /// - Parameters:
   ///   - apiKey: The optional API key required for authentication.
   ///   - baseURL: The local host URL. defaults to  "http://localhost:11434"
   ///
   /// - Returns: A fully configured object conforming to `OpenAIService`.
   public static func service(
      apiKey: Authorization = .apiKey(""),
      baseURL: String)
      -> some OpenAIService
   {
      LocalModelService(
         apiKey: apiKey,
         baseURL: baseURL)
   }
}
