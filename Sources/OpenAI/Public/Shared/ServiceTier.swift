//
//  ServiceTier.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 9/29/26.
//

import Foundation

/// Specifies the processing type used for serving a request.
///
/// Pass the raw value to parameters that take a service tier string, e.g.
/// `ModelResponseParameter(input: ..., model: .gpt6Astra, serviceTier: ServiceTier.ultrafast.rawValue)`.
public enum ServiceTier: String, Codable {
  /// The request will be processed with the service tier configured in the Project settings.
  /// Unless otherwise configured, the Project will use 'default'.
  case auto
  /// The request will be processed with the standard pricing and performance for the selected model.
  case `default`
  /// Lower cost, higher latency processing. Requests may share resources with other flex requests.
  case flex
  /// Faster processing at a higher price.
  case priority
  /// The fastest service tier, offering up to 6x faster token generation, at a premium price.
  /// Available in the Responses API for `Model.gpt6Astra` (broadly available) and `Model.gpt56Sol` (preview).
  /// Supports US data residency and global processing only.
  /// [Ultrafast mode](https://developers.openai.com/api/docs/guides/ultrafast-mode)
  case ultrafast
}
