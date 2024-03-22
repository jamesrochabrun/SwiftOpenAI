//
//  AssistantStreamDemoScreen.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 3/19/24.
//

import SwiftUI
import SwiftOpenAI

public struct AssistantStartThreadScreen: View {
   
   let assistant: AssistantObject
   let service: OpenAIService
   @State private var threadProvider: AssistantThreadConfigurationProvider
   @State private var firstMessage: String = ""
   
   @State private var tutorialStage = TutorialState.crateThread
   
   enum TutorialState {
      case crateThread
      case createMessage(threadID: String)
      case createRunAndStream(message: MessageObject)
   }
   
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
            switch tutorialStage {
            case .crateThread:
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
            case .createMessage(let threadID):
               VStack(alignment: .leading, spacing: 20) {
                  Text("Nice! Thread created id:")
                     .font(.title).bold()
                  Text("\(threadID)")
                  Text("Step 2: Create a message in the text field and press the button ✈️").font(.title)
                  Text("eg: Briefly explain SwiftUI state.")
                  HStack(spacing: 4) {
                     TextField("Enter prompt", text: $firstMessage, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                     Button {
                        Task {
                           try await threadProvider.createMessage(threadID: threadID, parameters: .init(role: .user, content: firstMessage))
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
            case .createRunAndStream(let message):
               VStack(spacing: 20) {
                  Text("Nice! Message created with id:")
                     .font(.title).bold()
                  Text("\(message.threadID)")
                     .font(.body)
                  Button {
                     Task {
                        try await threadProvider.createRunAndStreamMessage(
                           threadID: message.threadID,
                           parameters: .init(assistantID: assistant.id, stream: true))
                     }
                  } label: {
                     Text("Step 3: Run and Straem the message")
                  }
                  .buttonStyle(.borderedProminent)
                  Text(threadProvider.messageText)
                     .font(.body)
               }
            }
         }
         .padding()
      }
   }
}
