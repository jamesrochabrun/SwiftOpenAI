//
//  InputType.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

// MARK: - InputType

/// Text, image, or file inputs to the model, used to generate a response.
///
/// Learn more:
///
/// [Text inputs and outputs](https://platform.openai.com/docs/guides/text)
/// [Image inputs](https://platform.openai.com/docs/guides/images)
/// [File inputs](https://platform.openai.com/docs/guides/pdf-files)
/// [Conversation state](https://platform.openai.com/docs/guides/conversation-state)
/// [Function calling](https://platform.openai.com/docs/guides/function-calling)
public enum InputType: Codable {
  /// A text input to the model, equivalent to a text input with the user role.
  case string(String)

  /// A list of one or many input items to the model, containing different content types.
  case array([InputItem])

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let text = try? container.decode(String.self) {
      self = .string(text)
    } else if let array = try? container.decode([InputItem].self) {
      self = .array(array)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Input must be a string or an array of input items")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let text):
      try container.encode(text)
    case .array(let items):
      try container.encode(items)
    }
  }

}

// MARK: - InputItem

/// An input item that represents a message in a conversation
public struct InputItem: Codable {
  /// The role of the message input (user, system, assistant)
  public let role: String

  /// The content of the message
  public let content: [ContentItem]

  public init(role: String, content: [ContentItem]) {
    self.role = role
    self.content = content
  }
}

// MARK: - ContentItem

/// Content item types for messages
public enum ContentItem: Codable {
  /// Text content
  case text(TextContent)

  /// Image URL content
  case imageUrl(ImageUrlContent)

  /// File content with file ID
  case fileId(FileIdContent)

  /// File content with file data
  case fileData(FileDataContent)

  /// Audio content
  case audio(AudioContent)

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    let singleValueContainer = try decoder.singleValueContainer()

    switch type {
    case "input_text":
      self = try .text(singleValueContainer.decode(TextContent.self))

    case "input_image":
      self = try .imageUrl(singleValueContainer.decode(ImageUrlContent.self))

    case "input_file":
      if try container.decodeIfPresent(String.self, forKey: .fileId) != nil {
        self = try .fileId(singleValueContainer.decode(FileIdContent.self))
      } else {
        self = try .fileData(singleValueContainer.decode(FileDataContent.self))
      }

    case "input_audio":
      self = try .audio(singleValueContainer.decode(AudioContent.self))

    default:
      throw DecodingError.dataCorruptedError(
        forKey: .type,
        in: container,
        debugDescription: "Unknown content type: \(type)")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .text(let text):
      try container.encode(text)
    case .imageUrl(let image):
      try container.encode(image)
    case .fileId(let file):
      try container.encode(file)
    case .fileData(let file):
      try container.encode(file)
    case .audio(let audio):
      try container.encode(audio)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case fileId = "file_id"
  }
}

// MARK: - TextContent

/// Text content structure
public struct TextContent: Codable {
  /// The text content
  public let text: String

  /// The type of content, always "input_text"
  public let type = "input_text"

  public init(text: String) {
    self.text = text
  }

  enum CodingKeys: String, CodingKey {
    case text
    case type
  }
}

// MARK: - ImageUrlContent

/// Image URL content structure
public struct ImageUrlContent: Codable {
  /// The URL of the image
  public let imageUrl: String

  /// The type of content, always "input_image"
  public let type = "input_image"

  /// The detail level for the image
  public let detail: String?

  public init(imageUrl: String, detail: String? = nil) {
    self.imageUrl = imageUrl
    self.detail = detail
  }

  enum CodingKeys: String, CodingKey {
    case imageUrl = "image_url"
    case type
    case detail
  }
}

// MARK: - FileIdContent

/// File content structure with file ID
public struct FileIdContent: Codable {
  /// The ID of the file
  public let fileId: String

  /// The type of content, always "input_file"
  public let type = "input_file"

  public init(fileId: String) {
    self.fileId = fileId
  }

  enum CodingKeys: String, CodingKey {
    case fileId = "file_id"
    case type
  }
}

// MARK: - FileDataContent

/// File content structure with file data
public struct FileDataContent: Codable {
  /// The filename
  public let filename: String

  /// The base64-encoded file data
  public let fileData: String

  /// The type of content, always "input_file"
  public let type = "input_file"

  public init(filename: String, fileData: String) {
    self.filename = filename
    self.fileData = fileData
  }

  enum CodingKeys: String, CodingKey {
    case filename
    case fileData = "file_data"
    case type
  }
}

// MARK: - AudioContent

/// Audio content structure
public struct AudioContent: Codable {
  /// The audio data
  public let data: String

  /// The format of the audio
  public let format: String

  /// The type of content, always "input_audio"
  public let type = "input_audio"

  public init(data: String, format: String) {
    self.data = data
    self.format = format
  }

  enum CodingKeys: String, CodingKey {
    case data
    case format
    case type
  }
}
