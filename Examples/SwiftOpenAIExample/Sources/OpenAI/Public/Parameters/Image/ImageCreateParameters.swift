//
//  ImageCreateParameters.swift
//
//
//  Created by James Rochabrun on 10/12/23.
//

import Foundation

/// [Creates an image given a prompt.](https://platform.openai.com/docs/api-reference/images/create)
public struct ImageCreateParameters: Encodable {
  public init(
    prompt: String,
    model: Dalle,
    numberOfImages: Int = 1,
    quality: String? = nil,
    responseFormat: ImageResponseFormat? = nil,
    style: String? = nil,
    user: String? = nil)
  {
    self.prompt = prompt
    self.model = model.model
    n = numberOfImages
    self.quality = quality
    self.responseFormat = responseFormat?.rawValue
    size = model.size
    self.style = style
    self.user = user
  }

  public enum ImageSize: String {
    case small = "256x256"
    case medium = "512x512"
    case large = "1024x1024"
  }

  public enum ImageResponseFormat: String {
    case url
    case b64Json = "b64_json"
  }

  enum CodingKeys: String, CodingKey {
    case prompt
    case model
    case n
    case quality
    case responseFormat = "response_format"
    case size
    case style
    case user
  }

  /// A text description of the desired image(s). The maximum length is 1000 characters for dall-e-2 and 4000 characters for dall-e-3.
  let prompt: String
  /// The model to use for image generation. Defaults to dall-e-2
  let model: String?
  /// The number of images to generate. Must be between 1 and 10. For dall-e-3, only n=1 is supported.
  let n: Int?
  /// The quality of the image that will be generated. hd creates images with finer details and greater consistency across the image. This param is only supported for dall-e-3. Defaults to standard
  let quality: String?
  /// The format in which the generated images are returned. Must be one of url or b64_json. Defaults to url
  let responseFormat: String?
  /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024 for dall-e-2. Must be one of 1024x1024, 1792x1024, or 1024x1792 for dall-e-3 models. Defaults to 1024x1024
  let size: String?
  /// The style of the generated images. Must be one of vivid or natural. Vivid causes the model to lean towards generating hyper-real and dramatic images. Natural causes the model to produce more natural, less hyper-real looking images. This param is only supported for dall-e-3. Defaults to vivid
  let style: String?
  /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices)
  let user: String?
}
