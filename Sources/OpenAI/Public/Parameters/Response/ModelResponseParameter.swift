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
   
   /// Text, image, or file inputs to the model, used to generate a response.
   /// A text input to the model, equivalent to a text input with the user role.
   /// A list of one or many input items to the [model](https://platform.openai.com/docs/models), containing different content types.
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
   /// and [reasoning tokens](https://platform.openai.com/docs/guides/reasoning).
   public var maxOutputTokens: Int?
   
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
   
   /// o-series models only
   /// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning)
   public var reasoning: Reasoning?
   
   /// Defaults to true
   /// Whether to store the generated model response for later retrieval via API.
   public var store: Bool?
   
   /// If set to true, the model response data will be streamed to the client as it is generated using [server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#Event_stream_format).
   /// See the [Streaming section below](https://platform.openai.com/docs/api-reference/responses-streaming) for more information.
   public var stream: Bool?
   
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
   
   /// Defaults to disabled
   /// The truncation strategy to use for the model response.
   /// auto: If the context of this response and previous ones exceeds the model's context window size, the
   /// model will truncate the response to fit the context window by dropping input items in the middle of the conversation.
   /// disabled (default): If a model response will exceed the context window size for a model, the request
   /// will fail with a 400 error.
   public var truncation: String?
   
   /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more.](https://platform.openai.com/docs/guides/safety-best-practices#end-user-ids)
   public var user: String?
   
   /// Audio detail structure
   public struct AudioDetail: Codable {
      public var data: String
      public var format: String
      
      public init(data: String, format: String) {
         self.data = data
         self.format = format
      }
   }
   
   /// Coding keys for ModelResponseParameter
   enum CodingKeys: String, CodingKey {
      case input
      case model
      case include
      case instructions
      case maxOutputTokens = "max_output_tokens"
      case metadata
      case parallelToolCalls = "parallel_tool_calls"
      case previousResponseId = "previous_response_id"
      case reasoning
      case store
      case stream
      case temperature
      case text
      case toolChoice = "tool_choice"
      case tools
      case topP = "top_p"
      case truncation
      case user
   }
   
   /// Initialize a new ModelResponseParameter
   public init(
      input: InputType,
      model: Model,
      include: [String]? = nil,
      instructions: String? = nil,
      maxOutputTokens: Int? = nil,
      metadata: [String: String]? = nil,
      parallelToolCalls: Bool? = nil,
      previousResponseId: String? = nil,
      reasoning: Reasoning? = nil,
      store: Bool? = nil,
      stream: Bool? = nil,
      temperature: Double? = nil,
      text: TextConfiguration? = nil,
      toolChoice: ToolChoiceMode? = nil,
      tools: [Tool]? = nil,
      topP: Double? = nil,
      truncation: String? = nil,
      user: String? = nil
   ) {
      self.input = input
      self.model = model.value
      self.include = include
      self.instructions = instructions
      self.maxOutputTokens = maxOutputTokens
      self.metadata = metadata
      self.parallelToolCalls = parallelToolCalls
      self.previousResponseId = previousResponseId
      self.reasoning = reasoning
      self.store = store
      self.stream = stream
      self.temperature = temperature
      self.text = text
      self.toolChoice = toolChoice
      self.tools = tools
      self.topP = topP
      self.truncation = truncation
      self.user = user
   }
}
