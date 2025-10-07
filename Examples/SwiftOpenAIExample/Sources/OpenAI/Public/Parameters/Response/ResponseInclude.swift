//
//  ResponseInclude.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 3/15/25.
//

import Foundation

// MARK: ResponseInclude

/// Specify additional output data to include in the model response.
public enum ResponseInclude: String {
  /// Include the sources of the web search tool call.
  case webSearchCallActionSources = "web_search_call.action.sources"

  /// Includes the outputs of python code execution in code interpreter tool call items.
  case codeInterpreterCallOutputs = "code_interpreter_call.outputs"

  /// Include image urls from the computer call output.
  case computerCallOutputImageUrl = "computer_call_output.output.image_url"

  /// Include the search results of the file search tool call.
  case fileSearchCallResults = "file_search_call.results"

  /// Include image urls from the input message.
  case messageInputImageImageUrl = "message.input_image.image_url"

  /// Include logprobs with assistant messages.
  case messageOutputTextLogprobs = "message.output_text.logprobs"

  /// Includes an encrypted version of reasoning tokens in reasoning item outputs. This enables reasoning items to be used in multi-turn conversations when using the Responses API statelessly (like when the store parameter is set to false, or when an organization is enrolled in the zero data retention program).
  case reasoningEncryptedContent = "reasoning.encrypted_content"
}
