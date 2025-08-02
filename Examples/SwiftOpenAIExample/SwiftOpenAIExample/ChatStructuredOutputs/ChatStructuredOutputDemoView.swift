//
//  ChatStructuredOutputDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 8/10/24.
//

import Foundation
import SwiftOpenAI
import SwiftUI

/// Schema demo
///
/// https://openai.com/index/introducing-structured-outputs-in-the-api/
///
/// "response_format": {
/// "type": "json_schema",
/// "json_schema": {
/// "name": "math_response",
/// "strict": true,
/// "schema": {
/// "type": "object",
/// "properties": {
/// "steps": {
/// "type": "array",
/// "items": {
/// "type": "object",
/// "properties": {
/// "explanation": {
/// "type": "string"
/// },
/// "output": {
/// "type": "string"
/// }
/// },
/// "required": ["explanation", "output"],
/// "additionalProperties": false
/// }
/// },
/// "final_answer": {
/// "type": "string"
/// }
/// },
/// "required": ["steps", "final_answer"],
/// "additionalProperties": false
/// }
/// }
/// }

// Steps to define the above Schema:

// 1: Define the Step schema object

let stepSchema = JSONSchema(
  type: .object,
  properties: [
    "explanation": JSONSchema(type: .string),
    "output": JSONSchema(
      type: .string),
  ],
  required: ["explanation", "output"],
  additionalProperties: false)

// 2. Define the steps Array schema.

let stepsArraySchema = JSONSchema(type: .array, items: stepSchema)

/// 3. Define the final Answer schema.
let finalAnswerSchema = JSONSchema(type: .string)

/// 4. Define the response format JSON schema.
let responseFormatSchema = JSONSchemaResponseFormat(
  name: "math_response",
  strict: true,
  schema: JSONSchema(
    type: .object,
    properties: [
      "steps": stepsArraySchema,
      "final_answer": finalAnswerSchema,
    ],
    required: ["steps", "final_answer"],
    additionalProperties: false))

// MARK: - ChatStructuredOutputDemoView

// We can also handle optional values.
//
// let weatherSchema = JSONSchemaResponseFormat(
// name: "get_weather",
// description: "Fetches the weather in the given location",
// strict: true,
// schema: JSONSchema(
// type: .object,
// properties: [
// "location": JSONSchema(
// type: .string,
// description: "The location to get the weather for"
// ),
// "unit": JSONSchema(
// type: .optional(.string),
// description: "The unit to return the temperature in",
// enum: ["F", "C"]
// ),
// "thinking": .init(
// type: .object,
// description: "your thinking",
// properties: ["step": .init(type: .string)],
// required: ["step"])
// ],
// required: ["location", "unit", "thinking"]
// )
// )

struct ChatStructuredOutputDemoView: View {
  init(service: OpenAIService) {
    _chatProvider = State(initialValue: ChatStructuredOutputProvider(service: service))
  }

  enum ChatConfig {
    case chatCompletion
    case chatCompeltionStream
  }

  var body: some View {
    ScrollView {
      VStack {
        picker
        textArea
        Text(chatProvider.errorMessage)
          .foregroundColor(.red)
        switch selectedSegment {
        case .chatCompeltionStream:
          streamedChatResultView
        case .chatCompletion:
          chatCompletionResultView
        }
      }
    }
    .overlay(
      Group {
        if isLoading {
          ProgressView()
        } else {
          EmptyView()
        }
      })
  }

  var picker: some View {
    Picker("Options", selection: $selectedSegment) {
      Text("Chat Completion").tag(ChatConfig.chatCompletion)
      Text("Chat Completion stream").tag(ChatConfig.chatCompeltionStream)
    }
    .pickerStyle(SegmentedPickerStyle())
    .padding()
  }

  var textArea: some View {
    HStack(spacing: 4) {
      TextField("Enter prompt", text: $prompt, axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .padding()
      Button {
        Task {
          isLoading = true
          defer { isLoading = false } // ensure isLoading is set to false when the

          let content = ChatCompletionParameters.Message.ContentType.text(prompt)
          prompt = ""
          let parameters = ChatCompletionParameters(
            messages: [
              .init(role: .system, content: .text("You are a helpful math tutor.")),
              .init(
                role: .user,
                content: content),
            ],
            model: .gpt4o20240806,
            responseFormat: .jsonSchema(responseFormatSchema))
          switch selectedSegment {
          case .chatCompletion:
            try await chatProvider.startChat(parameters: parameters)
          case .chatCompeltionStream:
            try await chatProvider.startStreamedChat(parameters: parameters)
          }
        }
      } label: {
        Image(systemName: "paperplane")
      }
      .buttonStyle(.bordered)
    }
    .padding()
  }

  /// stream = `false`
  var chatCompletionResultView: some View {
    ForEach(Array(chatProvider.messages.enumerated()), id: \.offset) { _, val in
      VStack(spacing: 0) {
        Text("\(val)")
      }
    }
  }

  /// stream = `true`
  var streamedChatResultView: some View {
    VStack {
      Button("Cancel stream") {
        chatProvider.cancelStream()
      }
      Text(chatProvider.message)
    }
  }

  @State private var chatProvider: ChatStructuredOutputProvider
  @State private var isLoading = false
  @State private var prompt = ""
  @State private var selectedSegment = ChatConfig.chatCompeltionStream
}
