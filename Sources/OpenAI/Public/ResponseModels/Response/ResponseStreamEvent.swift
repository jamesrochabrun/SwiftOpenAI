//
//  ResponseStreamEvent.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 6/7/25.
//

import Foundation

// MARK: - ResponseStreamEvent

/// Represents all possible streaming events from the Responses API
public enum ResponseStreamEvent: Decodable {
  /// Emitted when a response is created
  case responseCreated(ResponseCreatedEvent)

  /// Emitted when the response is in progress
  case responseInProgress(ResponseInProgressEvent)

  /// Emitted when the model response is complete
  case responseCompleted(ResponseCompletedEvent)

  /// Emitted when a response fails
  case responseFailed(ResponseFailedEvent)

  /// Emitted when a response finishes as incomplete
  case responseIncomplete(ResponseIncompleteEvent)

  /// Emitted when a response is queued
  case responseQueued(ResponseQueuedEvent)

  /// Emitted when a new output item is added
  case outputItemAdded(OutputItemAddedEvent)

  /// Emitted when an output item is marked done
  case outputItemDone(OutputItemDoneEvent)

  /// Emitted when a new content part is added
  case contentPartAdded(ContentPartAddedEvent)

  /// Emitted when a content part is done
  case contentPartDone(ContentPartDoneEvent)

  /// Emitted when there is an additional text delta
  case outputTextDelta(OutputTextDeltaEvent)

  /// Emitted when text content is finalized
  case outputTextDone(OutputTextDoneEvent)

  /// Emitted when there is a partial refusal text
  case refusalDelta(RefusalDeltaEvent)

  /// Emitted when refusal text is finalized
  case refusalDone(RefusalDoneEvent)

  /// Emitted when there is a partial function-call arguments delta
  case functionCallArgumentsDelta(FunctionCallArgumentsDeltaEvent)

  /// Emitted when function-call arguments are finalized
  case functionCallArgumentsDone(FunctionCallArgumentsDoneEvent)

  /// Emitted when a file search call is initiated
  case fileSearchCallInProgress(FileSearchCallInProgressEvent)

  /// Emitted when a file search is currently searching
  case fileSearchCallSearching(FileSearchCallSearchingEvent)

  /// Emitted when a file search call is completed
  case fileSearchCallCompleted(FileSearchCallCompletedEvent)

  /// Emitted when a web search call is initiated
  case webSearchCallInProgress(WebSearchCallInProgressEvent)

  /// Emitted when a web search call is executing
  case webSearchCallSearching(WebSearchCallSearchingEvent)

  /// Emitted when a web search call is completed
  case webSearchCallCompleted(WebSearchCallCompletedEvent)

  /// Emitted when a new reasoning summary part is added
  case reasoningSummaryPartAdded(ReasoningSummaryPartAddedEvent)

  /// Emitted when a reasoning summary part is completed
  case reasoningSummaryPartDone(ReasoningSummaryPartDoneEvent)

  /// Emitted when a delta is added to a reasoning summary text
  case reasoningSummaryTextDelta(ReasoningSummaryTextDeltaEvent)

  /// Emitted when a reasoning summary text is completed
  case reasoningSummaryTextDone(ReasoningSummaryTextDoneEvent)

  /// Emitted when a delta is added to reasoning text
  case reasoningTextDelta(ReasoningTextDeltaEvent)

  /// Emitted when reasoning text is completed
  case reasoningTextDone(ReasoningTextDoneEvent)

  /// Emitted when an image generation call is in progress
  case imageGenerationCallInProgress(ImageGenerationCallInProgressEvent)

  /// Emitted when an image generation call is generating
  case imageGenerationCallGenerating(ImageGenerationCallGeneratingEvent)

  /// Emitted when a partial image is available
  case imageGenerationCallPartialImage(ImageGenerationCallPartialImageEvent)

  /// Emitted when an image generation call is completed
  case imageGenerationCallCompleted(ImageGenerationCallCompletedEvent)

  /// Emitted when a code interpreter call is in progress
  case codeInterpreterCallInProgress(CodeInterpreterCallInProgressEvent)

