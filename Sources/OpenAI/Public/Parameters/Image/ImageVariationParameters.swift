//
//  ImageVariationParameters.swift
//
//
//  Created by James Rochabrun on 10/12/23.
//

import Foundation
import UIKit

/// [Creates a variation of a given image.](https://platform.openai.com/docs/api-reference/images/createVariation)
public struct ImageVariationParameters: Encodable {
   
   /// The image to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
   let image: Data
   /// The number of images to generate. Must be between 1 and 10. Defaults to 1
   let n: Int?
   /// The format in which the generated images are returned. Must be one of url or b64_json. Defaults to url
   let responseFormat: String?
   /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024. Defaults to 1024x1024
   let size: String?
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices)
   let user: String?
   
   enum ImageSize: String {
      case small = "256x256"
      case medium = "512x512"
      case large = "1024x1024"
   }
   
   enum ImageResponseFormat: String {
      case url = "url"
      case b64Json = "b64_json"
   }
   
   enum CodingKeys: String, CodingKey {
      case image
      case n
      case responseFormat = "response_format"
      case size
      case user
   }
   
   init(
      image: UIImage,
      numberOfImages: Int? = nil,
      size: ImageSize? = nil,
      responseFormat: ImageResponseFormat? = nil,
      user: String? = nil)
   {
      self.image = image.pngData()!
      self.n = numberOfImages
      self.size = size?.rawValue
      self.responseFormat = responseFormat?.rawValue
      self.user = user
   }
}

// MARK: MultipartFormDataParameters

extension ImageVariationParameters: MultipartFormDataParameters {
   
   public func encode(boundary: String) -> Data {
      MultipartFormDataBuilder(boundary: boundary, entries: [
         .file(paramName: Self.CodingKeys.image.rawValue, fileName: "", fileData: image, contentType: "image/png"),
         .string(paramName: Self.CodingKeys.n.rawValue, value: n),
         .string(paramName: Self.CodingKeys.size.rawValue, value: size),
         .string(paramName: Self.CodingKeys.responseFormat.rawValue, value: responseFormat),
         .string(paramName: Self.CodingKeys.user.rawValue, value: user),
      ]).build()
   }
}
