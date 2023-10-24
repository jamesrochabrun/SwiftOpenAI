# SwiftOpenAI
<img width="1090" alt="repoOpenAI" src="https://github.com/jamesrochabrun/SwiftOpenAI/assets/5378604/51bc5736-a32f-4a9f-922e-209d950e28f7">

![iOS 15+](https://img.shields.io/badge/iOS-15%2B-blue.svg)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
[![swift-version](https://img.shields.io/badge/swift-5.9-brightgreen.svg)](https://github.com/apple/swift)
[![swiftui-version](https://img.shields.io/badge/swiftui-brightgreen)](https://developer.apple.com/documentation/swiftui)
[![xcode-version](https://img.shields.io/badge/xcode-15%20-brightgreen)](https://developer.apple.com/xcode/)
[![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)

An open-source Swift package designed for effortless interaction with OpenAI's public API. 

## Table of Contents
- [Description](#description)
- [Getting an API Key](#getting-an-api-key)
- [Installation](#installation)
- [Usage](#usage)

## Description

`SwiftOpenAI` is an open-source Swift package that streamlines interactions with **all** OpenAI's API endpoints.

### OpenAI ENDPOINTS

- [Audio](#audio)
- [Chat](#chat)
- [Embeddings](#embeddings)
- [Fine-tuning](#fine-tuning)
- [Files](#files)
- [Images](#images)
- [Models](#models)
- [Moderations](#moderations)

## Getting an API Key

⚠️ **Important**

To interact with OpenAI services, you'll need an API key. Follow these steps to obtain one:

1. Visit [OpenAI](https://www.openai.com/).
2. Sign up for an [account](https://platform.openai.com/signup) or [log in](https://platform.openai.com/login) if you already have one.
3. Navigate to the [API key page](https://platform.openai.com/account/api-keys) and follow the instructions to generate a new API key.

For more information, consult OpenAI's [official documentation](https://platform.openai.com/docs/).

## Installation

### Swift Package Manager

1. Open your Swift project in Xcode.
2. Go to `File` ->  `Add Package Dependency`.
3. In the search bar, enter [this URL](https://github.com/jamesrochabrun/SwiftOpenAI).
4. Choose the version you'd like to install.
5. Click `Add Package`.

## Usage

To use SwiftOpenAI in your project, first import the package:

```swift
import SwiftOpenAI
```

Then, initialize the service using your OpenAI API key:

```swift
let apiKey = "your_openai_api_key_here"
let service = OpenAIServiceFactory.service(apiKey: apiKey)
```

You can optionally specify an organization name if needed.

```swift
let apiKey = "your_openai_api_key_here"
let oganizationID = "your_organixation_id"
let service = OpenAIServiceFactory.service(apiKey: apiKey, organizationID: oganizationID)
```

That's all you need to begin accessing the full range of OpenAI endpoints.

### Audio

#### Audio Transcriptions
Parameters
```swift
public struct AudioTranscriptionParameters: Encodable {
   
   /// The name of the file asset is not documented in OpenAI's official documentation; however, it is essential for constructing the multipart request.
   let fileName: String
   /// The audio file object (not file name) translate, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
   let file: Data
   /// ID of the model to use. Only whisper-1 is currently available.
   let model: String
   /// The language of the input audio. Supplying the input language in [ISO-639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) format will improve accuracy and latency.
   let language: String?
   /// An optional text to guide the model's style or continue a previous audio segment. The [prompt](https://platform.openai.com/docs/guides/speech-to-text/prompting) should match the audio language.
   let prompt: String?
   /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt. Defaults to json
   let responseFormat: String?
   /// The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use [log probability](https://en.wikipedia.org/wiki/Log_probability) to automatically increase the temperature until certain thresholds are hit. Defaults to 0
   let temperature: Double?
   
   public enum Model: String {
      case whisperOne = "whisper-1"
   }
   
   enum CodingKeys: String, CodingKey {
      case file
      case model
      case prompt
      case responseFormat = "response_format"
      case temperature
      case language
   }
   
   public init(
      fileName: String,
      file: Data,
      model: Model = .whisperOne,
      prompt: String? = nil,
      responseFormat: String? = nil,
      temperature: Double? = nil,
      language: String? = nil)
   {
      self.fileName = fileName
      self.file = file
      self.model = model.rawValue
      self.prompt = prompt
      self.responseFormat = responseFormat
      self.temperature = temperature
      self.language = language
   }
}
```

Response
```swift
public struct AudioObject: Decodable {
   
   /// The transcribed text if the request uses the `transcriptions` API, or the translated text if the request uses the `translations` endpoint.
   public let text: String
}
```

Usage
```swift
let fileName = "narcos.m4a"
let data = Data(contentsOfURL:_) // Data retrieved from the file named "narcos.m4a".
let parameters = AudioTranscriptionParameters(fileName: fileName, file: data) // **Important**: in the file name always provide the file extension.
let audioObject =  try await service.createTranscription(parameters: parameters)
```
#### Audio Translations
Parameters
```swift
public struct AudioTranslationParameters: Encodable {
   
   /// The name of the file asset is not documented in OpenAI's official documentation; however, it is essential for constructing the multipart request.
   let fileName: String
   /// The audio file object (not file name) translate, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
   let file: Data
   /// ID of the model to use. Only whisper-1 is currently available.
   let model: String
   /// An optional text to guide the model's style or continue a previous audio segment. The [prompt](https://platform.openai.com/docs/guides/speech-to-text/prompting) should match the audio language.
   let prompt: String?
   /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt. Defaults to json
   let responseFormat: String?
   /// The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use [log probability](https://en.wikipedia.org/wiki/Log_probability) to automatically increase the temperature until certain thresholds are hit. Defaults to 0
   let temperature: Double?
   
   public enum Model: String {
      case whisperOne = "whisper-1"
   }
   
   enum CodingKeys: String, CodingKey {
      case file
      case model
      case prompt
      case responseFormat = "response_format"
      case temperature
   }
   
   public init(
      fileName: String,
      file: Data,
      model: Model = .whisperOne,
      prompt: String? = nil,
      responseFormat: String? = nil,
      temperature: Double? = nil)
   {
      self.fileName = fileName
      self.file = file
      self.model = model.rawValue
      self.prompt = prompt
      self.responseFormat = responseFormat
      self.temperature = temperature
   }
}
```

Response
```swift
public struct AudioObject: Decodable {
   
   /// The transcribed text if the request uses the `transcriptions` API, or the translated text if the request uses the `translations` endpoint.
   public let text: String
}
```

Usage
```swift
let fileName = "german.m4a"
let data = Data(contentsOfURL:_) // Data retrieved from the file named "german.m4a".
let parameters = AudioTranslationParameters(fileName: fileName, file: data) // **Important**: in the file name always provide the file extension.
let audioObject = try await service.createTranslation(parameters: parameters)
```

### Chat
Parameters
```swift
/// [Create chat completion](https://platform.openai.com/docs/api-reference/chat/create)
public struct ChatCompletionParameters: Encodable {
   
   /// A list of messages comprising the conversation so far. [Example Python code](https://cookbook.openai.com/examples/how_to_format_inputs_to_chatgpt_models)
   let messages: [Message]
   /// ID of the model to use. See the [model endpoint compatibility](https://platform.openai.com/docs/models/how-we-use-your-data) table for details on which models work with the Chat API.
   let model: String
   /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim. Defaults to 0
   /// [See more information about frequency and presence penalties.](https://platform.openai.com/docs/guides/gpt/parameter-details)
   let frequencyPenalty: Double?
   /// Controls how the model responds to function calls. none means the model does not call a function, and responds to the end-user. auto means the model can pick between an end-user or calling a function. Specifying a particular function via {"name": "my_function"} forces the model to call that function. none is the default when no functions are present. auto is the default if functions are present.
   let functionCall: FunctionCall?
   /// A list of functions the model may generate JSON inputs for.
   let functions: [ChatFunction]?
   /// Modify the likelihood of specified tokens appearing in the completion.
   /// Accepts a json object that maps tokens (specified by their token ID in the tokenizer) to an associated bias value from -100 to 100. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token. Defaults to null.
   let logitBias: [Int: Double]?
   /// The maximum number of [tokens](https://platform.openai.com/tokenizer) to generate in the chat completion.
   /// The total length of input tokens and generated tokens is limited by the model's context length. Example [Python code](https://cookbook.openai.com/examples/how_to_count_tokens_with_tiktoken) for counting tokens.
   /// Defaults to inf
   let maxTokens: Int?
   /// How many chat completion choices to generate for each input message. Defaults to 1.
   let n: Int?
   /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics. Defaults to 0
   /// [See more information about frequency and presence penalties.](https://platform.openai.com/docs/guides/gpt/parameter-details)
   let presencePenalty: Double?
   /// Up to 4 sequences where the API will stop generating further tokens. Defaults to null.
   let stop: [String]?
   /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only [server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format) as they become available, with the stream terminated by a data: [DONE] message. [Example Python code](https://cookbook.openai.com/examples/how_to_stream_completions ).
   /// Defaults to false.
   var stream: Bool? = nil
   /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
   /// We generally recommend altering this or `top_p` but not both. Defaults to 1.
   let temperature: Double?
   /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
   /// We generally recommend altering this or `temperature` but not both. Defaults to 1
   let topP: Double?
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
   /// [Learn more](https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids).
   let user: String?
   
   public enum Model: String {
      case gpt35Turbo = "gpt-3.5-turbo"
      case gpt4 = "gpt-4"
      case gpt35Turbo0613 = "gpt-3.5-turbo-0613"
      case gpt35Turbo16k0613 = "gpt-3.5-turbo-16k-0613"
   }
   
   public struct Message: Encodable {
      
      /// The role of the messages author. One of system, user, assistant, or function.
      let role: String
      /// The contents of the message. content is required for all messages, and may be null for assistant messages with function calls.
      let content: String
      /// The name of the author of this message. name is required if role is function, and it should be the name of the function whose response is in the content. May contain a-z, A-Z, 0-9, and underscores, with a maximum length of 64 characters.
      let name: String?
      /// The name and arguments of a function that should be called, as generated by the model.
      let functionCall: FunctionCall?
      
      public enum Role: String {
         case system
         case user
         case assistant
         case function
      }
      
      public struct FunctionCall: Encodable {
         
         /// The arguments to call the function with, as generated by the model in JSON format. Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema. Validate the arguments in your code before calling your function.
         let arguments: String
         /// The name of the function to call.
         let name: String
      }
      
      enum CodingKeys: String, CodingKey {
         case role
         case content
         case name
         case functionCall = "function_call"
      }
      
      public init(
         role: Role,
         content: String,
         name: String? = nil,
         functionCall: FunctionCall? = nil)
      {
         self.role = role.rawValue
         self.content = content
         self.name = name
         self.functionCall = functionCall
      }
   }
   
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
   
   public struct ChatFunction: Encodable, Equatable {
      
      /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
      let name: String
      /// A description of what the function does, used by the model to choose when and how to call the function.
      let description: String?
      /// The parameters the functions accepts, described as a JSON Schema object. See the [guide](https://platform.openai.com/docs/guides/gpt/function-calling) for examples, and the [JSON Schema reference](https://json-schema.org/understanding-json-schema) for documentation about the format.
      /// To describe a function that accepts no parameters, provide the value `{"type": "object", "properties": {}}`.
      let parameters: JSONSchema
      
      public struct JSONSchema: Encodable, Equatable {
         
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
         
         public struct Property: Encodable, Equatable {
            
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
         
         public enum JSONType: String, Encodable {
            case integer = "integer"
            case string = "string"
            case boolean = "boolean"
            case array = "array"
            case object = "object"
            case number = "number"
            case `null` = "null"
         }
         
         public struct Items: Encodable, Equatable {
            
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
   }
   
   enum CodingKeys: String, CodingKey {
      case messages
      case model
      case frequencyPenalty = "frequency_penalty"
      case functionCall = "function_call"
      case functions
      case logitBias = "logit_bias"
      case maxTokens = "max_tokens"
      case n
      case presencePenalty = "presence_penalty"
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
      functions: [ChatFunction]? = nil,
      logitBias: [Int: Double]? = nil,
      maxTokens: Int? = nil,
      n: Int? = nil,
      presencePenalty: Double? = nil,
      stop: [String]? = nil,
      temperature: Double? = nil,
      topProbability: Double? = nil,
      user: String? = nil)
   {
      self.messages = messages
      self.model = model.rawValue
      self.frequencyPenalty = frequencyPenalty
      self.functionCall = functionCall
      self.functions = functions
      self.logitBias = logitBias
      self.maxTokens = maxTokens
      self.n = n
      self.presencePenalty = presencePenalty
      self.stop = stop
      self.temperature = temperature
      self.topP = topProbability
      self.user = user
   }
}
```

Response
### Chat completion object
```swift
/// Represents a chat [completion](https://platform.openai.com/docs/api-reference/chat/object) response returned by model, based on the provided input.
public struct ChatCompletionObject: Decodable {
   
   /// A unique identifier for the chat completion.
   public let id: String
   /// A list of chat completion choices. Can be more than one if n is greater than 1.
   public let choices: [ChatChoice]
   /// The Unix timestamp (in seconds) of when the chat completion was created.
   public let created: Int
   /// The model used for the chat completion.
   public let model: String
   /// The object type, which is always chat.completion.
   public let object: String
   /// Usage statistics for the completion request.
   public let usage: ChatUsage
   
   public struct ChatChoice: Decodable {
      
      /// The reason the model stopped generating tokens. This will be stop if the model hit a natural stop point or a provided stop sequence, length if the maximum number of tokens specified in the request was reached, content_filter if content was omitted due to a flag from our content filters, or function_call if the model called a function.
      public let finishReason: IntOrStringValue
      /// The index of the choice in the list of choices.
      public let index: Int
      /// A chat completion message generated by the model.
      public let message: ChatMessage
      
      public struct ChatMessage: Decodable {
         
         /// The contents of the message.
         public let content: String?
         /// The name and arguments of a function that should be called, as generated by the model.
         public let functionCall: FunctionCall?
         /// The role of the author of this message.
         public let role: String
         
         public struct FunctionCall: Codable {
            /// The name of the function to call.
            public let name: String
            /// The arguments to call the function with, as generated by the model in JSON format. Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema. Validate the arguments in your code before calling your function.
            public let arguments: String
         }
         
         enum CodingKeys: String, CodingKey {
            case content
            case functionCall = "function_call"
            case role
         }
      }
      
      enum CodingKeys: String, CodingKey {
         case finishReason = "finish_reason"
         case index
         case message
      }
   }
   
   public struct ChatUsage: Decodable {
      
      /// Number of tokens in the generated completion.
      public let completionTokens: Int
      /// Number of tokens in the prompt.
      public let promptTokens: Int
      /// Total number of tokens used in the request (prompt + completion).
      public let totalTokens: Int
      
      enum CodingKeys: String, CodingKey {
         case completionTokens = "completion_tokens"
         case promptTokens = "prompt_tokens"
         case totalTokens = "total_tokens"
      }
   }
}
```

Usage
```swift
let prompt = "Tell me a joke"
let parameters = ChatCompletionParameters(messages: [.init(role: .assistant, content: prompt)], model: .gpt35Turbo)
let chatCompletionObject = service.startChat(parameters: parameters)
```

Response
### Chat completion chunk object
```swift
/// Represents a [streamed](https://platform.openai.com/docs/api-reference/chat/streaming) chunk of a chat completion response returned by model, based on the provided input.
public struct ChatCompletionChunkObject: Decodable {
   
   /// A unique identifier for the chat completion chunk.
   public let id: String
   /// A list of chat completion choices. Can be more than one if n is greater than 1.
   public let choices: [ChatChoice]
   /// The Unix timestamp (in seconds) of when the chat completion chunk was created.
   public let created: Int
   /// The model to generate the completion.
   public let model: String
   /// The object type, which is always chat.completion.chunk.
   public let object: String
   
   public struct ChatChoice: Decodable {
      
      /// A chat completion delta generated by streamed model responses.
      public let delta: Delta
      /// The reason the model stopped generating tokens. This will be stop if the model hit a natural stop point or a provided stop sequence, length if the maximum number of tokens specified in the request was reached, content_filter if content was omitted due to a flag from our content filters, or function_call if the model called a function.
      public let finishReason: IntOrStringValue?
      /// The index of the choice in the list of choices.
      public let index: Int
      
      public struct Delta: Decodable {
         
         /// The contents of the chunk message.
         public let content: String?
         /// The name and arguments of a function that should be called, as generated by the model.
         public let functionCall: FunctionCall?
         /// The role of the author of this message.
         public let role: String?
         
         public struct FunctionCall: Decodable {
            
            /// The arguments to call the function with, as generated by the model in JSON format. Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema. Validate the arguments in your code before calling your function.
            public let arguments: String
            /// The name of the function to call.
            public let name: String
         }
         
         enum CodingKeys: String, CodingKey {
            case content
            case functionCall = "function_call"
            case role
         }
      }
      
      enum CodingKeys: String, CodingKey {
         case delta
         case finishReason = "finish_reason"
         case index
      }
   }
}
```
Usage
```swift
let prompt = "Tell me a joke"
let parameters = ChatCompletionParameters(messages: [.init(role: .assistant, content: prompt)], model: .gpt35Turbo)
let chatCompletionObject = try await service.startStreamedChat(parameters: parameters)
```

### Embeddings
Parameters
```swift
/// [Creates](https://platform.openai.com/docs/api-reference/embeddings/create) an embedding vector representing the input text.
public struct EmbeddingParameter: Encodable {
   
   /// ID of the model to use. You can use the List models API to see all of your available models, or see our [Model overview ](https://platform.openai.com/docs/models/overview) for descriptions of them.
   let model: String
   /// Input text to embed, encoded as a string or array of tokens. To embed multiple inputs in a single request, pass an array of strings or an array of token arrays. Each input must not exceed the max input tokens for the model (8191 tokens for text-embedding-ada-002) and cannot be an empty string. [How to Count Tokens with `tiktoken`](https://cookbook.openai.com/examples/how_to_count_tokens_with_tiktoken)
   let input: String
   
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more.](https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids)
   let user: String?
   
   public enum Model: String {
      case textEmbeddingAda002 = "text-embedding-ada-002"
   }
   
   public init(
      model: Model = .textEmbeddingAda002,
      input: String,
      user: String? = nil)
   {
      self.model = model.rawValue
      self.input = input
      self.user = user
   }
}
```
Response
```swift
/// [Represents an embedding vector returned by embedding endpoint.](https://platform.openai.com/docs/api-reference/embeddings/object)
public struct EmbeddingObject: Decodable {
   
   /// The object type, which is always "embedding".
   public let object: String
   /// The embedding vector, which is a list of floats. The length of vector depends on the model as listed in the embedding guide.[https://platform.openai.com/docs/guides/embeddings]
   public let embedding: [Float]
   /// The index of the embedding in the list of embeddings.
   public let index: Int
}
```

Usage
```swift
let prompt = "Hello world."
let embeddingObjects = try await service.createEmbeddings(parameters: parameters).data
```

### Fine-tuning
Parameters
```swift
/// [Creates a job](https://platform.openai.com/docs/api-reference/fine-tuning/create) that fine-tunes a specified model from a given dataset.
///Response includes details of the enqueued job including job status and the name of the fine-tuned models once complete.
public struct FineTuningJobParameters: Encodable {
   
   /// The name of the model to fine-tune. You can select one of the [supported models](https://platform.openai.com/docs/models/overview).
   let model: String
   /// The ID of an uploaded file that contains training data.
   /// See [upload file](https://platform.openai.com/docs/api-reference/files/upload) for how to upload a file.
   /// Your dataset must be formatted as a JSONL file. Additionally, you must upload your file with the purpose fine-tune.
   /// See the [fine-tuning guide](https://platform.openai.com/docs/guides/fine-tuning) for more details.
   let trainingFile: String
   /// The hyperparameters used for the fine-tuning job.
   let hyperparameters: HyperParameters?
   /// A string of up to 18 characters that will be added to your fine-tuned model name.
   /// For example, a suffix of "custom-model-name" would produce a model name like ft:gpt-3.5-turbo:openai:custom-model-name:7p4lURel.
   /// Defaults to null.
   let suffix: String?
   /// The ID of an uploaded file that contains validation data.
   /// If you provide this file, the data is used to generate validation metrics periodically during fine-tuning. These metrics can be viewed in the fine-tuning results file. The same data should not be present in both train and validation files.
   /// Your dataset must be formatted as a JSONL file. You must upload your file with the purpose fine-tune.
   /// See the [fine-tuning guide](https://platform.openai.com/docs/guides/fine-tuning) for more details.
   let validationFile: String?
   
   enum CodingKeys: String, CodingKey {
      case model
      case trainingFile = "training_file"
      case validationFile = "validation_file"
   }
   
   
   /// Fine-tuning is [currently available](https://platform.openai.com/docs/guides/fine-tuning/what-models-can-be-fine-tuned) for the following models:
   /// gpt-3.5-turbo-0613 (recommended)
   /// babbage-002
   /// davinci-002
   /// OpenAI expects gpt-3.5-turbo to be the right model for most users in terms of results and ease of use, unless you are migrating a legacy fine-tuned model.
   public enum Model: String {
      case gpt35 = "gpt-3.5-turbo-0613" /// recommended
      case babbage002 = "babbage-002"
      case davinci002 = "davinci-002"
   }
   
   public struct HyperParameters: Encodable {
      /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset.
      /// Defaults to auto.
      let nEpochs: Int?
      
      public init(
         nEpochs: Int?)
      {
         self.nEpochs = nEpochs
      }
      
      enum CodingKeys: String, CodingKey {
         case nEpochs = "n_epochs"
      }
   }
   
   public init(
      model: Model,
      trainingFile: String,
      hyperparameters: HyperParameters? = nil,
      suffix: String? = nil,
      validationFile: String? = nil)
   {
      self.model = model.rawValue
      self.trainingFile = trainingFile
      self.hyperparameters = hyperparameters
      self.suffix = suffix
      self.validationFile = validationFile
   }
}
```
Response
```swift
/// The fine_tuning.job object represents a [fine-tuning job](https://platform.openai.com/docs/api-reference/fine-tuning/object) that has been created through the API.
public struct FineTuningJobObject: Decodable {
   
   /// The object identifier, which can be referenced in the API endpoints.
   public let id: String
   /// The Unix timestamp (in seconds) for when the fine-tuning job was created.
   public let createdAt: Int
   
   //TODO: Error
   /**
    error
    object or null
    For fine-tuning jobs that have failed, this will contain more information on the cause of the failure.
    */
   
   /// The name of the fine-tuned model that is being created. The value will be null if the fine-tuning job is still running.
   public let fineTunedModel: String?
   /// The Unix timestamp (in seconds) for when the fine-tuning job was finished. The value will be null if the fine-tuning job is still running.
   public let finishedAt: Int?
   /// The hyperparameters used for the fine-tuning job. See the [fine-tuning guide](https://platform.openai.com/docs/guides/fine-tuning)  for more details.
   public let hyperparameters: HyperParameters
   /// The base model that is being fine-tuned.
   public let model: String
   /// The object type, which is always "fine_tuning.job".
   public let object: String
   /// The organization that owns the fine-tuning job.
   public let organizationId: String
   /// The compiled results file ID(s) for the fine-tuning job. You can retrieve the results with the [Files API](https://platform.openai.com/docs/api-reference/files/retrieve-contents).
   public let resultFiles: [String]
   /// The current status of the fine-tuning job, which can be either `validating_files`, `queued`, `running`, `succeeded`, `failed`, or `cancelled`.
   public let status: String
   /// The total number of billable tokens processed by this fine-tuning job. The value will be null if the fine-tuning job is still running.
   public let trainedTokens: Int?
   
   /// The file ID used for training. You can retrieve the training data with the [Files API](https://platform.openai.com/docs/api-reference/files/retrieve-contents).
   public let trainingFile: String
   /// The file ID used for validation. You can retrieve the validation results with the [Files API](https://platform.openai.com/docs/api-reference/files/retrieve-contents).
   public let validationFile: String?
   
   public enum Status: String {
      case validatingFiles = "validating_files"
      case queued
      case running
      case succeeded
      case failed
      case cancelled
   }
   
   enum CodingKeys: String, CodingKey {
      case id
      case createdAt = "created_at"
      case fineTunedModel = "fine_tuned_model"
      case finishedAt = "finished_at"
      case hyperparameters
      case model
      case object
      case organizationId = "organization_id"
      case resultFiles = "result_files"
      case status
      case trainedTokens = "trained_tokens"
      case trainingFile = "training_file"
      case validationFile = "validation_file"
   }
   
   public struct HyperParameters: Decodable {
      /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset. "auto" decides the optimal number of epochs based on the size of the dataset. If setting the number manually, we support any number between 1 and 50 epochs.
      public let nEpochs: IntOrStringValue
      
      enum CodingKeys: String, CodingKey {
         case nEpochs = "n_epochs"
      }
   }
}
```

Usage
List fine-tuning jobs
```swift
let fineTuningJobs = try await service.istFineTuningJobs()
```
Create fine-tuning job
```swift
let trainingFileID = "file-Atc9okK0MOuQwQzDJCZXnrh6" // The id of the file that has been uploaded using the `Files` API. https://platform.openai.com/docs/api-reference/fine-tuning/create#fine-tuning/create-training_file
let parameters = FineTuningJobParameters(model: .gpt35, trainingFile: trainingFileID)
let fineTuningJob = try await service.createFineTuningJob(parameters: parameters)
```
Retrieve fine-tuning job
```swift
let fineTuningJobID = "ftjob-abc123"
let fineTuningJob = try await service.retrieveFineTuningJob(id: fineTuningJobID)
```
Cancel fine-tuning job
```swift
let fineTuningJobID = "ftjob-abc123"
let canceledFineTuningJob = try await service.cancelFineTuningJobWith(id: fineTuningJobID)
```
#### Fine-tuning job event object
Response
```swift
/// [Fine-tuning job event object](https://platform.openai.com/docs/api-reference/fine-tuning/event-object)
public struct FineTuningJobEventObject: Decodable {
   
   public let id: String
   
   public let createdAt: Int
   
   public let level: String
   
   public let message: String
   
   public let object: String
   
   public let type: String?
   
   public let data: Data?
   
   public struct Data: Decodable {
      public let step: Int
      public let trainLoss: Double
      public let trainMeanTokenAccuracy: Double
      
      enum CodingKeys: String, CodingKey {
         case step
         case trainLoss = "train_loss"
         case trainMeanTokenAccuracy = "train_mean_token_accuracy"
      }
   }
   
   enum CodingKeys: String, CodingKey {
      case id
      case createdAt = "created_at"
      case level
      case message
      case object
      case type
      case data
   }
}
```
Usage
```swift
let fineTuningJobID = "ftjob-abc123"
let jobEvents = try await service.listFineTuningEventsForJobWith(id: id, after: nil, limit: nil).data
```

### Files
### Images
### Models
### Moderations