  /// Emitted when the code interpreter is actively interpreting code
  case codeInterpreterCallInterpreting(CodeInterpreterCallInterpretingEvent)

  /// Emitted when a code interpreter call is completed
  case codeInterpreterCallCompleted(CodeInterpreterCallCompletedEvent)

  /// Emitted when a partial code snippet is streamed by the code interpreter
  case codeInterpreterCallCodeDelta(CodeInterpreterCallCodeDeltaEvent)

  /// Emitted when the code snippet is finalized by the code interpreter
  case codeInterpreterCallCodeDone(CodeInterpreterCallCodeDoneEvent)

  /// Emitted when there is a delta to custom tool call input
  case customToolCallInputDelta(CustomToolCallInputDeltaEvent)

  /// Emitted when custom tool call input is complete
  case customToolCallInputDone(CustomToolCallInputDoneEvent)

  /// Emitted when there is a delta to MCP call arguments
  case mcpCallArgumentsDelta(MCPCallArgumentsDeltaEvent)

  /// Emitted when MCP call arguments are done
  case mcpCallArgumentsDone(MCPCallArgumentsDoneEvent)

  /// Emitted when an MCP call is in progress
  case mcpCallInProgress(MCPCallInProgressEvent)

  /// Emitted when an MCP call is completed
  case mcpCallCompleted(MCPCallCompletedEvent)

  /// Emitted when an MCP call failed
  case mcpCallFailed(MCPCallFailedEvent)

  /// Emitted when MCP list tools is in progress
  case mcpListToolsInProgress(MCPListToolsInProgressEvent)

  /// Emitted when MCP list tools is completed
  case mcpListToolsCompleted(MCPListToolsCompletedEvent)

  /// Emitted when MCP list tools failed
  case mcpListToolsFailed(MCPListToolsFailedEvent)

  /// Emitted when an annotation is added to output text
  case outputTextAnnotationAdded(OutputTextAnnotationAddedEvent)

  /// Emitted when there is a delta to reasoning content
  case reasoningDelta(ReasoningDeltaEvent)

  /// Emitted when reasoning content is done
  case reasoningDone(ReasoningDoneEvent)

  /// Emitted when there is a delta to reasoning summary
  case reasoningSummaryDelta(ReasoningSummaryDeltaEvent)

  /// Emitted when reasoning summary is done
  case reasoningSummaryDone(ReasoningSummaryDoneEvent)

  /// Emitted when an error occurs
  case error(ErrorEvent)

