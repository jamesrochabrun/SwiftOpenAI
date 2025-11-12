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
  ///   - decoder: The JSON decoder to be used for parsing API responses (default is `JSONDecoder.init()`).
  ///   - httpClient: The HTTPClient to be used for network calls. Defaults to `HTTPClientFactory.createDefault()`
  ///   - debugEnabled: If `true` service prints event on DEBUG builds, default to `false`.
  ///
  /// - Returns: A fully configured object conforming to `OpenAIService`.
  public static func service(
    apiKey: String,
    organizationID: String? = nil,
    decoder: JSONDecoder = .init(),
    httpClient: HTTPClient? = nil,
    debugEnabled: Bool = false)
    -> OpenAIService
  {
    let client = httpClient ?? HTTPClientFactory.createDefault()
    return DefaultOpenAIService(
      apiKey: apiKey,
      organizationID: organizationID,
      httpClient: client,
      decoder: decoder,
      debugEnabled: debugEnabled)
  }

  // MARK: Azure

  /// Creates and returns an instance of `OpenAIService`.
  ///
  /// - Parameters:
  ///   - azureConfiguration: The AzureOpenAIConfiguration.
  ///   - decoder: The JSON decoder to be used for parsing API responses (default is `JSONDecoder.init()`).
  ///   - httpClient: The HTTPClient to be used for network calls. Defaults to `HTTPClientFactory.createDefault()`
  ///   - debugEnabled: If `true` service prints event on DEBUG builds, default to `false`.
  ///
  /// - Returns: A fully configured object conforming to `OpenAIService`.
  public static func service(
    azureConfiguration: AzureOpenAIConfiguration,
    decoder: JSONDecoder = .init(),
    httpClient: HTTPClient? = nil,
    debugEnabled: Bool = false)
    -> OpenAIService
  {
    let client = httpClient ?? HTTPClientFactory.createDefault()
    return DefaultOpenAIAzureService(
      azureConfiguration: azureConfiguration,
      httpClient: client,
      decoder: decoder,
      debugEnabled: debugEnabled)
  }

  #if !os(Linux)

  // MARK: AIProxy

  /// Creates and returns an instance of `OpenAIService` for use with aiproxy.pro
  /// Use this service to protect your OpenAI API key before going to production.
  ///
  /// - Parameters:
  ///   - aiproxyPartialKey: The partial key provided in the 'API Keys' section of the AIProxy dashboard.
  ///                        Please see the integration guide for acquiring your key, at https://www.aiproxy.pro/docs
  ///
  ///   - aiproxyServiceURL: The service URL is displayed in the AIProxy dashboard when you submit your OpenAI key.
  ///                        This argument is required for keys that you submitted after July 22nd, 2024. If you are an
  ///                        existing customer that configured your AIProxy project before July 22nd, you may continue
  ///                        to leave this blank.
  ///
  ///   - aiproxyClientID: If your app already has client or user IDs that you want to annotate AIProxy requests
  ///                      with, you can pass a clientID here. If you do not have existing client or user IDs, leave
  ///                      the `clientID` argument out, and IDs will be generated automatically for you.
  ///   - debugEnabled: If `true` service prints event on DEBUG builds, default to `false`.
  ///
  /// - Returns: A conformer of OpenAIService that proxies all requests through api.aiproxy.pro
  public static func service(
    aiproxyPartialKey: String,
    aiproxyServiceURL: String? = nil,
    aiproxyClientID: String? = nil,
    debugEnabled: Bool = false)
    -> OpenAIService
  {
    AIProxyService(
      partialKey: aiproxyPartialKey,
      serviceURL: aiproxyServiceURL,
      clientID: aiproxyClientID,
      debugEnabled: debugEnabled)
  }
  #endif

  // MARK: Custom URL

  /// Creates and returns an instance of `OpenAIService`.
  ///
  /// Use this service if you need to provide a custom URL, for example to run local models with OpenAI endpoints compatibility using Ollama.
  /// Check [Ollama blog post](https://ollama.com/blog/openai-compatibility) for more.
  ///
  /// - Parameters:
  ///   - apiKey: The optional API key required for authentication.
  ///   - baseURL: The local host URL. defaults to  "http://localhost:11434"
  ///   - httpClient: The HTTPClient to be used for network calls. Defaults to `HTTPClientFactory.createDefault()`
  ///   - debugEnabled: If `true` service prints event on DEBUG builds, default to `false`.
  ///
  /// - Returns: A fully configured object conforming to `OpenAIService`.
  public static func service(
    apiKey: Authorization = .apiKey(""),
    baseURL: String,
    httpClient: HTTPClient? = nil,
    debugEnabled: Bool = false)
    -> OpenAIService
  {
    let client = httpClient ?? HTTPClientFactory.createDefault()
    return LocalModelService(
      apiKey: apiKey,
      baseURL: baseURL,
      httpClient: client,
      debugEnabled: debugEnabled)
  }

  // MARK: Proxy Path

  /// Creates and returns an instance of `OpenAIService`.
  ///
  /// Use this service if you need to provide a custom URL with a proxy path, for example to run Groq.
  ///
  /// - Parameters:
  ///   - apiKey: The optional API key required for authentication.
  ///   - baseURL: The local host URL.  e.g "https://api.groq.com" or "https://generativelanguage.googleapis.com"
  ///   - proxyPath: The proxy path e.g `openai`
  ///   - overrideVersion: The API version. defaults to `v1`
  ///   - extraHeaders: Additional headers needed for the request. Do not provide API key in these headers.
  ///   - httpClient: The HTTPClient to be used for network calls. Defaults to `HTTPClientFactory.createDefault()`
  ///   - debugEnabled: If `true` service prints event on DEBUG builds, default to `false`.
  ///
  /// - Returns: A fully configured object conforming to `OpenAIService`.
  public static func service(
    apiKey: String,
    overrideBaseURL: String,
    proxyPath: String? = nil,
    overrideVersion: String? = nil,
    extraHeaders: [String: String]? = nil,
    httpClient: HTTPClient? = nil,
    debugEnabled: Bool = false)
    -> OpenAIService
  {
    let client = httpClient ?? HTTPClientFactory.createDefault()
    return DefaultOpenAIService(
      apiKey: apiKey,
      baseURL: overrideBaseURL,
      proxyPath: proxyPath,
      overrideVersion: overrideVersion,
      extraHeaders: extraHeaders,
      httpClient: client,
      debugEnabled: debugEnabled)
  }
}
