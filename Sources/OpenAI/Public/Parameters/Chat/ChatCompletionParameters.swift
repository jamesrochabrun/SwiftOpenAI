//
//  ChatCompletionParameters.swift
//
//
//  Created by James Rochabrun on 10/10/23.
//

import Foundation

/// [Create chat completion](https://platform.openai.com/docs/api-reference/chat/create)
public struct ChatCompletionParameters: Encodable {
   
   /// A list of messages comprising the conversation so far. [Example Python code](https://cookbook.openai.com/examples/how_to_format_inputs_to_chatgpt_models)
   public var messages: [Message]
   /// ID of the model to use. See the [model endpoint compatibility](https://platform.openai.com/docs/models/how-we-use-your-data) table for details on which models work with the Chat API.
   public var model: String
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
   /// Modify the likelihood of specified tokens appearing in the completion.
   /// Accepts a json object that maps tokens (specified by their token ID in the tokenizer) to an associated bias value from -100 to 100. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token. Defaults to null.
   public var logitBias: [Int: Double]?
   /// The maximum number of [tokens](https://platform.openai.com/tokenizer) to generate in the chat completion.
   /// The total length of input tokens and generated tokens is limited by the model's context length. Example [Python code](https://cookbook.openai.com/examples/how_to_count_tokens_with_tiktoken) for counting tokens.
   /// Defaults to inf
   public var maxTokens: Int?
   /// How many chat completion choices to generate for each input message. Defaults to 1.
   public var n: Int?
   /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics. Defaults to 0
   /// [See more information about frequency and presence penalties.](https://platform.openai.com/docs/guides/gpt/parameter-details)
   public var presencePenalty: Double?
   /// An object specifying the format that the model must output. Used to enable JSON mode.
   /// Setting to `{ type: "json_object" }` enables `JSON` mode, which guarantees the message the model generates is valid JSON.
   ///Important: when using `JSON` mode you must still instruct the model to produce `JSON` yourself via some conversation message, for example via your system message. If you don't do this, the model may generate an unending stream of whitespace until the generation reaches the token limit, which may take a lot of time and give the appearance of a "stuck" request. Also note that the message content may be partial (i.e. cut off) if `finish_reason="length"`, which indicates the generation exceeded `max_tokens` or the conversation exceeded the max context length.
   public var responseFormat: ResponseFormat?
   /// This feature is in `Beta`. If specified, our system will make a best effort to sample deterministically, such that repeated requests with the same `seed` and parameters should return the same result.
   /// Determinism is not guaranteed, and you should refer to the `system_fingerprint` response parameter to monitor changes in the backend.
   public var seed: Int?
   /// Up to 4 sequences where the API will stop generating further tokens. Defaults to null.
   public var stop: [String]?
   /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only [server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format) as they become available, with the stream terminated by a data: [DONE] message. [Example Python code](https://cookbook.openai.com/examples/how_to_stream_completions ).
   /// Defaults to false.
   var stream: Bool? = nil
   /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
   /// We generally recommend altering this or `top_p` but not both. Defaults to 1.
   public var temperature: Double?
   /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
   /// We generally recommend altering this or `temperature` but not both. Defaults to 1
   public var topP: Double?
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
   /// [Learn more](https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids).
   public var user: String?
   
   public struct Message: Encodable {
      
      /// The role of the messages author. One of system, user, assistant, or tool message.
      let role: String
      /// The contents of the message. content is required for all messages, and may be null for assistant messages with function calls.
      let content: ContentType
      /// The name of the author of this message. name is required if role is function, and it should be the name of the function whose response is in the content. May contain a-z, A-Z, 0-9, and underscores, with a maximum length of 64 characters.
      let name: String?
      /// The name and arguments of a function that should be called, as generated by the model.
      @available(*, deprecated, message: "Deprecated and replaced by `tool_calls`")
      let functionCall: FunctionCall?
      /// The tool calls generated by the model, such as function calls.
      let toolCalls: [ToolCall]?
      /// Tool call that this message is responding to.
      let toolCallID: String?
      
      public enum ContentType: Encodable {
         
         case text(String)
         case contentArray([MessageContent])
         
         public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .text(let text):
               try container.encode(text)
            case .contentArray(let contentArray):
               try container.encode(contentArray)
            }
         }
         
         public enum MessageContent: Encodable, Equatable, Hashable {
            
            case text(String)
            case imageUrl(URL)
            
            enum CodingKeys: String, CodingKey {
               case type
               case text
               case imageUrl = "image_url"
            }
            
            public func encode(to encoder: Encoder) throws {
               var container = encoder.container(keyedBy: CodingKeys.self)
               switch self {
               case .text(let text):
                  try container.encode("text", forKey: .type)
                  try container.encode(text, forKey: .text)
               case .imageUrl(let url):
                  try container.encode("image_url", forKey: .type)
                  try container.encode(url, forKey: .imageUrl)
               }
            }
            
            public func hash(into hasher: inout Hasher) {
                switch self {
                case .text(let string):
                    hasher.combine(string)
                case .imageUrl(let url):
                    hasher.combine(url)
                }
            }
            
            public static func ==(lhs: MessageContent, rhs: MessageContent) -> Bool {
                switch (lhs, rhs) {
                case let (.text(a), .text(b)):
                    return a == b
                case let (.imageUrl(a), .imageUrl(b)):
                    return a == b
                default:
                    return false
                }
            }
         }
      }
      
