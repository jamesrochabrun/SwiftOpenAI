//
//  Dalle.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// [DALL·E](https://platform.openai.com/docs/models/dall-e)
///
/// DALL·E is a AI system that can create realistic images and art from a description in natural language. DALL·E 3 currently supports the ability, given a prompt, to create a new image with a specific size. DALL·E 2 also support the ability to edit an existing image, or create variations of a user provided image.
///
/// DALL·E 3 is available through our Images API along with DALL·E 2. You can try DALL·E 3 through ChatGPT Plus.
///
///
/// | MODEL     | DESCRIPTION                                                  |
/// |-----------|--------------------------------------------------------------|
/// | dall-e-3  | DALL·E 3 New                                                 |
/// |           | The latest DALL·E model released in Nov 2023. Learn more.    |
/// | dall-e-2  | The previous DALL·E model released in Nov 2022.              |
/// |           | The 2nd iteration of DALL·E with more realistic, accurate,   |
/// |           | and 4x greater resolution images than the original model.    |
public enum Dalle {
  case dalle2(Dalle2ImageSize)
  case dalle3(Dalle3ImageSize)

  public enum Dalle2ImageSize: String {
    case small = "256x256"
    case medium = "512x512"
    case large = "1024x1024"
  }

  public enum Dalle3ImageSize: String {
    case largeSquare = "1024x1024"
    case landscape = "1792x1024"
    case portrait = "1024x1792"
  }

  var model: String {
    switch self {
    case .dalle2: Model.dalle2.value
    case .dalle3: Model.dalle3.value
    }
  }

  var size: String {
    switch self {
    case .dalle2(let dalle2ImageSize):
      dalle2ImageSize.rawValue
    case .dalle3(let dalle3ImageSize):
      dalle3ImageSize.rawValue
    }
  }
}
