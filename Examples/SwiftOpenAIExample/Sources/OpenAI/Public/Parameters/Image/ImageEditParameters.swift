//
//  ImageEditParameters.swift
//
//
//  Created by James Rochabrun on 10/12/23.
//

import Foundation
#if canImport(UIKit)
import UIKit

public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit

public typealias PlatformImage = NSImage
#endif

// MARK: - ImageEditParameters

/// [Creates an edited or extended image given an original image and a prompt.](https://platform.openai.com/docs/api-reference/images/createEdit)
public struct ImageEditParameters: Encodable {
  #if canImport(UIKit) || canImport(AppKit)
  public init(
    image: PlatformImage,
    model: Dalle? = nil,
    mask: PlatformImage? = nil,
    prompt: String,
    numberOfImages: Int? = nil,
    responseFormat: ImageResponseFormat? = nil,
    user: String? = nil)
  {
    #if canImport(UIKit)
    let imageData = image.pngData()
    let maskData = mask?.pngData()
    #elseif canImport(AppKit)
    let imageData = image.tiffRepresentation
    let maskData = mask?.tiffRepresentation
    #endif

    guard let imageData else {
      fatalError("Failed to get image data")
    }

    if mask != nil, maskData == nil {
      fatalError("Failed to get mask data")
    }

    self.init(
      imageData: imageData,
      maskData: maskData,
      model: model,
      prompt: prompt,
      numberOfImages: numberOfImages,
      responseFormat: responseFormat,
      user: user)
  }
  #endif

  /// Creates parameters from raw data (for platforms without UIKit/AppKit support)
  /// - Parameters:
  ///   - imageData: Raw image data
  ///   - maskData: Optional raw mask data
  ///   - model: The model to use
  ///   - prompt: A text description of the desired image
  ///   - numberOfImages: Number of images to generate
  ///   - responseFormat: Format of the response
  ///   - user: User identifier
  public init(
    imageData: Data,
    maskData: Data? = nil,
    model: Dalle? = nil,
    prompt: String,
    numberOfImages: Int? = nil,
    responseFormat: ImageResponseFormat? = nil,
    user: String? = nil)
  {
    image = imageData
    self.model = model?.model
    mask = maskData
    self.prompt = prompt
    n = numberOfImages
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
    case prompt
    case mask
    case model
    case n
    case size
    case responseFormat = "response_format"
    case user
  }

  /// The image to edit. Must be a valid PNG file, less than 4MB, and square. If mask is not provided, image must have transparency, which will be used as the mask.
  let image: Data
  /// A text description of the desired image(s). The maximum length is 1000 characters.
  let prompt: String
  /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited. Must be a valid PNG file, less than 4MB, and have the same dimensions as image.
  let mask: Data?
  /// The model to use for image generation. Only dall-e-2 is supported at this time. Defaults to dall-e-2
  let model: String?
  /// The number of images to generate. Must be between 1 and 10. Defaults to 1
  let n: Int?
  /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024. Defaults to 1024x1024
  let size: String?
  /// The format in which the generated images are returned. Must be one of url or b64_json. Defaults to url
  let responseFormat: String?
  /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices)
  let user: String?
}

// MARK: MultipartFormDataParameters

extension ImageEditParameters: MultipartFormDataParameters {
  public func encode(boundary: String) -> Data {
    MultipartFormDataBuilder(boundary: boundary, entries: [
      .file(paramName: Self.CodingKeys.image.rawValue, fileName: "", fileData: image, contentType: "image/png"),
      .string(paramName: Self.CodingKeys.prompt.rawValue, value: prompt),
      .string(paramName: Self.CodingKeys.mask.rawValue, value: mask),
      .string(paramName: Self.CodingKeys.model.rawValue, value: model),
      .string(paramName: Self.CodingKeys.n.rawValue, value: n),
      .string(paramName: Self.CodingKeys.size.rawValue, value: size),
      .string(paramName: Self.CodingKeys.responseFormat.rawValue, value: responseFormat),
      .string(paramName: Self.CodingKeys.user.rawValue, value: user),
    ]).build()
  }
}
