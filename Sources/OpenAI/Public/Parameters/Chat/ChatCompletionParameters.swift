//
//  ChatCompletionParameters.swift
//
//
//  Created by James Rochabrun on 10/10/23.
//

import Foundation

/// [Create chat completion](https://platform.openai.com/docs/api-reference/chat/create)
/// For Azure available parameters make sure to visit [Azure API reeference](https://learn.microsoft.com/en-us/azure/ai-services/openai/reference)
public struct ChatCompletionParameters: Encodable {
  public init(
    messages: [Message],
    model: Model,
    store: Bool? = nil,
    reasoningEffort: ReasoningEffort? = nil,
    metadata: [String: String]? = nil,
    frequencyPenalty: Double? = nil,
    functionCall: FunctionCall? = nil,
    toolChoice: ToolChoice? = nil,
    functions: [ChatFunction]? = nil,
    tools: [Tool]? = nil,
    parallelToolCalls: Bool? = nil,
    logitBias: [Int: Double]? = nil,
    logProbs: Bool? = nil,
    topLogprobs: Int? = nil,
    maxTokens: Int? = nil,
    n: Int? = nil,
    modalities: [String]? = nil,
    prediction: Prediction? = nil,
    audio: Audio? = nil,
    responseFormat: ResponseFormat? = nil,
    presencePenalty: Double? = nil,
    serviceTier: ServiceTier? = nil,
    seed: Int? = nil,
    stop: [String]? = nil,
    temperature: Double? = nil,
    topProbability: Double? = nil,
    user: String? = nil,
    streamOptions: StreamOptions? = nil)
  {
    self.messages = messages
    self.model = model.value
    self.store = store
    self.reasoningEffort = reasoningEffort?.rawValue
    self.metadata = metadata
    self.frequencyPenalty = frequencyPenalty
    self.functionCall = functionCall
    self.toolChoice = toolChoice
    self.functions = functions
    self.tools = tools
    self.parallelToolCalls = parallelToolCalls
    self.logitBias = logitBias
    logprobs = logProbs
    self.topLogprobs = topLogprobs
    self.maxTokens = maxTokens
    self.n = n
    self.modalities = modalities
    self.prediction = prediction
    self.audio = audio
    self.responseFormat = responseFormat
    self.presencePenalty = presencePenalty
    self.serviceTier = serviceTier?.rawValue
    self.seed = seed
    self.stop = stop
    self.temperature = temperature
    topP = topProbability
    self.user = user
    self.streamOptions = streamOptions
  }

  public struct Message: Encodable {
    public init(
      role: Role,
      content: ContentType,
      refusal: String? = nil,
      name: String? = nil,
      audio: Audio? = nil,
      functionCall: FunctionCall? = nil,
      toolCalls: [ToolCall]? = nil,
      toolCallID: String? = nil)
    {
      self.role = role.rawValue
      self.content = content
      self.refusal = refusal
      self.name = name
      self.audio = audio
      self.functionCall = functionCall
      self.toolCalls = toolCalls
      self.toolCallID = toolCallID
    }

    public enum ContentType: Encodable {
      case text(String)
      case contentArray([MessageContent])

      public enum MessageContent: Encodable, Equatable, Hashable {
        case text(String)
        case imageUrl(ImageDetail)
        case inputAudio(AudioDetail)

        public struct ImageDetail: Encodable, Equatable, Hashable {
          public let url: URL
          public let detail: String?

          enum CodingKeys: String, CodingKey {
            case url
            case detail
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(url, forKey: .url)
            try container.encodeIfPresent(detail, forKey: .detail)
          }

          public init(url: URL, detail: String? = nil) {
            self.url = url
            self.detail = detail
          }
        }

        public struct AudioDetail: Encodable, Equatable, Hashable {
          public let data: String
          public let format: String

          enum CodingKeys: String, CodingKey {
            case data
            case format
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(data, forKey: .data)
            try container.encode(format, forKey: .format)
          }

          public init(data: String, format: String) {
            self.data = data
            self.format = format
          }
        }

        public static func ==(lhs: MessageContent, rhs: MessageContent) -> Bool {
          switch (lhs, rhs) {
          case (.text(let a), .text(let b)):
            a == b
          case (.imageUrl(let a), .imageUrl(let b)):
            a == b
          case (.inputAudio(let a), .inputAudio(let b)):
            a == b
          default:
            false
          }
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          switch self {
          case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)

          case .imageUrl(let imageDetail):
            try container.encode("image_url", forKey: .type)
            try container.encode(imageDetail, forKey: .imageUrl)

          case .inputAudio(let audioDetail):
            try container.encode("input_audio", forKey: .type)
            try container.encode(audioDetail, forKey: .inputAudio)
          }
        }

