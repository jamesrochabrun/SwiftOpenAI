//
//  CreateImageEditParameters.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 4/24/25.
//
import Foundation

// MARK: - CreateImageEditParameters

/// Creates an edited or extended image given one or more source images and a prompt.
/// This endpoint only supports `gpt-image-1` and `dall-e-2`.
public struct CreateImageEditParameters: Encodable {
  #if canImport(UIKit) || canImport(AppKit)
  /// Creates parameters for editing a single image (compatible with both dall-e-2 and gpt-image-1)
  /// - Parameters:
  ///   - image: The image to edit
  ///   - prompt: A text description of the desired image
  ///   - mask: Optional mask indicating areas to edit
  ///   - model: The model to use
  ///   - numberOfImages: Number of images to generate
  ///   - quality: Quality of the generated images
  ///   - responseFormat: Format of the response
  ///   - size: Size of the generated images
  ///   - user: User identifier
  public init(
    image: PlatformImage,
    prompt: String,
    mask: PlatformImage? = nil,
    model: ModelType = .dallE2,
    numberOfImages: Int? = nil,
    quality: Quality? = nil,
    responseFormat: ImageResponseFormat? = nil,
    size: String? = nil,
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

    self.init(
      imageData: [imageData],
      prompt: prompt,
      maskData: maskData,
      model: model,
      numberOfImages: numberOfImages,
      quality: quality,
      responseFormat: responseFormat,
      size: size,
      user: user)
  }

  /// Creates parameters for editing multiple images (for gpt-image-1 only)
  /// - Parameters:
  ///   - images: Array of images to edit
  ///   - prompt: A text description of the desired image
  ///   - mask: Optional mask indicating areas to edit
  ///   - numberOfImages: Number of images to generate
  ///   - quality: Quality of the generated images
  ///   - size: Size of the generated images
  ///   - user: User identifier
  public init(
    images: [PlatformImage],
    prompt: String,
    mask: PlatformImage? = nil,
    numberOfImages: Int? = nil,
    quality: Quality? = nil,
    size: String? = nil,
    user: String? = nil)
  {
    var imageDataArray: [Data] = []

    for image in images {
      #if canImport(UIKit)
      if let data = image.pngData() {
        imageDataArray.append(data)
      }
      #elseif canImport(AppKit)
      if let data = image.tiffRepresentation {
        imageDataArray.append(data)
      }
      #endif
    }

    if imageDataArray.isEmpty {
      assertionFailure("Failed to get image data for any of the provided images")
    }

    #if canImport(UIKit)
    let maskData = mask?.pngData()
    #elseif canImport(AppKit)
    let maskData = mask?.tiffRepresentation
    #endif

    self.init(
      imageData: imageDataArray,
      prompt: prompt,
      maskData: maskData,
      model: .gptImage1,
      numberOfImages: numberOfImages,
      quality: quality,
      responseFormat: nil, // Not needed for gpt-image-1
      size: size,
      user: user)
  }
  #endif

  /// Creates parameters from raw data (for advanced use cases)
  /// - Parameters:
  ///   - imageData: Raw image data (one or more images)
  ///   - prompt: A text description of the desired image
  ///   - maskData: Optional mask data
  ///   - model: The model to use
  ///   - numberOfImages: Number of images to generate
  ///   - quality: Quality of the generated images
  ///   - responseFormat: Format of the response
  ///   - size: Size of the generated images
  ///   - user: User identifier
  public init(
    imageData: [Data],
    prompt: String,
    maskData: Data? = nil,
    model: ModelType = .dallE2,
    numberOfImages: Int? = nil,
    quality: Quality? = nil,
    responseFormat: ImageResponseFormat? = nil,
    size: String? = nil,
    user: String? = nil)
  {
    image = imageData
    self.prompt = prompt
    mask = maskData
    self.model = model.rawValue
    n = numberOfImages
    self.quality = quality?.rawValue
    self.responseFormat = responseFormat?.rawValue
    self.size = size
    self.user = user
  }

  public enum ModelType: String {
    case dallE2 = "dall-e-2"
    case gptImage1 = "gpt-image-1"
  }

  public enum Quality: String {
    case auto
    case high
    case medium
    case low
    case standard
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
    case quality
    case responseFormat = "response_format"
    case size
    case user
  }

  /// The image(s) to edit.
  /// For `gpt-image-1`, each image should be a `png`, `webp`, or `jpg` file less than 25MB.
  /// For `dall-e-2`, you can only provide one image, and it should be a square `png` file less than 4MB.
  let image: [Data]

  /// A text description of the desired image(s).
  /// The maximum length is 1000 characters for `dall-e-2`, and 32000 characters for `gpt-image-1`.
  let prompt: String

  /// An additional image whose fully transparent areas indicate where `image` should be edited.
  /// If there are multiple images provided, the mask will be applied on the first image.
  /// Must be a valid PNG file, less than 4MB, and have the same dimensions as `image`.
  let mask: Data?

  /// The model to use for image generation. Only `dall-e-2` and `gpt-image-1` are supported.
  /// Defaults to `dall-e-2` unless a parameter specific to `gpt-image-1` is used.
  let model: String?

  /// The number of images to generate. Must be between 1 and 10.
  /// Defaults to 1.
  let n: Int?

  /// The quality of the image that will be generated.
  /// `high`, `medium` and `low` are only supported for `gpt-image-1`.
  /// `dall-e-2` only supports `standard` quality.
  /// Defaults to `auto`.
  let quality: String?

  /// The format in which the generated images are returned.
  /// Must be one of `url` or `b64_json`.
  /// URLs are only valid for 60 minutes after the image has been generated.
  /// This parameter is only supported for `dall-e-2`, as `gpt-image-1` will always return base64-encoded images.
  let responseFormat: String?

  /// The size of the generated images.
  /// Must be one of `1024x1024`, `1536x1024` (landscape), `1024x1536` (portrait), or `auto` (default value) for `gpt-image-1`,
  /// and one of `256x256`, `512x512`, or `1024x1024` for `dall-e-2`.
  let size: String?

  /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
  let user: String?
}

// MARK: MultipartFormDataParameters

extension CreateImageEditParameters: MultipartFormDataParameters {
  public func encode(boundary: String) -> Data {
    var entries: [MultipartFormDataEntry] = []

    // Add images (possibly multiple for gpt-image-1)
    for (index, imageData) in image.enumerated() {
      entries.append(.file(
        paramName: "\(CodingKeys.image.rawValue)[]",
        fileName: "image\(index).png",
        fileData: imageData,
        contentType: "image/png"))
    }

    // Add prompt
    entries.append(.string(paramName: CodingKeys.prompt.rawValue, value: prompt))

    // Add mask if provided
    if let mask {
      entries.append(.file(
        paramName: CodingKeys.mask.rawValue,
        fileName: "mask.png",
        fileData: mask,
        contentType: "image/png"))
    }

    // Add remaining parameters if they have values
    if let model {
      entries.append(.string(paramName: CodingKeys.model.rawValue, value: model))
    }

    if let n {
      entries.append(.string(paramName: CodingKeys.n.rawValue, value: n))
    }

    if let quality {
      entries.append(.string(paramName: CodingKeys.quality.rawValue, value: quality))
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
