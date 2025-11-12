//
//  ImageVariationParameters.swift
//
//
//  Created by James Rochabrun on 10/12/23.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - ImageVariationParameters

/// [Creates a variation of a given image.](https://platform.openai.com/docs/api-reference/images/createVariation)
public struct ImageVariationParameters: Encodable {
  #if canImport(UIKit) || canImport(AppKit)
  public init(
    image: PlatformImage,
    model: Dalle? = nil,
    numberOfImages: Int? = nil,
    responseFormat: ImageResponseFormat? = nil,
    user: String? = nil)
  {
    #if canImport(UIKit)
    let imageData = image.pngData()
    #elseif canImport(AppKit)
    let imageData = image.tiffRepresentation
    #endif

    guard let imageData else {
      fatalError("Failed to load image data from image.")
    }

    self.init(
      imageData: imageData,
      model: model,
      numberOfImages: numberOfImages,
      responseFormat: responseFormat,
      user: user)
  }
  #endif

  /// Creates parameters from raw data (for platforms without UIKit/AppKit support)
  /// - Parameters:
  ///   - imageData: Raw image data
  ///   - model: The model to use
  ///   - numberOfImages: Number of images to generate
  ///   - responseFormat: Format of the response
  ///   - user: User identifier
  public init(
    imageData: Data,
    model: Dalle? = nil,
    numberOfImages: Int? = nil,
    responseFormat: ImageResponseFormat? = nil,
    user: String? = nil)
  {
    if let model, model.model != Model.dalle2.value {
      assertionFailure(
        "Only dall-e-2 is supported at this time [https://platform.openai.com/docs/api-reference/images/createEdit]")
    }

    image = imageData
    n = numberOfImages
    self.model = model?.model
    size = model?.size
    self.responseFormat = responseFormat?.rawValue
    self.user = user
  }

  public enum ImageResponseFormat: String {
    case url
    case b64Json = "b64_json"
  }

  enum CodingKeys: String, CodingKey {
    case image
    case model
    case n
    case responseFormat = "response_format"
    case size
    case user
  }

  /// The image to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
  let image: Data
  /// The model to use for image generation. Only dall-e-2 is supported at this time. Defaults to dall-e-2
  let model: String?
  /// The number of images to generate. Must be between 1 and 10. Defaults to 1
  let n: Int?
  /// The format in which the generated images are returned. Must be one of url or b64_json. Defaults to url
  let responseFormat: String?
  /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024. Defaults to 1024x1024
  let size: String?
  /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices)
  let user: String?
}

// MARK: MultipartFormDataParameters

extension ImageVariationParameters: MultipartFormDataParameters {
  public func encode(boundary: String) -> Data {
    MultipartFormDataBuilder(boundary: boundary, entries: [
      .file(paramName: Self.CodingKeys.image.rawValue, fileName: "", fileData: image, contentType: "image/png"),
      .string(paramName: Self.CodingKeys.model.rawValue, value: model),
      .string(paramName: Self.CodingKeys.n.rawValue, value: n),
      .string(paramName: Self.CodingKeys.size.rawValue, value: size),
      .string(paramName: Self.CodingKeys.responseFormat.rawValue, value: responseFormat),
      .string(paramName: Self.CodingKeys.user.rawValue, value: user),
    ]).build()
  }
}
