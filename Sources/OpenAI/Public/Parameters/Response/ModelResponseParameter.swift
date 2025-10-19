//
//  ModelResponseParameter.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

// MARK: ModelResponseParameter

/// [Create a model response](https://platform.openai.com/docs/api-reference/responses/create)
public struct ModelResponseParameter: Codable {
  /// Initialize a new ModelResponseParameter
  public init(
    input: InputType,
    model: Model,
    background: Bool? = nil,
    conversation: Conversation? = nil,
    include: [ResponseInclude]? = nil,
    instructions: String? = nil,
    maxOutputTokens: Int? = nil,
    maxToolCalls: Int? = nil,
    metadata: [String: String]? = nil,
    parallelToolCalls: Bool? = nil,
    previousResponseId: String? = nil,
    prompt: Prompt? = nil,
    promptCacheKey: String? = nil,
    safetyIdentifier: String? = nil,
    reasoning: Reasoning? = nil,
    serviceTier: String? = nil,
    store: Bool? = nil,
    stream: Bool? = nil,
    streamOptions: StreamOptions? = nil,
    temperature: Double? = nil,
    text: TextConfiguration? = nil,
    toolChoice: ToolChoiceMode? = nil,
    tools: [Tool]? = nil,
    topP: Double? = nil,
    topLogprobs: Int? = nil,
    truncation: TruncationStrategy? = nil,
    user: String? = nil)
  {
    self.background = background
    self.conversation = conversation
    self.input = input
    self.model = model.value
    self.include = include?.map(\.rawValue)
    self.instructions = instructions
    self.maxOutputTokens = maxOutputTokens
    self.maxToolCalls = maxToolCalls
    self.metadata = metadata
    self.parallelToolCalls = parallelToolCalls
    self.previousResponseId = previousResponseId
    self.prompt = prompt
    self.promptCacheKey = promptCacheKey
    self.safetyIdentifier = safetyIdentifier
    self.reasoning = reasoning
    self.serviceTier = serviceTier
    self.store = store
    self.stream = stream
    self.streamOptions = streamOptions
    self.temperature = temperature
    self.text = text
    self.toolChoice = toolChoice
    self.tools = tools
    self.topP = topP
    self.topLogprobs = topLogprobs
    self.truncation = truncation?.rawValue
    self.user = user
  }

  /// Audio detail structure
  public struct AudioDetail: Codable {
    public var data: String
    public var format: String

    public init(data: String, format: String) {
      self.data = data
      self.format = format
    }
  }

  /// The truncation strategy to use for the model response
  public enum TruncationStrategy: String {
    /// If the input to this Response exceeds the model's context window size, the model will truncate the response to fit the context window by dropping items from the beginning of the conversation
    case auto

    /// If the input size will exceed the context window size for a model, the request will fail with a 400 error
    case disabled
  }

  /// Defaults to false
  /// Whether to run the model response in the background. Learn more.
  public var background: Bool?

  /// Defaults to null
  /// The conversation that this response belongs to. Items from this conversation are prepended to input_items for this response request. Input items and output items from this response are automatically added to this conversation after this response completes.
  public var conversation: Conversation?

  /// Text, image, or file inputs to the model, used to generate a response.
  /// A text input to the model, equivalent to a text input with the user role.
  /// A list of one or many input items to the [model](https://platform.openai.com/docs/models), containing different content types.
  public var input: InputType

  /// Model ID used to generate the response, like gpt-4o or o1. OpenAI offers a wide range of models with
  /// different capabilities, performance characteristics, and price points.
  /// Refer to the model guide to browse and compare available models.
  public var model: String

  /// Specify additional output data to include in the model response. Currently supported values are:
  /// - web_search_call.action.sources: Include the sources of the web search tool call.
  /// - code_interpreter_call.outputs: Includes the outputs of python code execution in code interpreter tool call items.
  /// - computer_call_output.output.image_url: Include image urls from the computer call output.
  /// - file_search_call.results: Include the search results of the file search tool call.
  /// - message.input_image.image_url: Include image urls from the input message.
  /// - message.output_text.logprobs: Include logprobs with assistant messages.
  /// - reasoning.encrypted_content: Includes an encrypted version of reasoning tokens in reasoning item outputs.
  public var include: [String]?

  /// Inserts a system (or developer) message as the first item in the model's context.
  /// When using along with previous_response_id, the instructions from a previous response will be not be
  /// carried over to the next response. This makes it simple to swap out system (or developer) messages in new responses.
  public var instructions: String?

  /// An upper bound for the number of tokens that can be generated for a response, including visible output tokens
  /// and [reasoning tokens](https://platform.openai.com/docs/guides/reasoning).
  public var maxOutputTokens: Int?

  /// The maximum number of total calls to built-in tools that can be processed in a response. This maximum number applies across all built-in tool calls, not per individual tool. Any further attempts to call a tool by the model will be ignored.
  public var maxToolCalls: Int?

  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information
  /// about the object in a structured format, and querying for objects via API or the dashboard.
  /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
  public var metadata: [String: String]?

