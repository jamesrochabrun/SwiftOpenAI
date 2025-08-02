//
//  Tool.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

/// An array of tools the model may call while generating a response
public enum Tool: Codable {
  /// A tool that searches for relevant content from uploaded files
  case fileSearch(FileSearchTool)

  /// Defines a function in your own code the model can choose to call
  case function(FunctionTool)

  /// A tool that controls a virtual computer
  case computerUse(ComputerUseTool)

  /// This tool searches the web for relevant results to use in a response
  case webSearch(WebSearchTool)

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    let singleValueContainer = try decoder.singleValueContainer()

    switch type {
    case "file_search":
      self = try .fileSearch(singleValueContainer.decode(FileSearchTool.self))
    case "function":
      self = try .function(singleValueContainer.decode(FunctionTool.self))
    case "computer_use_preview":
      self = try .computerUse(singleValueContainer.decode(ComputerUseTool.self))
    case "web_search_preview", "web_search_preview_2025_03_11":
      self = try .webSearch(singleValueContainer.decode(WebSearchTool.self))
    default:
      throw DecodingError.dataCorruptedError(
        forKey: .type,
        in: container,
        debugDescription: "Unknown tool type: \(type)")
    }
  }

  /// Specifies the comparison operator for filters
  public enum ComparisonOperator: String, Codable {
    /// Equals
    case equals = "eq"

    /// Not equal
    case notEqual = "ne"

    /// Greater than
    case greaterThan = "gt"

    /// Greater than or equal
    case greaterThanOrEqual = "gte"

    /// Less than
    case lessThan = "lt"

    /// Less than or equal
    case lessThanOrEqual = "lte"
  }

  /// High level guidance for the amount of context window space to use for the search
  public enum SearchContextSize: String, Codable {
    /// Low context window space (fewer tokens)
    case low

    /// Medium context window space (default)
    case medium

    /// High context window space (more tokens)
    case high
  }

  /// The type of the web search tool
  public enum WebSearchType: Codable {
    /// Standard web search preview
    case webSearchPreview

    /// Updated web search preview (2025-03-11 version)
    case webSearchPreview20250311

    /// Custom search type for future compatibility
    case custom(String)

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let value = try container.decode(String.self)

      switch value {
      case "web_search_preview":
        self = .webSearchPreview
      case "web_search_preview_2025_03_11":
        self = .webSearchPreview20250311
      default:
        self = .custom(value)
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
      case .webSearchPreview:
        try container.encode("web_search_preview")
      case .webSearchPreview20250311:
        try container.encode("web_search_preview_2025_03_11")
      case .custom(let value):
        try container.encode(value)
      }
    }
  }

  /// A tool that searches for relevant content from uploaded files
  public struct FileSearchTool: Codable {
    public init(
      vectorStoreIds: [String],
      filters: FileSearchFilter? = nil,
      maxNumResults: Int? = nil,
      rankingOptions: RankingOptions? = nil)
    {
      self.vectorStoreIds = vectorStoreIds
      self.filters = filters
      self.maxNumResults = maxNumResults
      self.rankingOptions = rankingOptions
    }

    /// The type of the file search tool. Always file_search.
    public let type = "file_search"

    /// The IDs of the vector stores to search.
    public let vectorStoreIds: [String]

    /// A filter to apply based on file attributes.
    public let filters: FileSearchFilter?

    /// The maximum number of results to return. This number should be between 1 and 50 inclusive.
    public let maxNumResults: Int?

    /// Ranking options for search.
    public let rankingOptions: RankingOptions?

    enum CodingKeys: String, CodingKey {
      case type
      case vectorStoreIds = "vector_store_ids"
      case filters
      case maxNumResults = "max_num_results"
      case rankingOptions = "ranking_options"
    }
  }

  /// Filter for file search
  public enum FileSearchFilter: Codable {
    /// A filter used to compare a specified attribute key to a given value
    case comparison(ComparisonFilter)

    /// Combine multiple filters using and or or
    case compound(CompoundFilter)

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      if let type = try? container.decode(String.self, forKey: .type) {
        if type == "and" || type == "or" {
          self = try .compound(decoder.singleValueContainer().decode(CompoundFilter.self))
        } else {
          self = try .comparison(decoder.singleValueContainer().decode(ComparisonFilter.self))
        }
      } else {
        throw DecodingError.keyNotFound(
          CodingKeys.type,
          .init(
            codingPath: container.codingPath,
            debugDescription: "Type key missing for FileSearchFilter"))
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
      case .comparison(let filter):
        try container.encode(filter)
      case .compound(let filter):
        try container.encode(filter)
      }
    }

    private enum CodingKeys: String, CodingKey {
      case type
    }
  }

  /// A filter used to compare a specified attribute key to a given value
  public struct ComparisonFilter: Codable {
    public init(key: String, type: ComparisonOperator, value: FilterValue) {
      self.key = key
      self.type = type
      self.value = value
    }

    /// The key to compare against the value
    public let key: String

    /// Specifies the comparison operator
    public let type: ComparisonOperator

    /// The value to compare against the attribute key; supports string, number, or boolean types
    public let value: FilterValue

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(key, forKey: .key)
      try container.encode(type.rawValue, forKey: .type)
      try value.encode(to: encoder)
    }

    enum CodingKeys: String, CodingKey {
      case key
      case type
      case value
    }
  }

  /// Filter value type (string, number, or boolean)
  public enum FilterValue: Codable {
    case string(String)
    case number(Double)
    case boolean(Bool)

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()

      if let stringValue = try? container.decode(String.self) {
        self = .string(stringValue)
      } else if let numberValue = try? container.decode(Double.self) {
        self = .number(numberValue)
      } else if let boolValue = try? container.decode(Bool.self) {
        self = .boolean(boolValue)
      } else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Expected string, number, or boolean for filter value")
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
      case .string(let value):
        try container.encode(value)
      case .number(let value):
        try container.encode(value)
      case .boolean(let value):
        try container.encode(value)
      }
    }
  }

  /// Combine multiple filters using and or or
  public struct CompoundFilter: Codable {
    /// Array of filters to combine. Items can be ComparisonFilter or CompoundFilter.
    public let filters: [FileSearchFilter]

    /// Type of operation: and or or
    public let type: String

    public init(filters: [FileSearchFilter], type: String) {
      self.filters = filters
      self.type = type
    }
  }

  /// Ranking options for search
  public struct RankingOptions: Codable {
    /// The ranker to use for the file search. Defaults to auto
    public let ranker: String?

    /// The score threshold for the file search, a number between 0 and 1.
    /// Numbers closer to 1 will attempt to return only the most relevant results,
    /// but may return fewer results. Defaults to 0
    public let scoreThreshold: Double?

    public init(ranker: String? = nil, scoreThreshold: Double? = nil) {
      self.ranker = ranker
      self.scoreThreshold = scoreThreshold
    }

    enum CodingKeys: String, CodingKey {
      case ranker
      case scoreThreshold = "score_threshold"
    }
  }

  /// Defines a function in your own code the model can choose to call
  public struct FunctionTool: Codable {
    public init(
      name: String,
      parameters: JSONSchema,
      strict: Bool? = nil,
      description: String? = nil)
    {
      self.name = name
      self.parameters = parameters
      self.strict = strict
      self.description = description
    }

    /// The name of the function to call
    public let name: String

    /// A JSON schema object describing the parameters of the function
    public let parameters: JSONSchema

    /// Whether to enforce strict parameter validation. Default true
    public let strict: Bool?

    /// The type of the function tool. Always function
    public let type = "function"

    /// A description of the function. Used by the model to determine whether or not to call the function
    public let description: String?

    enum CodingKeys: String, CodingKey {
      case name
      case parameters
      case strict
      case type
      case description
    }
  }

  /// A tool that controls a virtual computer
  public struct ComputerUseTool: Codable {
    public init(
      displayHeight: Int,
      displayWidth: Int,
      environment: String)
    {
      self.displayHeight = displayHeight
      self.displayWidth = displayWidth
      self.environment = environment
    }

    /// The height of the computer display
    public let displayHeight: Int

    /// The width of the computer display
    public let displayWidth: Int

    /// The type of computer environment to control
    public let environment: String

    /// The type of the computer use tool. Always computer_use_preview
    public let type = "computer_use_preview"

    enum CodingKeys: String, CodingKey {
      case displayHeight = "display_height"
      case displayWidth = "display_width"
      case environment
      case type
    }
  }

  /// This tool searches the web for relevant results to use in a response
  public struct WebSearchTool: Codable {
    public init(
      type: WebSearchType,
      searchContextSize: SearchContextSize? = nil,
      userLocation: UserLocation? = nil)
    {
      self.type = type
      self.searchContextSize = searchContextSize
      self.userLocation = userLocation
    }

    /// The type of the web search tool
    public let type: WebSearchType

    /// High level guidance for the amount of context window space to use for the search
    public let searchContextSize: SearchContextSize?

    /// Approximate location parameters for the search
    public let userLocation: UserLocation?

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      // Special handling for type
      switch type {
      case .webSearchPreview:
        try container.encode("web_search_preview", forKey: .type)
      case .webSearchPreview20250311:
        try container.encode("web_search_preview_2025_03_11", forKey: .type)
      case .custom(let value):
        try container.encode(value, forKey: .type)
      }

      try container.encodeIfPresent(searchContextSize, forKey: .searchContextSize)
      try container.encodeIfPresent(userLocation, forKey: .userLocation)
    }

    enum CodingKeys: String, CodingKey {
      case type
      case searchContextSize = "search_context_size"
      case userLocation = "user_location"
    }
  }

  /// Approximate location parameters for the search
  public struct UserLocation: Codable {
    public init(
      city: String? = nil,
      country: String? = nil,
      region: String? = nil,
      timezone: String? = nil)
    {
      self.city = city
      self.country = country
      self.region = region
      self.timezone = timezone
    }

    /// Custom decoder implementation to handle the constant "type" property
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      // We can optionally verify the type value matches what we expect
      let decodedType = try container.decodeIfPresent(String.self, forKey: .type)
      if let decodedType, decodedType != "approximate" {
        // You can choose to throw an error here or just log a warning
        print("Warning: Expected UserLocation type to be 'approximate', but got '\(decodedType)'")
      }

      // Decode the optional properties
      city = try container.decodeIfPresent(String.self, forKey: .city)
      country = try container.decodeIfPresent(String.self, forKey: .country)
      region = try container.decodeIfPresent(String.self, forKey: .region)
      timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
    }

    /// The type of location approximation. Always approximate
    public let type = "approximate"

    /// Free text input for the city of the user, e.g. San Francisco
    public let city: String?

    /// The two-letter ISO country code of the user, e.g. US
    public let country: String?

    /// Free text input for the region of the user, e.g. California
    public let region: String?

    /// The IANA timezone of the user, e.g. America/Los_Angeles
    public let timezone: String?

    enum CodingKeys: String, CodingKey {
      case type
      case city
      case country
      case region
      case timezone
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .fileSearch(let tool):
      try container.encode(tool)
    case .function(let tool):
      try container.encode(tool)
    case .computerUse(let tool):
      try container.encode(tool)
    case .webSearch(let tool):
      try container.encode(tool)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case type
  }
}