  /// For unknown event type
  case unknownEventType(String)

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    switch type {
    case "response.created":
      self = try .responseCreated(ResponseCreatedEvent(from: decoder))
    case "response.in_progress":
      self = try .responseInProgress(ResponseInProgressEvent(from: decoder))
    case "response.completed":
      self = try .responseCompleted(ResponseCompletedEvent(from: decoder))
    case "response.failed":
      self = try .responseFailed(ResponseFailedEvent(from: decoder))
    case "response.incomplete":
      self = try .responseIncomplete(ResponseIncompleteEvent(from: decoder))
    case "response.queued":
      self = try .responseQueued(ResponseQueuedEvent(from: decoder))
    case "response.output_item.added":
      self = try .outputItemAdded(OutputItemAddedEvent(from: decoder))
    case "response.output_item.done":
      self = try .outputItemDone(OutputItemDoneEvent(from: decoder))
    case "response.content_part.added":
      self = try .contentPartAdded(ContentPartAddedEvent(from: decoder))
    case "response.content_part.done":
      self = try .contentPartDone(ContentPartDoneEvent(from: decoder))
    case "response.output_text.delta":
      self = try .outputTextDelta(OutputTextDeltaEvent(from: decoder))
    case "response.output_text.done":
      self = try .outputTextDone(OutputTextDoneEvent(from: decoder))
    case "response.refusal.delta":
      self = try .refusalDelta(RefusalDeltaEvent(from: decoder))
    case "response.refusal.done":
      self = try .refusalDone(RefusalDoneEvent(from: decoder))
    case "response.function_call_arguments.delta":
      self = try .functionCallArgumentsDelta(FunctionCallArgumentsDeltaEvent(from: decoder))
    case "response.function_call_arguments.done":
      self = try .functionCallArgumentsDone(FunctionCallArgumentsDoneEvent(from: decoder))
    case "response.file_search_call.in_progress":
      self = try .fileSearchCallInProgress(FileSearchCallInProgressEvent(from: decoder))
    case "response.file_search_call.searching":
      self = try .fileSearchCallSearching(FileSearchCallSearchingEvent(from: decoder))
    case "response.file_search_call.completed":
      self = try .fileSearchCallCompleted(FileSearchCallCompletedEvent(from: decoder))
    case "response.web_search_call.in_progress":
      self = try .webSearchCallInProgress(WebSearchCallInProgressEvent(from: decoder))
    case "response.web_search_call.searching":
      self = try .webSearchCallSearching(WebSearchCallSearchingEvent(from: decoder))
    case "response.web_search_call.completed":
      self = try .webSearchCallCompleted(WebSearchCallCompletedEvent(from: decoder))
    case "response.reasoning_summary_part.added":
      self = try .reasoningSummaryPartAdded(ReasoningSummaryPartAddedEvent(from: decoder))
    case "response.reasoning_summary_part.done":
      self = try .reasoningSummaryPartDone(ReasoningSummaryPartDoneEvent(from: decoder))
    case "response.reasoning_summary_text.delta":
      self = try .reasoningSummaryTextDelta(ReasoningSummaryTextDeltaEvent(from: decoder))
    case "response.reasoning_summary_text.done":
      self = try .reasoningSummaryTextDone(ReasoningSummaryTextDoneEvent(from: decoder))
    case "response.reasoning_text.delta":
      self = try .reasoningTextDelta(ReasoningTextDeltaEvent(from: decoder))
    case "response.reasoning_text.done":
      self = try .reasoningTextDone(ReasoningTextDoneEvent(from: decoder))
    case "response.image_generation_call.in_progress":
      self = try .imageGenerationCallInProgress(ImageGenerationCallInProgressEvent(from: decoder))
    case "response.image_generation_call.generating":
      self = try .imageGenerationCallGenerating(ImageGenerationCallGeneratingEvent(from: decoder))
    case "response.image_generation_call.partial_image":
      self = try .imageGenerationCallPartialImage(ImageGenerationCallPartialImageEvent(from: decoder))
    case "response.image_generation_call.completed":
      self = try .imageGenerationCallCompleted(ImageGenerationCallCompletedEvent(from: decoder))
    case "response.code_interpreter_call.in_progress":
      self = try .codeInterpreterCallInProgress(CodeInterpreterCallInProgressEvent(from: decoder))
    case "response.code_interpreter_call.interpreting":
      self = try .codeInterpreterCallInterpreting(CodeInterpreterCallInterpretingEvent(from: decoder))
    case "response.code_interpreter_call.completed":
      self = try .codeInterpreterCallCompleted(CodeInterpreterCallCompletedEvent(from: decoder))
    case "response.code_interpreter_call_code.delta":
      self = try .codeInterpreterCallCodeDelta(CodeInterpreterCallCodeDeltaEvent(from: decoder))
    case "response.code_interpreter_call_code.done":
      self = try .codeInterpreterCallCodeDone(CodeInterpreterCallCodeDoneEvent(from: decoder))
    case "response.custom_tool_call_input.delta":
      self = try .customToolCallInputDelta(CustomToolCallInputDeltaEvent(from: decoder))
    case "response.custom_tool_call_input.done":
      self = try .customToolCallInputDone(CustomToolCallInputDoneEvent(from: decoder))
    case "response.mcp_call.arguments.delta":
      self = try .mcpCallArgumentsDelta(MCPCallArgumentsDeltaEvent(from: decoder))
    case "response.mcp_call.arguments.done":
      self = try .mcpCallArgumentsDone(MCPCallArgumentsDoneEvent(from: decoder))
    case "response.mcp_call.in_progress":
      self = try .mcpCallInProgress(MCPCallInProgressEvent(from: decoder))
    case "response.mcp_call.completed":
      self = try .mcpCallCompleted(MCPCallCompletedEvent(from: decoder))
    case "response.mcp_call.failed":
      self = try .mcpCallFailed(MCPCallFailedEvent(from: decoder))
    case "response.mcp_list_tools.in_progress":
      self = try .mcpListToolsInProgress(MCPListToolsInProgressEvent(from: decoder))
    case "response.mcp_list_tools.completed":
      self = try .mcpListToolsCompleted(MCPListToolsCompletedEvent(from: decoder))
    case "response.mcp_list_tools.failed":
      self = try .mcpListToolsFailed(MCPListToolsFailedEvent(from: decoder))
    case "response.output_text.annotation.added":
      self = try .outputTextAnnotationAdded(OutputTextAnnotationAddedEvent(from: decoder))
    case "response.reasoning.delta":
      self = try .reasoningDelta(ReasoningDeltaEvent(from: decoder))
    case "response.reasoning.done":
      self = try .reasoningDone(ReasoningDoneEvent(from: decoder))
    case "response.reasoning_summary.delta":
      self = try .reasoningSummaryDelta(ReasoningSummaryDeltaEvent(from: decoder))
    case "response.reasoning_summary.done":
      self = try .reasoningSummaryDone(ReasoningSummaryDoneEvent(from: decoder))
    case "error":
      self = try .error(ErrorEvent(from: decoder))
    default:
      self = .unknownEventType(type)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case type
  }
}