        public func hash(into hasher: inout Hasher) {
          switch self {
          case .text(let string):
            hasher.combine(string)
          case .imageUrl(let imageDetail):
            hasher.combine(imageDetail)
          case .inputAudio(let audioDetail):
            hasher.combine(audioDetail)
          }
        }

        enum CodingKeys: String, CodingKey {
          case type
          case text
          case imageUrl = "image_url"
          case inputAudio = "input_audio"
        }
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let text):
          try container.encode(text)
        case .contentArray(let contentArray):
          try container.encode(contentArray)
        }
      }
    }

    public enum Role: String {
      case system // content, role
      case user // content, role
      case assistant // content, role, tool_calls
      case tool // content, role, tool_call_id
    }

    public struct Audio: Encodable {
      /// Unique identifier for a previous audio response from the model.
      public let id: String

      public init(id: String) {
        self.id = id
      }
    }

    /// The contents of the message. content is required for all messages, and may be null for assistant messages with function calls.
    public let content: ContentType
    /// The refusal message by the assistant.
    public let refusal: String?
    /// The role of the messages author. One of system, user, assistant, or tool message.
    public let role: String
    /// The name of the author of this message. name is required if role is function, and it should be the name of the function whose response is in the content. May contain a-z, A-Z, 0-9, and underscores, with a maximum length of 64 characters.
    public let name: String?
    /// Data about a previous audio response from the model. [Learn more.](https://platform.openai.com/docs/guides/audio)
    public let audio: Audio?

    enum CodingKeys: String, CodingKey {
      case role
      case content
      case refusal
      case name
      case audio
      case functionCall = "function_call"
      case toolCalls = "tool_calls"
      case toolCallID = "tool_call_id"
    }

    /// The name and arguments of a function that should be called, as generated by the model.
    @available(*, deprecated, message: "Deprecated and replaced by `tool_calls`")
    let functionCall: FunctionCall?
    /// The tool calls generated by the model, such as function calls.
    let toolCalls: [ToolCall]?
    /// Tool call that this message is responding to.
    let toolCallID: String?
  }

  @available(*, deprecated, message: "Deprecated in favor of ToolChoice.")
  public enum FunctionCall: Encodable, Equatable {
    case none
    case auto
    case function(String)

    public func encode(to encoder: Encoder) throws {
      switch self {
      case .none:
        var container = encoder.singleValueContainer()
        try container.encode(CodingKeys.none.rawValue)

      case .auto:
        var container = encoder.singleValueContainer()
        try container.encode(CodingKeys.auto.rawValue)

      case .function(let name):
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .function)
      }
    }

    enum CodingKeys: String, CodingKey {
      case none
      case auto
      case function = "name"
    }
  }

  /// [Documentation](https://platform.openai.com/docs/api-reference/chat/create#chat-create-tools)
  public struct Tool: Encodable {
    /// The type of the tool. Currently, only `function` is supported.
    public let type: String
    /// object
    public let function: ChatFunction

    public init(
      type: String = "function",
      function: ChatFunction)
    {
      self.type = type
      self.function = function
    }
  }

  public struct ChatFunction: Codable, Equatable {
    public init(
      name: String,
      strict: Bool?,
      description: String?,
      parameters: JSONSchema?)
    {
      self.name = name
      self.strict = strict
      self.description = description
      self.parameters = parameters
    }

    /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
    public let name: String
    /// A description of what the function does, used by the model to choose when and how to call the function.
    public let description: String?
    /// The parameters the functions accepts, described as a JSON Schema object. See the [guide](https://platform.openai.com/docs/guides/gpt/function-calling) for examples, and the [JSON Schema reference](https://json-schema.org/understanding-json-schema) for documentation about the format.
    /// Omitting parameters defines a function with an empty parameter list.
    public let parameters: JSONSchema?
    /// Defaults to false, Whether to enable strict schema adherence when generating the function call. If set to true, the model will follow the exact schema defined in the parameters field. Only a subset of JSON Schema is supported when strict is true. Learn more about Structured Outputs in the [function calling guide].(https://platform.openai.com/docs/api-reference/chat/docs/guides/function-calling)
    public let strict: Bool?
  }

  public enum ServiceTier: String, Encodable {
    /// Specifies the latency tier to use for processing the request. This parameter is relevant for customers subscribed to the scale tier service:
    /// If set to 'auto', the system will utilize scale tier credits until they are exhausted.
    /// If set to 'default', the request will be processed in the shared cluster.
    /// When this parameter is set, the response body will include the service_tier utilized.
    case auto
    case `default`
  }

  public struct StreamOptions: Encodable {
    /// If set, an additional chunk will be streamed before the data: [DONE] message.
    /// The usage field on this chunk shows the token usage statistics for the entire request,
    /// and the choices field will always be an empty array. All other chunks will also include
    /// a usage field, but with a null value.
    let includeUsage: Bool

    enum CodingKeys: String, CodingKey {
      case includeUsage = "include_usage"
    }

    public init(includeUsage: Bool) {
      self.includeUsage = includeUsage
    }
  }

  /// Parameters for audio output. Required when audio output is requested with modalities: ["audio"]
  /// [Learn more.](https://platform.openai.com/docs/guides/audio)
  public struct Audio: Encodable {
    /// Specifies the voice type. Supported voices are alloy, echo, fable, onyx, nova, and shimmer.
    public let voice: String
    /// Specifies the output audio format. Must be one of wav, mp3, flac, opus, or pcm16.
    public let format: String

    public init(
      voice: String,
      format: String)
    {
      self.voice = voice
      self.format = format
    }
  }

  public struct Prediction: Encodable {
    public init(content: PredictionContent, type: String = "content") {
      self.type = type
      self.content = content
    }

    public enum PredictionContent: Encodable {
      case text(String)
      case contentArray([ContentPart])

      public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let text):
          try container.encode(text)
        case .contentArray(let parts):
          try container.encode(parts)
        }
      }
    }

    public struct ContentPart: Encodable {
      public let type: String
      public let text: String

      public init(type: String, text: String) {
        self.type = type
        self.text = text
      }
    }

    public let type: String
    public let content: PredictionContent
  }

  public enum ReasoningEffort: String, Encodable {
    case low
    case medium
    case high
  }

  /// A list of messages comprising the conversation so far. [Example Python code](https://cookbook.openai.com/examples/how_to_format_inputs_to_chatgpt_models)
  public var messages: [Message]
  /// ID of the model to use. See the [model endpoint compatibility](https://platform.openai.com/docs/models/how-we-use-your-data) table for details on which models work with the Chat API.
  public var model: String
  /// Whether or not to store the output of this chat completion request for use in our [model distillation](https://platform.openai.com/docs/guides/distillation) or [evals](https://platform.openai.com/docs/guides/evals) products.
  /// Defaults to false
  public var store: Bool?
  /// Constrains effort on reasoning for [reasoning models](https://platform.openai.com/docs/guides/reasoning). Currently supported values are low, medium, and high. Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
  /// Defaults to medium o1 models only
  public var reasoningEffort: String?
  /// Developer-defined tags and values used for filtering completions in the [dashboard](https://platform.openai.com/chat-completions).
  public var metadata: [String: String]?
  /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim. Defaults to 0
  /// [See more information about frequency and presence penalties.](https://platform.openai.com/docs/guides/gpt/parameter-details)
  public var frequencyPenalty: Double?
  /// Controls how the model responds to function calls. none means the model does not call a function, and responds to the end-user. auto means the model can pick between an end-user or calling a function. Specifying a particular function via {"name": "my_function"} forces the model to call that function. none is the default when no functions are present. auto is the default if functions are present.
  @available(*, deprecated, message: "Deprecated in favor of tool_choice.")
  public var functionCall: FunctionCall?
  /// Controls which (if any) function is called by the model. none means the model will not call a function and instead generates a message.
  /// auto means the model can pick between generating a message or calling a function. Specifying a particular function via `{"type: "function", "function": {"name": "my_function"}}` forces the model to call that function.
  /// `none` is the default when no functions are present. auto is the default if functions are present.
  public var toolChoice: ToolChoice?
  /// A list of functions the model may generate JSON inputs for.
  @available(*, deprecated, message: "Deprecated in favor of tools.")
  public var functions: [ChatFunction]?
  /// A list of tools the model may call. Currently, only functions are supported as a tool. Use this to provide a list of functions the model may generate JSON inputs for.
  public var tools: [Tool]?
  /// Whether to enable parallel function calling during tool use. Defaults to true.
  public var parallelToolCalls: Bool?
  /// Modify the likelihood of specified tokens appearing in the completion.
  /// Accepts a json object that maps tokens (specified by their token ID in the tokenizer) to an associated bias value from -100 to 100. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token. Defaults to null.
  public var logitBias: [Int: Double]?
  /// Whether to return log probabilities of the output tokens or not. If true, returns the log probabilities of each output token returned in the content of message. This option is currently not available on the gpt-4-vision-preview model. Defaults to false.
  public var logprobs: Bool?
  /// An integer between 0 and 5 specifying the number of most likely tokens to return at each token position, each with an associated log probability. logprobs must be set to true if this parameter is used.
  public var topLogprobs: Int?
  /// The maximum number of [tokens](https://platform.openai.com/tokenizer) that can be generated in the chat completion. This value can be used to control [costs](https://openai.com/api/pricing/) for text generated via API.
  /// This value is now deprecated in favor of max_completion_tokens, and is not compatible with [o1 series models](https://platform.openai.com/docs/guides/reasoning)
  public var maxTokens: Int?
  /// An upper bound for the number of tokens that can be generated for a completion, including visible output tokens and [reasoning tokens](https://platform.openai.com/docs/guides/reasoning)
  public var maCompletionTokens: Int?
  /// How many chat completion choices to generate for each input message. Defaults to 1.
  public var n: Int?
  /// Output types that you would like the model to generate for this request. Most models are capable of generating text, which is the default:
  /// ["text"]
  /// The gpt-4o-audio-preview model can also be used to [generate audio](https://platform.openai.com/docs/guides/audio). To request that this model generate both text and audio responses, you can use:
  /// ["text", "audio"]
  public var modalities: [String]?
  /// Configuration for a [Predicted Output](https://platform.openai.com/docs/guides/predicted-outputs), which can greatly improve response times when large parts of the model response are known ahead of time. This is most common when you are regenerating a file with only minor changes to most of the content.
  public var prediction: Prediction?
  /// Parameters for audio output. Required when audio output is requested with modalities: ["audio"]. [Learn more.](https://platform.openai.com/docs/guides/audio)
  public var audio: Audio?
  /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics. Defaults to 0
  /// [See more information about frequency and presence penalties.](https://platform.openai.com/docs/guides/gpt/parameter-details)
  public var presencePenalty: Double?
  /// An object specifying the format that the model must output. Used to enable JSON mode.
  /// Setting to `{ type: "json_object" }` enables `JSON` mode, which guarantees the message the model generates is valid JSON.
  /// Important: when using `JSON` mode you must still instruct the model to produce `JSON` yourself via some conversation message, for example via your system message. If you don't do this, the model may generate an unending stream of whitespace until the generation reaches the token limit, which may take a lot of time and give the appearance of a "stuck" request. Also note that the message content may be partial (i.e. cut off) if `finish_reason="length"`, which indicates the generation exceeded `max_tokens` or the conversation exceeded the max context length.
  public var responseFormat: ResponseFormat?
  /// Specifies the latency tier to use for processing the request. This parameter is relevant for customers subscribed to the scale tier service:
  /// If set to 'auto', the system will utilize scale tier credits until they are exhausted.
  /// If set to 'default', the request will be processed in the shared cluster.
  /// When this parameter is set, the response body will include the service_tier utilized.
  public var serviceTier: String?
  /// This feature is in `Beta`. If specified, our system will make a best effort to sample deterministically, such that repeated requests with the same `seed` and parameters should return the same result.
  /// Determinism is not guaranteed, and you should refer to the `system_fingerprint` response parameter to monitor changes in the backend.
  public var seed: Int?
  /// Up to 4 sequences where the API will stop generating further tokens. Defaults to null.
  public var stop: [String]?
  /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  /// We generally recommend altering this or `top_p` but not both. Defaults to 1.
  public var temperature: Double?
  /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
  /// We generally recommend altering this or `temperature` but not both. Defaults to 1
  public var topP: Double?
  /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
  /// [Learn more](https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids).
  public var user: String?

  enum CodingKeys: String, CodingKey {
    case messages
    case model
    case store
    case reasoningEffort = "reasoning_effort"
    case metadata
    case frequencyPenalty = "frequency_penalty"
    case toolChoice = "tool_choice"
    case functionCall = "function_call"
    case tools
    case parallelToolCalls = "parallel_tool_calls"
    case functions
    case logitBias = "logit_bias"
    case logprobs
    case topLogprobs = "top_logprobs"
    case maxTokens = "max_tokens"
    case maCompletionTokens = "max_completion_tokens"
    case n
    case modalities
    case prediction
    case audio
    case responseFormat = "response_format"
    case presencePenalty = "presence_penalty"
    case seed
    case serviceTier = "service_tier"
    case stop
    case stream
    case streamOptions = "stream_options"
    case temperature
    case topP = "top_p"
    case user
  }

  /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only [server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format) as they become available, with the stream terminated by a data: [DONE] message. [Example Python code](https://cookbook.openai.com/examples/how_to_stream_completions ).
  /// Defaults to false.
  var stream: Bool? = nil
  /// Options for streaming response. Only set this when you set stream: true
  var streamOptions: StreamOptions?
}
