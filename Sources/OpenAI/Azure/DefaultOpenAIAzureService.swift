//
//  DefaultOpenAIAzureService.swift
//
//
//  Created by James Rochabrun on 1/23/24.
//

import Foundation

final public class DefaultOpenAIAzureService: OpenAIService {

   public init(
      azureConfiguration: AzureOpenAIConfiguration,
      urlSessionConfiguration: URLSessionConfiguration = .default,
      decoder: JSONDecoder = .init(),
      debugEnabled: Bool)
   {
      session = URLSession(configuration: urlSessionConfiguration)
      self.decoder = decoder
      self.openAIEnvironment = OpenAIEnvironment(
         baseURL: "https://\(azureConfiguration.resourceName)/openai.azure.com",
         proxyPath: nil,
         version: nil
     )
      apiKey = azureConfiguration.openAIAPIKey
      extraHeaders = azureConfiguration.extraHeaders
      initialQueryItems = [.init(name: "api-version", value: azureConfiguration.apiVersion)]
      self.debugEnabled = debugEnabled
   }
   
   public let session: URLSession
   public let decoder: JSONDecoder
   public let openAIEnvironment: OpenAIEnvironment

   private let apiKey: Authorization
   private let initialQueryItems: [URLQueryItem]
   /// Set this flag to TRUE if you need to print request events in DEBUG builds.
   private let debugEnabled: Bool
   
   
   // Assistants API
   private let extraHeaders: [String: String]?
   private static let assistantsBetaV2 = "assistants=v2"
   
