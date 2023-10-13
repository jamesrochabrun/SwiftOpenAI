//
//  ImageCreateParameters.swift
//  
//
//  Created by James Rochabrun on 10/12/23.
//

import Foundation

/// [Creates an image given a prompt.](https://platform.openai.com/docs/api-reference/images/create)
struct ImageCreateParameters: Encodable {
   
   /// A text description of the desired image(s). The maximum length is 1000 characters.
   let prompt: String
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
       case prompt
       case n
       case size
       case responseFormat = "response_format"
       case user
   }
   
   init(
      prompt: String,
      numberOfImages: Int? = nil,
      size: ImageSize? = nil,
      responseFormat: ImageResponseFormat? = nil,
      user: String? = nil)
   {
      self.prompt = prompt
      self.n = numberOfImages
      self.size = size?.rawValue
      self.responseFormat = responseFormat?.rawValue
      self.user = user
   }
}