      public enum Role: String {
         case system // content, role
         case user // content, role
         case assistant // content, role, tool_calls
         case tool // content, role, tool_call_id
      }
      
      enum CodingKeys: String, CodingKey {
         case role
         case content
         case name
         case functionCall = "function_call"
         case toolCalls = "tool_calls"
         case toolCallID = "tool_call_id"
      }
      
      public init(
         role: Role,
         content: ContentType,
         name: String? = nil,
         functionCall: FunctionCall? = nil,
         toolCalls: [ToolCall]? = nil,
         toolCallID: String? = nil)
      {
         self.role = role.rawValue
         self.content = content
         self.name = name
         self.functionCall = functionCall
         self.toolCalls = toolCalls
         self.toolCallID = toolCallID
      }
   }
   
   @available(*, deprecated, message: "Deprecated in favor of ToolChoice.")
   public enum FunctionCall: Encodable, Equatable {
      case none
      case auto
      case function(String)
      
      enum CodingKeys: String, CodingKey {
         case none = "none"
         case auto = "auto"
         case function = "name"
      }
      
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
   }
   
   /// string `none` means the model will not call a function and instead generates a message.
   /// `auto` means the model can pick between generating a message or calling a function.
   /// `object` Specifies a tool the model should use. Use to force the model to call a specific function. The type of the tool. Currently, only` function` is supported. `{"type: "function", "function": {"name": "my_function"}}`
   public enum ToolChoice: Encodable, Equatable {
      case none
      case auto
      case function(type: String?, name: String)
      
      enum CodingKeys: String, CodingKey {
         case none = "none"
         case auto = "auto"
         case name = "name"
         case type = "type"
      }
      
      public func encode(to encoder: Encoder) throws {
         switch self {
         case .none:
            var container = encoder.singleValueContainer()
            try container.encode(CodingKeys.none.rawValue)
         case .auto:
            var container = encoder.singleValueContainer()
            try container.encode(CodingKeys.auto.rawValue)
         case .function(let type, let name):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            if let type {
               try container.encode(type, forKey: .type)
            }
         }
      }
   }
   
   public struct Tool: Encodable {
      
      /// The type of the tool. Currently, only `function` is supported.
      let type: String
      /// object
      let function: ChatFunction
      
      public init(
         type: String = "function",
         function: ChatFunction)
      {
         self.type = type
         self.function = function
      }
   }
   
   public struct ChatFunction: Codable, Equatable {
      
      /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
      let name: String
      /// A description of what the function does, used by the model to choose when and how to call the function.
      let description: String?
      /// The parameters the functions accepts, described as a JSON Schema object. See the [guide](https://platform.openai.com/docs/guides/gpt/function-calling) for examples, and the [JSON Schema reference](https://json-schema.org/understanding-json-schema) for documentation about the format.
      /// To describe a function that accepts no parameters, provide the value `{"type": "object", "properties": {}}`.
      let parameters: JSONSchema
      
      public struct JSONSchema: Codable, Equatable {
         
         public let type: JSONType
         public let properties: [String: Property]?
         public let required: [String]?
         public let pattern: String?
         public let const: String?
         public let enumValues: [String]?
         public let multipleOf: Int?
         public let minimum: Int?
         public let maximum: Int?
         
         private enum CodingKeys: String, CodingKey {
            case type, properties, required, pattern, const
            case enumValues = "enum"
            case multipleOf, minimum, maximum
         }
         
         public struct Property: Codable, Equatable {
            
            public let type: JSONType
            public let description: String?
            public let format: String?
            public let items: Items?
            public let required: [String]?
            public let pattern: String?
            public let const: String?
            public let enumValues: [String]?
            public let multipleOf: Int?
            public let minimum: Double?
            public let maximum: Double?
            public let minItems: Int?
            public let maxItems: Int?
            public let uniqueItems: Bool?
            
            private enum CodingKeys: String, CodingKey {
               case type, description, format, items, required, pattern, const
               case enumValues = "enum"
               case multipleOf, minimum, maximum
               case minItems, maxItems, uniqueItems
            }
            
            public init(
               type: JSONType,
               description: String? = nil,
               format: String? = nil,
               items: Items? = nil,
               required: [String]? = nil,
               pattern: String? = nil,
               const: String? = nil,
               enumValues: [String]? = nil,
               multipleOf: Int? = nil,
               minimum: Double? = nil,
               maximum: Double? = nil,
               minItems: Int? = nil,
               maxItems: Int? = nil,
               uniqueItems: Bool? = nil)
            {
               self.type = type
               self.description = description
               self.format = format
               self.items = items
               self.required = required
               self.pattern = pattern
               self.const = const
               self.enumValues = enumValues
               self.multipleOf = multipleOf
               self.minimum = minimum
               self.maximum = maximum
               self.minItems = minItems
               self.maxItems = maxItems
               self.uniqueItems = uniqueItems
            }
         }
         
         public enum JSONType: String, Codable {
            case integer = "integer"
            case string = "string"
            case boolean = "boolean"
            case array = "array"
            case object = "object"
            case number = "number"
            case `null` = "null"
         }
         
         public struct Items: Codable, Equatable {
            
            public let type: JSONType
            public let properties: [String: Property]?
            public let pattern: String?
            public let const: String?
            public let enumValues: [String]?
            public let multipleOf: Int?
            public let minimum: Double?
            public let maximum: Double?
            public let minItems: Int?
            public let maxItems: Int?
            public let uniqueItems: Bool?
            
            private enum CodingKeys: String, CodingKey {
               case type, properties, pattern, const
               case enumValues = "enum"
               case multipleOf, minimum, maximum, minItems, maxItems, uniqueItems
            }
            
            public init(
               type: JSONType,
               properties: [String : Property]? = nil,
               pattern: String? = nil,
               const: String? = nil,
               enumValues: [String]? = nil,
               multipleOf: Int? = nil,
               minimum: Double? = nil,
               maximum: Double? = nil,
               minItems: Int? = nil,
               maxItems: Int? = nil,
               uniqueItems: Bool? = nil)
            {
               self.type = type
               self.properties = properties
               self.pattern = pattern
               self.const = const
               self.enumValues = enumValues
               self.multipleOf = multipleOf
               self.minimum = minimum
               self.maximum = maximum
               self.minItems = minItems
               self.maxItems = maxItems
               self.uniqueItems = uniqueItems
            }
         }
         
         public init(
            type: JSONType,
            properties: [String : Property]? = nil,
            required: [String]? = nil,
            pattern: String? = nil,
            const: String? = nil,
            enumValues: [String]? = nil,
            multipleOf: Int? = nil,
            minimum: Int? = nil,
            maximum: Int? = nil)
         {
            self.type = type
            self.properties = properties
            self.required = required
            self.pattern = pattern
            self.const = const
            self.enumValues = enumValues
            self.multipleOf = multipleOf
            self.minimum = minimum
            self.maximum = maximum
         }
      }
      
      public init(
         name: String,
         description: String?,
         parameters: JSONSchema)
      {
         self.name = name
         self.description = description
         self.parameters = parameters
      }
   }
   
   public struct ResponseFormat: Encodable {
      
      /// Defaults to text
      /// Setting to `json_object` enables JSON mode. This guarantees that the message the model generates is valid JSON.
      /// Note that your system prompt must still instruct the model to produce JSON, and to help ensure you don't forget, the API will throw an error if the string JSON does not appear in your system message.
      /// Also note that the message content may be partial (i.e. cut off) if `finish_reason="length"`, which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
      /// Must be one of `text `or `json_object`.
      public var type: String?
      
      public init(
         type: String?)
      {
         self.type = type
      }
   }
   
   enum CodingKeys: String, CodingKey {
      case messages
      case model
      case frequencyPenalty = "frequency_penalty"
      case toolChoice = "tool_choice"
      case functionCall = "function_call"
      case tools
      case functions
      case logitBias = "logit_bias"
      case maxTokens = "max_tokens"
      case n
      case responseFormat = "response_format"
      case presencePenalty = "presence_penalty"
      case seed
      case stop
      case stream
      case temperature
      case topP = "top_p"
      case user
   }
   
   public init(
      messages: [Message],
      model: Model,
      frequencyPenalty: Double? = nil,
      functionCall: FunctionCall? = nil,
      toolChoice: ToolChoice? = nil,
      functions: [ChatFunction]? = nil,
      tools: [Tool]? = nil,
      logitBias: [Int: Double]? = nil,
      maxTokens: Int? = nil,
      n: Int? = nil,
      responseFormat: ResponseFormat? = nil,
      presencePenalty: Double? = nil,
      seed: Int? = nil,
      stop: [String]? = nil,
      temperature: Double? = nil,
      topProbability: Double? = nil,
      user: String? = nil)
   {
      self.messages = messages
      self.model = model.value
      self.frequencyPenalty = frequencyPenalty
      self.functionCall = functionCall
      self.toolChoice = toolChoice
      self.functions = functions
      self.tools = tools
      self.logitBias = logitBias
      self.maxTokens = maxTokens
      self.n = n
      self.responseFormat = responseFormat
      self.presencePenalty = presencePenalty
      self.seed = seed
      self.stop = stop
      self.temperature = temperature
      self.topP = topProbability
      self.user = user
   }
}