  /// Whether to allow the model to run tool calls in parallel.
  /// Defaults to true
  public var parallelToolCalls: Bool?

  /// The unique ID of the previous response to the model. Use this to create multi-turn conversations.
  /// Learn more about [conversation state](https://platform.openai.com/docs/guides/conversation-state)
  public var previousResponseId: String?

  /// Reference to a prompt template and its variables. Learn more.
  public var prompt: Prompt?

  /// Used by OpenAI to cache responses for similar requests to optimize your cache hit rates. Replaces the user field. Learn more.
  public var promptCacheKey: String?

  /// A stable identifier used to help detect users of your application that may be violating OpenAI's usage policies. The IDs should be a string that uniquely identifies each user. We recommend hashing their username or email address, in order to avoid sending us any identifying information. Learn more.
  public var safetyIdentifier: String?

  /// o-series models only
  /// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning)
  public var reasoning: Reasoning?

  /// Defaults to true
  /// Whether to store the generated model response for later retrieval via API.
  public var store: Bool?

  /// Defaults to auto
  /// Specifies the processing type used for serving the request.
  ///
  /// If set to 'auto', then the request will be processed with the service tier configured in the Project settings. Unless otherwise configured, the Project will use 'default'.
  /// If set to 'default', then the request will be processed with the standard pricing and performance for the selected model.
  /// If set to 'flex' or 'priority', then the request will be processed with the corresponding service tier.
  /// When not set, the default behavior is 'auto'.
  /// When the service_tier parameter is set, the response body will include the service_tier value based on the processing mode actually used to serve the request. This response value may be different from the value set in the parameter.
  public var serviceTier: String?

  /// If set to true, the model response data will be streamed to the client as it is generated using [server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#Event_stream_format).
  /// See the [Streaming section below](https://platform.openai.com/docs/api-reference/responses-streaming) for more information.
  public var stream: Bool?

  /// Defaults to null
  /// Options for streaming responses. Only set this when you set stream: true.
  public var streamOptions: StreamOptions?

  /// Defaults to 1
  /// What sampling temperature to use, between 0 and 2.
  /// Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  /// We generally recommend altering this or top_p but not both.
  public var temperature: Double?

  /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
  /// [Text inputs and outputs](https://platform.openai.com/docs/guides/text)
  /// [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
  public var text: TextConfiguration?

  /// How the model should select which tool (or tools) to use when generating a response.
  /// See the tools parameter to see how to specify which tools the model can call.
  public var toolChoice: ToolChoiceMode?

  /// An array of tools the model may call while generating a response. You can specify which tool to use by setting the tool_choice parameter.
  /// The two categories of tools you can provide the model are:
  /// Built-in tools: Tools that are provided by OpenAI that extend the model's capabilities, like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search0. Learn more about [built-in tools](https://platform.openai.com/docs/guides/tools).
  /// Function calls (custom tools): Functions that are defined by you, enabling the model to call your own code. Learn more about [function calling.](https://platform.openai.com/docs/guides/function-calling)
  public var tools: [Tool]?

  /// Defaults to 1
  /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass.
  /// So 0.1 means only the tokens comprising the top 10% probability mass are considered.
  /// We generally recommend altering this or temperature but not both.
  public var topP: Double?

  /// An integer between 0 and 20 specifying the number of most likely tokens to return at each token position, each with an associated log probability.
  public var topLogprobs: Int?

  /// Defaults to disabled
  /// The truncation strategy to use for the model response. See TruncationStrategy enum for available options.
  public var truncation: String?

  /// Deprecated
  /// This field is being replaced by safety_identifier and prompt_cache_key. Use prompt_cache_key instead to maintain caching optimizations. A stable identifier for your end-users. Used to boost cache hit rates by better bucketing similar requests and to help OpenAI detect and prevent abuse. Learn more.
  @available(*, deprecated, message: "This field is being replaced by safety_identifier and prompt_cache_key")
  public var user: String?

  /// Coding keys for ModelResponseParameter
  enum CodingKeys: String, CodingKey {
    case background
    case conversation
    case input
    case model
    case include
    case instructions
    case maxOutputTokens = "max_output_tokens"
    case maxToolCalls = "max_tool_calls"
    case metadata
    case parallelToolCalls = "parallel_tool_calls"
    case previousResponseId = "previous_response_id"
    case prompt
    case promptCacheKey = "prompt_cache_key"
    case safetyIdentifier = "safety_identifier"
    case reasoning
    case serviceTier = "service_tier"
    case store
    case stream
    case streamOptions = "stream_options"
    case temperature
    case text
    case toolChoice = "tool_choice"
    case tools
    case topP = "top_p"
    case topLogprobs = "top_logprobs"
    case truncation
    case user
  }
}
