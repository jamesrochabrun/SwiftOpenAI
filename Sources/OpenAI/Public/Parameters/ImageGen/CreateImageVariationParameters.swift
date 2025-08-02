//
//  CreateImageVariationParameters.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 4/24/25.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - CreateImageVariationParameters

/// Creates a variation of a given image.
/// This endpoint only supports `dall-e-2`.
public struct CreateImageVariationParameters: Encodable {
  #if canImport(UIKit) || canImport(AppKit)
  /// Creates parameters for generating variations of an image
  /// - Parameters:
  ///   - image: The image to use as the basis for variations
  ///   - numberOfImages: Number of variations to generate (1-10)
  ///   - responseFormat: Format of the response
  ///   - size: Size of the generated images
  ///   - user: User identifier
  public init(
    image: PlatformImage,
    numberOfImages: Int? = nil,
    responseFormat: ImageResponseFormat? = nil,
    size: Size? = nil,
    user: String? = nil)
  {
    #if canImport(UIKit)
    let imageData = image.pngData()
    #elseif canImport(AppKit)
    let imageData = image.tiffRepresentation
    #endif

    guard let imageData else {
      fatalError("Failed to get image data")
    }

    self.init(
      imageData: imageData,
      numberOfImages: numberOfImages,
      responseFormat: responseFormat,
      size: size,
      user: user)
  }
  #endif

  /// Creates parameters from raw image data
  /// - Parameters:
  ///   - imageData: Raw image data
  ///   - numberOfImages: Number of variations to generate (1-10)
  ///   - responseFormat: Format of the response
  ///   - size: Size of the generated images
  ///   - user: User identifier
  public init(
    imageData: Data,
    numberOfImages: Int? = nil,
    responseFormat: ImageResponseFormat? = nil,
    size: Size? = nil,
    user: String? = nil)
  {
    image = imageData
    model = ModelType.dallE2.rawValue
    n = numberOfImages
    self.responseFormat = responseFormat?.rawValue
    self.size = size?.rawValue
    self.user = user
  }

  public enum ModelType: String {
    case dallE2 = "dall-e-2"
  }

  public enum Size: String {
    case small = "256x256"
    case medium = "512x512"
    case large = "1024x1024"
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

  /// The image to use as the basis for the variation(s).
  /// Must be a valid PNG file, less than 4MB, and square.
  let image: Data

  /// The model to use for image generation. Only `dall-e-2` is supported at this time.
  /// Defaults to `dall-e-2`.
  let model: String?

  /// The number of images to generate. Must be between 1 and 10.
  /// Defaults to 1.
  let n: Int?

  /// The format in which the generated images are returned.
  /// Must be one of `url` or `b64_json`.
  /// URLs are only valid for 60 minutes after the image has been generated.
  /// Defaults to `url`.
  let responseFormat: String?

  /// The size of the generated images.
  /// Must be one of `256x256`, `512x512`, or `1024x1024`.
  /// Defaults to `1024x1024`.
  let size: String?

  /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
  let user: String?
}

// MARK: MultipartFormDataParameters

extension CreateImageVariationParameters: MultipartFormDataParameters {
  public func encode(boundary: String) -> Data {
    var entries: [MultipartFormDataEntry] = []

    // Add image file
    entries.append(.file(
      paramName: CodingKeys.image.rawValue,
      fileName: "image.png",
      fileData: image,
      contentType: "image/png"))

    // Add remaining parameters if they have values
    if let model {
      entries.append(.string(paramName: CodingKeys.model.rawValue, value: model))
    }

    if let n {
      entries.append(.string(paramName: CodingKeys.n.rawValue, value: n))
    }

    if let responseFormat {
      entries.append(.string(paramName: CodingKeys.responseFormat.rawValue, value: responseFormat))
    }

    if let size {
      entries.append(.string(paramName: CodingKeys.size.rawValue, value: size))
    }

    if let user {
      entries.append(.string(paramName: CodingKeys.user.rawValue, value: user))
    }

    return MultipartFormDataBuilder(boundary: boundary, entries: entries).build()
  }
}