// MARK: - ResponseCreatedEvent

/// Emitted when a response is created
public struct ResponseCreatedEvent: Decodable {
  public let type: String
  public let response: ResponseModel
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case response
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ResponseInProgressEvent

/// Emitted when the response is in progress
public struct ResponseInProgressEvent: Decodable {
  public let type: String
  public let response: ResponseModel
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case response
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ResponseCompletedEvent

/// Emitted when the model response is complete
public struct ResponseCompletedEvent: Decodable {
  public let type: String
  public let response: ResponseModel
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case response
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ResponseFailedEvent

/// Emitted when a response fails
public struct ResponseFailedEvent: Decodable {
  public let type: String
  public let response: ResponseModel
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case response
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ResponseIncompleteEvent

/// Emitted when a response finishes as incomplete
public struct ResponseIncompleteEvent: Decodable {
  public let type: String
  public let response: ResponseModel
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case response
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ResponseQueuedEvent

/// Emitted when a response is queued
public struct ResponseQueuedEvent: Decodable {
  public let type: String
  public let response: ResponseModel
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case response
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - OutputItemAddedEvent

/// Emitted when a new output item is added
public struct OutputItemAddedEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let item: StreamOutputItem
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case item
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - OutputItemDoneEvent

/// Emitted when an output item is marked done
public struct OutputItemDoneEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let item: StreamOutputItem
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case item
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ContentPartAddedEvent

/// Emitted when a new content part is added
public struct ContentPartAddedEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let part: ContentPart
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case part
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ContentPartDoneEvent

/// Emitted when a content part is done
public struct ContentPartDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let part: ContentPart
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case part
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - OutputTextDeltaEvent

/// Emitted when there is an additional text delta
public struct OutputTextDeltaEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let delta: String
  public let logprobs: [LogprobContent]?
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case delta
    case logprobs
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - LogprobContent

/// Log probability information for a token in the delta
public struct LogprobContent: Decodable {
  /// The token string
  public let token: String
  /// The log probability of the token
  public let logprob: Double
  /// Array of the most likely tokens and their log probabilities
  public let topLogprobs: [TopLogprob]?
  /// Byte offsets for the token
  public let bytes: [Int]?