   public func createTranscription(parameters: AudioTranscriptionParameters) async throws -> AudioObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createTranslation(parameters: AudioTranslationParameters) async throws -> AudioObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createSpeech(parameters: AudioSpeechParameters) async throws -> AudioSpeechObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func startChat(parameters: ChatCompletionParameters) async throws -> ChatCompletionObject {
      var chatParameters = parameters
      chatParameters.stream = false
      let request = try AzureOpenAIAPI.chat(deploymentID: parameters.model).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: chatParameters,
         queryItems: initialQueryItems)
      return try await fetch(debugEnabled: debugEnabled, type: ChatCompletionObject.self, with: request)
   }
   
   public func startStreamedChat(parameters: ChatCompletionParameters) async throws -> AsyncThrowingStream<ChatCompletionChunkObject, Error> {
      var chatParameters = parameters
      chatParameters.stream = true
      let request = try AzureOpenAIAPI.chat(deploymentID: parameters.model).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: chatParameters,
         queryItems: initialQueryItems
      )
      return try await fetchStream(debugEnabled: debugEnabled, type: ChatCompletionChunkObject.self, with: request)
   }
   
   public func createEmbeddings(parameters: EmbeddingParameter) async throws -> OpenAIResponse<EmbeddingObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createFineTuningJob(parameters: FineTuningJobParameters) async throws -> FineTuningJobObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listFineTuningJobs(after lastJobID: String?, limit: Int?) async throws -> OpenAIResponse<FineTuningJobObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveFineTuningJob(id: String) async throws -> FineTuningJobObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func cancelFineTuningJobWith(id: String) async throws -> FineTuningJobObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listFineTuningEventsForJobWith(id: String, after lastEventId: String?, limit: Int?) async throws -> OpenAIResponse<FineTuningJobEventObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listFiles() async throws -> OpenAIResponse<FileObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func uploadFile(parameters: FileParameters) async throws -> FileObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func deleteFileWith(id: String) async throws -> DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveFileWith(id: String) async throws -> FileObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveContentForFileWith(id: String) async throws -> [[String : Any]] {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createImages(parameters: ImageCreateParameters) async throws -> OpenAIResponse<ImageObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func editImage(parameters: ImageEditParameters) async throws -> OpenAIResponse<ImageObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createImageVariations(parameters: ImageVariationParameters) async throws -> OpenAIResponse<ImageObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listModels() async throws -> OpenAIResponse<ModelObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveModelWith(id: String) async throws -> ModelObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func deleteFineTuneModelWith(id: String) async throws -> DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createModerationFromText(parameters: ModerationParameter<String>) async throws -> ModerationObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createModerationFromTexts(parameters: ModerationParameter<[String]>) async throws -> ModerationObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createAssistant(parameters: AssistantParameters) async throws -> AssistantObject {
      let request = try AzureOpenAIAPI.assistant(.create).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders
      )
      return try await fetch(debugEnabled: debugEnabled, type: AssistantObject.self, with: request)
   }
   
   public func retrieveAssistant(id: String) async throws -> AssistantObject {
      let request = try AzureOpenAIAPI.assistant(.retrieve(assistantID: id)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders
      )
      return try await fetch(debugEnabled: debugEnabled, type: AssistantObject.self, with: request)
   }
   
   public func modifyAssistant(id: String, parameters: AssistantParameters) async throws -> AssistantObject {
      let request = try AzureOpenAIAPI.assistant(.modify(assistantID: id)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders
      )
      return try await fetch(debugEnabled: debugEnabled, type: AssistantObject.self, with: request)
   }
   
   public func deleteAssistant(id: String) async throws -> DeletionStatus {
      let request = try AzureOpenAIAPI.assistant(.delete(assistantID: id)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .delete,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders
      )
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }
   
   public func listAssistants(limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<AssistantObject> {
      var queryItems: [URLQueryItem] = initialQueryItems
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
      let request = try AzureOpenAIAPI.assistant(.list).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: queryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders
      )
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<AssistantObject>.self, with: request)
   }
   
   public func createThread(parameters: CreateThreadParameters) async throws -> ThreadObject {
      let request = try AzureOpenAIAPI.thread(.create).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post, 
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: ThreadObject.self, with: request)
   }
   
   public func retrieveThread(id: String) async throws -> ThreadObject {
      let request = try AzureOpenAIAPI.thread(.retrieve(threadID: id)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: ThreadObject.self, with: request)
   }
   
   public func modifyThread(id: String, parameters: ModifyThreadParameters) async throws -> ThreadObject {
      let request = try AzureOpenAIAPI.thread(.modify(threadID: id)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: ThreadObject.self, with: request)
   }
   
   public func deleteThread(id: String) async throws -> DeletionStatus {
      let request = try AzureOpenAIAPI.thread(.delete(threadID: id)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .delete,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }
   
   public func createMessage(threadID: String, parameters: MessageParameter) async throws -> MessageObject {
      let request = try AzureOpenAIAPI.message(.create(threadID: threadID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: MessageObject.self, with: request)
   }
   
   public func retrieveMessage(threadID: String, messageID: String) async throws -> MessageObject {
      let request = try AzureOpenAIAPI.message(.retrieve(threadID: threadID, messageID: messageID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: MessageObject.self, with: request)
   }
   
   public func modifyMessage(threadID: String, messageID: String, parameters: ModifyMessageParameters) async throws -> MessageObject {
      let request = try AzureOpenAIAPI.message(.modify(threadID: threadID, messageID: messageID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: MessageObject.self, with: request)
   }
   
   public func deleteMessage(
      threadID: String,
      messageID: String)
      async throws -> DeletionStatus
   {
      let request = try AzureOpenAIAPI.message(.delete(threadID: threadID, messageID: messageID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .delete,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }
   
   public func listMessages(threadID: String, limit: Int?, order: String?, after: String?, before: String?, runID: String?) async throws -> OpenAIResponse<MessageObject> {
      var queryItems: [URLQueryItem] = initialQueryItems
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
      if let runID {
         queryItems.append(.init(name: "run_id", value: runID))
      }
      let request = try AzureOpenAIAPI.message(.list(threadID: threadID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: queryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<MessageObject>.self, with: request)
   }
   
   public func createRun(threadID: String, parameters: RunParameter) async throws -> RunObject {
      let request = try AzureOpenAIAPI.run(.create(threadID: threadID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }
   
   public func retrieveRun(threadID: String, runID: String) async throws -> RunObject {
      let request = try AzureOpenAIAPI.run(.retrieve(threadID: threadID, runID: runID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }
   
   public func modifyRun(threadID: String, runID: String, parameters: ModifyRunParameters) async throws -> RunObject {
      let request = try AzureOpenAIAPI.run(.modify(threadID: threadID, runID: runID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }
   
   public func listRuns(threadID: String, limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<RunObject> {
      var queryItems: [URLQueryItem] = initialQueryItems
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
      let request = try AzureOpenAIAPI.run(.list(threadID: threadID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         queryItems: queryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<RunObject>.self, with: request)
   }
   
   public func cancelRun(threadID: String, runID: String) async throws -> RunObject {
      let request = try AzureOpenAIAPI.run(.cancel(threadID: threadID, runID: runID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }
   
   public func submitToolOutputsToRun(threadID: String, runID: String, parameters: RunToolsOutputParameter) async throws -> RunObject {
      let request = try AzureOpenAIAPI.run(.submitToolOutput(threadID: threadID, runID: runID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }
   
   public func createThreadAndRun(parameters: CreateThreadAndRunParameter) async throws -> RunObject {
      let request = try AzureOpenAIAPI.run(.createThreadAndRun).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
   }
   
   public func retrieveRunstep(threadID: String, runID: String, stepID: String) async throws -> RunStepObject {
      let request = try OpenAIAPI.runStep(.retrieve(threadID: threadID, runID: runID, stepID: stepID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: RunStepObject.self, with: request)
   }
   
   public func listRunSteps(threadID: String, runID: String, limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<RunStepObject> {
      var queryItems: [URLQueryItem] = initialQueryItems
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
      let request = try AzureOpenAIAPI.runStep(.list(threadID: threadID, runID: runID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: queryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<RunStepObject>.self, with: request)
   }
   
   public func createThreadAndRunStream(
      parameters: CreateThreadAndRunParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
   {
      var runParameters = parameters
      runParameters.stream = true
      let request = try AzureOpenAIAPI.run(.createThreadAndRun).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: runParameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetchAssistantStreamEvents(with: request, debugEnabled: debugEnabled)
   }
   
   public func createRunStream(
      threadID: String,
      parameters: RunParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
   {
      var runParameters = parameters
      runParameters.stream = true
      let request = try AzureOpenAIAPI.run(.create(threadID: threadID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: runParameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetchAssistantStreamEvents(with: request, debugEnabled: debugEnabled)
   }
   
   public func submitToolOutputsToRunStream(
      threadID: String,
      runID: String,
      parameters: RunToolsOutputParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error> 
   {
      var runToolsOutputParameter = parameters
      runToolsOutputParameter.stream = true
      let request = try AzureOpenAIAPI.run(.submitToolOutput(threadID: threadID, runID: runID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: runToolsOutputParameter,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetchAssistantStreamEvents(with: request, debugEnabled: debugEnabled)
   }
   
   // MARK: Batch

   public func createBatch(
      parameters: BatchParameter)
      async throws -> BatchObject
   {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveBatch(
      id: String)
      async throws -> BatchObject
   {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func cancelBatch(
      id: String) async throws -> BatchObject
   {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }

   public func listBatch(
      after: String?,
      limit: Int?)
      async throws-> OpenAIResponse<BatchObject>
   {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   // MARK: Vector Store

   public func createVectorStore(
      parameters: VectorStoreParameter)
      async throws -> VectorStoreObject
   {
      let request = try AzureOpenAIAPI.vectorStore(.create).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters, 
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreObject.self, with: request)
   }
   
   public func listVectorStores(
      limit: Int?,
      order: String?,
      after: String?,
      before: String?)
      async throws -> OpenAIResponse<VectorStoreObject>
   {
      var queryItems: [URLQueryItem] = initialQueryItems
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
      let request = try AzureOpenAIAPI.vectorStore(.list).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: queryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<VectorStoreObject>.self, with: request)
   }
   
   public func retrieveVectorStore(
      id: String) async throws
      -> VectorStoreObject
   {
      let request = try AzureOpenAIAPI.vectorStore(.retrieve(vectorStoreID: id)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreObject.self, with: request)
   }
   
   public func modifyVectorStore(
      parameters: VectorStoreParameter,
      id: String)
      async throws -> VectorStoreObject
   {
      let request = try AzureOpenAIAPI.vectorStore(.modify(vectorStoreID: id)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreObject.self, with: request)
   }
   
   public func deleteVectorStore(
      id: String)
      async throws -> DeletionStatus
   {
      let request = try AzureOpenAIAPI.vectorStore(.delete(vectorStoreID: id)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .delete,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }
   
   // MARK: Vector Store Files
   
   public func createVectorStoreFile(vectorStoreID: String, parameters: VectorStoreFileParameter) async throws -> VectorStoreFileObject {
      let request = try AzureOpenAIAPI.vectorStoreFile(.create(vectorStoreID: vectorStoreID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .post,
         params: parameters,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileObject.self, with: request)
   }

   public func listVectorStoreFiles(vectorStoreID: String, limit: Int?, order: String?, after: String?, before: String?, filter: String?) async throws -> OpenAIResponse<VectorStoreFileObject> {
      var queryItems: [URLQueryItem] = initialQueryItems
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
      let request = try AzureOpenAIAPI.vectorStoreFile(.list(vectorStoreID: vectorStoreID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: queryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<VectorStoreFileObject>.self, with: request)
   }
   
   public func retrieveVectorStoreFile(vectorStoreID: String, fileID: String) async throws -> VectorStoreFileObject {
      let request = try AzureOpenAIAPI.vectorStoreFile(.retrieve(vectorStoreID: vectorStoreID, fileID: fileID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .get,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileObject.self, with: request)
   }
   
   public func deleteVectorStoreFile(vectorStoreID: String, fileID: String) async throws -> DeletionStatus {
      let request = try AzureOpenAIAPI.vectorStoreFile(.delete(vectorStoreID: vectorStoreID, fileID: fileID)).request(
         apiKey: apiKey,
         openAIEnvironment: openAIEnvironment,
         organizationID: nil,
         method: .delete,
         queryItems: initialQueryItems,
         betaHeaderField: Self.assistantsBetaV2,
         extraHeaders: extraHeaders)
      return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
   }
   
   public func createVectorStoreFileBatch(vectorStoreID: String, parameters: VectorStoreFileBatchParameter) async throws -> VectorStoreFileBatchObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveVectorStoreFileBatch(vectorStoreID: String, batchID: String) async throws -> VectorStoreFileBatchObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func cancelVectorStoreFileBatch(vectorStoreID: String, batchID: String) async throws -> VectorStoreFileBatchObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listVectorStoreFilesInABatch(vectorStoreID: String, batchID: String, limit: Int?, order: String?, after: String?, before: String?, filter: String?) async throws -> OpenAIResponse<VectorStoreFileObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
}
