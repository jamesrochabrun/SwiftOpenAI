//
//  AssistantThreadConfigurationProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 3/19/24.
//

import Foundation
import SwiftOpenAI

@Observable
class AssistantThreadConfigurationProvider {
  // MARK: - Initializer

  init(service: OpenAIService) {
    self.service = service
  }

  var thread: ThreadObject?
  var message: MessageObject?
  var runObject: RunObject?
  var messageText = ""
  var toolOuptutMessage = ""
  var functionCallOutput = ""

  func createThread()
    async throws
  {
    do {
      thread = try await service.createThread(parameters: .init())
    } catch {
      print("THREAD ERROR: \(error)")
    }
  }

  func createMessage(
    threadID: String,
    parameters: MessageParameter)
    async throws
  {
    do {
      message = try await service.createMessage(threadID: threadID, parameters: parameters)
    } catch {
      print("THREAD ERROR: \(error)")
    }
  }

  func createRunAndStreamMessage(
    threadID: String,
    parameters: RunParameter)
    async throws
  {
    do {
      let stream = try await service.createRunStream(threadID: threadID, parameters: parameters)
      for try await result in stream {
        switch result {
        case .threadMessageDelta(let messageDelta):
          let content = messageDelta.delta.content.first
          switch content {
          case .imageFile, .imageUrl, nil:
            break
          case .text(let textContent):
            messageText += textContent.text.value
          }

        case .threadRunStepDelta(let runStepDelta):
          let toolCall = runStepDelta.delta.stepDetails.toolCalls?.first?.toolCall
          switch toolCall {
          case .codeInterpreterToolCall(let toolCall):
            toolOuptutMessage += toolCall.input ?? ""
          case .fileSearchToolCall(let toolCall):
            print("PROVIDER: File search tool call \(toolCall)")
          case .functionToolCall(let toolCall):
            functionCallOutput += toolCall.arguments
          case nil:
            print("PROVIDER: tool call nil")
          }

        case .threadRunCompleted(let runObject):
          print("PROVIDER: the run is completed - \(runObject)")

        default: break
        }
      }
    } catch {
      print("THREAD ERROR: \(error)")
    }
  }

  // MARK: - Private Properties

  private let service: OpenAIService
}
