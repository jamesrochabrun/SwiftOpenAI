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
- [Azure OpenAI](#azure-openAI)
- [Collaboration](#collaboration)

## Description

`SwiftOpenAI` is an open-source Swift package that streamlines interactions with **all** OpenAI's API endpoints, now with added support for Azure and Assistant stream APIs. 

### OpenAI ENDPOINTS

- [Audio](#audio)
   - [Transcriptions](#audio-transcriptions)
   - [Translations](#audio-translations)
   - [Speech](#audio-Speech)
- [Chat](#chat)
   - [Function Calling](#function-calling)
   - [Vision](#vision)
- [Embeddings](#embeddings)
- [Fine-tuning](#fine-tuning)
- [Files](#files)
- [Images](#images)
- [Models](#models)
- [Moderations](#moderations)

### **BETA**
- [Assistants](#assistants)
   - [Assistants File Object](#assistants-file-object)
- [Threads](#threads)
- [Messages](#messages)
   - [Message File Object](#message-file-object)
- [Runs](#runs)
   - [Run Step object](#run-step-object)
   - [Run Step details](#run-step-details)
- [Assistants Streaming](#assistants-streaming)
   - [Message Delta Object](#message-delta-object)
   - [Run Step Delta Object](#run-step-delta-object)

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

### Audio Transcriptions
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
### Audio Translations
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

### Audio Speech
Parameters
```swift
/// [Generates audio from the input text.](https://platform.openai.com/docs/api-reference/audio/createSpeech)
public struct AudioSpeechParameters: Encodable {

   /// One of the available [TTS models](https://platform.openai.com/docs/models/tts): tts-1 or tts-1-hd
   let model: String
   /// The text to generate audio for. The maximum length is 4096 characters.
   let input: String
   /// The voice to use when generating the audio. Supported voices are alloy, echo, fable, onyx, nova, and shimmer. Previews of the voices are available in the [Text to speech guide.](https://platform.openai.com/docs/guides/text-to-speech/voice-options)
   let voice: String
   /// Defaults to mp3, The format to audio in. Supported formats are mp3, opus, aac, and flac.
   let responseFormat: String?
   /// Defaults to 1,  The speed of the generated audio. Select a value from 0.25 to 4.0. 1.0 is the default.
   let speed: Double?

   public enum TTSModel: String {
      case tts1 = "tts-1"
      case tts1HD = "tts-1-hd"
   }

   public enum Voice: String {
      case alloy
      case echo
      case fable
      case onyx
      case nova
      case shimmer
   }

   public enum ResponseFormat: String {
      case mp3
      case opus
      case aac
      case flac
   }
   
   public init(
      model: TTSModel,
      input: String,
      voice: Voice,
      responseFormat: ResponseFormat? = nil,
      speed: Double? = nil)
   {
       self.model = model.rawValue
       self.input = input
       self.voice = voice.rawValue
       self.responseFormat = responseFormat?.rawValue
       self.speed = speed
   }
}
```

Response
```swift
/// The [audio speech](https://platform.openai.com/docs/api-reference/audio/createSpeech) response.
public struct AudioSpeechObject: Decodable {

   /// The audio file content data.
   public let output: Data
}
```

Usage
```swift
let prompt = "Hello, how are you today?"
let parameters = AudioSpeechParameters(model: .tts1, input: prompt, voice: .shimmer)
let audioObjectData = try await service.createSpeech(parameters: parameters).output
playAudio(from: audioObjectData)

// Play data
 private func playAudio(from data: Data) {
       do {
           // Initialize the audio player with the data
           audioPlayer = try AVAudioPlayer(data: data)
           audioPlayer?.prepareToPlay()
           audioPlayer?.play()
       } catch {
           // Handle errors
           print("Error playing audio: \(error.localizedDescription)")
       }
   }
```

### Chat
Parameters
```swift
/// [Create chat completion](https://platform.openai.com/docs/api-reference/chat/create)
public struct ChatCompletionParameters: Encodable {
   
   /// A list of messages comprising the conversation so far. [Example Python code](https://cookbook.openai.com/examples/how_to_format_inputs_to_chatgpt_models)
   public var messages: [Message]
   /// ID of the model to use. See the [model endpoint compatibility](https://platform.openai.com/docs/models/how-we-use-your-data) table for details on which models work with the Chat API.
   let model: String
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
   /// Whether to return log probabilities of the output tokens or not. If true, returns the log probabilities of each output token returned in the content of message. This option is currently not available on the gpt-4-vision-preview model. Defaults to false.
   public var logprobs: Bool?
   /// An integer between 0 and 5 specifying the number of most likely tokens to return at each token position, each with an associated log probability. logprobs must be set to true if this parameter is used.
   public var topLogprobs: Int?
   /// The maximum number of [tokens](https://platform.openai.com/tokenizer) to generate in the chat completion.
   /// The total length of input tokens and generated tokens is limited by the model's context length. Example [Python code](https://cookbook.openai.com/examples/how_to_count_tokens_with_tiktoken) for counting tokens.
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
   let user: String?
   
   public enum Model: String {
      case gpt35Turbo = "gpt-3.5-turbo"
      case gpt35Turbo1106 = "gpt-3.5-turbo-1106" // Most updated - Supports parallel function calls
      case gpt4 = "gpt-4"
      case gpt41106Preview = "gpt-4-1106-preview"  // Most updated - Supports parallel function calls
      case gpt35Turbo0613 = "gpt-3.5-turbo-0613" // To be deprecated "2024-06-13"
      case gpt35Turbo16k0613 = "gpt-3.5-turbo-16k-0613" // To be deprecated "2024-06-13"
      
      case gpt4VisionPreview = "gpt-4-vision-preview" // Vision
   }
   
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
         
         public enum MessageContent: Encodable {
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
         }
      }
      
      public enum Role: String {
         case system // content, role
         case user // content, role
         case assistant // content, role, tool_calls
         case tool // content, role, tool_call_id
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
   /// This fingerprint represents the backend configuration that the model runs with.
   /// Can be used in conjunction with the seed request parameter to understand when backend changes have been made that might impact determinism.
   public let systemFingerprint: String?
   /// The object type, which is always chat.completion.
   public let object: String
   /// Usage statistics for the completion request.
   public let usage: ChatUsage
   
   public struct ChatChoice: Decodable {
      
      /// The reason the model stopped generating tokens. This will be stop if the model hit a natural stop point or a provided stop sequence, length if the maximum number of tokens specified in the request was reached, content_filter if content was omitted due to a flag from our content filters, tool_calls if the model called a tool, or function_call (deprecated) if the model called a function.
      public let finishReason: IntOrStringValue?
      /// The index of the choice in the list of choices.
      public let index: Int
      /// A chat completion message generated by the model.
      public let message: ChatMessage   
      /// Log probability information for the choice.
      public let logprobs: LogProb?
      
      public struct ChatMessage: Decodable {
         
         /// The contents of the message.
         public let content: String?
         /// The tool calls generated by the model, such as function calls.
         public let toolCalls: [ToolCall]?
         /// The name and arguments of a function that should be called, as generated by the model.
         @available(*, deprecated, message: "Deprecated and replaced by `tool_calls`")
         public let functionCall: FunctionCall?
         /// The role of the author of this message.
         public let role: String
         /// Provided by the Vision API.
         public let finishDetails: FinishDetails?
         
         /// Provided by the Vision API.
         public struct FinishDetails: Decodable {
            let type: String
         }
      }
      
      public struct LogProb: Decodable {
         /// A list of message content tokens with log probability information.
         let content: [TokenDetail]
      }
      
      public struct TokenDetail: Decodable {
         /// The token.
         let token: String
         /// The log probability of this token.
         let logprob: Double
         /// A list of integers representing the UTF-8 bytes representation of the token. Useful in instances where characters are represented by multiple tokens and their byte representations must be combined to generate the correct text representation. Can be null if there is no bytes representation for the token.
         let bytes: [Int]?
         /// List of the most likely tokens and their log probability, at this token position. In rare cases, there may be fewer than the number of requested top_logprobs returned.
         let topLogprobs: [TopLogProb]
         
         enum CodingKeys: String, CodingKey {
            case token, logprob, bytes
            case topLogprobs = "top_logprobs"
         }
         
         struct TopLogProb: Decodable {
            /// The token.
            let token: String
            /// The log probability of this token.
            let logprob: Double
            /// A list of integers representing the UTF-8 bytes representation of the token. Useful in instances where characters are represented by multiple tokens and their byte representations must be combined to generate the correct text representation. Can be null if there is no bytes representation for the token.
            let bytes: [Int]?
         }
      }
   }
   
   public struct ChatUsage: Decodable {
      
      /// Number of tokens in the generated completion.
      public let completionTokens: Int
      /// Number of tokens in the prompt.
      public let promptTokens: Int
      /// Total number of tokens used in the request (prompt + completion).
      public let totalTokens: Int
   }
}
```

Usage
```swift
let prompt = "Tell me a joke"
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text(prompt))], model: .gpt41106Preview)
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
   /// This fingerprint represents the backend configuration that the model runs with.
   /// Can be used in conjunction with the seed request parameter to understand when backend changes have been made that might impact determinism.
   public let systemFingerprint: String?
   /// The object type, which is always chat.completion.chunk.
   public let object: String
   
   public struct ChatChoice: Decodable {
      
      /// A chat completion delta generated by streamed model responses.
      public let delta: Delta
      /// The reason the model stopped generating tokens. This will be stop if the model hit a natural stop point or a provided stop sequence, length if the maximum number of tokens specified in the request was reached, content_filter if content was omitted due to a flag from our content filters, tool_calls if the model called a tool, or function_call (deprecated) if the model called a function.
      public let finishReason: IntOrStringValue?
      /// The index of the choice in the list of choices.
      public let index: Int
      /// Provided by the Vision API.
      public let finishDetails: FinishDetails?
      
      public struct Delta: Decodable {
         
         /// The contents of the chunk message.
         public let content: String?
         /// The tool calls generated by the model, such as function calls.
         public let toolCalls: [ToolCall]?
         /// The name and arguments of a function that should be called, as generated by the model.
         @available(*, deprecated, message: "Deprecated and replaced by `tool_calls`")
         public let functionCall: FunctionCall?
         /// The role of the author of this message.
         public let role: String?
      }
      
      public struct LogProb: Decodable {
         /// A list of message content tokens with log probability information.
         let content: [TokenDetail]
      }
      
      public struct TokenDetail: Decodable {
         /// The token.
         let token: String
         /// The log probability of this token.
         let logprob: Double
         /// A list of integers representing the UTF-8 bytes representation of the token. Useful in instances where characters are represented by multiple tokens and their byte representations must be combined to generate the correct text representation. Can be null if there is no bytes representation for the token.
         let bytes: [Int]?
         /// List of the most likely tokens and their log probability, at this token position. In rare cases, there may be fewer than the number of requested top_logprobs returned.
         let topLogprobs: [TopLogProb]
         
         enum CodingKeys: String, CodingKey {
            case token, logprob, bytes
            case topLogprobs = "top_logprobs"
         }
         
         struct TopLogProb: Decodable {
            /// The token.
            let token: String
            /// The log probability of this token.
            let logprob: Double
            /// A list of integers representing the UTF-8 bytes representation of the token. Useful in instances where characters are represented by multiple tokens and their byte representations must be combined to generate the correct text representation. Can be null if there is no bytes representation for the token.
            let bytes: [Int]?
         }
      }
      
      /// Provided by the Vision API.
      public struct FinishDetails: Decodable {
         let type: String
      }
   }
}
```
Usage
```swift
let prompt = "Tell me a joke"
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text(prompt))], model: .gpt41106Preview)
let chatCompletionObject = try await service.startStreamedChat(parameters: parameters)
```

### Function Calling

Chat Completion also supports [Function Calling](https://platform.openai.com/docs/guides/function-calling) and [Parallel Function Calling](https://platform.openai.com/docs/guides/function-calling/parallel-function-calling). `functions` has been deprecated in favor of `tools` check [OpenAI Documentation](https://platform.openai.com/docs/api-reference/chat/create) for more.

```swift
public struct ToolCall: Codable {

   public let index: Int
   /// The ID of the tool call.
   public let id: String?
   /// The type of the tool. Currently, only `function` is supported.
   public let type: String?
   /// The function that the model called.
   public let function: FunctionCall

   public init(
      index: Int,
      id: String,
      type: String = "function",
      function: FunctionCall)
   {
      self.index = index
      self.id = id
      self.type = type
      self.function = function
   }
}

public struct FunctionCall: Codable {

   /// The arguments to call the function with, as generated by the model in JSON format. Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema. Validate the arguments in your code before calling your function.
   let arguments: String
   /// The name of the function to call.
   let name: String

   public init(
      arguments: String,
      name: String)
   {
      self.arguments = arguments
      self.name = name
   }
}
```

Usage
```swift
/// Define a `ToolCall`
var tool: ToolCall {
   .init(
      type: "function", // The type of the tool. Currently, only "function" is supported.
      function: .init(
         name: "create_image",
         description: "Call this function if the request asks to generate an image",
         parameters: .init(
            type: .object,
            properties: [
               "prompt": .init(type: .string, description: "The exact prompt passed in."),
               "count": .init(type: .integer, description: "The number of images requested")
            ],
            required: ["prompt", "count"])))
}

let prompt = "Show me an image of an unicorn eating ice cream"
let content: ChatCompletionParameters.Message.ContentType = .text(prompt)
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: content)], model: .gpt41106Preview, tools: [tool])
let chatCompletionObject = try await service.startStreamedChat(parameters: parameters)
```
For more details about how to also uploadin base 64 encoded images in iOS check the [ChatFunctionsCalllDemo](https://github.com/jamesrochabrun/SwiftOpenAI/tree/main/Examples/SwiftOpenAIExample/SwiftOpenAIExample/ChatFunctionsCall) demo on the Examples section of this package.

### Vision

[Vison](https://platform.openai.com/docs/guides/vision) API is available for use; developers must access it through the chat completions API, specifically using the gpt-4-vision-preview model. Using any other model will not provide an image description

Usage
```swift
let imageURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
let prompt = "What is this?"
let messageContent: [ChatCompletionParameters.Message.ContentType.MessageContent] = [.text(prompt), .imageUrl(imageURL)] // Users can add as many `.imageUrl` instances to the service.
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .contentArray(messageContent))], model: .gpt4VisionPreview)
let chatCompletionObject = try await service.startStreamedChat(parameters: parameters)
```

![Simulator Screen Recording - iPhone 15 - 2023-11-09 at 17 12 06](https://github.com/jamesrochabrun/SwiftOpenAI/assets/5378604/db2cbb3b-0c80-4ac8-8fe5-dbb782b270da)

For more details about how to also uploadin base 64 encoded images in iOS check the [ChatVision](https://github.com/jamesrochabrun/SwiftOpenAI/tree/main/Examples/SwiftOpenAIExample/SwiftOpenAIExample/Vision) demo on the Examples section of this package.

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
      self.model = model.value
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
  /// For fine-tuning jobs that have failed, this will contain more information on the cause of the failure.
   public let error: OpenAIErrorResponse.Error?
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
   
   public struct HyperParameters: Decodable {
      /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset. "auto" decides the optimal number of epochs based on the size of the dataset. If setting the number manually, we support any number between 1 and 50 epochs.
      public let nEpochs: IntOrStringValue
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
   }
}
```
Usage
```swift
let fineTuningJobID = "ftjob-abc123"
let jobEvents = try await service.listFineTuningEventsForJobWith(id: id, after: nil, limit: nil).data
```

### Files
Parameters
```swift
/// [Upload a file](https://platform.openai.com/docs/api-reference/files/create) that can be used across various endpoints/features. Currently, the size of all the files uploaded by one organization can be up to 1 GB. Please contact us if you need to increase the storage limit.
public struct FileParameters: Encodable {
   
   /// The name of the file asset is not documented in OpenAI's official documentation; however, it is essential for constructing the multipart request.
   let fileName: String
   /// The file object (not file name) to be uploaded.
   /// If the purpose is set to "fine-tune", the file will be used for fine-tuning.
   let file: Data
   /// The intended purpose of the uploaded file.
   /// Use "fine-tune" for [fine-tuning](https://platform.openai.com/docs/api-reference/fine-tuning). This allows us to validate the format of the uploaded file is correct for fine-tuning.
   let purpose: String
   
   public init(
      fileName: String,
      file: Data,
      purpose: String)
   {
      self.fileName = fileName
      self.file = file
      self.purpose = purpose
   }
}
```
Response
```swift
/// The [File object](https://platform.openai.com/docs/api-reference/files/object) represents a document that has been uploaded to OpenAI.
public struct FileObject: Decodable {
   
   /// The file identifier, which can be referenced in the API endpoints.
   public let id: String
   /// The size of the file in bytes.
   public let bytes: Int
   /// The Unix timestamp (in seconds) for when the file was created.
   public let createdAt: Int
   /// The name of the file.
   public let filename: String
   /// The object type, which is always "file".
   public let object: String
   /// The intended purpose of the file. Currently, only "fine-tune" is supported.
   public let purpose: String
   /// The current status of the file, which can be either uploaded, processed, pending, error, deleting or deleted.
   public let status: String
   /// Additional details about the status of the file. If the file is in the error state, this will include a message describing the error.
   public let statusDetails: String?
   
   public enum Status: String {
      case uploaded
      case processed
      case pending
      case error
      case deleting
      case deleted
   }

   public init(
      id: String,
      bytes: Int,
      createdAt: Int,
      filename: String,
      object: String,
      purpose: String,
      status: Status,
      statusDetails: String?)
   {
      self.id = id
      self.bytes = bytes
      self.createdAt = createdAt
      self.filename = filename
      self.object = object
      self.purpose = purpose
      self.status = status.rawValue
      self.statusDetails = statusDetails
   }
   
   public struct DeletionStatus: Decodable {
      public let id: String
      public let object: String
      public let deleted: Bool
   }
}
```
Usage
List files
```swift
let files = try await service.listFiles().data
```
### Upload file
```swift
let fileName = "worldCupData.jsonl"
let data = Data(contentsOfURL:_) // Data retrieved from the file named "worldCupData.jsonl".
let parameters = FileParameters(fileName: "WorldCupData", file: data, purpose: "fine-tune") // Important: make sure to provide a file name.
let uploadedFile =  try await service.uploadFile(parameters: parameters) 
```
Delete file
```swift
let fileID = "file-abc123"
let deletedStatus = try await service.deleteFileWith(id: fileID)
```
Retrieve file
```swift
let fileID = "file-abc123"
let retrievedFile = try await service.retrieveFileWith(id: fileID)
```
Retrieve file content
```swift
let fileID = "file-abc123"
let fileContent = try await service.retrieveContentForFileWith(id: fileID)
```

### Images

For handling image sizes, we utilize the `Dalle` model. An enum with associated values has been defined to represent its size constraints accurately.

 [DALL·E](https://platform.openai.com/docs/models/dall-e)
 
 DALL·E is a AI system that can create realistic images and art from a description in natural language. DALL·E 3 currently supports the ability, given a prompt, to create a new image with a specific size. DALL·E 2 also support the ability to edit an existing image, or create variations of a user provided image.
 
 DALL·E 3 is available through our Images API along with DALL·E 2. You can try DALL·E 3 through ChatGPT Plus.
 
 
 | MODEL     | DESCRIPTION                                                  |
 |-----------|--------------------------------------------------------------|
 | dall-e-3  | DALL·E 3 New                                                 |
 |           | The latest DALL·E model released in Nov 2023. Learn more.    |
 | dall-e-2  | The previous DALL·E model released in Nov 2022.              |
 |           | The 2nd iteration of DALL·E with more realistic, accurate,   |
 |           | and 4x greater resolution images than the original model.    |

public enum Dalle {
   
   case dalle2(Dalle2ImageSize)
   case dalle3(Dalle3ImageSize)
   
   public enum Dalle2ImageSize: String {
      case small = "256x256"
      case medium = "512x512"
      case large = "1024x1024"
   }
   
   public enum Dalle3ImageSize: String {
      case largeSquare = "1024x1024"
      case landscape  = "1792x1024"
      case portrait = "1024x1792"
   }
   
   var model: String {
      switch self {
      case .dalle2: return Model.dalle2.rawValue
      case .dalle3: return Model.dalle3.rawValue
      }
   }
   
   var size: String {
      switch self {
      case .dalle2(let dalle2ImageSize):
         return dalle2ImageSize.rawValue
      case .dalle3(let dalle3ImageSize):
         return dalle3ImageSize.rawValue
      }
   }
}

#### Image create
Parameters
```swift
public struct ImageCreateParameters: Encodable {
   
   /// A text description of the desired image(s). The maximum length is 1000 characters for dall-e-2 and 4000 characters for dall-e-3.
   let prompt: String
   /// The model to use for image generation. Defaults to dall-e-2
   let model: String?
   /// The number of images to generate. Must be between 1 and 10. For dall-e-3, only n=1 is supported.
   let n: Int?
   /// The quality of the image that will be generated. hd creates images with finer details and greater consistency across the image. This param is only supported for dall-e-3. Defaults to standard
   let quality: String?
   /// The format in which the generated images are returned. Must be one of url or b64_json. Defaults to url
   let responseFormat: String?
   /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024 for dall-e-2. Must be one of 1024x1024, 1792x1024, or 1024x1792 for dall-e-3 models. Defaults to 1024x1024
   let size: String?
   /// The style of the generated images. Must be one of vivid or natural. Vivid causes the model to lean towards generating hyper-real and dramatic images. Natural causes the model to produce more natural, less hyper-real looking images. This param is only supported for dall-e-3. Defaults to vivid
   let style: String?
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices)
   let user: String?
   
   public init(
      prompt: String,
      model: Dalle,
      numberOfImages: Int = 1,
      quality: String? = nil,
      responseFormat: ImageResponseFormat? = nil,
      style: String? = nil,
      user: String? = nil)
   {
   self.prompt = prompt
   self.model = model.model
   self.n = numberOfImages
   self.quality = quality
   self.responseFormat = responseFormat?.rawValue
   self.size = model.size
   self.style = style
   self.user = user
   }   
}
```
#### Image Edit 
Parameters
```swift
/// [Creates an edited or extended image given an original image and a prompt.](https://platform.openai.com/docs/api-reference/images/createEdit)
public struct ImageEditParameters: Encodable {
   
   /// The image to edit. Must be a valid PNG file, less than 4MB, and square. If mask is not provided, image must have transparency, which will be used as the mask.
   let image: Data
   /// A text description of the desired image(s). The maximum length is 1000 characters.
   let prompt: String
   /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited. Must be a valid PNG file, less than 4MB, and have the same dimensions as image.
   let mask: Data?
   /// The model to use for image generation. Only dall-e-2 is supported at this time. Defaults to dall-e-2
   let model: String?
   /// The number of images to generate. Must be between 1 and 10. Defaults to 1
   let n: Int?
   /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024. Defaults to 1024x1024
   let size: String?
   /// The format in which the generated images are returned. Must be one of url or b64_json. Defaults to url
   let responseFormat: String?
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices)
   let user: String?
   
   public init(
      image: UIImage,
      model: Dalle? = nil,
      mask: UIImage? = nil,
      prompt: String,
      numberOfImages: Int? = nil,
      responseFormat: ImageResponseFormat? = nil,
      user: String? = nil)
   {
      if (image.pngData() == nil) {
         assertionFailure("Failed to get PNG data from image")
      }
      if let mask, mask.pngData() == nil {
         assertionFailure("Failed to get PNG data from mask")
      }
      if let model, model.model != Model.dalle2.rawValue {
         assertionFailure("Only dall-e-2 is supported at this time [https://platform.openai.com/docs/api-reference/images/createEdit]")
      }
      self.image = image.pngData()!
      self.model = model?.model
      self.mask = mask?.pngData()
      self.prompt = prompt
      self.n = numberOfImages
      self.size = model?.size
      self.responseFormat = responseFormat?.rawValue
      self.user = user
   }
}
```
#### Image variation
Parameters
```swift
/// [Creates a variation of a given image.](https://platform.openai.com/docs/api-reference/images/createVariation)
public struct ImageVariationParameters: Encodable {
   
   /// The image to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
   let image: Data
   /// The model to use for image generation. Only dall-e-2 is supported at this time. Defaults to dall-e-2
   let model: String?
   /// The number of images to generate. Must be between 1 and 10. Defaults to 1
   let n: Int?
   /// The format in which the generated images are returned. Must be one of url or b64_json. Defaults to url
   let responseFormat: String?
   /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024. Defaults to 1024x1024
   let size: String?
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices)
   let user: String?
   
   public init(
      image: UIImage,
      model: Dalle? = nil,
      numberOfImages: Int? = nil,
      responseFormat: ImageResponseFormat? = nil,
      user: String? = nil)
   {
      if let model, model.model != Model.dalle2.rawValue {
         assertionFailure("Only dall-e-2 is supported at this time [https://platform.openai.com/docs/api-reference/images/createEdit]")
      }
      self.image = image.pngData()!
      self.n = numberOfImages
      self.model = model?.model
      self.size = model?.size
      self.responseFormat = responseFormat?.rawValue
      self.user = user
   }
}
```
Response
```swift
/// [Represents the url or the content of an image generated by the OpenAI API.](https://platform.openai.com/docs/api-reference/images/object)
public struct ImageObject: Decodable {
   /// The URL of the generated image, if response_format is url (default).
   public let url: URL?
   /// The base64-encoded JSON of the generated image, if response_format is b64_json.
   public let b64Json: String?
   /// The prompt that was used to generate the image, if there was any revision to the prompt.
   public let revisedPrompt: String?
}
```

Usage
```swift
/// Create image
let prompt = "A mix of a dragon and an unicorn"
let createParameters = ImageCreateParameters(prompt: prompt, model: .dalle3(.largeSquare))
let imageURLS = try await service.createImages(parameters: createParameters).data.map(\.url)
```
```swift
/// Edit image
let data = Data(contentsOfURL:_) // the data from an image.
let image = UIImage(data: data)
let prompt = "Add a background filled with pink balloons."
let editParameters = ImageEditParameters(image: image, prompt: prompt, numberOfImages: 4)  
let imageURLS = try await service.editImage(parameters: parameters).data.map(\.url)
```
```swift
/// Image variations
let data = Data(contentsOfURL:_) // the data from an image.
let image = UIImage(data: data)
let variationParameters = ImageVariationParameters(image: image, numberOfImages: 4)
let imageURLS = try await service.createImageVariations(parameters: parameters).data.map(\.url)
```

### Models
Response
```swift

/// Describes an OpenAI [model](https://platform.openai.com/docs/api-reference/models/object) offering that can be used with the API.
public struct ModelObject: Decodable {
   
   /// The model identifier, which can be referenced in the API endpoints.
   public let id: String
   /// The Unix timestamp (in seconds) when the model was created.
   public let created: Int
   /// The object type, which is always "model".
   public let object: String
   /// The organization that owns the model.
   public let ownedBy: String
   /// An array representing the current permissions of a model. Each element in the array corresponds to a specific permission setting. If there are no permissions or if the data is unavailable, the array may be nil.
   public let permission: [Permission]?
   
   public struct Permission: Decodable {
      public let id: String?
      public let object: String?
      public let created: Int?
      public let allowCreateEngine: Bool?
      public let allowSampling: Bool?
      public let allowLogprobs: Bool?
      public let allowSearchIndices: Bool?
      public let allowView: Bool?
      public let allowFineTuning: Bool?
      public let organization: String?
      public let group: String?
      public let isBlocking: Bool?
   }
   
   /// Represents the response from the [delete](https://platform.openai.com/docs/api-reference/models/delete) fine-tuning API
   public struct DeletionStatus: Decodable {
      
      public let id: String
      public let object: String
      public let deleted: Bool
   }
}
```
Usage
```swift
/// List models
let models = try await service.listModels().data
```
```swift
/// Retrieve model
let modelID = "gpt-3.5-turbo-instruct"
let retrievedModel = try await service.retrieveModelWith(id: modelID)
```
```swift
/// Delete fine tuned model
let modelID = "fine-tune-model-id"
let deletionStatus = try await service.deleteFineTuneModelWith(id: modelID)
```
### Moderations
Parameters
```swift
/// [Classifies if text violates OpenAI's Content Policy.](https://platform.openai.com/docs/api-reference/moderations/create)
public struct ModerationParameter<Input: Encodable>: Encodable {
   
   /// The input text to classify, string or array.
   let input: Input
   /// Two content moderations models are available: text-moderation-stable and text-moderation-latest.
   /// The default is text-moderation-latest which will be automatically upgraded over time. This ensures you are always using our most accurate model. If you use text-moderation-stable, we will provide advanced notice before updating the model. Accuracy of text-moderation-stable may be slightly lower than for text-moderation-latest.
   let model: String?
   
   enum Model: String {
      case stable = "text-moderation-stable"
      case latest = "text-moderation-latest"
   }
   
   init(
      input: Input,
      model: Model? = nil)
   {
      self.input = input
      self.model = model?.rawValue
   }
}
```
Response
```swift
/// The [moderation object](https://platform.openai.com/docs/api-reference/moderations/object). Represents policy compliance report by OpenAI's content moderation model against a given input.
public struct ModerationObject: Decodable {
   
   /// The unique identifier for the moderation request.
   public let id: String
   /// The model used to generate the moderation results.
   public let model: String
   /// A list of moderation objects.
   public let results: [Moderation]
   
   public struct Moderation: Decodable {
      
      /// Whether the content violates OpenAI's usage policies.
      public let flagged: Bool
      /// A list of the categories, and whether they are flagged or not.
      public let categories: Category<Bool>
      /// A list of the categories along with their scores as predicted by model.
      public let categoryScores: Category<Double>
      
      public struct Category<T: Decodable>: Decodable {
         
         /// Content that expresses, incites, or promotes hate based on race, gender, ethnicity, religion, nationality, sexual orientation, disability status, or caste. Hateful content aimed at non-protected groups (e.g., chess players) is harrassment.
         public let hate: T
         /// Hateful content that also includes violence or serious harm towards the targeted group based on race, gender, ethnicity, religion, nationality, sexual orientation, disability status, or caste.
         public let hateThreatening: T
         /// Content that expresses, incites, or promotes harassing language towards any target.
         public let harassment: T
         /// Harassment content that also includes violence or serious harm towards any target.
         public let harassmentThreatening: T
         /// Content that promotes, encourages, or depicts acts of self-harm, such as suicide, cutting, and eating disorders.
         public let selfHarm: T
         /// Content where the speaker expresses that they are engaging or intend to engage in acts of self-harm, such as suicide, cutting, and eating disorders.
         public let selfHarmIntent: T
         /// Content that encourages performing acts of self-harm, such as suicide, cutting, and eating disorders, or that gives instructions or advice on how to commit such acts.
         public let selfHarmInstructions: T
         /// Content meant to arouse sexual excitement, such as the description of sexual activity, or that promotes sexual services (excluding sex education and wellness).
         public let sexual: T
         /// Sexual content that includes an individual who is under 18 years old.
         public let sexualMinors: T
         /// Content that depicts death, violence, or physical injury.
         public let violence: T
         /// Content that depicts death, violence, or physical injury in graphic detail.
         public let violenceGraphic: T
      }
   }
}
```
Usage
```swift
/// Single prompt
let prompt = "I am going to kill him"
let parameters = ModerationParameter(input: prompt)
let isFlagged = try await service.createModerationFromText(parameters: parameters)
```
```swift
/// Multiple prompts
let prompts = ["I am going to kill him", "I am going to die"]
let parameters = ModerationParameter(input: prompts)
let isFlagged = try await service.createModerationFromTexts(parameters: parameters)
```

### **BETA**
### Assistants
Parameters
```swift
/// Create an [assistant](https://platform.openai.com/docs/api-reference/assistants/createAssistant) with a model and instructions.
/// Modifies an [assistant](https://platform.openai.com/docs/api-reference/assistants/modifyAssistant).
public struct AssistantParameters: Encodable {
   
   /// ID of the model to use. You can use the [List models](https://platform.openai.com/docs/api-reference/models/list) API to see all of your available models, or see our [Model overview](https://platform.openai.com/docs/models/overview) for descriptions of them.
   public var model: String?
   /// The name of the assistant. The maximum length is 256 characters.
   public var name: String?
   /// The description of the assistant. The maximum length is 512 characters.
   public var description: String?
   /// The system instructions that the assistant uses. The maximum length is 32768 characters.
   public var instructions: String?
   /// A list of tool enabled on the assistant. There can be a maximum of 128 tools per assistant. Tools can be of types code_interpreter, retrieval, or function. Defaults to []
   public var tools: [AssistantObject.Tool] = []
   /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs attached to this assistant. There can be a maximum of 20 files attached to the assistant. Files are ordered by their creation date in ascending order.
   public var fileIDS: [String]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public var metadata: [String: String]?
   
   public enum Action {
      case create(model: String) // model is required on creation of assistant.
      case modify(model: String?) // model is optional on modification of assistant.
      
      var model: String? {
         switch self {
         case .create(let model): return model
         case .modify(let model): return model
         }
      }
   }
   
   public init(
      action: Action,
      name: String? = nil,
      description: String? = nil,
      instructions: String? = nil,
      tools: [AssistantObject.Tool] = [],
      fileIDS: [String]? = nil,
      metadata: [String : String]? = nil)
   {
      self.model = action.model
      self.name = name
      self.description = description
      self.instructions = instructions
      self.tools = tools
      self.fileIDS = fileIDS
      self.metadata = metadata
   }
}
```
Response
```swift
/// Represents an [assistant](https://platform.openai.com/docs/api-reference/assistants) that can call the model and use tools.
public struct AssistantObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always "assistant".
   public let object: String
   /// The Unix timestamp (in seconds) for when the assistant was created.
   public let createdAt: Int
   /// The name of the assistant. The maximum length is 256 characters.
   public let name: String?
   /// The description of the assistant. The maximum length is 512 characters.
   public let description: String?
   /// ID of the model to use. You can use the [List models](https://platform.openai.com/docs/api-reference/models/list) API to see all of your available models, or see our [Model overview](https://platform.openai.com/docs/models/overview) for descriptions of them.
   public let model: String
   /// The system instructions that the assistant uses. The maximum length is 32768 characters.
   public let instructions: String?
   /// A list of tool enabled on the assistant. There can be a maximum of 128 tools per assistant. Tools can be of types code_interpreter, retrieval, or function.
   public let tools: [Tool]
   /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs attached to this assistant. There can be a maximum of 20 files attached to the assistant. Files are ordered by their creation date in ascending order.
   public let fileIDS: [String]
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
   
   public struct Tool: Codable {
      
      /// The type of tool being defined.
      public let type: String
      public let function: ChatCompletionParameters.ChatFunction?
      
      public enum ToolType: String, CaseIterable {
         case codeInterpreter = "code_interpreter"
         case retrieval
         case function
      }
      
      /// Helper.
      public var displayToolType: ToolType? { .init(rawValue: type) }
      
      public init(
         type: ToolType,
         function: ChatCompletionParameters.ChatFunction? = nil)
      {
         self.type = type.rawValue
         self.function = function
      }
   }
   
   public struct DeletionStatus: Decodable {
      public let id: String
      public let object: String
      public let deleted: Bool
   }
}
```

Usage

Create Assistant
```swift
let parameters = AssistantParameters(action: .create(model: Model.gpt41106Preview.rawValue), name: "Math tutor")
let assistant = try await service.createAssistant(parameters: parameters)
```
Retrieve Assistant
```swift
let assistantID = "asst_abc123"
let assistant = try await service.retrieveAssistant(id: assistantID)
```
Modify Assistant
```swift
let assistantID = "asst_abc123"
let parameters = AssistantParameters(action: .modify, name: "Math tutor for kids")
let assistant = try await service.modifyAssistant(id: assistantID, parameters: parameters)
```
Delete Assistant
```swift
let assistantID = "asst_abc123"
let deletionStatus = try await service.deleteAssistant(id: assistantID)
```
List Assistants
```swift
let assistants = try await service.listAssistants()
```

### Assistants File Object
Parameters
```swift
/// [Creates an assistant file.](https://platform.openai.com/docs/api-reference/assistants/createAssistantFile)
public struct AssistantFileParamaters: Encodable {
   
   /// The ID of the assistant for which to create a File.
   let assistantID: String
   /// A [File](https://platform.openai.com/docs/api-reference/files) ID (with purpose="assistants") that the assistant should use.
   /// Useful for tools like retrieval and code_interpreter that can access files.
   let fileID: String
}
```
Response
```swift
/// The [assistant file object.](https://platform.openai.com/docs/api-reference/assistants/file-object)
/// A list of [Files](https://platform.openai.com/docs/api-reference/files) attached to an assistant.
public struct AssistantFileObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   let id: String
   /// The object type, which is always assistant.file.
   let object: String
   /// The Unix timestamp (in seconds) for when the assistant file was created.
   let createdAt: Int
   /// The assistant ID that the file is attached to.
   let assistantID: String
   
   
   enum CodingKeys: String, CodingKey {
      case id
      case object
      case createdAt = "created_at"
      case assistantID = "assistant_id"
   }
   
   public struct DeletionStatus: Decodable {
      public let id: String
      public let object: String
      public let deleted: Bool
   }
}
```
Usage

Refer to the [Upload file](#upload-file) section or consult the Files[https://platform.openai.com/docs/api-reference/files] OpenAI documentation for details on how to upload a file that can be attached to the assistant.
```swift
let fileID = "file-abc123"
let parameters = AssistantParameters(action: .create(model: Model.gpt41106Preview.rawValue), name: "Math tutor", fileIDS: [fileID])
let assistant = try await service.createAssistant(parameters: parameters)
```

### Threads
Parameters
```swift
/// Create a [Thread](https://platform.openai.com/docs/api-reference/threads/createThread)
public struct CreateThreadParameters: Encodable {
   
   /// A list of [messages](https://platform.openai.com/docs/api-reference/messages) to start the thread with.
   public var messages: [MessageObject]?
   
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public var metadata: [String: String]?
   
   public init(
      messages: [MessageObject]? = nil,
      metadata: [String : String]? = nil)
   {
      self.messages = messages
      self.metadata = metadata
   }
}
```
Response
```swift
/// A [thread object](https://platform.openai.com/docs/api-reference/threads) represents a thread that contains [messages](https://platform.openai.com/docs/api-reference/messages).
public struct ThreadObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.
   public let object: String
   /// The Unix timestamp (in seconds) for when the thread was created.
   public let createdAt: Int
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
   
   public struct DeletionStatus: Decodable {
      public let id: String
      public let object: String
      public let deleted: Bool
   }
}
```

Usage

Create thread.
```swift
let parameters = CreateThreadParameters()
let thread = try await service.createThread(parameters: parameters)
```
Retrieve thread.
```swift
let threadID = "thread_abc123"
let thread = try await service.retrieveThread(id: id)
```
Modify thread.
```swift
let threadID = "thread_abc123"
let paramaters = CreateThreadParameters(metadata: ["modified": "true", "user": "abc123"]
let thread = try await service.modifyThread(id: id, parameters: parameters)
```
Delete thread.
```swift
let threadID = "thread_abc123"
let thread = try await service.deleteThread(id: id)
```

### Messages
Parameters
[Create a Message](https://platform.openai.com/docs/api-reference/messages/createMessage))
```swift
public struct MessageParameter: Encodable {
   
   /// The role of the entity that is creating the message. Currently only user is supported.
   let role: String
   /// The content of the message.
   let content: String
   /// A list of [File](https://platform.openai.com/docs/api-reference/files) IDs that the message should use. There can be a maximum of 10 files attached to a message. Useful for tools like retrieval and code_interpreter that can access and use files. Defaults to []
   let fileIDS: [String]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
   
   public init(
      role: String,
      content: String,
      fileIDS: [String]? = nil,
      metadata: [String : String]? = nil)
   {
      self.role = role
      self.content = content
      self.fileIDS = fileIDS
      self.metadata = metadata
   }
}
```
[Modify a Message](https://platform.openai.com/docs/api-reference/messages/modifyMessage))
```swift
public struct ModifyMessageParameters: Encodable {
   
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public var metadata: [String: String]
}
```
Response
```swift
/// Represents a [message](https://platform.openai.com/docs/api-reference/messages) within a [thread](https://platform.openai.com/docs/api-reference/threads).
public struct MessageObject: Codable {
   
   /// The identifier, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.message.
   public let object: String
   /// The Unix timestamp (in seconds) for when the message was created.
   public let createdAt: Int
   /// The [thread](https://platform.openai.com/docs/api-reference/threads) ID that this message belongs to.
   public let threadID: String
   /// The entity that produced the message. One of user or assistant.
   public let role: String
   /// The content of the message in array of text and/or images.
   public let content: [Content]
   /// If applicable, the ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) that authored this message.
   public let assistantID: String?
   /// If applicable, the ID of the [run](https://platform.openai.com/docs/api-reference/runs) associated with the authoring of this message.
   public let runID: String?
   /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs that the assistant should use. Useful for tools like retrieval and code_interpreter that can access files. A maximum of 10 files can be attached to a message.
   public let fileIDS: [String]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]?
   
   enum Role: String {
      case user
      case assistant
   }
   
   enum CodingKeys: String, CodingKey {
      case id
      case object
      case createdAt = "created_at"
      case threadID = "thread_id"
      case role
      case content
      case assistantID = "assistant_id"
      case runID = "run_id"
      case fileIDS = "file_ids"
      case metadata
   }
}

// MARK: MessageContent

public enum MessageContent: Codable {
   
   case imageFile(ImageFile)
   case text(Text)
}

// MARK: Image File

public struct ImageFile: Codable {
   /// Always image_file.
   public let type: String
   
   /// References an image [File](https://platform.openai.com/docs/api-reference/files) in the content of a message.
   public let imageFile: ImageFileContent
   
   public struct ImageFileContent: Codable {
      
      /// The [File](https://platform.openai.com/docs/api-reference/files) ID of the image in the message content.
      public let fileID: String
   }
}

// MARK: Text

public struct Text: Codable {
   
   /// Always text.
   public let type: String
   /// The text content that is part of a message.
   public let text: TextContent
   
   public struct TextContent: Codable {
      // The data that makes up the text.
      public let value: String
      
      public let annotations: [Annotation]
   }
}

// MARK: Annotation

public enum Annotation: Codable {
   
   case fileCitation(FileCitation)
   case filePath(FilePath)
}

// MARK: FileCitation

/// A citation within the message that points to a specific quote from a specific File associated with the assistant or the message. Generated when the assistant uses the "retrieval" tool to search files.
public struct FileCitation: Codable {
   
   /// Always file_citation.
   public let type: String
   /// The text in the message content that needs to be replaced.
   public let text: String
   public let fileCitation: FileCitation
   public  let startIndex: Int
   public let endIndex: Int
   
   public struct FileCitation: Codable {
      
      /// The ID of the specific File the citation is from.
      public let fileID: String
      /// The specific quote in the file.
      public let quote: String

   }
}

// MARK: FilePath

/// A URL for the file that's generated when the assistant used the code_interpreter tool to generate a file.
public struct FilePath: Codable {
   
   /// Always file_path
   public let type: String
   /// The text in the message content that needs to be replaced.
   public let text: String
   public let filePath: FilePath
   public let startIndex: Int
   public let endIndex: Int
   
   public struct FilePath: Codable {
      /// The ID of the file that was generated.
      public let fileID: String
   }
}
```

Usage

Create Message.
```swift
let threadID = "thread_abc123"
let prompt = "Give me some ideas for a birthday party."
let parameters = MessageParameter(role: "user", content: prompt")
let message = try await service.createMessage(threadID: threadID, parameters: parameters)
```

Retireve Message.
```swift
let threadID = "thread_abc123"
let messageID = "msg_abc123"
let message = try await service.retrieveMessage(threadID: threadID, messageID: messageID)
```

Modify Message.
```swift
let threadID = "thread_abc123"
let messageID = "msg_abc123"
let parameters = ModifyMessageParameters(metadata: ["modified": "true", "user": "abc123"]
let message = try await service.modifyMessage(threadID: threadID, messageID: messageID, parameters: parameters)
```

List Messages
```swift
let threadID = "thread_abc123"
let messages = try await service.listMessages(threadID: threadID, limit: nil, order: nil, after: nil, before: nil) 
```

### Message File Object
[A list of files attached to a message](https://platform.openai.com/docs/api-reference/messages/file-object)
Response
```swift
public struct MessageFileObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.message.file.
   public let object: String
   /// The Unix timestamp (in seconds) for when the message file was created.
   public let createdAt: Int
}
```
Usage
[Retrieve Message File](https://platform.openai.com/docs/api-reference/messages/getMessageFile)
```swift
let threadID = "thread_abc123"
let messageID = "msg_abc123"
let fileID = "file-abc123"
let messageFile = try await service.retrieveMessageFile(threadID: threadID, messageID: messageID, fileID: fileID)
```
[List Message Files](https://platform.openai.com/docs/api-reference/messages/listMessageFiles0)
```swift
let threadID = "thread_abc123"
let messageID = "msg_abc123"
let messageFiles = try await service.listMessageFiles(threadID: threadID, messageID: messageID, limit: nil, order: nil, after: nil, before: v)
```

### Runs
Parameters

[Create a run](https://platform.openai.com/docs/api-reference/runs/createRun)
```swift
public struct RunParameter: Encodable {
   
   /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) to use to execute this run.
    let assistantID: String
   /// The ID of the [Model](https://platform.openai.com/docs/api-reference/models) to be used to execute this run. If a value is provided here, it will override the model associated with the assistant. If not, the model associated with the assistant will be used.
   let model: String?
   /// Override the default system message of the assistant. This is useful for modifying the behavior on a per-run basis.
   let instructions: String?
   /// Appends additional instructions at the end of the instructions for the run. This is useful for modifying the behavior on a per-run basis without overriding other instructions.
   let additionalInstructions: String?
   /// Override the tools the assistant can use for this run. This is useful for modifying the behavior on a per-run basis.
   let tools: [AssistantObject.Tool]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
   /// If true, returns a stream of events that happen during the Run as server-sent events, terminating when the Run enters a terminal state with a data: [DONE] message.
   var stream: Bool
}
```
[Modify a Run](https://platform.openai.com/docs/api-reference/runs/modifyRun)
```swift
public struct ModifyRunParameters: Encodable {
   
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public var metadata: [String: String]
   
   public init(
      metadata: [String : String])
   {
      self.metadata = metadata
   }
}
```
[Creates a Thread and Runs.](https://platform.openai.com/docs/api-reference/runs/createThreadAndRun)
```swift
public struct CreateThreadAndRunParameter: Encodable {
   
   /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) to use to execute this run.
   let assistantId: String
   /// A thread to create.
   let thread: CreateThreadParameters?
   /// The ID of the [Model](https://platform.openai.com/docs/api-reference/models) to be used to execute this run. If a value is provided here, it will override the model associated with the assistant. If not, the model associated with the assistant will be used.
   let model: String?
   /// Override the default system message of the assistant. This is useful for modifying the behavior on a per-run basis.
   let instructions: String?
   /// Override the tools the assistant can use for this run. This is useful for modifying the behavior on a per-run basis.
   let tools: [AssistantObject.Tool]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
   /// If true, returns a stream of events that happen during the Run as server-sent events, terminating when the Run enters a terminal state with a data: [DONE] message.
   let stream: Bool
}
```
[Submit tool outputs to run](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs)
```swift
public struct RunToolsOutputParameter: Encodable {
   
   /// A list of tools for which the outputs are being submitted.
   public let toolOutputs: [ToolOutput]
   /// If true, returns a stream of events that happen during the Run as server-sent events, terminating when the Run enters a terminal state with a data: [DONE] message.
   public let stream: Bool
}
```
   
Response
```swift
public struct RunObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.run.
   public let object: String
   /// The Unix timestamp (in seconds) for when the run was created.
   public let createdAt: Int
   /// The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) that was executed on as a part of this run.
   public let threadID: String
   /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for execution of this run.
   public let assistantID: String
   /// The status of the run, which can be either queued, in_progress, requires_action, cancelling, cancelled, failed, completed, or expired.
   public let status: String
   /// Details on the action required to continue the run. Will be null if no action is required.
   public let requiredAction: RequiredAction?
   /// The last error associated with this run. Will be null if there are no errors.
   public let lastError: LastError?
   /// The Unix timestamp (in seconds) for when the run will expire.
   public let expiresAt: Int
   /// The Unix timestamp (in seconds) for when the run was started.
   public let startedAt: Int?
   /// The Unix timestamp (in seconds) for when the run was cancelled.
   public let cancelledAt: Int?
   /// The Unix timestamp (in seconds) for when the run failed.
   public let failedAt: Int?
   /// The Unix timestamp (in seconds) for when the run was completed.
   public let completedAt: Int?
   /// The model that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let model: String
   /// The instructions that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let instructions: String?
   /// The list of tools that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let tools: [AssistantObject.Tool]
   /// The list of [File](https://platform.openai.com/docs/api-reference/files) IDs the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let fileIDS: [String]
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
}
```
Usage

Create a Run
```swift
let assistantID = "asst_abc123"
ler parameters = RunParameter(assistantID: assistantID)
let run = try await service.createRun(threadID: threadID, parameters: parameters)
```
Retrieve a Run
```swift
let threadID = "thread_abc123"
let runID = "run_abc123"
let run = try await service.retrieveRun(threadID: threadID, runID: runID)
```
Modify a Run
```swift
let threadID = "thread_abc123"
let runID = "run_abc123"
let parameters = ModifyRunParameters(metadata: ["modified": "true", "user": "abc123"]
let message = try await service.modifyRun(threadID: threadID, messageID: messageID, parameters: parameters)
```
List runs
```swift
let threadID = "thread_abc123"
let runs = try await service.listRuns(threadID: threadID, limit: nil, order: nil, after: nil, before: nil) 
```
Submit tool outputs to Run
```swift
let threadID = "thread_abc123"
let runID = "run_abc123"
let toolCallID = "call_abc123"
let output = "28C"
let parameters = RunToolsOutputParameter(toolOutputs: [.init(toolCallId: toolCallID, output: output)])
let run = try await service.submitToolOutputsToRun(threadID: threadID", runID: runID", parameters: parameters)
```
Cancel a Run
```swift
/// Cancels a run that is in_progress.
let threadID = "thread_abc123"
let runID = "run_abc123"
let run = try await service.cancelRun(threadID: threadID, runID: runID)
```
Create thread and Run
```swift
let assistantID = "asst_abc123"
let threadParameters = CreateThreadParameters()
let parameters = CreateThreadAndRunParameter(assistantID: assistantID)
let run = service.createThreadAndRun(parameters: parameters)
```

### Run Step Object
Represents a [step](https://platform.openai.com/docs/api-reference/runs/step-object) in execution of a run.
Response
```swift
public struct RunStepObject: Decodable {
   
   /// The identifier of the run step, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always `thread.run.step``.
   public let object: String
   /// The Unix timestamp (in seconds) for when the run step was created.
   public let createdAt: Int
   /// The ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) associated with the run step.
   public let assistantId: String
   /// The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) that was run.
   public let threadId: String
   ///The ID of the [run](https://platform.openai.com/docs/api-reference/runs) that this run step is a part of.
   public let runId: String
   /// The type of run step, which can be either message_creation or tool_calls.
   public let type: String
   /// The status of the run step, which can be either in_progress, cancelled, failed, completed, or expired.
   public let status: String
   /// The details of the run step.
   public let stepDetails: RunStepDetails
   /// The last error associated with this run step. Will be null if there are no errors.
   public let lastError: RunObject.LastError?
   /// The Unix timestamp (in seconds) for when the run step expired. A step is considered expired if the parent run is expired.
   public let expiredAt: Int?
   /// The Unix timestamp (in seconds) for when the run step was cancelled.
   public let cancelledAt: Int?
   /// The Unix timestamp (in seconds) for when the run step failed.
   public let failedAt: Int?
   /// The Unix timestamp (in seconds) for when the run step completed.
   public let completedAt: Int?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]?
   /// Usage statistics related to the run step. This value will be null while the run step's status is in_progress.
   public let usage: Usage?
}
```
Usage
Retrieve a Run step
```swift
let threadID = "thread_abc123"
let runID = "run_abc123"
let stepID = "step_abc123"
let runStep = try await service.retrieveRunstep(threadID: threadID, runID: runID, stepID: stepID)
```
List run steps
```swift
let threadID = "thread_abc123"
let runID = "run_abc123"
let runSteps = try await service.listRunSteps(threadID: threadID, runID: runID, limit: nil, order: nil, after: nil, before: nil) 
```

### Run Step Detail

The details of the run step.

```swift
public struct RunStepDetails: Codable {
   
   /// `message_creation` or `tool_calls`
   public let type: String
   /// Details of the message creation by the run step.
   public let messageCreation: MessageCreation?
   /// Details of the tool call.
   public let toolCalls: [ToolCall]?
}
```

### Assistants Streaming

Assistants API [streaming.](https://platform.openai.com/docs/api-reference/assistants-streaming)

Stream the result of executing a Run or resuming a Run after submitting tool outputs.

You can stream events from the [Create Thread and Run](https://platform.openai.com/docs/api-reference/runs/createThreadAndRun), [Create Run](https://platform.openai.com/docs/api-reference/runs/createRun), and [Submit Tool Outputs](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs) endpoints by passing "stream": true. The response will be a Server-Sent events stream.

OpenAI Python tutorial(https://platform.openai.com/docs/assistants/overview?context=with-streaming))

### Message Delta Object

[MessageDeltaObject](https://platform.openai.com/docs/api-reference/assistants-streaming/message-delta-object) Represents a message delta i.e. any changed fields on a message during streaming.

```swift
public struct MessageDeltaObject: Decodable {
   
   /// The identifier of the message, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.message.delta.
   public let object: String
   /// The delta containing the fields that have changed on the Message.
   public let delta: Delta
   
   public struct Delta: Decodable {
      
      /// The entity that produced the message. One of user or assistant.
      public let role: String
      /// The content of the message in array of text and/or images.
      public let content: [MessageContent]
      /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs that the assistant should use. Useful for tools like retrieval and code_interpreter that can access files. A maximum of 10 files can be attached to a message.
      public let fileIDS: [String]?

      enum Role: String {
         case user
         case assistant
      }
      
      enum CodingKeys: String, CodingKey {
         case role
         case content
         case fileIDS = "file_ids"
      }
   }
}
```

### Run Step Delta Object

Represents a [run step delta](https://platform.openai.com/docs/api-reference/assistants-streaming/run-step-delta-object) i.e. any changed fields on a run step during streaming.

```swift
public struct RunStepDeltaObject: Decodable {
   
   /// The identifier of the run step, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.run.step.delta.
   public let object: String
   /// The delta containing the fields that have changed on the run step.
   public let delta: Delta
   
   public struct Delta: Decodable {
      
      /// The details of the run step.
      public let stepDetails: RunStepDetails
      
      private enum CodingKeys: String, CodingKey {
         case stepDetails = "step_details"
      }
   }
}
```

⚠️ To utilize the `createRunAndStreamMessage`, first create an assistant and initiate a thread.

Usage
[Create Run](https://platform.openai.com/docs/api-reference/runs/createRun) with stream.

The `createRunAndStreamMessage` streams [events](https://platform.openai.com/docs/api-reference/assistants-streaming/events), You can decide which one you need for your implementation. For example, this is how you can access message delta and run step delta objects

```swift
let assistantID = "asst_abc123""
let threadID = "thread_abc123"
let messageParameter = MessageParameter(role: .user, content: "Tell me the square root of 1235")
let message = try await service.createMessage(threadID: threadID, parameters: messageParameter)
let runParameters = RunParameter(assistantID: assistantID)
let stream = try await service.createRunAndStreamMessage(threadID: threadID, parameters: runParameters)

         for try await result in stream {
            switch result {
            case .threadMessageDelta(let messageDelta):
               let content = messageDelta.delta.content.first
               switch content {
               case .imageFile, nil:
                  break
               case .text(let textContent):
                  print(textContent.text.value) // this will print the streamed response for a message.
               }
               
            case .threadRunStepDelta(let runStepDelta):
               if let toolCall = runStepDelta.delta.stepDetails.toolCalls?.first?.toolCall {
                  switch toolCall {
                  case .codeInterpreterToolCall(let toolCall):
                     print(toolCall.input ?? "") // this will print the streamed response for code interpreter tool call.
                  case .retrieveToolCall(let toolCall):
                     print("Retrieve tool call")
                  case .functionToolCall(let toolCall):
                     print("Function tool call")
                  case nil:
                     break
                  }
               }
            }
         }
```

You can go to the [Examples folder](https://github.com/jamesrochabrun/SwiftOpenAI/tree/main/Examples/SwiftOpenAIExample/SwiftOpenAIExample) in this package, navigate to the 'Configure Assistants' tab, create an assistant, and follow the subsequent steps.

### Stream support has also been added to:

[Create Thread and Run](https://platform.openai.com/docs/api-reference/runs/createThreadAndRun):

```swift
   /// Creates a thread and run with stream enabled.
   ///
   /// - Parameter parameters: The parameters needed to create a thread and run.
   /// - Returns: An AsyncThrowingStream of [AssistantStreamEvent](https://platform.openai.com/docs/api-reference/assistants-streaming/events) objects.
   /// - Throws: An error if the request fails.
   ///
   /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/createThreadAndRun).
   func createThreadAndRunStream(
      parameters: CreateThreadAndRunParameter)
   async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
```

[Submit Tool Outputs](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs):

```swift
   /// When a run has the status: "requires_action" and required_action.type is submit_tool_outputs, this endpoint can be used to submit the outputs from the tool calls once they're all completed. All outputs must be submitted in a single request. Stream enabled
   ///
   /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) to which this run belongs.
   /// - Parameter runID: The ID of the run that requires the tool output submission.
   /// - Parameter parameters: The parameters needed for the run tools output.
   /// - Returns: An AsyncThrowingStream of [AssistantStreamEvent](https://platform.openai.com/docs/api-reference/assistants-streaming/events) objects.
   /// - Throws: An error if the request fails.
   ///
   /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs).
   func submitToolOutputsToRunStream(
      threadID: String,
      runID: String,
      parameters: RunToolsOutputParameter)
   async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
```

## Azure OpenAI

This library provides support for both chat completions and chat stream completions through Azure OpenAI. Currently, `DefaultOpenAIAzureService` supports chat completions, including both streamed and non-streamed options.

For more information about Azure configuration refer to the [documentation.](https://learn.microsoft.com/en-us/azure/ai-services/openai/reference)

To instantiate `DefaultOpenAIAzureService` you need to provide a `AzureOpenAIConfiguration`

```swift
let azureConfiguration = AzureOpenAIConfiguration(
                           resourceName: "YOUR_RESOURCE_NAME", 
                           openAIAPIKey: .apiKey("YOUR_OPENAI_APIKEY), 
                           apiVersion: "THE_API_VERSION")
                           
let service = OpenAIServiceFactory.service(azureConfiguration: azureConfiguration)           
```

supported api version can be found on the azure [documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/reference#completions)

Current Supported versions

```2022-12-01```
```2023-03-15-preview```
```2023-05-15```
```2023-06-01-preview```
```2023-07-01-preview```
```2023-08-01-preview```
```2023-09-01-preview```

### Usage on [Chat completions](https://learn.microsoft.com/en-us/azure/ai-services/openai/reference#chat-completions):

```swift
let parameters = ChatCompletionParameters(
                     messages: [.init(role: .user, content: .text(prompt))], 
                     model: .custom("DEPLOYMENT_NAME") /// The deployment name you chose when you deployed the model. e.g: "gpt-35-turbo-0613"
let completionObject = try await service.startChat(parameters: parameters)
```

### Collaboration
Open a PR for any proposed change pointing it to `main` branch.
