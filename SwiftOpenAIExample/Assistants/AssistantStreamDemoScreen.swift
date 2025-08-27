//
//  AssistantStreamDemoScreen.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 3/19/24.
//

import SwiftOpenAI
import SwiftUI

// MARK: - AssistantStartThreadScreen

public struct AssistantStartThreadScreen: View {
  init(assistant: AssistantObject, service: OpenAIService) {
    self.assistant = assistant
    self.service = service
    _threadProvider = State(initialValue: AssistantThreadConfigurationProvider(service: service))
  }

  public var body: some View {
    ScrollView {
      VStack {
        Text(assistant.name ?? "No name")
          .font(.largeTitle).bold()
        Text("For function call demo type: Create an image of a cow.")
          .font(.caption)
        switch tutorialStage {
        case .crateThread:
          createThreadView

        case .createMessage(let threadID):
          createMessageView(threadID: threadID)

        case .createRunAndStream(let message):
          createRunAndStreamView(threadID: message.threadID)

        case .showStream(let threadID):
          showStreamView(threadID: threadID)
        }
      }
      .padding()
    }
  }

  enum TutorialState {
    case crateThread
    case createMessage(threadID: String)
    case createRunAndStream(message: MessageObject)
    case showStream(threadID: String)
  }

  let assistant: AssistantObject
  let service: OpenAIService

  var createThreadView: some View {
    Button {
      Task {
        try await threadProvider.createThread()
        if let threadID = threadProvider.thread?.id {
          tutorialStage = .createMessage(threadID: threadID)
        }
      }
    } label: {
      Text("Step 1: Create a thread")
    }
  }

  func createMessageView(threadID: String) -> some View {
    VStack(alignment: .leading, spacing: 20) {
      Text("Nice! Thread created id:")
        .font(.title).bold()
      Text("\(threadID)")
      Text("Step 2: Create a message in the text field and press the button ✈️").font(.title)
      Text("eg: Briefly explain SwiftUI state.")
      HStack(spacing: 4) {
        TextField("Enter prompt", text: $prompt, axis: .vertical)
          .textFieldStyle(.roundedBorder)
          .padding()
        Button {
          Task {
            try await threadProvider.createMessage(
              threadID: threadID,
              parameters: .init(role: .user, content: .stringContent(prompt)))
            if let message = threadProvider.message {
              tutorialStage = .createRunAndStream(message: message)
            }
          }
        } label: {
          Image(systemName: "paperplane")
        }
      }
    }
    .padding()
  }

  func createRunAndStreamView(threadID: String) -> some View {
    VStack(spacing: 20) {
      Text("Nice! Message created with id:")
        .font(.title2).bold()
      Text("\(threadID)")
        .font(.body)
      Text("Step 3: Run and Stream the message")
        .font(.title2)

      Button {
        Task {
          tutorialStage = .showStream(threadID: threadID)
          try await threadProvider.createRunAndStreamMessage(
            threadID: threadID,
            parameters: .init(assistantID: assistant.id))
        }
      } label: {
        Text("Run and Stream the message")
      }
      .buttonStyle(.borderedProminent)
      ChatStreamView(provider: threadProvider, prompt: prompt, assistantName: assistant.name)
    }
  }

  func showStreamView(threadID: String) -> some View {
    VStack {
      TextField("Enter prompt", text: $prompt, axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .padding()
      Button {
        Task {
          try await threadProvider.createMessage(
            threadID: threadID,
            parameters: .init(role: .user, content: .stringContent(prompt)))
          threadProvider.messageText = ""
          threadProvider.toolOuptutMessage = ""
          try await threadProvider.createRunAndStreamMessage(
            threadID: threadID,
            parameters: .init(assistantID: assistant.id))
        }
      } label: {
        Text("Run and Stream the message")
      }
      .buttonStyle(.borderedProminent)
      ChatStreamView(provider: threadProvider, prompt: prompt, assistantName: assistant.name)
    }
  }

  @State private var threadProvider: AssistantThreadConfigurationProvider
  @State private var prompt = ""

  @State private var tutorialStage = TutorialState.crateThread
}

// MARK: - ChatStreamView

struct ChatStreamView: View {
  let provider: AssistantThreadConfigurationProvider
  let prompt: String
  let assistantName: String?

  var body: some View {
    VStack(spacing: 24) {
      VStack(alignment: .leading, spacing: 16) {
        Text("User:")
          .font(.title2)
          .bold()
        Text(prompt)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      VStack(alignment: .leading, spacing: 16) {
        Text("\(assistantName ?? "Assistant"):")
          .font(.title2)
          .bold()
        if !provider.toolOuptutMessage.isEmpty {
          Text("Code Intepreter")
            .foregroundColor(.mint)
            .fontDesign(.monospaced)
            .bold()
            .font(.title3)
          Text(LocalizedStringKey(provider.toolOuptutMessage))
            .fontDesign(.monospaced)
        }
        if !provider.messageText.isEmpty {
          Text("Message")
            .font(.title3)
            .foregroundColor(.mint)
            .fontDesign(.monospaced)
            .bold()
          Text(provider.messageText)
            .font(.body)
        }
        if !provider.functionCallOutput.isEmpty {
          Text("Function Call")
            .font(.title3)
            .foregroundColor(.pink)
            .fontDesign(.monospaced)
            .bold()
          Text(provider.functionCallOutput)
            .font(.body)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
