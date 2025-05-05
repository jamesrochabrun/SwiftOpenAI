//
//  AIProxyService.swift
//
//
//  Created by Lou Zell on 3/27/24.
//

import Foundation

private let aiproxySecureDelegate = AIProxyCertificatePinningDelegate()


struct AIProxyService: OpenAIService {

   let session: URLSession
   let decoder: JSONDecoder
   let openAIEnvironment: OpenAIEnvironment

   /// Your partial key is provided during the integration process at dashboard.aiproxy.pro
   /// Please see the [integration guide](https://www.aiproxy.pro/docs/integration-guide.html) for acquiring your partial key
   private let partialKey: String
   /// Optionally supply your own client IDs to annotate requests with in the AIProxy developer dashboard.
   /// It is safe to leave this blank (most people do). If you leave it blank, AIProxy generates client IDs for you.
   private let clientID: String?
   /// Set this flag to TRUE if you need to print request events in DEBUG builds.
   private let debugEnabled: Bool

   /// [organization](https://platform.openai.com/docs/api-reference/organization-optional)
   private let organizationID: String?

   private static let assistantsBetaV2 = "assistants=v2"

   /// Initializes an instance of the OpenAI service with the required configurations.
   ///
   /// - Parameters:
   ///   - partialKey: Your partial key provided during the integration process at `dashboard.aiproxy.pro`.
   ///                 Refer to the [integration guide](https://www.aiproxy.pro/docs/integration-guide.html)
   ///                 for details on acquiring your partial key. This is required.
   ///   - serviceURL: Your service URL, also provided during the integration process. If you integrated before
   ///                 July 22nd, 2024, you can leave this parameter blank, and it will default to
   ///                 `"https://api.aiproxy.pro"`. This is optional.
   ///   - clientID: An optional client ID to annotate requests in the AIProxy developer dashboard.
   ///               If left blank, AIProxy generates client IDs for you. Most users can safely leave this blank.
   ///   - organizationID: An optional OpenAI organization ID. Refer to the [organization documentation](https://platform.openai.com/docs/api-reference/organization-optional)
   ///                     for details on its usage. Defaults to `nil`.
   ///   - debugEnabled: A flag to enable printing request events during DEBUG builds. Set this to `true` for debugging.
   init(
      partialKey: String,
      serviceURL: String? = nil,
      clientID: String? = nil,
      organizationID: String? = nil,
      debugEnabled: Bool)
   {
      self.session = URLSession(
         configuration: .default,
         delegate: aiproxySecureDelegate,
         delegateQueue: nil
      )
      self.decoder = JSONDecoder()
      self.partialKey = partialKey
      self.clientID = clientID
      self.organizationID = organizationID
      self.debugEnabled = debugEnabled
      self.openAIEnvironment = .init(baseURL: serviceURL ?? "https://api.aiproxy.pro", proxyPath: nil, version: "v1")
   }

   // MARK: Audio

   func createTranscription(
      parameters: AudioTranscriptionParameters)
      async throws -> AudioObject
   {
      let request = try await OpenAIAPI.audio(.transcriptions).multiPartRequest(aiproxyPartialKey: partialKey, openAIEnvironment: openAIEnvironment, clientID: clientID, organizationID: organizationID, method: .post,  params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: AudioObject.self, with: request)
   }

   func createTranslation(
      parameters: AudioTranslationParameters)
      async throws -> AudioObject
   {
      let request = try await OpenAIAPI.audio(.translations).multiPartRequest(aiproxyPartialKey: partialKey, openAIEnvironment: openAIEnvironment, clientID: clientID, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: AudioObject.self, with: request)
   }

