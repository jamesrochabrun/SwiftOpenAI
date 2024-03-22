//
//  File.swift
//  
//
//  Created by James Rochabrun on 10/17/23.
//

import Foundation

struct DefaultOpenAIService: OpenAIService {
   
   let session: URLSession
   let decoder: JSONDecoder
   
   private let sessionID = UUID().uuidString
   /// [authentication](https://platform.openai.com/docs/api-reference/authentication)
   private let apiKey: Authorization
   /// [organization](https://platform.openai.com/docs/api-reference/organization-optional)
   private let organizationID: String?
   
   private static let assistantsBeta = "assistants=v1"
   
   init(
      apiKey: String,
      organizationID: String? = nil,
      configuration: URLSessionConfiguration = .default,
      decoder: JSONDecoder = .init())
   {
      self.session = URLSession(configuration: configuration)
      self.decoder = decoder
      self.apiKey = .bearer(apiKey)
      self.organizationID = organizationID
   }
   
   // MARK: Audio
   
   func createTranscription(
      parameters: AudioTranscriptionParameters)
      async throws -> AudioObject
   {
      let request = try OpenAIAPI.audio(.transcriptions).multiPartRequest(apiKey: apiKey, organizationID: organizationID, method: .post,  params: parameters)
      return try await fetch(type: AudioObject.self, with: request)
   }
   
   func createTranslation(
      parameters: AudioTranslationParameters)
      async throws -> AudioObject
   {
      let request = try OpenAIAPI.audio(.translations).multiPartRequest(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: AudioObject.self, with: request)
   }
   
   func createSpeech(
      parameters: AudioSpeechParameters)
      async throws -> AudioSpeechObject
   {
      let request = try OpenAIAPI.audio(.speech).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      let data = try await fetchAudio(with: request)
      return AudioSpeechObject(output: data)
   }
   
   // MARK: Chat
   
   func startChat(
      parameters: ChatCompletionParameters)
      async throws -> ChatCompletionObject
   {
      var chatParameters = parameters
      chatParameters.stream = false
      let request = try OpenAIAPI.chat.request(apiKey: apiKey, organizationID: organizationID, method: .post, params: chatParameters)
      return try await fetch(type: ChatCompletionObject.self, with: request)
   }
   
   func startStreamedChat(
      parameters: ChatCompletionParameters)
      async throws -> AsyncThrowingStream<ChatCompletionChunkObject, Error>
   {
      var chatParameters = parameters
      chatParameters.stream = true
      let request = try OpenAIAPI.chat.request(apiKey: apiKey, organizationID: organizationID, method: .post, params: chatParameters)
      return try await fetchStream(type: ChatCompletionChunkObject.self, with: request)
   }
   
   // MARK: Embeddings
   
