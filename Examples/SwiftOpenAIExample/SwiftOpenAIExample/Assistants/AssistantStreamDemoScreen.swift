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
      case createRun(message: MessageObject)
      case streamRun(RunObject)

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
               .font(.largeTitle)
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
               VStack(alignment: .leading) {
                  Text("Nice! Thread created id: \(threadID)")
                  Text("Step 2: Create a message in the text filed and press the button ✈️")
                  HStack(spacing: 4) {
                     TextField("Enter prompt", text: $firstMessage, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                     Button {
                        Task {
                           try await threadProvider.createMessage(threadID: threadID, parameters: .init(role: .user, content: firstMessage))
                           if let message = threadProvider.message {
                              tutorialStage = .createRun(message: message)
                           }
                        }
                     } label: {
                        Image(systemName: "paperplane")
                     }
                  }
               }
            case .createRun(let message):
               Text("Nice! Message created with id \(message.threadID)")
               Button {
                  Task {
                     try await threadProvider.createRun(threadID: message.threadID, parameters: .init(assistantID: assistant.id, stream: true))
                     if let run = threadProvider.runObject {
                        tutorialStage = .streamRun(run)
                     }
                  }
               } label: {
                  Text("Step 3: Create a Run")
               }
               
            case .streamRun(let run):
               let _ = dump(run)
               Text("Run")
            }
         }
         .padding()
      }
   }
}
