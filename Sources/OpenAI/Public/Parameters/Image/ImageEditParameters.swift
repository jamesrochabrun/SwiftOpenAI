//
//  ImageEditParameters.swift
//
//
//  Created by James Rochabrun on 10/12/23.
//

import Foundation
import UIKit

/// [Creates an edited or extended image given an original image and a prompt.](https://platform.openai.com/docs/api-reference/images/createEdit)
public struct ImageEditParameters: Encodable {
   
   /// The image to edit. Must be a valid PNG file, less than 4MB, and square. If mask is not provided, image must have transparency, which will be used as the mask.
   let image: Data
   /// A text description of the desired image(s). The maximum length is 1000 characters.
   let prompt: String
   /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited. Must be a valid PNG file, less than 4MB, and have the same dimensions as image.
   let mask: Data?
   /// The number of images to generate. Must be between 1 and 10. Defaults to 1
   let n: Int?
   /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024. Defaults to 1024x1024
   let size: String?
   /// The format in which the generated images are returned. Must be one of url or b64_json. Defaults to url
   let responseFormat: String?
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
      case prompt
      case mask
      case n
      case size
      case responseFormat = "response_format"
      case user
   }
   
   init(
      image: UIImage,
      mask: UIImage? = nil,
      prompt: String,
      numberOfImages: Int? = nil,
      size: ImageSize? = nil,
      responseFormat: ImageResponseFormat? = nil,
      user: String? = nil)
   {
      if (image.pngData() == nil) {
          assertionFailure("Failed to get PNG data from image")
      }
      if let mask, mask.pngData() == nil {
         assertionFailure("Failed to get PNG data from mask")
      }
      self.image = image.pngData()!
      self.mask = mask?.pngData()
      self.prompt = prompt
      self.n = numberOfImages
      self.size = size?.rawValue
      self.responseFormat = responseFormat?.rawValue
      self.user = user
   }
}

// MARK: MultipartFormDataParameters

extension ImageEditParameters: MultipartFormDataParameters {
   
   func encode(boundary: String) -> Data {
      MultipartFormDataBuilder(boundary: boundary, entries: [
         .file(paramName: Self.CodingKeys.image.rawValue, fileName: "", fileData: image, contentType: "image/png"),
         .string(paramName: Self.CodingKeys.prompt.rawValue, value: prompt),
         .string(paramName: Self.CodingKeys.mask.rawValue, value: mask),
         .string(paramName: Self.CodingKeys.n.rawValue, value: n),
         .string(paramName: Self.CodingKeys.size.rawValue, value: size),
         .string(paramName: Self.CodingKeys.responseFormat.rawValue, value: responseFormat),
         .string(paramName: Self.CodingKeys.user.rawValue, value: user),
      ]).build()
   }
}