   func createEmbeddings(
      parameters: EmbeddingParameter)
      async throws -> OpenAIResponse<EmbeddingObject>
   {
      let request = try OpenAIAPI.embeddings.request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: OpenAIResponse<EmbeddingObject>.self, with: request)
   }
   
   // MARK: Fine-tuning
   
   func createFineTuningJob(
      parameters: FineTuningJobParameters)
      async throws -> FineTuningJobObject
   {
      let request = try OpenAIAPI.fineTuning(.create).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: FineTuningJobObject.self, with: request)
   }
   
   func listFineTuningJobs(
      after lastJobID: String? = nil,
      limit: Int? = nil)
      async throws -> OpenAIResponse<FineTuningJobObject>
   {
      var queryItems: [URLQueryItem] = []
      if let lastJobID, let limit {
         queryItems = [.init(name: "after", value: lastJobID), .init(name: "limit", value: "\(limit)")]
      } else if let lastJobID {
         queryItems = [.init(name: "after", value: lastJobID)]
      } else if let limit {
         queryItems = [.init(name: "limit", value: "\(limit)")]
      }
      
      let request = try OpenAIAPI.fineTuning(.list).request(apiKey: apiKey, organizationID: organizationID, method: .get, queryItems: queryItems)
      return try await fetch(type: OpenAIResponse<FineTuningJobObject>.self, with: request)
   }
   
   func retrieveFineTuningJob(
      id: String)
      async throws -> FineTuningJobObject
   {
      let request = try OpenAIAPI.fineTuning(.retrieve(jobID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .get)
      return try await fetch(type: FineTuningJobObject.self, with: request)
   }
   
   func cancelFineTuningJobWith(
      id: String)
      async throws -> FineTuningJobObject
   {
      let request = try OpenAIAPI.fineTuning(.cancel(jobID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .post)
      return try await fetch(type: FineTuningJobObject.self, with: request)
   }
   
   func listFineTuningEventsForJobWith(
      id: String,
      after lastEventId: String? = nil,
      limit: Int? = nil)
      async throws -> OpenAIResponse<FineTuningJobEventObject>
   {
      var queryItems: [URLQueryItem] = []
      if let lastEventId, let limit {
         queryItems = [.init(name: "after", value: lastEventId), .init(name: "limit", value: "\(limit)")]
      } else if let lastEventId {
         queryItems = [.init(name: "after", value: lastEventId)]
      } else if let limit {
         queryItems = [.init(name: "limit", value: "\(limit)")]
      }
      let request = try OpenAIAPI.fineTuning(.events(jobID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .get, queryItems: queryItems)
      return try await fetch(type: OpenAIResponse<FineTuningJobEventObject>.self, with: request)
   }
   
   // MARK: Files
   
   func listFiles()
      async throws -> OpenAIResponse<FileObject>
   {
      let request = try OpenAIAPI.file(.list).request(apiKey: apiKey, organizationID: organizationID, method: .get)
      return try await fetch(type: OpenAIResponse<FileObject>.self, with: request)
   }
   
   func uploadFile(
      parameters: FileParameters)
      async throws -> FileObject
   {
      let request = try OpenAIAPI.file(.upload).multiPartRequest(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: FileObject.self, with: request)
   }
   
   func deleteFileWith(
      id: String)
      async throws -> FileObject.DeletionStatus
   {
      let request = try OpenAIAPI.file(.delete(fileID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .delete)
      return try await fetch(type: FileObject.DeletionStatus.self, with: request)
   }
   
   func retrieveFileWith(
      id: String)
      async throws -> FileObject
   {
      let request = try OpenAIAPI.file(.retrieve(fileID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .get)
      return try await fetch(type: FileObject.self, with: request)
   }
   
   func retrieveContentForFileWith(
      id: String)
      async throws -> [[String: Any]]
   {
      let request = try OpenAIAPI.file(.retrieveFileContent(fileID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .get)
      return try await fetchContentsOfFile(request: request)
   }
   
   // MARK: Images
   
   func createImages(
      parameters: ImageCreateParameters)
      async throws -> OpenAIResponse<ImageObject>
   {
      let request = try OpenAIAPI.images(.generations).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: OpenAIResponse<ImageObject>.self,  with: request)
   }
   
   func editImage(
      parameters: ImageEditParameters)
      async throws -> OpenAIResponse<ImageObject>
   {
      let request = try OpenAIAPI.images(.edits).multiPartRequest(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: OpenAIResponse<ImageObject>.self, with: request)
   }
   
   func createImageVariations(
      parameters: ImageVariationParameters)
      async throws -> OpenAIResponse<ImageObject>
   {
      let request = try OpenAIAPI.images(.variations).multiPartRequest(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: OpenAIResponse<ImageObject>.self, with: request)
   }
   
   // MARK: Models
   
   func listModels()
      async throws -> OpenAIResponse<ModelObject>
   {
      let request = try OpenAIAPI.model(.list).request(apiKey: apiKey, organizationID: organizationID, method: .get)
      return try await fetch(type: OpenAIResponse<ModelObject>.self,  with: request)
   }
   
   func retrieveModelWith(
      id: String)
      async throws -> ModelObject
   {
      let request = try OpenAIAPI.model(.retrieve(modelID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .get)
      return try await fetch(type: ModelObject.self,  with: request)
   }
   
   func deleteFineTuneModelWith(
      id: String)
      async throws -> ModelObject.DeletionStatus
   {
      let request = try OpenAIAPI.model(.deleteFineTuneModel(modelID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .delete)
      return try await fetch(type: ModelObject.DeletionStatus.self,  with: request)
   }
   
   // MARK: Moderations
   
   func createModerationFromText(
      parameters: ModerationParameter<String>)
      async throws -> ModerationObject
   {
      let request = try OpenAIAPI.moderations.request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: ModerationObject.self, with: request)
   }
   
   func createModerationFromTexts(
      parameters: ModerationParameter<[String]>)
      async throws -> ModerationObject
   {
      let request = try OpenAIAPI.moderations.request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: ModerationObject.self, with: request)
   }
   
   // MARK: Assistants [BETA]
   
   func createAssistant(
      parameters: AssistantParameters)
      async throws -> AssistantObject
   {
      let request = try OpenAIAPI.assistant(.create).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: AssistantObject.self, with: request)
   }
   
   func retrieveAssistant(
      id: String)
      async throws -> AssistantObject
   {
      let request = try OpenAIAPI.assistant(.retrieve(assistantID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .get, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: AssistantObject.self, with: request)
   }
   
   func modifyAssistant(
      id: String,
      parameters: AssistantParameters)
      async throws -> AssistantObject
   {
      let request = try OpenAIAPI.assistant(.modify(assistantID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: AssistantObject.self, with: request)
   }
   
   func deleteAssistant(
      id: String)
      async throws -> AssistantObject.DeletionStatus
   {
      let request = try OpenAIAPI.assistant(.delete(assistantID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .delete, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: AssistantObject.DeletionStatus.self, with: request)
   }
   
   func listAssistants(
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil)
      async throws -> OpenAIResponse<AssistantObject>
   {
      var queryItems: [URLQueryItem] = []
      if let limit {
         queryItems.append(.init(name: "limit", value: "\(limit)"))
      }
      if let order {
         queryItems.append(.init(name: "order", value: order))
      }
      if let after {
         queryItems.append(.init(name: "after", value: after))
      }
      if let before {
         queryItems.append(.init(name: "before", value: before))
      }
      let request = try OpenAIAPI.assistant(.list).request(apiKey: apiKey, organizationID: organizationID, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: OpenAIResponse<AssistantObject>.self, with: request)
   }
   
   // MARK: AssistantsFileObject [BETA]
   
   func createAssistantFile(
      assistantID: String,
      parameters: AssistantFileParamaters)
      async throws -> AssistantFileObject
   {
      let request = try OpenAIAPI.assistantFile(.create(assistantID: assistantID)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: AssistantFileObject.self, with: request)
   }
   
   func retrieveAssistantFile(
      assistantID: String,
      fileID: String)
      async throws -> AssistantFileObject
   {
      let request = try OpenAIAPI.assistantFile(.retrieve(assistantID: assistantID, fileID: fileID)).request(apiKey: apiKey, organizationID: organizationID, method: .get, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: AssistantFileObject.self, with: request)
   }
   
   func deleteAssistantFile(
      assistantID: String,
      fileID: String)
      async throws -> AssistantFileObject.DeletionStatus
   {
      let request = try OpenAIAPI.assistantFile(.delete(assistantID: assistantID, fileID: fileID)).request(apiKey: apiKey, organizationID: organizationID, method: .delete, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: AssistantFileObject.DeletionStatus.self, with: request)
   }
   
   func listAssistantFiles(
      assistantID: String,
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil)
      async throws -> OpenAIResponse<AssistantFileObject>
   {
      var queryItems: [URLQueryItem] = []
      if let limit {
         queryItems.append(.init(name: "limit", value: "\(limit)"))
      }
      if let order {
         queryItems.append(.init(name: "order", value: order))
      }
      if let after {
         queryItems.append(.init(name: "after", value: after))
      }
      if let before {
         queryItems.append(.init(name: "before", value: before))
      }
      let request = try OpenAIAPI.assistant(.list).request(apiKey: apiKey, organizationID: organizationID, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: OpenAIResponse<AssistantFileObject>.self, with: request)
   }
   
   // MARK: Thread [BETA]
   
   func createThread(
      parameters: CreateThreadParameters)
      async throws -> ThreadObject
   {
      let request = try OpenAIAPI.thread(.create).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: ThreadObject.self, with: request)
   }
   
   func retrieveThread(id: String)
      async throws -> ThreadObject
   {
      let request = try OpenAIAPI.thread(.retrieve(threadID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .get, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: ThreadObject.self, with: request)
   }
   
   func modifyThread(
      id: String,
      parameters: ModifyThreadParameters)
      async throws -> ThreadObject
   {
      let request = try OpenAIAPI.thread(.modify(threadID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: ThreadObject.self, with: request)
   }
   
   func deleteThread(
      id: String)
      async throws -> ThreadObject.DeletionStatus
   {
      let request = try OpenAIAPI.thread(.delete(threadID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .delete, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: ThreadObject.DeletionStatus.self, with: request)
   }
   
   // MARK: Message [BETA]
   
   func createMessage(
      threadID: String,
      parameters: MessageParameter)
      async throws -> MessageObject
   {
      let request = try OpenAIAPI.message(.create(threadID: threadID)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: MessageObject.self, with: request)
   }
   
   func retrieveMessage(
      threadID: String,
      messageID: String)
      async throws -> MessageObject
   {
      let request = try OpenAIAPI.message(.retrieve(threadID: threadID, messageID: messageID)).request(apiKey: apiKey, organizationID: organizationID, method: .get, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: MessageObject.self, with: request)
   }
   
   func modifyMessage(
      threadID: String,
      messageID: String,
      parameters: ModifyMessageParameters)
      async throws -> MessageObject
   {
      let request = try OpenAIAPI.message(.modify(threadID: threadID, messageID: messageID)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: MessageObject.self, with: request)
   }
   
   func listMessages(
      threadID: String,
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil)
      async throws -> OpenAIResponse<MessageObject>
   {
      var queryItems: [URLQueryItem] = []
      if let limit {
         queryItems.append(.init(name: "limit", value: "\(limit)"))
      }
      if let order {
         queryItems.append(.init(name: "order", value: order))
      }
      if let after {
         queryItems.append(.init(name: "after", value: after))
      }
      if let before {
         queryItems.append(.init(name: "before", value: before))
      }
      let request = try OpenAIAPI.message(.list(threadID: threadID)).request(apiKey: apiKey, organizationID: organizationID, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: OpenAIResponse<MessageObject>.self, with: request)
   }
   
   // MARK: Message File [BETA]
   
   func retrieveMessageFile(
      threadID: String,
      messageID: String,
      fileID: String)
      async throws -> MessageFileObject
   {
      let request = try OpenAIAPI.messageFile(.retrieve(threadID: threadID, messageID: messageID, fileID: fileID)).request(apiKey: apiKey, organizationID: organizationID, method: .get, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: MessageFileObject.self, with: request)
   }
   
   func listMessageFiles(
      threadID: String,
      messageID: String,
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil)
      async throws -> OpenAIResponse<MessageFileObject>
   {
      var queryItems: [URLQueryItem] = []
      if let limit {
         queryItems.append(.init(name: "limit", value: "\(limit)"))
      }
      if let order {
         queryItems.append(.init(name: "order", value: order))
      }
      if let after {
         queryItems.append(.init(name: "after", value: after))
      }
      if let before {
         queryItems.append(.init(name: "before", value: before))
      }
      let request = try OpenAIAPI.messageFile(.list(threadID: threadID, messageID: messageID)).request(apiKey: apiKey, organizationID: organizationID, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: OpenAIResponse<MessageFileObject>.self, with: request)
   }
   
   func createRun(
      threadID: String,
      parameters: RunParameter)
      async throws -> RunObject
   {
      let request = try OpenAIAPI.run(.create(threadID: threadID)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: RunObject.self, with: request)
   }
   
   func retrieveRun(
      threadID: String,
      runID: String)
      async throws -> RunObject
   {
      let request = try OpenAIAPI.run(.retrieve(threadID: threadID, runID: runID)).request(apiKey: apiKey, organizationID: organizationID, method: .get, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: RunObject.self, with: request)
   }
   
   func modifyRun(
      threadID: String,
      runID: String,
      parameters: ModifyRunParameters)
      async throws -> RunObject
   {
      let request = try OpenAIAPI.run(.modify(threadID: threadID, runID: runID)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: RunObject.self, with: request)
   }
   
   func listRuns(
      threadID: String,
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil)
      async throws -> OpenAIResponse<RunObject>
   {
      var queryItems: [URLQueryItem] = []
      if let limit {
         queryItems.append(.init(name: "limit", value: "\(limit)"))
      }
      if let order {
         queryItems.append(.init(name: "order", value: order))
      }
      if let after {
         queryItems.append(.init(name: "after", value: after))
      }
      if let before {
         queryItems.append(.init(name: "before", value: before))
      }
      let request = try OpenAIAPI.run(.list(threadID: threadID)).request(apiKey: apiKey, organizationID: organizationID, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: OpenAIResponse<RunObject>.self, with: request)
   }
   
   func cancelRun(
      threadID: String,
      runID: String)
      async throws -> RunObject
   {
      let request = try OpenAIAPI.run(.cancel(threadID: threadID, runID: runID)).request(apiKey: apiKey, organizationID: organizationID, method: .post, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: RunObject.self, with: request)
   }
   
   func submitToolOutputsToRun(
      threadID: String,
      runID: String,
      parameters: RunToolsOutputParameter)
      async throws -> RunObject
   {
      let request = try OpenAIAPI.run(.submitToolOutput(threadID: threadID, runID: runID)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: RunObject.self, with: request)
   }
   
   func createThreadAndRun(
      parameters: CreateThreadAndRunParameter)
      async throws -> RunObject
   {
      let request = try OpenAIAPI.run(.createThreadAndRun).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(type: RunObject.self, with: request)
   }
   
   // MARK: Run Step [BETA]
   
   func retrieveRunstep(
      threadID: String,
      runID: String,
      stepID: String)
      async throws -> RunStepObject
   {
      let request = try OpenAIAPI.runStep(.retrieve(threadID: threadID, runID: runID, stepID: stepID)).request(apiKey: apiKey, organizationID: organizationID, method: .get, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: RunStepObject.self, with: request)
   }
   
   func listRunSteps(
      threadID: String,
      runID: String,
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil)
      async throws -> OpenAIResponse<RunStepObject>
   {
      var queryItems: [URLQueryItem] = []
      if let limit {
         queryItems.append(.init(name: "limit", value: "\(limit)"))
      }
      if let order {
         queryItems.append(.init(name: "order", value: order))
      }
      if let after {
         queryItems.append(.init(name: "after", value: after))
      }
      if let before {
         queryItems.append(.init(name: "before", value: before))
      }
      let request = try OpenAIAPI.runStep(.list(threadID: threadID, runID: runID)).request(apiKey: apiKey, organizationID: organizationID, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBeta)
      return try await fetch(type: OpenAIResponse<RunStepObject>.self, with: request)
   }
   
   func createRunStream(
      threadID: String,
      parameters: RunParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
   {
      var runParameters = parameters
      runParameters.stream = true
      let request = try OpenAIAPI.run(.create(threadID: threadID)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: runParameters, betaHeaderField: Self.assistantsBeta)
      return try await fetchAssistantStreamEvents(with: request)
   }
   
   func createThreadAndRunStream(
      parameters: CreateThreadAndRunParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error> {
      var runParameters = parameters
      runParameters.stream = true
      let request = try OpenAIAPI.run(.createThreadAndRun).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters)
      return try await fetchAssistantStreamEvents(with: request)
   }
   
   func submitToolOutputsToRunStream(
      threadID: String,
      runID: String,
      parameters: RunToolsOutputParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
   {
      var runToolsOutputParameter = parameters
      runToolsOutputParameter.stream = true
      let request = try OpenAIAPI.run(.submitToolOutput(threadID: threadID, runID: runID)).request(apiKey: apiKey, organizationID: organizationID, method: .post, params: parameters, betaHeaderField: Self.assistantsBeta)
      return try await fetchAssistantStreamEvents(with: request)
   }
}
