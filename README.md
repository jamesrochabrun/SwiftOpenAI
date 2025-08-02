# SwiftOpenAI
<img width="1090" alt="repoOpenAI" src="https://github.com/jamesrochabrun/SwiftOpenAI/assets/5378604/51bc5736-a32f-4a9f-922e-209d950e28f7">

![iOS 15+](https://img.shields.io/badge/iOS-15%2B-blue.svg)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue.svg)
![watchOS 9+](https://img.shields.io/badge/watchOS-9%2B-blue.svg)
![Linux](https://img.shields.io/badge/Linux-blue.svg)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
[![swift-version](https://img.shields.io/badge/swift-5.9-brightgreen.svg)](https://github.com/apple/swift)
[![swiftui-version](https://img.shields.io/badge/swiftui-brightgreen)](https://developer.apple.com/documentation/swiftui)
[![xcode-version](https://img.shields.io/badge/xcode-15%20-brightgreen)](https://developer.apple.com/xcode/)
[![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)
[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-048754?logo=buymeacoffee)](https://buymeacoffee.com/jamesrochabrun)

An open-source Swift package designed for effortless interaction with OpenAI's public API. 

🚀 Now also available as [CLI](https://github.com/jamesrochabrun/SwiftOpenAICLI) and also as [MCP](https://github.com/jamesrochabrun/SwiftOpenAIMCP)

## Table of Contents
- [Description](#description)
- [Getting an API Key](#getting-an-api-key)
- [Installation](#installation)
- [Compatibility](#compatibility)
- [Usage](#usage)
- [Collaboration](#collaboration)

## Description

`SwiftOpenAI` is an open-source Swift package that streamlines interactions with **all** OpenAI's API endpoints, now with added support for Azure, AIProxy, and Assistant stream APIs.

### OpenAI ENDPOINTS

- [Audio](#audio)
   - [Transcriptions](#audio-transcriptions)
   - [Translations](#audio-translations)
   - [Speech](#audio-Speech)
- [Chat](#chat)
   - [Function Calling](#function-calling)
   - [Structured Outputs](#structured-outputs)
   - [Vision](#vision)
- [Response](#response)
   - [Streaming Responses](#streaming-responses)
- [Embeddings](#embeddings)
- [Fine-tuning](#fine-tuning)
- [Batch](#batch)
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
- [Vector Stores](#vector-stores)
   - [Vector store File](#vector-store-file)
   - [Vector store File Batch](#vector-store-file-batch)

## Getting an API Key

⚠️ **Important**

To interact with OpenAI services, you'll need an API key. Follow these steps to obtain one:

1. Visit [OpenAI](https://www.openai.com/).
2. Sign up for an [account](https://platform.openai.com/signup) or [log in](https://platform.openai.com/login) if you already have one.
3. Navigate to the [API key page](https://platform.openai.com/account/api-keys) and follow the instructions to generate a new API key.

For more information, consult OpenAI's [official documentation](https://platform.openai.com/docs/).

⚠️  Please take precautions to keep your API key secure per [OpenAI's guidance](https://platform.openai.com/docs/api-reference/authentication):

> Remember that your API key is a secret! Do not share it with others or expose
> it in any client-side code (browsers, apps). Production requests must be
> routed through your backend server where your API key can be securely
> loaded from an environment variable or key management service.

SwiftOpenAI has built-in support for AIProxy, which is a backend for AI apps, to satisfy this requirement.
To configure AIProxy, see the instructions [here](#aiproxy).


## Installation

### Swift Package Manager

1. Open your Swift project in Xcode.
2. Go to `File` ->  `Add Package Dependency`.
3. In the search bar, enter [this URL](https://github.com/jamesrochabrun/SwiftOpenAI).
4. Choose the version you'd like to install (see the note below).
5. Click `Add Package`.

Note: Xcode has a quirk where it defaults an SPM package's upper limit to 2.0.0. This package is beyond that
limit, so you should not accept the defaults that Xcode proposes. Instead, enter the lower bound of the
[release version](https://github.com/jamesrochabrun/SwiftOpenAI/releases) that you'd like to support, and then
tab out of the input box for Xcode to adjust the upper bound. Alternatively, you may select `branch` -> `main`
to stay on the bleeding edge.

## Compatibility

### Platform Support

SwiftOpenAI supports both Apple platforms and Linux.
- **Apple platforms** include iOS 15+, macOS 13+, and watchOS 9+.
- **Linux**: SwiftOpenAI on Linux uses AsyncHTTPClient to work around URLSession bugs in Apple's Foundation framework, and can be used with the [Vapor](https://vapor.codes/) server framework.

### OpenAI-Compatible Providers

SwiftOpenAI supports various providers that are OpenAI-compatible, including but not limited to:

- [Azure OpenAI](#azure-openai)
- [Anthropic](#anthropic)
- [Gemini](#gemini)
- [Ollama](#ollama)
- [Groq](#groq)
- [xAI](#xai)
- [OpenRouter](#openRouter)
- [DeepSeek](#deepseek)
- [AIProxy](#aiproxy)

Check OpenAIServiceFactory for convenience initializers that you can use to provide custom URLs.

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

https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/1408259-timeoutintervalforrequest

For reasoning models, ensure that you extend the timeoutIntervalForRequest in the URL session configuration to a higher value. The default is 60 seconds, which may be insufficient, as requests to reasoning models can take longer to process and respond.

To configure it:

```swift
let apiKey = "your_openai_api_key_here"
let organizationID = "your_organization_id"
let session = URLSession.shared
session.configuration.timeoutIntervalForRequest = 360 // e.g., 360 seconds or more.
let httpClient = URLSessionHTTPClientAdapter(urlSession: session)
let service = OpenAIServiceFactory.service(apiKey: apiKey, organizationID: organizationID, httpClient: httpClient)
```

That's all you need to begin accessing the full range of OpenAI endpoints.

### How to get the status code of network errors

You may want to build UI around the type of error that the API returns.
For example, a `429` means that your requests are being rate limited.
The `APIError` type has a case `responseUnsuccessful` with two associated values: a `description` and `statusCode`.
Here is a usage example using the chat completion API:

```swift
let service = OpenAIServiceFactory.service(apiKey: apiKey)
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text("hello world"))],
                                          model: .gpt4o)
do {
   let choices = try await service.startChat(parameters: parameters).choices
   // Work with choices
} catch APIError.responseUnsuccessful(let description, let statusCode) {
   print("Network error with status code: \(statusCode) and description: \(description)")
} catch {
   print(error.localizedDescription)
}
```


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
   
   public enum Model {
      case whisperOne 
      case custom(model: String)
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
   
   public enum Model {
      case whisperOne 
      case custom(model: String)
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
public struct ChatCompletionParameters: Encodable {
   
   /// A list of messages comprising the conversation so far. [Example Python code](https://cookbook.openai.com/examples/how_to_format_inputs_to_chatgpt_models)
   public var messages: [Message]
   /// ID of the model to use. See the [model endpoint compatibility](https://platform.openai.com/docs/models/how-we-use-your-data) table for details on which models work with the Chat API.
   public var model: String
   /// Whether or not to store the output of this chat completion request for use in our [model distillation](https://platform.openai.com/docs/guides/distillation) or [evals](https://platform.openai.com/docs/guides/evals) products.
   /// Defaults to false
   public var store: Bool?
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
   ///The gpt-4o-audio-preview model can also be used to [generate audio](https://platform.openai.com/docs/guides/audio). To request that this model generate both text and audio responses, you can use:
   /// ["text", "audio"]
   public var modalities: [String]?
   /// Parameters for audio output. Required when audio output is requested with modalities: ["audio"]. [Learn more.](https://platform.openai.com/docs/guides/audio)
   public var audio: Audio?
   /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics. Defaults to 0
   /// [See more information about frequency and presence penalties.](https://platform.openai.com/docs/guides/gpt/parameter-details)
   public var presencePenalty: Double?
   /// An object specifying the format that the model must output. Used to enable JSON mode.
   /// Setting to `{ type: "json_object" }` enables `JSON` mode, which guarantees the message the model generates is valid JSON.
   ///Important: when using `JSON` mode you must still instruct the model to produce `JSON` yourself via some conversation message, for example via your system message. If you don't do this, the model may generate an unending stream of whitespace until the generation reaches the token limit, which may take a lot of time and give the appearance of a "stuck" request. Also note that the message content may be partial (i.e. cut off) if `finish_reason="length"`, which indicates the generation exceeded `max_tokens` or the conversation exceeded the max context length.
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
   /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only [server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format) as they become available, with the stream terminated by a data: [DONE] message. [Example Python code](https://cookbook.openai.com/examples/how_to_stream_completions ).
   /// Defaults to false.
   var stream: Bool? = nil
   /// Options for streaming response. Only set this when you set stream: true
   var streamOptions: StreamOptions?
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
            case imageUrl(ImageDetail)
            
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
                  try container.encode(detail, forKey: .detail)
               }
               
               public init(url: URL, detail: String? = nil) {
                  self.url = url
                  self.detail = detail
               }
            }
            
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
               case .imageUrl(let imageDetail):
                  try container.encode("image_url", forKey: .type)
                  try container.encode(imageDetail, forKey: .imageUrl)
               }
            }
            
            public func hash(into hasher: inout Hasher) {
               switch self {
               case .text(let string):
                  hasher.combine(string)
               case .imageUrl(let imageDetail):
                  hasher.combine(imageDetail)
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
   
   /// [Documentation](https://platform.openai.com/docs/api-reference/chat/create#chat-create-tools)
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
      /// Omitting parameters defines a function with an empty parameter list.
      let parameters: JSONSchema?
      /// Defaults to false, Whether to enable strict schema adherence when generating the function call. If set to true, the model will follow the exact schema defined in the parameters field. Only a subset of JSON Schema is supported when strict is true. Learn more about Structured Outputs in the [function calling guide].(https://platform.openai.com/docs/api-reference/chat/docs/guides/function-calling)
      let strict: Bool?
      
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

   enum CodingKeys: String, CodingKey {
      case messages
      case model
      case store
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
   
   public init(
      messages: [Message],
      model: Model,
      store: Bool? = nil,
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
      audio: Audio? = nil,
      responseFormat: ResponseFormat? = nil,
      presencePenalty: Double? = nil,
      serviceTier: ServiceTier? = nil,
      seed: Int? = nil,
      stop: [String]? = nil,
      temperature: Double? = nil,
      topProbability: Double? = nil,
      user: String? = nil)
   {
      self.messages = messages
      self.model = model.value
      self.store = store
      self.frequencyPenalty = frequencyPenalty
      self.functionCall = functionCall
      self.toolChoice = toolChoice
      self.functions = functions
      self.tools = tools
      self.parallelToolCalls = parallelToolCalls
      self.logitBias = logitBias
      self.logprobs = logProbs
      self.topLogprobs = topLogprobs
      self.maxTokens = maxTokens
      self.n = n
      self.modalities = modalities
      self.audio = audio
      self.responseFormat = responseFormat
      self.presencePenalty = presencePenalty
      self.serviceTier = serviceTier?.rawValue
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
   /// The service tier used for processing the request. This field is only included if the service_tier parameter is specified in the request.
   public let serviceTier: String?
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
         /// The refusal message generated by the model.
         public let refusal: String?
         /// If the audio output modality is requested, this object contains data about the audio response from the model. [Learn more](https://platform.openai.com/docs/guides/audio).
         public let audio: Audio?
         
         /// Provided by the Vision API.
         public struct FinishDetails: Decodable {
            let type: String
         }
         
         public struct Audio: Decodable {
            /// Unique identifier for this audio response.
            public let id: String
            /// The Unix timestamp (in seconds) for when this audio response will no longer be accessible on the server for use in multi-turn conversations.
            public let expiresAt: Int
            /// Base64 encoded audio bytes generated by the model, in the format specified in the request.
            public let data: String
            /// Transcript of the audio generated by the model.
            public let transcript: String
            
            enum CodingKeys: String, CodingKey {
               case id
               case expiresAt = "expires_at"
               case data
               case transcript
            }
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
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text(prompt))], model: .gpt4o)
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
   /// The service tier used for processing the request. This field is only included if the service_tier parameter is specified in the request.
   public let serviceTier: String?
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
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text(prompt))], model: .gpt4o)
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
For more details about how to also uploading base 64 encoded images in iOS check the [ChatFunctionsCalllDemo](https://github.com/jamesrochabrun/SwiftOpenAI/tree/main/Examples/SwiftOpenAIExample/SwiftOpenAIExample/ChatFunctionsCall) demo on the Examples section of this package.

### Structured Outputs

#### Documentation:

- [Structured Outputs Guides](https://platform.openai.com/docs/guides/structured-outputs/structured-outputs)
- [Examples](https://platform.openai.com/docs/guides/structured-outputs/examples)
- [How to use](https://platform.openai.com/docs/guides/structured-outputs/how-to-use)
- [Supported schemas](https://platform.openai.com/docs/guides/structured-outputs/supported-schemas)

Must knowns:

- [All fields must be required](https://platform.openai.com/docs/guides/structured-outputs/all-fields-must-be-required) , To use Structured Outputs, all fields or function parameters must be specified as required.
- Although all fields must be required (and the model will return a value for each parameter), it is possible to emulate an optional parameter by using a union type with null.
- [Objects have limitations on nesting depth and size](https://platform.openai.com/docs/guides/structured-outputs/objects-have-limitations-on-nesting-depth-and-size), A schema may have up to 100 object properties total, with up to 5 levels of nesting.

- [additionalProperties](https://platform.openai.com/docs/guides/structured-outputs/additionalproperties-false-must-always-be-set-in-objects)): false must always be set in objects
additionalProperties controls whether it is allowable for an object to contain additional keys / values that were not defined in the JSON Schema.
Structured Outputs only supports generating specified keys / values, so we require developers to set additionalProperties: false to opt into Structured Outputs.
- [Key ordering](https://platform.openai.com/docs/guides/structured-outputs/key-ordering), When using Structured Outputs, outputs will be produced in the same order as the ordering of keys in the schema.
- [Recursive schemas are supported](https://platform.openai.com/docs/guides/structured-outputs/recursive-schemas-are-supported)

#### How to use Structured Outputs in SwiftOpenAI

1. Function calling: Structured Outputs via tools is available by setting strict: true within your function definition. This feature works with all models that support tools, including all models gpt-4-0613 and gpt-3.5-turbo-0613 and later. When Structured Outputs are enabled, model outputs will match the supplied tool definition.

Using this schema:

```json
{
  "schema": {
    "type": "object",
    "properties": {
      "steps": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "explanation": {
              "type": "string"
            },
            "output": {
              "type": "string"
            }
          },
          "required": ["explanation", "output"],
          "additionalProperties": false
        }
      },
      "final_answer": {
        "type": "string"
      }
    },
    "required": ["steps", "final_answer"],
    "additionalProperties": false
  }
}
```

You can use the convenient `JSONSchema` object like this:

```swift
// 1: Define the Step schema object

let stepSchema = JSONSchema(
   type: .object,
   properties: [
      "explanation": JSONSchema(type: .string),
      "output": JSONSchema(
         type: .string)
   ],
   required: ["explanation", "output"],
   additionalProperties: false
)

// 2. Define the steps Array schema.

let stepsArraySchema = JSONSchema(type: .array, items: stepSchema)

// 3. Define the final Answer schema.

let finalAnswerSchema = JSONSchema(type: .string)

// 4. Define math reponse JSON schema.

let mathResponseSchema = JSONSchema(
      type: .object,
      properties: [
         "steps": stepsArraySchema,
         "final_answer": finalAnswerSchema
      ],
      required: ["steps", "final_answer"],
      additionalProperties: false
)

let tool = ChatCompletionParameters.Tool(
            function: .init(
               name: "math_response",
               strict: true,
               parameters: mathResponseSchema))
)

let prompt = "solve 8x + 31 = 2"
let systemMessage = ChatCompletionParameters.Message(role: .system, content: .text("You are a math tutor"))
let userMessage = ChatCompletionParameters.Message(role: .user, content: .text(prompt))
let parameters = ChatCompletionParameters(
   messages: [systemMessage, userMessage],
   model: .gpt4o20240806,
   tools: [tool])

let chat = try await service.startChat(parameters: parameters)
```

2. A new option for the `response_format` parameter: developers can now supply a JSON Schema via `json_schema`, a new option for the response_format parameter. This is useful when the model is not calling a tool, but rather, responding to the user in a structured way. This feature works with our newest GPT-4o models: `gpt-4o-2024-08-06`, released today, and `gpt-4o-mini-2024-07-18`. When a response_format is supplied with strict: true, model outputs will match the supplied schema.

Using the previous schema, this is how you can implement it as json schema using the convenient `JSONSchemaResponseFormat` object:

```swift
// 1: Define the Step schema object

let stepSchema = JSONSchema(
   type: .object,
   properties: [
      "explanation": JSONSchema(type: .string),
      "output": JSONSchema(
         type: .string)
   ],
   required: ["explanation", "output"],
   additionalProperties: false
)

// 2. Define the steps Array schema.

let stepsArraySchema = JSONSchema(type: .array, items: stepSchema)

// 3. Define the final Answer schema.

let finalAnswerSchema = JSONSchema(type: .string)

// 4. Define the response format JSON schema.

let responseFormatSchema = JSONSchemaResponseFormat(
   name: "math_response",
   strict: true,
   schema: JSONSchema(
      type: .object,
      properties: [
         "steps": stepsArraySchema,
         "final_answer": finalAnswerSchema
      ],
      required: ["steps", "final_answer"],
      additionalProperties: false
   )
)

let prompt = "solve 8x + 31 = 2"
let systemMessage = ChatCompletionParameters.Message(role: .system, content: .text("You are a math tutor"))
let userMessage = ChatCompletionParameters.Message(role: .user, content: .text(prompt))
let parameters = ChatCompletionParameters(
   messages: [systemMessage, userMessage],
   model: .gpt4o20240806,
   responseFormat: .jsonSchema(responseFormatSchema))
```

SwiftOpenAI Structred outputs supports:

- [x] Tools Structured output.
- [x] Response format Structure output.
- [x] Recursive Schema.
- [x] Optional values Schema.
- [ ] Pydantic models.

We don't support Pydantic models, users need tos manually create Schemas using `JSONSchema` or `JSONSchemaResponseFormat` objects.

Pro tip 🔥 Use [iosAICodeAssistant GPT](https://chatgpt.com/g/g-qj7RuW7PY-iosai-code-assistant) to construct SwifOpenAI schemas. Just paste your JSON schema and ask the GPT to create SwiftOpenAI schemas for tools and response format.

For more details visit the Demo project for [tools](https://github.com/jamesrochabrun/SwiftOpenAI/tree/main/Examples/SwiftOpenAIExample/SwiftOpenAIExample/ChatStructureOutputTool) and [response format](https://github.com/jamesrochabrun/SwiftOpenAI/tree/main/Examples/SwiftOpenAIExample/SwiftOpenAIExample/ChatStructuredOutputs).

### Vision

[Vision](https://platform.openai.com/docs/guides/vision) API is available for use; developers must access it through the chat completions API, specifically using the gpt-4-vision-preview model or gpt-4o model. Using any other model will not provide an image description

Usage
```swift
let imageURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
let prompt = "What is this?"
let messageContent: [ChatCompletionParameters.Message.ContentType.MessageContent] = [.text(prompt), .imageUrl(.init(url: imageURL)] // Users can add as many `.imageUrl` instances to the service.
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .contentArray(messageContent))], model: .gpt4o)
let chatCompletionObject = try await service.startStreamedChat(parameters: parameters)
```

![Simulator Screen Recording - iPhone 15 - 2023-11-09 at 17 12 06](https://github.com/jamesrochabrun/SwiftOpenAI/assets/5378604/db2cbb3b-0c80-4ac8-8fe5-dbb782b270da)

For more details about how to also uploading base 64 encoded images in iOS check the [ChatVision](https://github.com/jamesrochabrun/SwiftOpenAI/tree/main/Examples/SwiftOpenAIExample/SwiftOpenAIExample/Vision) demo on the Examples section of this package.

### Response

OpenAI's most advanced interface for generating model responses. Supports text and image inputs, and text outputs. Create stateful interactions with the model, using the output of previous responses as input. Extend the model's capabilities with built-in tools for file search, web search, computer use, and more. Allow the model access to external systems and data using function calling.

- Full streaming support with `responseCreateStream` method
- Comprehensive `ResponseStreamEvent` enum covering 40+ event types
- Enhanced `InputMessage` with `id` field for response ID tracking
- Improved conversation state management with `previousResponseId`
- Real-time text streaming, function calls, and tool usage events
- Support for reasoning summaries, web search, file search, and image generation events

Related guides:

- [Quickstart](https://platform.openai.com/docs/quickstart?api-mode=responses)
- [Text inputs and outputs](https://platform.openai.com/docs/guides/text?api-mode=responses)
- [Image inputs](https://platform.openai.com/docs/guides/images?api-mode=responses)
- [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs?api-mode=responses)
- [Function calling](https://platform.openai.com/docs/guides/function-calling?api-mode=responses)
- [Conversation state](https://platform.openai.com/docs/guides/conversation-state?api-mode=responses)
- [Extend the models with tools](https://platform.openai.com/docs/guides/tools?api-mode=responses)

Parameters
```swift
/// [Creates a model response.](https://platform.openai.com/docs/api-reference/responses/create)
public struct ModelResponseParameter: Codable {

   /// Text, image, or file inputs to the model, used to generate a response.
   /// A text input to the model, equivalent to a text input with the user role.
   /// A list of one or many input items to the model, containing different content types.
   public var input: InputType

   /// Model ID used to generate the response, like gpt-4o or o1. OpenAI offers a wide range of models with
   /// different capabilities, performance characteristics, and price points.
   /// Refer to the model guide to browse and compare available models.
   public var model: String

   /// Specify additional output data to include in the model response. Currently supported values are:
   /// file_search_call.results : Include the search results of the file search tool call.
   /// message.input_image.image_url : Include image urls from the input message.
   /// computer_call_output.output.image_url : Include image urls from the computer call output.
   public var include: [String]?

   /// Inserts a system (or developer) message as the first item in the model's context.
   /// When using along with previous_response_id, the instructions from a previous response will be not be
   /// carried over to the next response. This makes it simple to swap out system (or developer) messages in new responses.
   public var instructions: String?

   /// An upper bound for the number of tokens that can be generated for a response, including visible output tokens
   /// and reasoning tokens.
   public var maxOutputTokens: Int?

   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information
   /// about the object in a structured format, and querying for objects via API or the dashboard.
   /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
   public var metadata: [String: String]?

   /// Whether to allow the model to run tool calls in parallel.
   /// Defaults to true
   public var parallelToolCalls: Bool?

   /// The unique ID of the previous response to the model. Use this to create multi-turn conversations.
   /// Learn more about conversation state.
   public var previousResponseId: String?

   /// o-series models only
   /// Configuration options for reasoning models.
   public var reasoning: Reasoning?

   /// Whether to store the generated model response for later retrieval via API.
   /// Defaults to true
   public var store: Bool?

   /// If set to true, the model response data will be streamed to the client as it is generated using server-sent events.
   public var stream: Bool?

   /// What sampling temperature to use, between 0 and 2.
   /// Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
   /// We generally recommend altering this or top_p but not both.
   /// Defaults to 1
   public var temperature: Double?

   /// Configuration options for a text response from the model. Can be plain text or structured JSON data.
   public var text: TextConfiguration?

   /// How the model should select which tool (or tools) to use when generating a response.
   /// See the tools parameter to see how to specify which tools the model can call.
   public var toolChoice: ToolChoiceMode?

   /// An array of tools the model may call while generating a response. You can specify which tool to use by setting the tool_choice parameter.
   public var tools: [Tool]?

   /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass.
   /// So 0.1 means only the tokens comprising the top 10% probability mass are considered.
   /// We generally recommend altering this or temperature but not both.
   /// Defaults to 1
   public var topP: Double?

   /// The truncation strategy to use for the model response.
   /// Defaults to disabled
   public var truncation: String?

   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
   public var user: String?
}
```

[The Response object](https://platform.openai.com/docs/api-reference/responses/object)

```swift
/// The Response object returned when retrieving a model response
public struct ResponseModel: Decodable {

   /// Unix timestamp (in seconds) of when this Response was created.
   public let createdAt: Int

   /// An error object returned when the model fails to generate a Response.
   public let error: ErrorObject?

   /// Unique identifier for this Response.
   public let id: String

   /// Details about why the response is incomplete.
   public let incompleteDetails: IncompleteDetails?

   /// Inserts a system (or developer) message as the first item in the model's context.
   public let instructions: String?

   /// An upper bound for the number of tokens that can be generated for a response, including visible output tokens
   /// and reasoning tokens.
   public let maxOutputTokens: Int?

   /// Set of 16 key-value pairs that can be attached to an object.
   public let metadata: [String: String]

   /// Model ID used to generate the response, like gpt-4o or o1.
   public let model: String

   /// The object type of this resource - always set to response.
   public let object: String

   /// An array of content items generated by the model.
   public let output: [OutputItem]

   /// Whether to allow the model to run tool calls in parallel.
   public let parallelToolCalls: Bool

   /// The unique ID of the previous response to the model. Use this to create multi-turn conversations.
   public let previousResponseId: String?

   /// Configuration options for reasoning models.
   public let reasoning: Reasoning?

   /// The status of the response generation. One of completed, failed, in_progress, or incomplete.
   public let status: String

   /// What sampling temperature to use, between 0 and 2.
   public let temperature: Double?

   /// Configuration options for a text response from the model.
   public let text: TextConfiguration

   /// How the model should select which tool (or tools) to use when generating a response.
   public let toolChoice: ToolChoiceMode

   /// An array of tools the model may call while generating a response.
   public let tools: [Tool]

   /// An alternative to sampling with temperature, called nucleus sampling.
   public let topP: Double?

   /// The truncation strategy to use for the model response.
   public let truncation: String?

   /// Represents token usage details.
   public let usage: Usage?

   /// A unique identifier representing your end-user.
   public let user: String?
   
   /// Convenience property that aggregates all text output from output_text items in the output array.
   /// Similar to the outputText property in Python and JavaScript SDKs.
   public var outputText: String? 
}
```

Input Types
```swift
// InputType represents the input to the Response API
public enum InputType: Codable {
    case string(String)  // Simple text input
    case array([InputItem])  // Array of input items for complex conversations
}

// InputItem represents different types of input
public enum InputItem: Codable {
    case message(InputMessage)  // User, assistant, system messages
    case functionToolCall(FunctionToolCall)  // Function calls
    case functionToolCallOutput(FunctionToolCallOutput)  // Function outputs
    // ... other input types
}

// InputMessage structure with support for response IDs
public struct InputMessage: Codable {
    public let role: String  // "user", "assistant", "system"
    public let content: MessageContent
    public let type: String?  // Always "message"
    public let status: String?  // "completed" for assistant messages
    public let id: String?  // Response ID for assistant messages
}

// MessageContent can be text or array of content items
public enum MessageContent: Codable {
    case text(String)
    case array([ContentItem])  // For multimodal content
}
```

Usage

Simple text input
```swift
let prompt = "What is the capital of France?"
let parameters = ModelResponseParameter(input: .string(prompt), model: .gpt4o)
let response = try await service.responseCreate(parameters)
```

Text input with reasoning
```swift
let prompt = "How much wood would a woodchuck chuck?"
let parameters = ModelResponseParameter(
    input: .string(prompt),
    model: .o3Mini,
    reasoning: Reasoning(effort: "high")
)
let response = try await service.responseCreate(parameters)
```

Image input
```swift
let textPrompt = "What is in this image?"
let imageUrl = "https://example.com/path/to/image.jpg"
let imageContent = ContentItem.imageUrl(ImageUrlContent(imageUrl: imageUrl))
let textContent = ContentItem.text(TextContent(text: textPrompt))
let message = InputItem(role: "user", content: [textContent, imageContent])
let parameters = ModelResponseParameter(input: .array([message]), model: .gpt4o)
let response = try await service.responseCreate(parameters)
```

Using tools (web search)
```swift
let prompt = "What was a positive news story from today?"
let parameters = ModelResponseParameter(
    input: .string(prompt),
    model: .gpt4o,
    tools: [Tool(type: "web_search_preview", function: nil)]
)
let response = try await service.responseCreate(parameters)
```

Using tools (file search)
```swift
let prompt = "What are the key points in the document?"
let parameters = ModelResponseParameter(
    input: .string(prompt),
    model: .gpt4o,
    tools: [
        Tool(
            type: "file_search",
            function: ChatCompletionParameters.ChatFunction(
                name: "file_search",
                strict: false,
                description: "Search through files",
                parameters: JSONSchema(
                    type: .object,
                    properties: [
                        "vector_store_ids": JSONSchema(
                            type: .array,
                            items: JSONSchema(type: .string)
                        ),
                        "max_num_results": JSONSchema(type: .integer)
                    ],
                    required: ["vector_store_ids"],
                    additionalProperties: false
                )
            )
        )
    ]
)
let response = try await service.responseCreate(parameters)
```

Function calling
```swift
let prompt = "What is the weather like in Boston today?"
let parameters = ModelResponseParameter(
    input: .string(prompt),
    model: .gpt4o,
    tools: [
        Tool(
            type: "function",
            function: ChatCompletionParameters.ChatFunction(
                name: "get_current_weather",
                strict: false,
                description: "Get the current weather in a given location",
                parameters: JSONSchema(
                    type: .object,
                    properties: [
                        "location": JSONSchema(
                            type: .string,
                            description: "The city and state, e.g. San Francisco, CA"
                        ),
                        "unit": JSONSchema(
                            type: .string,
                            enum: ["celsius", "fahrenheit"]
                        )
                    ],
                    required: ["location", "unit"],
                    additionalProperties: false
                )
            )
        )
    ],
    toolChoice: .auto
)
let response = try await service.responseCreate(parameters)
```

Retrieving a response
```swift
let responseId = "resp_abc123"
let response = try await service.responseModel(id: responseId)
```

#### Streaming Responses

The Response API supports streaming responses using Server-Sent Events (SSE). This allows you to receive partial responses as they are generated, enabling real-time UI updates and better user experience.

Stream Events
```swift
// The ResponseStreamEvent enum represents all possible streaming events
public enum ResponseStreamEvent: Decodable {
  case responseCreated(ResponseCreatedEvent)
  case responseInProgress(ResponseInProgressEvent)
  case responseCompleted(ResponseCompletedEvent)
  case responseFailed(ResponseFailedEvent)
  case outputItemAdded(OutputItemAddedEvent)
  case outputTextDelta(OutputTextDeltaEvent)
  case outputTextDone(OutputTextDoneEvent)
  case functionCallArgumentsDelta(FunctionCallArgumentsDeltaEvent)
  case reasoningSummaryTextDelta(ReasoningSummaryTextDeltaEvent)
  case error(ErrorEvent)
  // ... and many more event types
}
```

Basic Streaming Example
```swift
// Enable streaming by setting stream: true
let parameters = ModelResponseParameter(
    input: .string("Tell me a story"),
    model: .gpt4o,
    stream: true
)

// Create a stream
let stream = try await service.responseCreateStream(parameters)

// Process events as they arrive
for try await event in stream {
    switch event {
    case .outputTextDelta(let delta):
        // Append text chunk to your UI
        print(delta.delta, terminator: "")
        
    case .responseCompleted(let completed):
        // Response is complete
        print("\nResponse ID: \(completed.response.id)")
        
    case .error(let error):
        // Handle errors
        print("Error: \(error.message)")
        
    default:
        // Handle other events as needed
        break
    }
}
```

Streaming with Conversation State
```swift
// Maintain conversation continuity with previousResponseId
var previousResponseId: String? = nil
var messages: [(role: String, content: String)] = []

// First message
let firstParams = ModelResponseParameter(
    input: .string("Hello!"),
    model: .gpt4o,
    stream: true
)

let firstStream = try await service.responseCreateStream(firstParams)
var firstResponse = ""

for try await event in firstStream {
    switch event {
    case .outputTextDelta(let delta):
        firstResponse += delta.delta
        
    case .responseCompleted(let completed):
        previousResponseId = completed.response.id
        messages.append((role: "user", content: "Hello!"))
        messages.append((role: "assistant", content: firstResponse))
        
    default:
        break
    }
}

// Follow-up message with conversation context
var inputArray: [InputItem] = []

// Add conversation history
for message in messages {
    inputArray.append(.message(InputMessage(
        role: message.role,
        content: .text(message.content)
    )))
}

// Add new user message
inputArray.append(.message(InputMessage(
    role: "user",
    content: .text("How are you?")
)))

let followUpParams = ModelResponseParameter(
    input: .array(inputArray),
    model: .gpt4o,
    previousResponseId: previousResponseId,
    stream: true
)

let followUpStream = try await service.responseCreateStream(followUpParams)
// Process the follow-up stream...
```

Streaming with Tools and Function Calling
```swift
let parameters = ModelResponseParameter(
    input: .string("What's the weather in San Francisco?"),
    model: .gpt4o,
    tools: [
        Tool(
            type: "function",
            function: ChatCompletionParameters.ChatFunction(
                name: "get_weather",
                description: "Get current weather",
                parameters: JSONSchema(
                    type: .object,
                    properties: [
                        "location": JSONSchema(type: .string)
                    ],
                    required: ["location"]
                )
            )
        )
    ],
    stream: true
)

let stream = try await service.responseCreateStream(parameters)
var functionCallArguments = ""

for try await event in stream {
    switch event {
    case .functionCallArgumentsDelta(let delta):
        // Accumulate function call arguments
        functionCallArguments += delta.delta
        
    case .functionCallArgumentsDone(let done):
        // Function call is complete
        print("Function: \(done.name)")
        print("Arguments: \(functionCallArguments)")
        
    case .outputTextDelta(let delta):
        // Regular text output
        print(delta.delta, terminator: "")
        
    default:
        break
    }
}
```

Canceling a Stream
```swift
// Streams can be canceled using Swift's task cancellation
let streamTask = Task {
    let stream = try await service.responseCreateStream(parameters)
    
    for try await event in stream {
        // Check if task is cancelled
        if Task.isCancelled {
            break
        }
        
        // Process events...
    }
}

// Cancel the stream when needed
streamTask.cancel()
```

Complete Streaming Implementation Example
```swift
@MainActor
@Observable
class ResponseStreamProvider {
    var messages: [Message] = []
    var isStreaming = false
    var error: String?
    
    private let service: OpenAIService
    private var previousResponseId: String?
    private var streamTask: Task<Void, Never>?
    
    init(service: OpenAIService) {
        self.service = service
    }
    
    func sendMessage(_ text: String) {
        streamTask?.cancel()
        
        // Add user message
        messages.append(Message(role: .user, content: text))
        
        // Start streaming
        streamTask = Task {
            await streamResponse(for: text)
        }
    }
    
    private func streamResponse(for userInput: String) async {
        isStreaming = true
        error = nil
        
        // Create streaming message placeholder
        let streamingMessage = Message(role: .assistant, content: "", isStreaming: true)
        messages.append(streamingMessage)
        
        do {
            // Build conversation history
            var inputArray: [InputItem] = []
            for message in messages.dropLast(2) {
                inputArray.append(.message(InputMessage(
                    role: message.role.rawValue,
                    content: .text(message.content)
                )))
            }
            inputArray.append(.message(InputMessage(
                role: "user",
                content: .text(userInput)
            )))
            
            let parameters = ModelResponseParameter(
                input: .array(inputArray),
                model: .gpt4o,
                previousResponseId: previousResponseId,
                stream: true
            )
            
            let stream = try await service.responseCreateStream(parameters)
            var accumulatedText = ""
            
            for try await event in stream {
                guard !Task.isCancelled else { break }
                
                switch event {
                case .outputTextDelta(let delta):
                    accumulatedText += delta.delta
                    updateStreamingMessage(with: accumulatedText)
                    
                case .responseCompleted(let completed):
                    previousResponseId = completed.response.id
                    finalizeStreamingMessage(with: accumulatedText, responseId: completed.response.id)
                    
                case .error(let errorEvent):
                    throw APIError.requestFailed(description: errorEvent.message)
                    
                default:
                    break
                }
            }
        } catch {
            self.error = error.localizedDescription
            messages.removeLast() // Remove streaming message on error
        }
        
        isStreaming = false
    }
    
    private func updateStreamingMessage(with content: String) {
        if let index = messages.lastIndex(where: { $0.isStreaming }) {
            messages[index].content = content
        }
    }
    
    private func finalizeStreamingMessage(with content: String, responseId: String) {
        if let index = messages.lastIndex(where: { $0.isStreaming }) {
            messages[index].content = content
            messages[index].isStreaming = false
            messages[index].responseId = responseId
        }
    }
}
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
   /// A list of integrations to enable for your fine-tuning job.
   let integrations: [Integration]?
   /// The seed controls the reproducibility of the job. Passing in the same seed and job parameters should produce the same results, but may differ in rare cases. If a seed is not specified, one will be generated for you.
   let seed: Int?
   
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

### Batch
Parameters
```swift
public struct BatchParameter: Encodable {
   
   /// The ID of an uploaded file that contains requests for the new batch.
   /// See [upload file](https://platform.openai.com/docs/api-reference/files/create) for how to upload a file.
   /// Your input file must be formatted as a [JSONL file](https://platform.openai.com/docs/api-reference/batch/requestInput), and must be uploaded with the purpose batch.
   let inputFileID: String
   /// The endpoint to be used for all requests in the batch. Currently only /v1/chat/completions is supported.
   let endpoint: String
   /// The time frame within which the batch should be processed. Currently only 24h is supported.
   let completionWindow: String
   /// Optional custom metadata for the batch.
   let metadata: [String: String]?
   
   enum CodingKeys: String, CodingKey {
      case inputFileID = "input_file_id"
      case endpoint
      case completionWindow = "completion_window"
      case metadata
   }
}
```
Response
```swift
public struct BatchObject: Decodable {
   
   let id: String
   /// The object type, which is always batch.
   let object: String
   /// The OpenAI API endpoint used by the batch.
   let endpoint: String
   
   let errors: Error
   /// The ID of the input file for the batch.
   let inputFileID: String
   /// The time frame within which the batch should be processed.
   let completionWindow: String
   /// The current status of the batch.
   let status: String
   /// The ID of the file containing the outputs of successfully executed requests.
   let outputFileID: String
   /// The ID of the file containing the outputs of requests with errors.
   let errorFileID: String
   /// The Unix timestamp (in seconds) for when the batch was created.
   let createdAt: Int
   /// The Unix timestamp (in seconds) for when the batch started processing.
   let inProgressAt: Int
   /// The Unix timestamp (in seconds) for when the batch will expire.
   let expiresAt: Int
   /// The Unix timestamp (in seconds) for when the batch started finalizing.
   let finalizingAt: Int
   /// The Unix timestamp (in seconds) for when the batch was completed.
   let completedAt: Int
   /// The Unix timestamp (in seconds) for when the batch failed.
   let failedAt: Int
   /// The Unix timestamp (in seconds) for when the batch expired.
   let expiredAt: Int
   /// The Unix timestamp (in seconds) for when the batch started cancelling.
   let cancellingAt: Int
   /// The Unix timestamp (in seconds) for when the batch was cancelled.
   let cancelledAt: Int
   /// The request counts for different statuses within the batch.
   let requestCounts: RequestCount
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]
   
   public struct Error: Decodable {
      
      let object: String
      let data: [Data]

      public struct Data: Decodable {
         
         /// An error code identifying the error type.
         let code: String
         /// A human-readable message providing more details about the error.
         let message: String
         /// The name of the parameter that caused the error, if applicable.
         let param: String?
         /// The line number of the input file where the error occurred, if applicable.
         let line: Int?
      }
   }
   
   public struct RequestCount: Decodable {
      
      /// Total number of requests in the batch.
      let total: Int
      /// Number of requests that have been completed successfully.
      let completed: Int
      /// Number of requests that have failed.
      let failed: Int
   }
}
```
Usage

Create batch
```swift
let inputFileID = "file-abc123"
let endpoint = "/v1/chat/completions"
let completionWindow = "24h"
let parameter = BatchParameter(inputFileID: inputFileID, endpoint: endpoint, completionWindow: completionWindow, metadata: nil)
let batch = try await service.createBatch(parameters: parameters)
```

Retrieve batch
```swift
let batchID = "batch_abc123"
let batch = try await service.retrieveBatch(id: batchID)
```

Cancel batch
```swift
let batchID = "batch_abc123"
let batch = try await service.cancelBatch(id: batchID)
```

List batch
```swift
let batches = try await service.listBatch(after: nil, limit: nil)
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

This library supports latest OpenAI Image generation

- Parameters Create

```swift
/// 'Create Image':
/// https://platform.openai.com/docs/api-reference/images/create
public struct CreateImageParameters: Encodable {
   
   /// A text description of the desired image(s).
   /// The maximum length is 32000 characters for `gpt-image-1`, 1000 characters for `dall-e-2` and 4000 characters for `dall-e-3`.
   public let prompt: String
   
   // MARK: - Optional properties
   
   /// Allows to set transparency for the background of the generated image(s).
   /// This parameter is only supported for `gpt-image-1`.
   /// Must be one of `transparent`, `opaque` or `auto` (default value).
   /// When `auto` is used, the model will automatically determine the best background for the image.
   /// If `transparent`, the output format needs to support transparency, so it should be set to either `png` (default value) or `webp`.
   public let background: Background?
   
   /// The model to use for image generation. One of `dall-e-2`, `dall-e-3`, or `gpt-image-1`.
   /// Defaults to `dall-e-2` unless a parameter specific to `gpt-image-1` is used.
   public let model: Model?
   
   /// Control the content-moderation level for images generated by `gpt-image-1`.
   /// Must be either low for less restrictive filtering or auto (default value).
   public let moderation: Moderation?
   
   /// The number of images to generate. Must be between 1 and 10. For `dall-e-3`, only `n=1` is supported.
   /// Defaults to `1`
   public let n: Int?
   
   /// The compression level (0-100%) for the generated images.
   /// This parameter is only supported for `gpt-image-1` with the `webp` or `jpeg` output formats, and defaults to 100.
   public let outputCompression: Int?
   
   /// The format in which the generated images are returned.
   /// This parameter is only supported for `gpt-image-1`.
   /// Must be one of `png`, `jpeg`, or `webp`.
   public let outputFormat: OutputFormat?
   
   /// The quality of the image that will be generated.
   /// - `auto` (default value) will automatically select the best quality for the given model.
   /// - `high`, `medium` and `low` are supported for gpt-image-1.
   /// - `hd` and `standard` are supported for dall-e-3.
   /// - `standard` is the only option for dall-e-2.
   public let quality: Quality?
   
   /// The format in which generated images with dall-e-2 and dall-e-3 are returned.
   /// Must be one of `url` or `b64_json`.
   /// URLs are only valid for 60 minutes after the image has been generated.
   /// This parameter isn't supported for `gpt-image-1` which will always return base64-encoded images.
   public let responseFormat: ResponseFormat?
   
   /// The size of the generated images.
   /// - For gpt-image-1, one of `1024x1024`, `1536x1024` (landscape), `1024x1536` (portrait), or `auto` (default value)
   /// - For dall-e-3, one of `1024x1024`, `1792x1024`, or `1024x1792`
   /// - For dall-e-2, one of `256x256`, `512x512`, or `1024x1024`
   public let size: String?
   
   /// The style of the generated images.
   /// This parameter is only supported for `dall-e-3`.
   /// Must be one of `vivid` or `natural`.
   /// Vivid causes the model to lean towards generating hyper-real and dramatic images.
   /// Natural causes the model to produce more natural, less hyper-real looking images.
   public let style: Style?
   
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
   public let user: String?
}
```

- Parameters Edit

```swift
/// Creates an edited or extended image given one or more source images and a prompt.
/// This endpoint only supports `gpt-image-1` and `dall-e-2`.
public struct CreateImageEditParameters: Encodable {
   
   /// The image(s) to edit.
   /// For `gpt-image-1`, each image should be a `png`, `webp`, or `jpg` file less than 25MB.
   /// For `dall-e-2`, you can only provide one image, and it should be a square `png` file less than 4MB.
   let image: [Data]
   
   /// A text description of the desired image(s).
   /// The maximum length is 1000 characters for `dall-e-2`, and 32000 characters for `gpt-image-1`.
   let prompt: String
   
   /// An additional image whose fully transparent areas indicate where `image` should be edited.
   /// If there are multiple images provided, the mask will be applied on the first image.
   /// Must be a valid PNG file, less than 4MB, and have the same dimensions as `image`.
   let mask: Data?
   
   /// The model to use for image generation. Only `dall-e-2` and `gpt-image-1` are supported.
   /// Defaults to `dall-e-2` unless a parameter specific to `gpt-image-1` is used.
   let model: String?
   
   /// The number of images to generate. Must be between 1 and 10.
   /// Defaults to 1.
   let n: Int?
   
   /// The quality of the image that will be generated.
   /// `high`, `medium` and `low` are only supported for `gpt-image-1`.
   /// `dall-e-2` only supports `standard` quality.
   /// Defaults to `auto`.
   let quality: String?
   
   /// The format in which the generated images are returned.
   /// Must be one of `url` or `b64_json`.
   /// URLs are only valid for 60 minutes after the image has been generated.
   /// This parameter is only supported for `dall-e-2`, as `gpt-image-1` will always return base64-encoded images.
   let responseFormat: String?
   
   /// The size of the generated images.
   /// Must be one of `1024x1024`, `1536x1024` (landscape), `1024x1536` (portrait), or `auto` (default value) for `gpt-image-1`,
   /// and one of `256x256`, `512x512`, or `1024x1024` for `dall-e-2`.
   let size: String?
   
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
   let user: String?
}
```

- Parameters Variations

```swift
/// Creates a variation of a given image.
/// This endpoint only supports `dall-e-2`.
public struct CreateImageVariationParameters: Encodable {
   
   /// The image to use as the basis for the variation(s).
   /// Must be a valid PNG file, less than 4MB, and square.
   let image: Data
   
   /// The model to use for image generation. Only `dall-e-2` is supported at this time.
   /// Defaults to `dall-e-2`.
   let model: String?
   
   /// The number of images to generate. Must be between 1 and 10.
   /// Defaults to 1.
   let n: Int?
   
   /// The format in which the generated images are returned.
   /// Must be one of `url` or `b64_json`.
   /// URLs are only valid for 60 minutes after the image has been generated.
   /// Defaults to `url`.
   let responseFormat: String?
   
   /// The size of the generated images.
   /// Must be one of `256x256`, `512x512`, or `1024x1024`.
   /// Defaults to `1024x1024`.
   let size: String?
   
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
   let user: String?
}
```

- Request example

```swift
import SwiftOpenAI

let service = OpenAIServiceFactory.service(apiKey: "<YOUR_KEY>")

// ❶ Describe the image you want
let prompt = "A watercolor dragon-unicorn hybrid flying above snowy mountains"

// ❷ Build parameters with the brand-new types (commit 880a15c)
let params = CreateImageParameters(
    prompt: prompt,
    model:  .gptImage1,      // .dallE3 / .dallE2 also valid
    n:      1,               // 1-10  (only 1 for DALL-E 3)
    quality: .high,          // .hd / .standard for DALL-E 3
    size:   "1024x1024"      // use "1792x1024" or "1024x1792" for wide / tall
)

do {
    // ❸ Fire the request – returns a `CreateImageResponse`
    let result = try await service.createImages(parameters: params)
    let url    = result.data?.first?.url          // or `b64Json` for base-64
    print("Image URL:", url ?? "none")
} catch {
    print("Generation failed:", error)
}
```

For a sample app example go to the `Examples/SwiftOpenAIExample` project on this repo.

⚠️ This library Also keeps compatinility with previous Image generation.


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
let imageURLS = try await service.legacyCreateImages(parameters: createParameters).data.map(\.url)
```
```swift
/// Edit image
let data = Data(contentsOfURL:_) // the data from an image.
let image = UIImage(data: data)
let prompt = "Add a background filled with pink balloons."
let editParameters = ImageEditParameters(image: image, prompt: prompt, numberOfImages: 4)  
let imageURLS = try await service.legacyEditImage(parameters: parameters).data.map(\.url)
```
```swift
/// Image variations
let data = Data(contentsOfURL:_) // the data from an image.
let image = UIImage(data: data)
let variationParameters = ImageVariationParameters(image: image, numberOfImages: 4)
let imageURLS = try await service.legacyCreateImageVariations(parameters: parameters).data.map(\.url)
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
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public var metadata: [String: String]?
   /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
   /// Defaults to 1
   public var temperature: Double?
   /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
  /// We generally recommend altering this or temperature but not both.
   /// Defaults to 1
   public var topP: Double?
   /// Specifies the format that the model must output. Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models since gpt-3.5-turbo-1106.
   /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
   /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
   /// Defaults to `auto`
   public var responseFormat: ResponseFormat?
   
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
   /// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
   public let toolResources: ToolResources?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]?
   /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
   /// Defaults to 1
   public var temperature: Double?
   /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
  /// We generally recommend altering this or temperature but not both.
   /// Defaults to 1
   public var topP: Double?
   /// Specifies the format that the model must output. Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models since gpt-3.5-turbo-1106.
   /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
   /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
   /// Defaults to `auto`
   public var responseFormat: ResponseFormat?

   public struct Tool: Codable {
      
      /// The type of tool being defined.
      public let type: String
      public let function: ChatCompletionParameters.ChatFunction?
      
      public enum ToolType: String, CaseIterable {
         case codeInterpreter = "code_interpreter"
         case fileSearch = "file_search"
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

### Threads
Parameters
```swift
/// Create a [Thread](https://platform.openai.com/docs/api-reference/threads/createThread)
public struct CreateThreadParameters: Encodable {
   
   /// A list of [messages](https://platform.openai.com/docs/api-reference/messages) to start the thread with.
   public var messages: [MessageObject]?
      /// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
   public var toolResources: ToolResources?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public var metadata: [String: String]?
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
   /// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
   public var toolResources: ToolResources?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
   
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
   
   /// The role of the entity that is creating the message. Allowed values include:
   /// user: Indicates the message is sent by an actual user and should be used in most cases to represent user-generated messages.
   /// assistant: Indicates the message is generated by the assistant. Use this value to insert messages from the assistant into the conversation.
   let role: String
   /// The content of the message, which can be a string or an array of content parts (text, image URL, image file).
   let content: Content
   /// A list of files attached to the message, and the tools they should be added to.
   let attachments: [MessageAttachment]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
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
   /// The status of the message, which can be either in_progress, incomplete, or completed.
   public let status: String
   /// On an incomplete message, details about why the message is incomplete.
   public let incompleteDetails: IncompleteDetails?
   /// The Unix timestamp (in seconds) for when the message was completed.
   public let completedAt: Int
   /// The entity that produced the message. One of user or assistant.
   public let role: String
   /// The content of the message in array of text and/or images.
   public let content: [MessageContent]
   /// If applicable, the ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) that authored this message.
   public let assistantID: String?
   /// If applicable, the ID of the [run](https://platform.openai.com/docs/api-reference/runs) associated with the authoring of this message.
   public let runID: String?
   /// A list of files attached to the message, and the tools they were added to.
   public let attachments: [MessageAttachment]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]?
   
   enum Role: String {
      case user
      case assistant
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
let parameters = MessageParameter(role: "user", content: .stringContent(prompt)")
let message = try await service.createMessage(threadID: threadID, parameters: parameters)
```

Retrieve Message.
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
   /// Adds additional messages to the thread before creating the run.
   let additionalMessages: [MessageParameter]?
   /// Override the tools the assistant can use for this run. This is useful for modifying the behavior on a per-run basis.
   let tools: [AssistantObject.Tool]?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
   /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
   /// Optional Defaults to 1
   let temperature: Double?
   /// If true, returns a stream of events that happen during the Run as server-sent events, terminating when the Run enters a terminal state with a data: [DONE] message.
   var stream: Bool
   /// The maximum number of prompt tokens that may be used over the course of the run. The run will make a best effort to use only the number of prompt tokens specified, across multiple turns of the run. If the run exceeds the number of prompt tokens specified, the run will end with status complete. See incomplete_details for more info.
   let maxPromptTokens: Int?
   /// The maximum number of completion tokens that may be used over the course of the run. The run will make a best effort to use only the number of completion tokens specified, across multiple turns of the run. If the run exceeds the number of completion tokens specified, the run will end with status complete. See incomplete_details for more info.
   let maxCompletionTokens: Int?
   /// Controls for how a thread will be truncated prior to the run. Use this to control the intial context window of the run.
   let truncationStrategy: TruncationStrategy?
   /// Controls which (if any) tool is called by the model. none means the model will not call any tools and instead generates a message. auto is the default value and means the model can pick between generating a message or calling a tool. Specifying a particular tool like {"type": "file_search"} or {"type": "function", "function": {"name": "my_function"}} forces the model to call that tool.
   let toolChoice: ToolChoice?
   /// Specifies the format that the model must output. Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models newer than gpt-3.5-turbo-1106.
   /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
   /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
   let responseFormat: ResponseFormat?
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
   /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
   /// Defaults to 1
   let temperature: Double?
   /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
   /// We generally recommend altering this or temperature but not both.
   let topP: Double?
   /// If true, returns a stream of events that happen during the Run as server-sent events, terminating when the Run enters a terminal state with a data: [DONE] message.
   var stream: Bool = false
   /// The maximum number of prompt tokens that may be used over the course of the run. The run will make a best effort to use only the number of prompt tokens specified, across multiple turns of the run. If the run exceeds the number of prompt tokens specified, the run will end with status incomplete. See incomplete_details for more info.
   let maxPromptTokens: Int?
   /// The maximum number of completion tokens that may be used over the course of the run. The run will make a best effort to use only the number of completion tokens specified, across multiple turns of the run. If the run exceeds the number of completion tokens specified, the run will end with status complete. See incomplete_details for more info.
   let maxCompletionTokens: Int?
   /// Controls for how a thread will be truncated prior to the run. Use this to control the intial context window of the run.
   let truncationStrategy: TruncationStrategy?
   /// Controls which (if any) tool is called by the model. none means the model will not call any tools and instead generates a message. auto is the default value and means the model can pick between generating a message or calling a tool. Specifying a particular tool like {"type": "file_search"} or {"type": "function", "function": {"name": "my_function"}} forces the model to call that tool.
   let toolChoice: ToolChoice?
   /// Specifies the format that the model must output. Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models newer than gpt-3.5-turbo-1106.
   /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
   /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
   let responseFormat: ResponseFormat?
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
   public let createdAt: Int?
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
   public let expiresAt: Int?
   /// The Unix timestamp (in seconds) for when the run was started.
   public let startedAt: Int?
   /// The Unix timestamp (in seconds) for when the run was cancelled.
   public let cancelledAt: Int?
   /// The Unix timestamp (in seconds) for when the run failed.
   public let failedAt: Int?
   /// The Unix timestamp (in seconds) for when the run was completed.
   public let completedAt: Int?
   /// Details on why the run is incomplete. Will be null if the run is not incomplete.
   public let incompleteDetails: IncompleteDetails?
   /// The model that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let model: String
   /// The instructions that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let instructions: String?
   /// The list of tools that the [assistant](https://platform.openai.com/docs/api-reference/assistants) used for this run.
   public let tools: [AssistantObject.Tool]
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
   /// Usage statistics related to the run. This value will be null if the run is not in a terminal state (i.e. in_progress, queued, etc.).
   public let usage: Usage?
   /// The sampling temperature used for this run. If not set, defaults to 1.
   public let temperature: Double?
   /// The nucleus sampling value used for this run. If not set, defaults to 1.
   public let topP: Double?
   /// The maximum number of prompt tokens specified to have been used over the course of the run.
   public let maxPromptTokens: Int?
   /// The maximum number of completion tokens specified to have been used over the course of the run.
   public let maxCompletionTokens: Int?
   /// Controls for how a thread will be truncated prior to the run. Use this to control the intial context window of the run.
   public let truncationStrategy: TruncationStrategy?
   /// Controls which (if any) tool is called by the model. none means the model will not call any tools and instead generates a message. auto is the default value and means the model can pick between generating a message or calling a tool. Specifying a particular tool like {"type": "TOOL_TYPE"} or {"type": "function", "function": {"name": "my_function"}} forces the model to call that tool.
   public let toolChoice: ToolChoice?
   /// Specifies the format that the model must output. Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models newer than gpt-3.5-turbo-1106.
   /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
   /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
   public let responseFormat: ResponseFormat?
}
```
Usage

Create a Run
```swift
let assistantID = "asst_abc123"
let parameters = RunParameter(assistantID: assistantID)
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
let assistantID = "asst_abc123"
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
                  case .fileSearchToolCall(let toolCall):
                     print("File search tool call")
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

### Vector Stores
Parameters
```swift
public struct VectorStoreParameter: Encodable {
   
   /// A list of [File](https://platform.openai.com/docs/api-reference/files) IDs that the vector store should use. Useful for tools like file_search that can access files.
   let fileIDS: [String]?
   /// The name of the vector store.
   let name: String?
   /// The expiration policy for a vector store.
   let expiresAfter: ExpirationPolicy?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]?
}
```
Response
```swift
public struct VectorStoreObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   let id: String
   /// The object type, which is always vector_store.
   let object: String
   /// The Unix timestamp (in seconds) for when the vector store was created.
   let createdAt: Int
   /// The name of the vector store.
   let name: String
   /// The total number of bytes used by the files in the vector store.
   let usageBytes: Int
   
   let fileCounts: FileCount
   /// The status of the vector store, which can be either expired, in_progress, or completed. A status of completed indicates that the vector store is ready for use.
   let status: String
   /// The expiration policy for a vector store.
   let expiresAfter: ExpirationPolicy?
   /// The Unix timestamp (in seconds) for when the vector store will expire.
   let expiresAt: Int?
   /// The Unix timestamp (in seconds) for when the vector store was last active.
   let lastActiveAt: Int?
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]
   
   public struct FileCount: Decodable {
      
      /// The number of files that are currently being processed.
      let inProgress: Int
      /// The number of files that have been successfully processed.
      let completed: Int
      /// The number of files that have failed to process.
      let failed: Int
      /// The number of files that were cancelled.
      let cancelled: Int
      /// The total number of files.
      let total: Int
   }
}
```
Usage
[Create vector Store](https://platform.openai.com/docs/api-reference/vector-stores/create)
```swift
let name = "Support FAQ"
let parameters = VectorStoreParameter(name: name)
try vectorStore = try await service.createVectorStore(parameters: parameters)
```

[List Vector stores](https://platform.openai.com/docs/api-reference/vector-stores/list)
```swift
let vectorStores = try await service.listVectorStores(limit: nil, order: nil, after: nil, before: nil)
```

[Retrieve Vector store](https://platform.openai.com/docs/api-reference/vector-stores/retrieve)
```swift
let vectorStoreID = "vs_abc123"
let vectorStore = try await service.retrieveVectorStore(id: vectorStoreID)
```

[Modify Vector store](https://platform.openai.com/docs/api-reference/vector-stores/modify)
```swift
let vectorStoreID = "vs_abc123"
let vectorStore = try await service.modifyVectorStore(id: vectorStoreID)
```

[Delete Vector store](https://platform.openai.com/docs/api-reference/vector-stores/delete)
```swift
let vectorStoreID = "vs_abc123"
let deletionStatus = try await service.deleteVectorStore(id: vectorStoreID)
```

### Vector Store File
Parameters
```swift
public struct VectorStoreFileParameter: Encodable {
   
   /// A [File](https://platform.openai.com/docs/api-reference/files) ID that the vector store should use. Useful for tools like file_search that can access files.
   let fileID: String
}
```
Response
```swift
public struct VectorStoreFileObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   let id: String
   /// The object type, which is always vector_store.file.
   let object: String
   /// The total vector store usage in bytes. Note that this may be different from the original file size.
   let usageBytes: Int
   /// The Unix timestamp (in seconds) for when the vector store file was created.
   let createdAt: Int
   /// The ID of the [vector store](https://platform.openai.com/docs/api-reference/vector-stores/object) that the [File](https://platform.openai.com/docs/api-reference/files) is attached to.
   let vectorStoreID: String
   /// The status of the vector store file, which can be either in_progress, completed, cancelled, or failed. The status completed indicates that the vector store file is ready for use.
   let status: String
   /// The last error associated with this vector store file. Will be null if there are no errors.
   let lastError: LastError?
}
```

Usage
[Create vector store file](https://platform.openai.com/docs/api-reference/vector-stores-files/createFile)
```swift
let vectorStoreID = "vs_abc123"
let fileID = "file-abc123"
let parameters = VectorStoreFileParameter(fileID: fileID)
let vectoreStoreFile = try await service.createVectorStoreFile(vectorStoreID: vectorStoreID, parameters: parameters)
```

[List vector store files](https://platform.openai.com/docs/api-reference/vector-stores-files/listFiles)
```swift
let vectorStoreID = "vs_abc123"
let vectorStoreFiles = try await service.listVectorStoreFiles(vectorStoreID: vectorStoreID, limit: nil, order: nil, aftre: nil, before: nil, filter: nil)
```

[Retrieve vector store file](https://platform.openai.com/docs/api-reference/vector-stores-files/getFile)
```swift
let vectorStoreID = "vs_abc123"
let fileID = "file-abc123"
let vectoreStoreFile = try await service.retrieveVectorStoreFile(vectorStoreID: vectorStoreID, fileID: fileID)
```

[Delete vector store file](https://platform.openai.com/docs/api-reference/vector-stores-files/deleteFile)
```swift
let vectorStoreID = "vs_abc123"
let fileID = "file-abc123"
let deletionStatus = try await service.deleteVectorStoreFile(vectorStoreID: vectorStoreID, fileID: fileID)
```

### Vector Store File Batch
Parameters
```swift
public struct VectorStoreFileBatchParameter: Encodable {
   
   /// A list of [File](https://platform.openai.com/docs/api-reference/files) IDs that the vector store should use. Useful for tools like file_search that can access files.
   let fileIDS: [String]
}
```
Response
```swift
public struct VectorStoreFileBatchObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   let id: String
   /// The object type, which is always vector_store.file_batch.
   let object: String
   /// The Unix timestamp (in seconds) for when the vector store files batch was created.
   let createdAt: Int
   /// The ID of the [vector store](https://platform.openai.com/docs/api-reference/vector-stores/object) that the [File](https://platform.openai.com/docs/api-reference/files) is attached to.
   let vectorStoreID: String
   /// The status of the vector store files batch, which can be either in_progress, completed, cancelled or failed.
   let status: String
   
   let fileCounts: FileCount
}
```
Usage

[Create vector store file batch](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/createBatch)
```swift
let vectorStoreID = "vs_abc123"
let fileIDS = ["file-abc123", "file-abc456"]
let parameters = VectorStoreFileBatchParameter(fileIDS: fileIDS)
let vectorStoreFileBatch = try await service.
   createVectorStoreFileBatch(vectorStoreID: vectorStoreID, parameters: parameters)
```

[Retrieve vector store file batch](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/getBatch)
```swift
let vectorStoreID = "vs_abc123"
let batchID = "vsfb_abc123"
let vectorStoreFileBatch = try await service.retrieveVectorStoreFileBatch(vectorStoreID: vectorStoreID, batchID: batchID)
```

[Cancel vector store file batch](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/cancelBatch)
```swift
let vectorStoreID = "vs_abc123"
let batchID = "vsfb_abc123"
let vectorStoreFileBatch = try await service.cancelVectorStoreFileBatch(vectorStoreID: vectorStoreID, batchID: batchID)
```

[List vector store files in a batch](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/listBatchFiles)
```swift
let vectorStoreID = "vs_abc123"
let batchID = "vsfb_abc123"
let vectorStoreFiles = try await service.listVectorStoreFilesInABatch(vectorStoreID: vectorStoreID, batchID: batchID)
```

⚠️ We currently support Only Assistants Beta 2. If you need support for Assistants V1, you can access it in the jroch-supported-branch-for-assistants-v1 branch or in the v2.3 release.. [Check OpenAI Documentation for details on migration.](https://platform.openai.com/docs/assistants/migration))

## Anthropic

Anthropic provides OpenAI compatibility, for more, visit the [documentation](https://docs.anthropic.com/en/api/openai-sdk#getting-started-with-the-openai-sdk)

To use Claude models with `SwiftOpenAI` you can.

```swift
let anthropicApiKey = ""
let openAIService = OpenAIServiceFactory.service(apiKey: anthropicApiKey, 
                     overrideBaseURL: "https://api.anthropic.com", 
                     overrideVersion: "v1")
```

Now you can create the completio parameters like this:

```swift
let parameters = ChatCompletionParameters(
   messages: [.init(
   role: .user,
   content: "Are you Claude?")],
   model: .custom("claude-3-7-sonnet-20250219"))
```

For a more complete Anthropic Swift Package, you can use [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic)

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

## AIProxy

### What is it?

[AIProxy](https://www.aiproxy.pro) is a backend for iOS apps that proxies requests from your app to OpenAI.
Using a proxy keeps your OpenAI key secret, protecting you from unexpectedly high bills due to key theft.
Requests are only proxied if they pass your defined rate limits and Apple's [DeviceCheck](https://developer.apple.com/documentation/devicecheck) verification.
We offer AIProxy support so you can safely distribute apps built with SwiftOpenAI.

### How does my SwiftOpenAI code change?

Proxy requests through AIProxy with two changes to your Xcode project:

1. Instead of initializing `service` with:

        let apiKey = "your_openai_api_key_here"
        let service = OpenAIServiceFactory.service(apiKey: apiKey)

Use:

        let service = OpenAIServiceFactory.service(
            aiproxyPartialKey: "your_partial_key_goes_here",
            aiproxyServiceURL: "your_service_url_goes_here"
        )

The `aiproxyPartialKey` and `aiproxyServiceURL` values are provided to you on the [AIProxy developer dashboard](https://developer.aiproxy.pro)

2. Add an `AIPROXY_DEVICE_CHECK_BYPASS' env variable to Xcode. This token is provided to you in the AIProxy
   developer dashboard, and is necessary for the iOS simulator to communicate with the AIProxy backend.
    - Type `cmd shift ,` to open up the "Edit Schemes" menu in Xcode
    - Select `Run` in the sidebar
    - Select `Arguments` from the top nav
    - Add to the "Environment Variables" section (not the "Arguments Passed on Launch" section) an env
      variable with name `AIPROXY_DEVICE_CHECK_BYPASS` and value that we provided you in the AIProxy dashboard


⚠️  The `AIPROXY_DEVICE_CHECK_BYPASS` is intended for the simulator only. Do not let it leak into
a distribution build of your app (including a TestFlight distribution). If you follow the steps above,
then the constant won't leak because env variables are not packaged into the app bundle.

#### What is the `AIPROXY_DEVICE_CHECK_BYPASS` constant?

AIProxy uses Apple's [DeviceCheck](https://developer.apple.com/documentation/devicecheck) to ensure
that requests received by the backend originated from your app on a legitimate Apple device.
However, the iOS simulator cannot produce DeviceCheck tokens. Rather than requiring you to
constantly build and run on device during development, AIProxy provides a way to skip the
DeviceCheck integrity check. The token is intended for use by developers only. If an attacker gets
the token, they can make requests to your AIProxy project without including a DeviceCheck token, and
thus remove one level of protection.

#### What is the `aiproxyPartialKey` constant?

This constant is safe to include in distributed version of your app. It is one part of an
encrypted representation of your real secret key. The other part resides on AIProxy's backend.
As your app makes requests to AIProxy, the two encrypted parts are paired, decrypted, and used
to fulfill the request to OpenAI.

#### How to setup my project on AIProxy?

Please see the [AIProxy integration guide](https://www.aiproxy.pro/docs/integration-guide.html)


### ⚠️  Disclaimer

Contributors of SwiftOpenAI shall not be liable for any damages or losses caused by third parties.
Contributors of this library provide third party integrations as a convenience. Any use of a third
party's services are assumed at your own risk.


## Ollama

Ollama now has built-in compatibility with the OpenAI [Chat Completions API](https://github.com/ollama/ollama/blob/main/docs/openai.md), making it possible to use more tooling and applications with Ollama locally.

<img width="783" alt="Screenshot 2024-06-24 at 11 52 35 PM" src="https://github.com/jamesrochabrun/SwiftOpenAI/assets/5378604/db2264cb-408c-471d-b65b-912795c082ed">

### ⚠️ Important

Remember that these models run locally, so you need to download them. If you want to use llama3, you can open the terminal and run the following command:

```python
ollama pull llama3
```

you can follow [Ollama documentation](https://github.com/ollama/ollama/blob/main/docs/openai.md) for more.

### How to use this models locally using SwiftOpenAI?

To use local models with an `OpenAIService` in your application, you need to provide a URL. 

```swift
let service = OpenAIServiceFactory.service(baseURL: "http://localhost:11434")
```

Then you can use the completions API as follows:

```swift
let prompt = "Tell me a joke"
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text(prompt))], model: .custom("llama3"))
let chatCompletionObject = service.startStreamedChat(parameters: parameters)
```

⚠️ Note: You can probably use the `OpenAIServiceFactory.service(apiKey:overrideBaseURL:proxyPath)` for any OpenAI compatible service.

### Resources:

[Ollama OpenAI compatibility docs.](https://github.com/ollama/ollama/blob/main/docs/openai.md)
[Ollama OpenAI compatibility blog post.](https://ollama.com/blog/openai-compatibility)

### Notes

You can also use this service constructor to provide any URL or apiKey if you need.

```swift
let service = OpenAIServiceFactory.service(apiKey: "YOUR_API_KEY", baseURL: "http://localhost:11434")
```

## Groq

<img width="792" alt="Screenshot 2024-10-11 at 11 49 04 PM" src="https://github.com/user-attachments/assets/7afb36a2-b2d8-4f89-9592-f4cece20d469">

Groq API is mostly compatible with OpenAI's client libraries like `SwiftOpenAI` to use Groq using this library you just need to create an instance of `OpenAIService` like this:

```swift
let apiKey = "your_api_key"
let service = OpenAIServiceFactory.service(apiKey: apiKey, overrideBaseURL: "https://api.groq.com/", proxyPath: "openai")

```

For Supported API's using Groq visit its [documentation](https://console.groq.com/docs/openai).

## xAI

<img width="792" alt="xAI Grok" src="https://github.com/user-attachments/assets/596ef28a-b8ea-4868-b37c-36ae28d77a30">

xAI provides an OpenAI-compatible completion API to its Grok models. You can use the OpenAI SDK to access these models.

```swift
let apiKey = "your_api_xai_key"
let service = OpenAIServiceFactory.service(apiKey: apiKey, overrideBaseURL: "https://api.x.ai", overrideVersion: "v1")
```

For more information about the `xAI` api visit its [documentation](https://docs.x.ai/docs/overview).

## OpenRouter

<img width="734" alt="Image" src="https://github.com/user-attachments/assets/2d658d07-0b41-4b5f-a094-ec7856f6fe98" />

[OpenRouter](https://openrouter.ai/docs/quick-start) provides an OpenAI-compatible completion API to 314 models & providers that you can call directly, or using the OpenAI SDK. Additionally, some third-party SDKs are available.

```swift

// Creating the service

let apiKey = "your_api_key"
let servcie = OpenAIServiceFactory.service(apiKey: apiKey, 
   overrideBaseURL: "https://openrouter.ai", 
   proxyPath: "api",
   extraHeaders: [
      "HTTP-Referer": "<YOUR_SITE_URL>", // Optional. Site URL for rankings on openrouter.ai.
         "X-Title": "<YOUR_SITE_NAME>"  // Optional. Site title for rankings on openrouter.ai.
   ])

// Making a request

let prompt = "What is the Manhattan project?"
let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text(prompt))], model: .custom("deepseek/deepseek-r1:free"))
let stream = service.startStreamedChat(parameters: parameters)
```

For more inofrmation about the `OpenRouter` api visit its [documentation](https://openrouter.ai/docs/quick-start).

## DeepSeek

![Image](https://github.com/user-attachments/assets/7733f011-691a-4de7-b715-c090e3647304)

The [DeepSeek](https://api-docs.deepseek.com/) API uses an API format compatible with OpenAI. By modifying the configuration, you can use SwiftOpenAI to access the DeepSeek API.

Creating the service

```swift

let apiKey = "your_api_key"
let service = OpenAIServiceFactory.service(
   apiKey: apiKey,
   overrideBaseURL: "https://api.deepseek.com")
```

Non-Streaming Example

```swift
let prompt = "What is the Manhattan project?"
let parameters = ChatCompletionParameters(
    messages: [.init(role: .user, content: .text(prompt))],
    model: .custom("deepseek-reasoner")
)

do {
    let result = try await service.chat(parameters: parameters)
    
    // Access the response content
    if let content = result.choices.first?.message.content {
        print("Response: \(content)")
    }
    
    // Access reasoning content if available
    if let reasoning = result.choices.first?.message.reasoningContent {
        print("Reasoning: \(reasoning)")
    }
} catch {
    print("Error: \(error)")
}
```

Streaming Example

```swift
let prompt = "What is the Manhattan project?"
let parameters = ChatCompletionParameters(
    messages: [.init(role: .user, content: .text(prompt))],
    model: .custom("deepseek-reasoner")
)

// Start the stream
do {
    let stream = try await service.startStreamedChat(parameters: parameters)
    for try await result in stream {
        let content = result.choices.first?.delta.content ?? ""
        self.message += content
        
        // Optional: Handle reasoning content if available
        if let reasoning = result.choices.first?.delta.reasoningContent {
            self.reasoningMessage += reasoning
        }
    }
} catch APIError.responseUnsuccessful(let description, let statusCode) {
    self.errorMessage = "Network error with status code: \(statusCode) and description: \(description)"
} catch {
    self.errorMessage = error.localizedDescription
}
```

Notes

- The DeepSeek API is compatible with OpenAI's format but uses different model names
- Use .custom("deepseek-reasoner") to specify the DeepSeek model
- The `reasoningContent` field is optional and specific to DeepSeek's API
- Error handling follows the same pattern as standard OpenAI requests.

For more inofrmation about the `DeepSeek` api visit its [documentation](https://api-docs.deepseek.com).

## Gemini

<img width="982" alt="Screenshot 2024-11-12 at 10 53 43 AM" src="https://github.com/user-attachments/assets/cebc18fe-b96d-4ffe-912e-77d625249cf2">

Gemini is now accessible from the OpenAI Library. Announcement .
`SwiftOpenAI` support all OpenAI endpoints, however Please refer to Gemini documentation to understand which API's are currently compatible' 

Gemini is now accessible through the OpenAI Library. See the announcement [here](https://developers.googleblog.com/en/gemini-is-now-accessible-from-the-openai-library/).
SwiftOpenAI supports all OpenAI endpoints. However, please refer to the [Gemini documentation](https://ai.google.dev/gemini-api/docs/openai) to understand which APIs are currently compatible."


You can instantiate a `OpenAIService` using your Gemini token like this...

```swift
let geminiAPIKey = "your_api_key"
let baseURL = "https://generativelanguage.googleapis.com"
let version = "v1beta"

let service = OpenAIServiceFactory.service(
   apiKey: apiKey, 
   overrideBaseURL: baseURL, 
   overrideVersion: version)
```

You can now create a chat request using the .custom model parameter and pass the model name as a string.

```swift
let parameters = ChatCompletionParameters(
      messages: [.init(
      role: .user,
      content: content)],
      model: .custom("gemini-1.5-flash"))

let stream = try await service.startStreamedChat(parameters: parameters)
```

## Collaboration
Open a PR for any proposed change pointing it to `main` branch. Unit tests are highly appreciated ❤️