   func createSpeech(
      parameters: AudioSpeechParameters)
      async throws -> AudioSpeechObject
   {
      let request = try await OpenAIAPI.audio(.speech).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters)
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
      let request = try await OpenAIAPI.chat.request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: chatParameters)
      return try await fetch(debugEnabled: debugEnabled, type: ChatCompletionObject.self, with: request)
   }

   func startStreamedChat(
      parameters: ChatCompletionParameters)
      async throws -> AsyncThrowingStream<ChatCompletionChunkObject, Error>
   {
      var chatParameters = parameters
      chatParameters.stream = true
      chatParameters.streamOptions = .init(includeUsage: true)
      let request = try await OpenAIAPI.chat.request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: chatParameters)
      return try await fetchStream(debugEnabled: debugEnabled, type: ChatCompletionChunkObject.self, with: request)
   }

   // MARK: Embeddings

   func createEmbeddings(
      parameters: EmbeddingParameter)
      async throws -> OpenAIResponse<EmbeddingObject>
   {
      let request = try await OpenAIAPI.embeddings.request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<EmbeddingObject>.self, with: request)
   }

   // MARK: Fine-tuning

   func createFineTuningJob(
      parameters: FineTuningJobParameters)
      async throws -> FineTuningJobObject
   {
      let request = try await OpenAIAPI.fineTuning(.create).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: FineTuningJobObject.self, with: request)
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

      let request = try await OpenAIAPI.fineTuning(.list).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<FineTuningJobObject>.self, with: request)
   }

   func retrieveFineTuningJob(
      id: String)
      async throws -> FineTuningJobObject
   {
      let request = try await OpenAIAPI.fineTuning(.retrieve(jobID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get)
      return try await fetch(debugEnabled: debugEnabled, type: FineTuningJobObject.self, with: request)
   }

   func cancelFineTuningJobWith(
      id: String)
      async throws -> FineTuningJobObject
   {
      let request = try await OpenAIAPI.fineTuning(.cancel(jobID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post)
      return try await fetch(debugEnabled: debugEnabled, type: FineTuningJobObject.self, with: request)
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
      let request = try await OpenAIAPI.fineTuning(.events(jobID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<FineTuningJobEventObject>.self, with: request)
   }

   // MARK: Files

   func listFiles()
      async throws -> OpenAIResponse<FileObject>
   {
      let request = try await OpenAIAPI.file(.list).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<FileObject>.self, with: request)
   }

   func uploadFile(
      parameters: FileParameters)
      async throws -> FileObject
   {
      let request = try await OpenAIAPI.file(.upload).multiPartRequest(aiproxyPartialKey: partialKey, openAIEnvironment: openAIEnvironment, clientID: clientID, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: FileObject.self, with: request)
   }

   func deleteFileWith(
      id: String)
      async throws -> DeletionStatus
   {
      let request = try await OpenAIAPI.file(.delete(fileID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .delete)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }

   func retrieveFileWith(
      id: String)
      async throws -> FileObject
   {
      let request = try await OpenAIAPI.file(.retrieve(fileID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get)
      return try await fetch(debugEnabled: debugEnabled, type: FileObject.self, with: request)
   }

   func retrieveContentForFileWith(
      id: String)
      async throws -> [[String: Any]]
   {
      let request = try await OpenAIAPI.file(.retrieveFileContent(fileID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get)
      return try await fetchContentsOfFile(request: request)
   }

   // MARK: Images

   func legacyCreateImages(
      parameters: ImageCreateParameters)
      async throws -> OpenAIResponse<ImageObject>
   {
      let request = try await OpenAIAPI.images(.generations).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<ImageObject>.self,  with: request)
   }

   func legacyEditImage(
      parameters: ImageEditParameters)
      async throws -> OpenAIResponse<ImageObject>
   {
      let request = try await OpenAIAPI.images(.edits).multiPartRequest(aiproxyPartialKey: partialKey, openAIEnvironment: openAIEnvironment, clientID: clientID, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<ImageObject>.self, with: request)
   }

   func legacyCreateImageVariations(
      parameters: ImageVariationParameters)
      async throws -> OpenAIResponse<ImageObject>
   {
      let request = try await OpenAIAPI.images(.variations).multiPartRequest(aiproxyPartialKey: partialKey, openAIEnvironment: openAIEnvironment, clientID: clientID, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<ImageObject>.self, with: request)
   }

   func createImages(
      parameters: CreateImageParameters)
      async throws -> CreateImageResponse
   {
      let request = try await OpenAIAPI.images(.generations).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: CreateImageResponse.self,  with: request)
   }

   func editImage(
      parameters: CreateImageEditParameters)
      async throws -> CreateImageResponse
   {
      let request = try await OpenAIAPI.images(.edits).multiPartRequest(aiproxyPartialKey: partialKey, openAIEnvironment: openAIEnvironment, clientID: clientID, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: CreateImageResponse.self, with: request)
   }

   func createImageVariations(
      parameters: CreateImageVariationParameters)
      async throws -> CreateImageResponse
   {
      let request = try await OpenAIAPI.images(.variations).multiPartRequest(aiproxyPartialKey: partialKey, openAIEnvironment: openAIEnvironment, clientID: clientID, organizationID: organizationID, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: CreateImageResponse.self, with: request)
   }
   
   // MARK: Models

   func listModels()
      async throws -> OpenAIResponse<ModelObject>
   {
      let request = try await OpenAIAPI.model(.list).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<ModelObject>.self,  with: request)
   }

   func retrieveModelWith(
      id: String)
      async throws -> ModelObject
   {
      let request = try await OpenAIAPI.model(.retrieve(modelID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get)
      return try await fetch(debugEnabled: debugEnabled, type: ModelObject.self,  with: request)
   }

   func deleteFineTuneModelWith(
      id: String)
      async throws -> DeletionStatus
   {
      let request = try await OpenAIAPI.model(.deleteFineTuneModel(modelID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .delete)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self,  with: request)
   }

   // MARK: Moderations

   func createModerationFromText(
      parameters: ModerationParameter<String>)
      async throws -> ModerationObject
   {
      let request = try await OpenAIAPI.moderations.request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: ModerationObject.self, with: request)
   }

   func createModerationFromTexts(
      parameters: ModerationParameter<[String]>)
      async throws -> ModerationObject
   {
      let request = try await OpenAIAPI.moderations.request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: ModerationObject.self, with: request)
   }

   // MARK: Assistants [BETA]

   func createAssistant(
      parameters: AssistantParameters)
      async throws -> AssistantObject
   {
      let request = try await OpenAIAPI.assistant(.create).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: AssistantObject.self, with: request)
   }

   func retrieveAssistant(
      id: String)
      async throws -> AssistantObject
   {
      let request = try await OpenAIAPI.assistant(.retrieve(assistantID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: AssistantObject.self, with: request)
   }

   func modifyAssistant(
      id: String,
      parameters: AssistantParameters)
      async throws -> AssistantObject
   {
      let request = try await OpenAIAPI.assistant(.modify(assistantID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: AssistantObject.self, with: request)
   }

   func deleteAssistant(
      id: String)
      async throws -> DeletionStatus
   {
      let request = try await OpenAIAPI.assistant(.delete(assistantID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .delete, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
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
      let request = try await OpenAIAPI.assistant(.list).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<AssistantObject>.self, with: request)
   }

   // MARK: Thread [BETA]

   func createThread(
      parameters: CreateThreadParameters)
      async throws -> ThreadObject
   {
      let request = try await OpenAIAPI.thread(.create).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: ThreadObject.self, with: request)
   }

   func retrieveThread(id: String)
      async throws -> ThreadObject
   {
      let request = try await OpenAIAPI.thread(.retrieve(threadID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: ThreadObject.self, with: request)
   }

   func modifyThread(
      id: String,
      parameters: ModifyThreadParameters)
      async throws -> ThreadObject
   {
      let request = try await OpenAIAPI.thread(.modify(threadID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: ThreadObject.self, with: request)
   }

   func deleteThread(
      id: String)
      async throws -> DeletionStatus
   {
      let request = try await OpenAIAPI.thread(.delete(threadID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .delete, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }

   // MARK: Message [BETA]

   func createMessage(
      threadID: String,
      parameters: MessageParameter)
      async throws -> MessageObject
   {
      let request = try await OpenAIAPI.message(.create(threadID: threadID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: MessageObject.self, with: request)
   }

   func retrieveMessage(
      threadID: String,
      messageID: String)
      async throws -> MessageObject
   {
      let request = try await OpenAIAPI.message(.retrieve(threadID: threadID, messageID: messageID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: MessageObject.self, with: request)
   }

   func modifyMessage(
      threadID: String,
      messageID: String,
      parameters: ModifyMessageParameters)
      async throws -> MessageObject
   {
      let request = try await OpenAIAPI.message(.modify(threadID: threadID, messageID: messageID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: MessageObject.self, with: request)
   }
   
   func deleteMessage(
      threadID: String,
      messageID: String)
      async throws -> DeletionStatus
   {
      let request = try await OpenAIAPI.message(.delete(threadID: threadID, messageID: messageID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .delete, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }

   func listMessages(
      threadID: String,
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil,
      runID: String? = nil)
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
      let request = try await OpenAIAPI.message(.list(threadID: threadID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<MessageObject>.self, with: request)
   }

   // MARK: Run [BETA]

   func createRun(
      threadID: String,
      parameters: RunParameter)
      async throws -> RunObject
   {
      let request = try await OpenAIAPI.run(.create(threadID: threadID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }

   func retrieveRun(
      threadID: String,
      runID: String)
      async throws -> RunObject
   {
      let request = try await OpenAIAPI.run(.retrieve(threadID: threadID, runID: runID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }

   func modifyRun(
      threadID: String,
      runID: String,
      parameters: ModifyRunParameters)
      async throws -> RunObject
   {
      let request = try await OpenAIAPI.run(.modify(threadID: threadID, runID: runID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
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
      let request = try await OpenAIAPI.run(.list(threadID: threadID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<RunObject>.self, with: request)
   }

   func cancelRun(
      threadID: String,
      runID: String)
      async throws -> RunObject
   {
      let request = try await OpenAIAPI.run(.cancel(threadID: threadID, runID: runID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }

   func submitToolOutputsToRun(
      threadID: String,
      runID: String,
      parameters: RunToolsOutputParameter)
      async throws -> RunObject
   {
      let request = try await OpenAIAPI.run(.submitToolOutput(threadID: threadID, runID: runID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }

   func createThreadAndRun(
      parameters: CreateThreadAndRunParameter)
      async throws -> RunObject
   {
      let request = try await OpenAIAPI.run(.createThreadAndRun).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }

   // MARK: Run Step [BETA]

   func retrieveRunstep(
      threadID: String,
      runID: String,
      stepID: String)
      async throws -> RunStepObject
   {
      let request = try await OpenAIAPI.runStep(.retrieve(threadID: threadID, runID: runID, stepID: stepID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: RunStepObject.self, with: request)
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
      let request = try await OpenAIAPI.runStep(.list(threadID: threadID, runID: runID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<RunStepObject>.self, with: request)
   }

   func createRunStream(
      threadID: String,
      parameters: RunParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
   {
      var runParameters = parameters
      runParameters.stream = true
      let request = try await OpenAIAPI.run(.create(threadID: threadID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: runParameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetchAssistantStreamEvents(with: request, debugEnabled: debugEnabled)
   }

   func createThreadAndRunStream(
      parameters: CreateThreadAndRunParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error> {
      var runParameters = parameters
      runParameters.stream = true
         let request = try await OpenAIAPI.run(.createThreadAndRun).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
         return try await fetchAssistantStreamEvents(with: request, debugEnabled: debugEnabled)
   }

   func submitToolOutputsToRunStream(
      threadID: String,
      runID: String,
      parameters: RunToolsOutputParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
   {
      var runToolsOutputParameter = parameters
      runToolsOutputParameter.stream = true
      let request = try await OpenAIAPI.run(.submitToolOutput(threadID: threadID, runID: runID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: runToolsOutputParameter, betaHeaderField: Self.assistantsBetaV2)
      return try await fetchAssistantStreamEvents(with: request, debugEnabled: debugEnabled)
   }

   // MARK: Batch

   func createBatch(
      parameters: BatchParameter)
      async throws -> BatchObject
   {
      let request = try await OpenAIAPI.batch(.create).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters)
      return try await fetch(debugEnabled: debugEnabled, type: BatchObject.self, with: request)
   }

   func retrieveBatch(
      id: String)
      async throws -> BatchObject
   {
      let request = try await OpenAIAPI.batch(.retrieve(batchID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get)
      return try await fetch(debugEnabled: debugEnabled, type: BatchObject.self, with: request)
   }

   func cancelBatch(
      id: String)
      async throws -> BatchObject
   {
      let request = try await OpenAIAPI.batch(.cancel(batchID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post)
      return try await fetch(debugEnabled: debugEnabled, type: BatchObject.self, with: request)
   }

   func listBatch(
      after: String? = nil,
      limit: Int? = nil)
      async throws-> OpenAIResponse<BatchObject>
   {
      var queryItems: [URLQueryItem] = []
      if let limit {
         queryItems.append(.init(name: "limit", value: "\(limit)"))
      }
      if let after {
         queryItems.append(.init(name: "after", value: after))
      }
      let request = try await OpenAIAPI.batch(.list).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<BatchObject>.self, with: request)
   }

   // MARK: Vector Store

   func createVectorStore(
      parameters: VectorStoreParameter)
      async throws -> VectorStoreObject
   {
      let request = try await OpenAIAPI.vectorStore(.create).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreObject.self, with: request)
   }

   func listVectorStores(
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil)
      async throws -> OpenAIResponse<VectorStoreObject>
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
      let request = try await OpenAIAPI.vectorStore(.list).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<VectorStoreObject>.self, with: request)
   }

   func retrieveVectorStore(
      id: String) async throws
      -> VectorStoreObject
   {
      let request = try await OpenAIAPI.vectorStore(.retrieve(vectorStoreID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreObject.self, with: request)
   }

   func modifyVectorStore(
      parameters: VectorStoreParameter,
      id: String)
      async throws -> VectorStoreObject
   {
      let request = try await OpenAIAPI.vectorStore(.modify(vectorStoreID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreObject.self, with: request)
   }

   func deleteVectorStore(
      id: String)
      async throws -> DeletionStatus
   {
      let request = try await OpenAIAPI.vectorStore(.modify(vectorStoreID: id)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .delete, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }

   // MARK: Vector Store Files

   func createVectorStoreFile(
      vectorStoreID: String,
      parameters: VectorStoreFileParameter)
      async throws -> VectorStoreFileObject
   {
      let request = try await OpenAIAPI.vectorStore(.create).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileObject.self, with: request)
   }

   func listVectorStoreFiles(
      vectorStoreID: String,
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil,
      filter: String? = nil)
      async throws -> OpenAIResponse<VectorStoreFileObject>
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
      if let filter {
         queryItems.append(.init(name: "filter", value: filter))
      }
      let request = try await OpenAIAPI.vectorStoreFile(.list(vectorStoreID: vectorStoreID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<VectorStoreFileObject>.self, with: request)
   }

   func retrieveVectorStoreFile(
      vectorStoreID: String,
      fileID: String)
      async throws -> VectorStoreFileObject
   {
      let request = try await OpenAIAPI.vectorStoreFile(.retrieve(vectorStoreID: vectorStoreID, fileID: fileID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileObject.self, with: request)
   }

   func deleteVectorStoreFile(
      vectorStoreID: String,
      fileID: String)
      async throws -> DeletionStatus
   {
      let request = try await OpenAIAPI.vectorStoreFile(.delete(vectorStoreID: vectorStoreID, fileID: fileID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .delete, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }

   // MARK: Vector Store File Batch

   func createVectorStoreFileBatch(
      vectorStoreID: String,
      parameters: VectorStoreFileBatchParameter)
      async throws -> VectorStoreFileBatchObject
   {
      let request = try await OpenAIAPI.vectorStoreFileBatch(.create(vectorStoreID: vectorStoreID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: parameters, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileBatchObject.self, with: request)
   }

   func retrieveVectorStoreFileBatch(
      vectorStoreID: String,
      batchID: String)
      async throws -> VectorStoreFileBatchObject
   {
      let request = try await OpenAIAPI.vectorStoreFileBatch(.retrieve(vectorStoreID: vectorStoreID, batchID: batchID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileBatchObject.self, with: request)
   }

   func cancelVectorStoreFileBatch(
      vectorStoreID: String,
      batchID: String)
      async throws -> VectorStoreFileBatchObject
   {
      let request = try await OpenAIAPI.vectorStoreFileBatch(.cancel(vectorStoreID: vectorStoreID, batchID: batchID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileBatchObject.self, with: request)
   }

   func listVectorStoreFilesInABatch(
      vectorStoreID: String,
      batchID: String,
      limit: Int? = nil,
      order: String? = nil,
      after: String? = nil,
      before: String? = nil,
      filter: String? = nil)
      async throws -> OpenAIResponse<VectorStoreFileObject>
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
      if let filter {
         queryItems.append(.init(name: "filter", value: filter))
      }
      let request = try await OpenAIAPI.vectorStoreFileBatch(.list(vectorStoreID: vectorStoreID, batchID: batchID)).request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .get, queryItems: queryItems, betaHeaderField: Self.assistantsBetaV2)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<VectorStoreFileObject>.self, with: request)
   }
   
   // MARK: Response
   
   func responseCreate(
      _ parameters: ModelResponseParameter)
      async throws -> ResponseModel
   {
      var responseParameters = parameters
      responseParameters.stream = false
      let request = try await OpenAIAPI.chat.request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post, params: responseParameters)
      return try await fetch(debugEnabled: debugEnabled, type: ResponseModel.self, with: request)
   }
   
   func responseModel(
      id: String)
      async throws -> ResponseModel
   {
      let request = try await OpenAIAPI.chat.request(aiproxyPartialKey: partialKey, clientID: clientID, organizationID: organizationID, openAIEnvironment: openAIEnvironment, method: .post)
      return try await fetch(debugEnabled: debugEnabled, type: ResponseModel.self, with: request)
   }
}


