//
//  MessageContent.swift
//
//
//  Created by James Rochabrun on 3/17/24.
//

import Foundation

// MARK: - AssistantMessageContent

///  The [content](https://platform.openai.com/docs/api-reference/messages/object#messages/object-content) of the message in array of text and/or images.
public enum AssistantMessageContent: Codable {
  case imageFile(ImageFile)
  case imageUrl(ImageURL)
  case text(Text)

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ContentTypeKey.self)
    let type = try container.decode(String.self, forKey: .type)

    switch type {
    case "image_file":
      let imageFile = try ImageFile(from: decoder)
      self = .imageFile(imageFile)

    case "image_url":
      let imageUrl = try ImageURL(from: decoder)
      self = .imageUrl(imageUrl)

    case "text":
      let text = try Text(from: decoder)
      self = .text(text)

    default:
      throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type for content")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .imageFile(let imageFile):
      try container.encode("image_file", forKey: .type)
      try container.encode(imageFile, forKey: .imageFile)

    case .imageUrl(let imageUrl):
      try container.encode("image_url", forKey: .type)
      try container.encode(imageUrl, forKey: .imageUrl)

    case .text(let text):
      try container.encode("text", forKey: .type)
      try container.encode(text, forKey: .text)
    }
  }

  enum CodingKeys: String, CodingKey {
    case type
    case imageFile = "image_file"
    case imageUrl = "image_url"
    case text
  }

  enum ContentTypeKey: CodingKey {
    case type
  }
}

// MARK: - ImageFile

public struct ImageFile: Codable {
  public struct ImageFileContent: Codable {
    /// The [File](https://platform.openai.com/docs/api-reference/files) ID of the image in the message content.
    public let fileID: String

    enum CodingKeys: String, CodingKey {
      case fileID = "file_id"
    }
  }

  /// Always image_file.
  public let type: String

  /// References an image [File](https://platform.openai.com/docs/api-reference/files) in the content of a message.
  public let imageFile: ImageFileContent

  enum CodingKeys: String, CodingKey {
    case imageFile = "image_file"
    case type
  }
}

// MARK: - ImageURL

public struct ImageURL: Codable {
  public struct ImageUrlContent: Codable {
    /// The [File](https://platform.openai.com/docs/api-reference/files) URL  of the image in the message content.
    public let url: String

    enum CodingKeys: String, CodingKey {
      case url
    }
  }

  /// Always image_url.
  public let type: String

  /// References an image [File](https://platform.openai.com/docs/api-reference/files) in the content of a message.
  public let imageUrl: ImageUrlContent

  enum CodingKeys: String, CodingKey {
    case imageUrl = "image_url"
    case type
  }
}

// MARK: - Text

public struct Text: Codable {
  /// Always text.
  public let type: String
  /// The text content that is part of a message.
  public let text: TextContent

  public struct TextContent: Codable {
    /// The data that makes up the text.
    public let value: String

    public let annotations: [Annotation]?
  }
}

// MARK: - Annotation

public enum Annotation: Codable {
  case fileCitation(FileCitation)
  case filePath(FilePath)

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: AnnotationTypeKey.self)
    let type = try container.decode(String.self, forKey: .type)
    switch type {
    case "file_citation":
      let fileCitationContainer = try decoder.container(keyedBy: CodingKeys.self)
      let fileCitation = try fileCitationContainer.decode(FileCitation.self, forKey: .fileCitation)
      self = .fileCitation(fileCitation)

    case "file_path":
      let filePathContainer = try decoder.container(keyedBy: CodingKeys.self)
      let filePath = try filePathContainer.decode(FilePath.self, forKey: .filePath)
      self = .filePath(filePath)

    default:
      throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type for annotation")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .fileCitation(let fileCitation):
      try container.encode("file_citation", forKey: .type)
      try container.encode(fileCitation, forKey: .fileCitation)

    case .filePath(let filePath):
      try container.encode("file_path", forKey: .type)
      try container.encode(filePath, forKey: .filePath)
    }
  }

  enum CodingKeys: String, CodingKey {
    case type
    case text
    case fileCitation = "file_citation"
    case filePath = "file_path"
    case startIndex = "start_index"
    case endIndex = "end_index"
  }

  enum AnnotationTypeKey: CodingKey {
    case type
  }
}

// MARK: - FileCitation

/// A citation within the message that points to a specific quote from a specific File associated with the assistant or the message. Generated when the assistant uses the "retrieval" tool to search files.
public struct FileCitation: Codable {
  public struct FileCitationDetails: Codable {
    /// The ID of the specific File the citation is from.
    public let fileID: String
    /// The specific quote in the file.
    public let quote: String

    enum CodingKeys: String, CodingKey {
      case fileID = "file_id"
      case quote
    }
  }

  /// Always file_citation, except when using Assistants API Beta, e.g. when using file_store search
  public let type: String?
  /// The text in the message content that needs to be replaced. Not always present with Assistants API Beta, e.g. when using file_store search
  public let text: String?
  public let fileCitation: FileCitationDetails?
  public let startIndex: Int?
  public let endIndex: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case text
    case fileCitation = "file_citation"
    case startIndex = "start_index"
    case endIndex = "end_index"
  }
}

// MARK: - FilePath

/// A URL for the file that's generated when the assistant used the code_interpreter tool to generate a file.
public struct FilePath: Codable {
  public struct FilePathDetails: Codable {
    /// The ID of the file that was generated.
    public let fileID: String

    enum CodingKeys: String, CodingKey {
      case fileID = "file_id"
    }
  }

  /// Always file_path
  public let type: String
  /// The text in the message content that needs to be replaced.
  public let text: String
  public let filePath: FilePathDetails
  public let startIndex: Int
  public let endIndex: Int

  enum CodingKeys: String, CodingKey {
    case type
    case text
    case filePath = "file_path"
    case startIndex = "start_index"
    case endIndex = "end_index"
  }
}
