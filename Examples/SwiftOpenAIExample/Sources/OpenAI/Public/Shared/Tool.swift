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

  /// A tool that runs Python code to help generate a response to a prompt
  case codeInterpreter(CodeInterpreterTool)

  /// A tool that generates images using a model like gpt-image-1
  case imageGeneration(ImageGenerationTool)

  /// A tool that allows the model to execute shell commands in a local environment
  case localShell(LocalShellTool)

  /// A tool that controls a virtual computer
  case computerUse(ComputerUseTool)

  /// This tool searches the web for relevant results to use in a response
  case webSearch(WebSearchTool)

  /// Give the model access to additional tools via remote Model Context Protocol (MCP) servers
  case mcp(MCPTool)

  /// A custom tool that returns plain text instead of JSON
  case custom(CustomTool)

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    let singleValueContainer = try decoder.singleValueContainer()

    switch type {
    case "file_search":
      self = try .fileSearch(singleValueContainer.decode(FileSearchTool.self))
    case "function":
      self = try .function(singleValueContainer.decode(FunctionTool.self))
    case "code_interpreter":
      self = try .codeInterpreter(singleValueContainer.decode(CodeInterpreterTool.self))
    case "image_generation":
      self = try .imageGeneration(singleValueContainer.decode(ImageGenerationTool.self))
    case "local_shell":
      self = try .localShell(singleValueContainer.decode(LocalShellTool.self))
    case "computer_use_preview":
      self = try .computerUse(singleValueContainer.decode(ComputerUseTool.self))
    case "web_search", "web_search_2025_08_26", "web_search_preview", "web_search_preview_2025_03_11":
      self = try .webSearch(singleValueContainer.decode(WebSearchTool.self))
    case "mcp":
      self = try .mcp(singleValueContainer.decode(MCPTool.self))
    case "custom":
      self = try .custom(singleValueContainer.decode(CustomTool.self))
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
    /// Standard web search
    case webSearch

    /// Updated web search (2025-08-26 version)
    case webSearch20250826

    /// Preview web search
    case webSearchPreview

    /// Preview web search (2025-03-11 version)
    case webSearchPreview20250311

    /// Custom search type for future compatibility
    case custom(String)

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let value = try container.decode(String.self)

      switch value {
      case "web_search":
        self = .webSearch
      case "web_search_2025_08_26":
        self = .webSearch20250826
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
      case .webSearch:
        try container.encode("web_search")
      case .webSearch20250826:
        try container.encode("web_search_2025_08_26")
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

  /// The code interpreter container. Can be a container ID or an object that specifies uploaded file IDs to make available to your code.
  public enum CodeInterpreterContainer: Codable {
    /// The container ID
    case id(String)

    /// Configuration for a code interpreter container. Optionally specify the IDs of the files to run the code on.
    case auto(fileIds: [String]?)

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()

      if let containerId = try? container.decode(String.self) {
        self = .id(containerId)
      } else if let autoContainer = try? container.decode(AutoContainer.self) {
        self = .auto(fileIds: autoContainer.fileIds)
      } else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Expected string container ID or auto container object")
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
      case .id(let containerId):
        try container.encode(containerId)
      case .auto(let fileIds):
        try container.encode(AutoContainer(fileIds: fileIds))
      }
    }

    /// Configuration for a code interpreter container
    private struct AutoContainer: Codable {
      /// Always auto
      let type = "auto"

      /// An optional list of uploaded files to make available to your code
      let fileIds: [String]?

      init(fileIds: [String]?) {
        self.fileIds = fileIds
      }

      enum CodingKeys: String, CodingKey {
        case type
        case fileIds = "file_ids"
      }
    }
  }

  /// Optional mask for inpainting
  public struct InputImageMask: Codable {
    public init(fileId: String? = nil, imageUrl: String? = nil) {
      self.fileId = fileId
      self.imageUrl = imageUrl
    }

    /// File ID for the mask image
    public let fileId: String?

    /// Base64-encoded mask image
    public let imageUrl: String?

    enum CodingKeys: String, CodingKey {
      case fileId = "file_id"
      case imageUrl = "image_url"
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

  /// A tool that runs Python code to help generate a response to a prompt
  public struct CodeInterpreterTool: Codable {
    public init(container: CodeInterpreterContainer) {
      self.container = container
    }

    /// The code interpreter container. Can be a container ID or an object that specifies uploaded file IDs to make available to your code.
    public let container: CodeInterpreterContainer

    /// The type of the code interpreter tool. Always code_interpreter
    public let type = "code_interpreter"

    enum CodingKeys: String, CodingKey {
      case container
      case type
    }
  }

  /// A tool that generates images using a model like gpt-image-1
  public struct ImageGenerationTool: Codable {
    public init(
      background: String? = nil,
      inputFidelity: String? = nil,
      inputImageMask: InputImageMask? = nil,
      model: String? = nil,
      moderation: String? = nil,
      outputCompression: Int? = nil,
      outputFormat: String? = nil,
      partialImages: Int? = nil,
      quality: String? = nil,
      size: String? = nil)
    {
      self.background = background
      self.inputFidelity = inputFidelity
      self.inputImageMask = inputImageMask
      self.model = model
      self.moderation = moderation
      self.outputCompression = outputCompression
      self.outputFormat = outputFormat
      self.partialImages = partialImages
      self.quality = quality
      self.size = size
    }

    /// The type of the image generation tool. Always image_generation
    public let type = "image_generation"

    /// Defaults to auto
    /// Background type for the generated image. One of transparent, opaque, or auto. Default: auto.
    public let background: String?

    /// Defaults to low
    /// Control how much effort the model will exert to match the style and features, especially facial features, of input images. This parameter is only supported for gpt-image-1. Supports high and low. Defaults to low.
    public let inputFidelity: String?

    /// Optional mask for inpainting. Contains image_url (string, optional) and file_id (string, optional).
    public let inputImageMask: InputImageMask?

    /// Defaults to gpt-image-1
    /// The image generation model to use. Default: gpt-image-1.
    public let model: String?

    /// Defaults to auto
    /// Moderation level for the generated image. Default: auto.
    public let moderation: String?

    /// Defaults to 100
    /// Compression level for the output image. Default: 100.
    public let outputCompression: Int?

    /// Defaults to png
    /// The output format of the generated image. One of png, webp, or jpeg. Default: png.
    public let outputFormat: String?

    /// Defaults to 0
    /// Number of partial images to generate in streaming mode, from 0 (default value) to 3.
    public let partialImages: Int?

    /// Defaults to auto
    /// The quality of the generated image. One of low, medium, high, or auto. Default: auto.
    public let quality: String?

    /// Defaults to auto
    /// The size of the generated image. One of 1024x1024, 1024x1536, 1536x1024, or auto. Default: auto.
    public let size: String?

    enum CodingKeys: String, CodingKey {
      case type
      case background
      case inputFidelity = "input_fidelity"
      case inputImageMask = "input_image_mask"
      case model
      case moderation
      case outputCompression = "output_compression"
      case outputFormat = "output_format"
      case partialImages = "partial_images"
      case quality
      case size
    }
  }

  /// A tool that allows the model to execute shell commands in a local environment
  public struct LocalShellTool: Codable {
    public init() { }

    /// The type of the local shell tool. Always local_shell
    public let type = "local_shell"

    enum CodingKeys: String, CodingKey {
      case type
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

  /// Filters for web search
  public struct WebSearchFilters: Codable {
    public init(allowedDomains: [String]? = nil) {
      self.allowedDomains = allowedDomains
    }

    /// Defaults to []
    /// Allowed domains for the search. If not provided, all domains are allowed. Subdomains of the provided domains are allowed as well.
    /// Example: ["pubmed.ncbi.nlm.nih.gov"]
    public let allowedDomains: [String]?

    enum CodingKeys: String, CodingKey {
      case allowedDomains = "allowed_domains"
    }
  }

  /// This tool searches the web for relevant results to use in a response
  public struct WebSearchTool: Codable {
    public init(
      type: WebSearchType,
      filters: WebSearchFilters? = nil,
      searchContextSize: SearchContextSize? = nil,
      userLocation: UserLocation? = nil)
    {
      self.type = type
      self.filters = filters
      self.searchContextSize = searchContextSize
      self.userLocation = userLocation
    }

    /// The type of the web search tool
    public let type: WebSearchType

    /// Filters for the search
    public let filters: WebSearchFilters?

    /// High level guidance for the amount of context window space to use for the search
    public let searchContextSize: SearchContextSize?

    /// Approximate location parameters for the search
    public let userLocation: UserLocation?

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      // Special handling for type
      switch type {
      case .webSearch:
        try container.encode("web_search", forKey: .type)
      case .webSearch20250826:
        try container.encode("web_search_2025_08_26", forKey: .type)
      case .webSearchPreview:
        try container.encode("web_search_preview", forKey: .type)
      case .webSearchPreview20250311:
        try container.encode("web_search_preview_2025_03_11", forKey: .type)
      case .custom(let value):
        try container.encode(value, forKey: .type)
      }

      try container.encodeIfPresent(filters, forKey: .filters)
      try container.encodeIfPresent(searchContextSize, forKey: .searchContextSize)
      try container.encodeIfPresent(userLocation, forKey: .userLocation)
    }

    enum CodingKeys: String, CodingKey {
      case type
      case filters
      case searchContextSize = "search_context_size"
      case userLocation = "user_location"
    }
  }

  /// Unconstrained free-form text format
  public struct TextFormat: Codable {
    public init() { }

    /// Unconstrained text format. Always text
    public let type = "text"

    enum CodingKeys: String, CodingKey {
      case type
    }
  }

  /// A grammar defined by the user
  public struct GrammarFormat: Codable {
    public init(definition: String, syntax: String) {
      self.definition = definition
      self.syntax = syntax
    }

    /// The grammar definition
    public let definition: String

    /// The syntax of the grammar definition. One of lark or regex
    public let syntax: String

    /// Grammar format. Always grammar
    public let type = "grammar"

    enum CodingKeys: String, CodingKey {
      case definition
      case syntax
      case type
    }
  }

  /// The input format for the custom tool
  public enum ToolFormat: Codable {
    /// Unconstrained free-form text
    case text(TextFormat)

    /// A grammar defined by the user
    case grammar(GrammarFormat)

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let type = try container.decode(String.self, forKey: .type)

      let singleValueContainer = try decoder.singleValueContainer()

      switch type {
      case "text":
        self = try .text(singleValueContainer.decode(TextFormat.self))
      case "grammar":
        self = try .grammar(singleValueContainer.decode(GrammarFormat.self))
      default:
        throw DecodingError.dataCorruptedError(
          forKey: .type,
          in: container,
          debugDescription: "Unknown format type: \(type)")
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
      case .text(let format):
        try container.encode(format)
      case .grammar(let format):
        try container.encode(format)
      }
    }

    private enum CodingKeys: String, CodingKey {
      case type
    }
  }

  /// A custom tool that processes input using a specified format
  public struct CustomTool: Codable {
    public init(
      name: String,
      description: String? = nil,
      format: ToolFormat? = nil)
    {
      self.name = name
      self.description = description
      self.format = format
    }

    /// The name of the custom tool, used to identify it in tool calls
    public let name: String

    /// Optional description of the custom tool, used to provide more context
    public let description: String?

    /// The input format for the custom tool. Default is unconstrained text
    public let format: ToolFormat?

    /// The type of the custom tool. Always custom
    public let type = "custom"

    enum CodingKeys: String, CodingKey {
      case name
      case description
      case format
      case type
    }
  }

  /// Identifier for service connectors
  public enum ConnectorId: String, Codable {
    /// Dropbox connector
    case dropbox = "connector_dropbox"

    /// Gmail connector
    case gmail = "connector_gmail"

    /// Google Calendar connector
    case googleCalendar = "connector_googlecalendar"

    /// Google Drive connector
    case googleDrive = "connector_googledrive"

    /// Microsoft Teams connector
    case microsoftTeams = "connector_microsoftteams"

    /// Outlook Calendar connector
    case outlookCalendar = "connector_outlookcalendar"

    /// Outlook Email connector
    case outlookEmail = "connector_outlookemail"

    /// SharePoint connector
    case sharePoint = "connector_sharepoint"
  }

  /// A filter object to specify which tools are allowed
  public struct MCPToolFilter: Codable {
    public init(readOnly: Bool? = nil, toolNames: [String]? = nil) {
      self.readOnly = readOnly
      self.toolNames = toolNames
    }

    /// Indicates whether or not a tool modifies data or is read-only. If an MCP server is annotated with readOnlyHint, it will match this filter.
    public let readOnly: Bool?

    /// List of allowed tool names
    public let toolNames: [String]?

    enum CodingKeys: String, CodingKey {
      case readOnly = "read_only"
      case toolNames = "tool_names"
    }
  }

  /// List of allowed tool names or a filter object
  public enum AllowedTools: Codable {
    /// A string array of allowed tool names
    case toolNames([String])

    /// A filter object to specify which tools are allowed
    case filter(MCPToolFilter)

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()

      if let toolNames = try? container.decode([String].self) {
        self = .toolNames(toolNames)
      } else if let filter = try? container.decode(MCPToolFilter.self) {
        self = .filter(filter)
      } else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Expected array of strings or MCPToolFilter object")
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
      case .toolNames(let names):
        try container.encode(names)
      case .filter(let filter):
        try container.encode(filter)
      }
    }
  }

  /// Approval filters for MCP tools
  public struct ApprovalFilters: Codable {
    public init(always: MCPToolFilter? = nil, never: MCPToolFilter? = nil) {
      self.always = always
      self.never = never
    }

    /// A filter object to specify which tools always require approval
    public let always: MCPToolFilter?

    /// A filter object to specify which tools never require approval
    public let never: MCPToolFilter?
  }

  /// Specify which of the MCP server's tools require approval
  public enum RequireApproval: Codable {
    /// All tools require approval
    case always

    /// No tools require approval
    case never

    /// Specify which tools require approval using filters
    case filters(ApprovalFilters)

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()

      if let stringValue = try? container.decode(String.self) {
        switch stringValue {
        case "always":
          self = .always
        case "never":
          self = .never
        default:
          throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unknown require_approval value: \(stringValue)")
        }
      } else if let filters = try? container.decode(ApprovalFilters.self) {
        self = .filters(filters)
      } else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Expected 'always', 'never', or ApprovalFilters object")
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
      case .always:
        try container.encode("always")
      case .never:
        try container.encode("never")
      case .filters(let filters):
        try container.encode(filters)
      }
    }
  }

  /// Give the model access to additional tools via remote Model Context Protocol (MCP) servers
  public struct MCPTool: Codable {
    public init(
      serverLabel: String,
      allowedTools: AllowedTools? = nil,
      authorization: String? = nil,
      connectorId: ConnectorId? = nil,
      headers: [String: String]? = nil,
      requireApproval: RequireApproval? = nil,
      serverDescription: String? = nil,
      serverUrl: String? = nil)
    {
      self.serverLabel = serverLabel
      self.allowedTools = allowedTools
      self.authorization = authorization
      self.connectorId = connectorId
      self.headers = headers
      self.requireApproval = requireApproval
      self.serverDescription = serverDescription
      self.serverUrl = serverUrl
    }

    /// A label for this MCP server, used to identify it in tool calls
    public let serverLabel: String

    /// The type of the MCP tool. Always mcp
    public let type = "mcp"

    /// List of allowed tool names or a filter object
    public let allowedTools: AllowedTools?

    /// An OAuth access token that can be used with a remote MCP server, either with a custom MCP server URL or a service connector
    public let authorization: String?

    /// Identifier for service connectors. One of server_url or connector_id must be provided
    public let connectorId: ConnectorId?

    /// Optional HTTP headers to send to the MCP server. Use for authentication or other purposes
    public let headers: [String: String]?

    /// Defaults to always
    /// Specify which of the MCP server's tools require approval
    public let requireApproval: RequireApproval?

    /// Optional description of the MCP server, used to provide more context
    public let serverDescription: String?

    /// The URL for the MCP server. One of server_url or connector_id must be provided
    public let serverUrl: String?

    enum CodingKeys: String, CodingKey {
      case serverLabel = "server_label"
      case type
      case allowedTools = "allowed_tools"
      case authorization
      case connectorId = "connector_id"
      case headers
      case requireApproval = "require_approval"
      case serverDescription = "server_description"
      case serverUrl = "server_url"
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
    case .codeInterpreter(let tool):
      try container.encode(tool)
    case .imageGeneration(let tool):
      try container.encode(tool)
    case .localShell(let tool):
      try container.encode(tool)
    case .computerUse(let tool):
      try container.encode(tool)
    case .webSearch(let tool):
      try container.encode(tool)
    case .mcp(let tool):
      try container.encode(tool)
    case .custom(let tool):
      try container.encode(tool)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case type
  }
}