  enum CodingKeys: String, CodingKey {
    case token
    case logprob
    case topLogprobs = "top_logprobs"
    case bytes
  }
}

// MARK: - TopLogprob

/// Information about a top alternative token
public struct TopLogprob: Decodable {
  /// The token string
  public let token: String
  /// The log probability of the token
  public let logprob: Double
  /// Byte offsets for the token
  public let bytes: [Int]?
}

// MARK: - OutputTextDoneEvent

/// Emitted when text content is finalized
public struct OutputTextDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let text: String
  public let logprobs: [LogprobContent]?
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case text
    case logprobs
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - RefusalDeltaEvent

/// Emitted when there is a partial refusal text
public struct RefusalDeltaEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let delta: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case delta
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - RefusalDoneEvent

/// Emitted when refusal text is finalized
public struct RefusalDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let refusal: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case refusal
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - FunctionCallArgumentsDeltaEvent

/// Emitted when there is a partial function-call arguments delta
public struct FunctionCallArgumentsDeltaEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let delta: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case delta
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - FunctionCallArgumentsDoneEvent

/// Emitted when function-call arguments are finalized
public struct FunctionCallArgumentsDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let name: String
  public let arguments: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case name
    case arguments
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - FileSearchCallInProgressEvent

/// Emitted when a file search call is initiated
public struct FileSearchCallInProgressEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - FileSearchCallSearchingEvent

/// Emitted when a file search is currently searching
public struct FileSearchCallSearchingEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - FileSearchCallCompletedEvent

/// Emitted when a file search call is completed
public struct FileSearchCallCompletedEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - WebSearchCallInProgressEvent

/// Emitted when a web search call is initiated
public struct WebSearchCallInProgressEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - WebSearchCallSearchingEvent

/// Emitted when a web search call is executing
public struct WebSearchCallSearchingEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - WebSearchCallCompletedEvent

/// Emitted when a web search call is completed
public struct WebSearchCallCompletedEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningSummaryPartAddedEvent

/// Emitted when a new reasoning summary part is added
public struct ReasoningSummaryPartAddedEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let summaryIndex: Int
  public let part: SummaryPart
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case summaryIndex = "summary_index"
    case part
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningSummaryPartDoneEvent

/// Emitted when a reasoning summary part is completed
public struct ReasoningSummaryPartDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let summaryIndex: Int
  public let part: SummaryPart
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case summaryIndex = "summary_index"
    case part
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningSummaryTextDeltaEvent

/// Emitted when a delta is added to a reasoning summary text
public struct ReasoningSummaryTextDeltaEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let summaryIndex: Int
  public let delta: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case summaryIndex = "summary_index"
    case delta
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningSummaryTextDoneEvent

/// Emitted when a reasoning summary text is completed
public struct ReasoningSummaryTextDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let summaryIndex: Int
  public let text: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case summaryIndex = "summary_index"
    case text
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningTextDeltaEvent

/// Emitted when a delta is added to a reasoning text
public struct ReasoningTextDeltaEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let delta: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case delta
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningTextDoneEvent

/// Emitted when reasoning text is completed
public struct ReasoningTextDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let text: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case text
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ImageGenerationCallInProgressEvent

/// Emitted when an image generation call is in progress
public struct ImageGenerationCallInProgressEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ImageGenerationCallGeneratingEvent

/// Emitted when an image generation call is generating
public struct ImageGenerationCallGeneratingEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ImageGenerationCallPartialImageEvent

/// Emitted when a partial image is available
public struct ImageGenerationCallPartialImageEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?
  public let partialImageIndex: Int
  public let partialImageB64: String

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
    case partialImageIndex = "partial_image_index"
    case partialImageB64 = "partial_image_b64"
  }
}

// MARK: - ImageGenerationCallCompletedEvent

/// Emitted when an image generation call is completed
public struct ImageGenerationCallCompletedEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - CodeInterpreterCallInProgressEvent

/// Emitted when a code interpreter call is in progress
public struct CodeInterpreterCallInProgressEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - CodeInterpreterCallInterpretingEvent

/// Emitted when the code interpreter is actively interpreting code
public struct CodeInterpreterCallInterpretingEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - CodeInterpreterCallCompletedEvent

/// Emitted when a code interpreter call is completed
public struct CodeInterpreterCallCompletedEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - CodeInterpreterCallCodeDeltaEvent

/// Emitted when a partial code snippet is streamed by the code interpreter
public struct CodeInterpreterCallCodeDeltaEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let delta: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case delta
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - CodeInterpreterCallCodeDoneEvent

/// Emitted when the code snippet is finalized by the code interpreter
public struct CodeInterpreterCallCodeDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let code: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case code
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - CustomToolCallInputDeltaEvent

/// Event representing a delta to the input of a custom tool call
public struct CustomToolCallInputDeltaEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let delta: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case delta
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - CustomToolCallInputDoneEvent

/// Event indicating that input for a custom tool call is complete
public struct CustomToolCallInputDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let input: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case input
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - MCPCallArgumentsDeltaEvent

/// Emitted when there is a delta to MCP call arguments
public struct MCPCallArgumentsDeltaEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let delta: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case delta
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - MCPCallArgumentsDoneEvent

/// Emitted when MCP call arguments are done
public struct MCPCallArgumentsDoneEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let arguments: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case arguments
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - MCPCallInProgressEvent

/// Emitted when an MCP call is in progress
public struct MCPCallInProgressEvent: Decodable {
  public let type: String
  public let outputIndex: Int
  public let itemId: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case outputIndex = "output_index"
    case itemId = "item_id"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - MCPCallCompletedEvent

/// Emitted when an MCP call is completed
public struct MCPCallCompletedEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - MCPCallFailedEvent

/// Emitted when an MCP call failed
public struct MCPCallFailedEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - MCPListToolsInProgressEvent

/// Emitted when MCP list tools is in progress
public struct MCPListToolsInProgressEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - MCPListToolsCompletedEvent

/// Emitted when MCP list tools is completed
public struct MCPListToolsCompletedEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - MCPListToolsFailedEvent

/// Emitted when MCP list tools failed
public struct MCPListToolsFailedEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - OutputTextAnnotationAddedEvent

/// Emitted when an annotation is added to output text
public struct OutputTextAnnotationAddedEvent: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    type = try container.decode(String.self, forKey: .type)
    itemId = try container.decode(String.self, forKey: .itemId)
    outputIndex = try container.decode(Int.self, forKey: .outputIndex)
    contentIndex = try container.decode(Int.self, forKey: .contentIndex)
    annotationIndex = try container.decode(Int.self, forKey: .annotationIndex)
    sequenceNumber = try container.decodeIfPresent(Int.self, forKey: .sequenceNumber)
    // For now, decode annotation as empty dictionary
    annotation = [:]
  }

  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let annotationIndex: Int
  public let annotation: [String: Any]
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case annotationIndex = "annotation_index"
    case annotation
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningDeltaEvent

/// Emitted when there is a delta to reasoning content
public struct ReasoningDeltaEvent: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    type = try container.decode(String.self, forKey: .type)
    itemId = try container.decode(String.self, forKey: .itemId)
    outputIndex = try container.decode(Int.self, forKey: .outputIndex)
    contentIndex = try container.decode(Int.self, forKey: .contentIndex)
    sequenceNumber = try container.decodeIfPresent(Int.self, forKey: .sequenceNumber)
    // For now, decode delta as empty dictionary
    delta = [:]
  }

  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let delta: [String: Any]
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case delta
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningDoneEvent

/// Emitted when reasoning content is done
public struct ReasoningDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let contentIndex: Int
  public let text: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case contentIndex = "content_index"
    case text
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningSummaryDeltaEvent

/// Emitted when there is a delta to reasoning summary
public struct ReasoningSummaryDeltaEvent: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    type = try container.decode(String.self, forKey: .type)
    itemId = try container.decode(String.self, forKey: .itemId)
    outputIndex = try container.decode(Int.self, forKey: .outputIndex)
    summaryIndex = try container.decode(Int.self, forKey: .summaryIndex)
    sequenceNumber = try container.decodeIfPresent(Int.self, forKey: .sequenceNumber)
    // For now, decode delta as empty dictionary
    delta = [:]
  }

  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let summaryIndex: Int
  public let delta: [String: Any]
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case summaryIndex = "summary_index"
    case delta
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ReasoningSummaryDoneEvent

/// Emitted when reasoning summary is done
public struct ReasoningSummaryDoneEvent: Decodable {
  public let type: String
  public let itemId: String
  public let outputIndex: Int
  public let summaryIndex: Int
  public let text: String
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case itemId = "item_id"
    case outputIndex = "output_index"
    case summaryIndex = "summary_index"
    case text
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - ErrorEvent

/// Emitted when an error occurs
public struct ErrorEvent: Decodable {
  public let type: String
  public let code: String?
  public let message: String
  public let param: String?
  public let sequenceNumber: Int?

  enum CodingKeys: String, CodingKey {
    case type
    case code
    case message
    case param
    case sequenceNumber = "sequence_number"
  }
}

// MARK: - StreamOutputItem

/// Stream output item that supports all output types during streaming
public enum StreamOutputItem: Decodable {
  /// An output message from the model
  case message(OutputItem.Message)
  /// The results of a file search tool call
  case fileSearchCall(OutputItem.FileSearchToolCall)
  /// A tool call to run a function
  case functionCall(OutputItem.FunctionToolCall)
  /// The results of a web search tool call
  case webSearchCall(OutputItem.WebSearchToolCall)
  /// A tool call to a computer use tool
  case computerCall(OutputItem.ComputerToolCall)
  /// A description of the chain of thought used by a reasoning model
  case reasoning(OutputItem.Reasoning)
  /// An image generation request made by the model
  case imageGenerationCall(OutputItem.ImageGenerationCall)
  /// A tool call to run code
  case codeInterpreterCall(OutputItem.CodeInterpreterCall)
  /// A tool call to run a command on the local shell
  case localShellCall(OutputItem.LocalShellCall)
  /// An invocation of a tool on an MCP server
  case mcpCall(OutputItem.MCPCall)
  /// A list of tools available on an MCP server
  case mcpListTools(OutputItem.MCPListTools)
  /// A request for human approval of a tool invocation
  case mcpApprovalRequest(OutputItem.MCPApprovalRequest)

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    switch type {
    case "message":
      let message = try OutputItem.Message(from: decoder)
      self = .message(message)

    case "file_search_call":
      let fileSearch = try OutputItem.FileSearchToolCall(from: decoder)
      self = .fileSearchCall(fileSearch)

    case "function_call":
      let functionCall = try OutputItem.FunctionToolCall(from: decoder)
      self = .functionCall(functionCall)

    case "web_search_call":
      let webSearch = try OutputItem.WebSearchToolCall(from: decoder)
      self = .webSearchCall(webSearch)

    case "computer_call":
      let computerCall = try OutputItem.ComputerToolCall(from: decoder)
      self = .computerCall(computerCall)

    case "reasoning":
      let reasoning = try OutputItem.Reasoning(from: decoder)
      self = .reasoning(reasoning)

    case "image_generation_call":
      let imageGeneration = try OutputItem.ImageGenerationCall(from: decoder)
      self = .imageGenerationCall(imageGeneration)

    case "code_interpreter_call":
      let codeInterpreter = try OutputItem.CodeInterpreterCall(from: decoder)
      self = .codeInterpreterCall(codeInterpreter)

    case "local_shell_call":
      let localShell = try OutputItem.LocalShellCall(from: decoder)
      self = .localShellCall(localShell)

    case "mcp_call":
      let mcpCall = try OutputItem.MCPCall(from: decoder)
      self = .mcpCall(mcpCall)

    case "mcp_list_tools":
      let mcpListTools = try OutputItem.MCPListTools(from: decoder)
      self = .mcpListTools(mcpListTools)

    case "mcp_approval_request":
      let mcpApprovalRequest = try OutputItem.MCPApprovalRequest(from: decoder)
      self = .mcpApprovalRequest(mcpApprovalRequest)

    default:
      throw DecodingError.dataCorruptedError(
        forKey: .type,
        in: container,
        debugDescription: "Unknown stream output item type: \(type)")
    }
  }

  private enum CodingKeys: String, CodingKey {
    case type
  }
}

// MARK: - ContentPart

/// Content part for streaming
public struct ContentPart: Decodable {
  public let type: String
  public let text: String?
  public let annotations: [Any]?

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    type = try container.decode(String.self, forKey: .type)
    text = try container.decodeIfPresent(String.self, forKey: .text)
    annotations = nil // Skip decoding annotations for now
  }

  enum CodingKeys: String, CodingKey {
    case type
    case text
    case annotations
  }
}

// MARK: - SummaryPart

/// Summary part for reasoning
public struct SummaryPart: Decodable {
  public let type: String
  public let text: String
}
