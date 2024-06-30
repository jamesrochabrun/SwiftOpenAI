//
//  LocalModelService.swift
//
//
//  Created by James Rochabrun on 6/30/24.
//

import Foundation

struct LocalModelService: OpenAIService {
   
   let session: URLSession
   let decoder: JSONDecoder
   /// [authentication](https://platform.openai.com/docs/api-reference/authentication)
   private let apiKey: Authorization

   public init(
      apiKey: Authorization = .apiKey(""),
      baseURL: String,
      configuration: URLSessionConfiguration = .default,
      decoder: JSONDecoder = .init())
   {
      self.session = URLSession(configuration: configuration)
      self.decoder = decoder
      self.apiKey = apiKey
      LocalModelAPI.overrideBaseURL = baseURL
   }
   
   func createTranscription(parameters: AudioTranscriptionParameters) async throws -> AudioObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createTranslation(parameters: AudioTranslationParameters) async throws -> AudioObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createSpeech(parameters: AudioSpeechParameters) async throws -> AudioSpeechObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func startChat(
      parameters: ChatCompletionParameters)
      async throws -> ChatCompletionObject
   {
      var chatParameters = parameters
      chatParameters.stream = false
      let request = try LocalModelAPI.chat.request(apiKey: apiKey, organizationID: nil, method: .post, params: chatParameters)
      return try await fetch(type: ChatCompletionObject.self, with: request)
   }
   
   func startStreamedChat(
      parameters: ChatCompletionParameters)
      async throws -> AsyncThrowingStream<ChatCompletionChunkObject, Error>
   {
      var chatParameters = parameters
      chatParameters.stream = true
      chatParameters.streamOptions = .init(includeUsage: true)
      let request = try LocalModelAPI.chat.request(apiKey: apiKey, organizationID: nil, method: .post, params: chatParameters)
      return try await fetchStream(type: ChatCompletionChunkObject.self, with: request)
   }
   
   func createEmbeddings(parameters: EmbeddingParameter) async throws -> OpenAIResponse<EmbeddingObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createFineTuningJob(parameters: FineTuningJobParameters) async throws -> FineTuningJobObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listFineTuningJobs(after lastJobID: String?, limit: Int?) async throws -> OpenAIResponse<FineTuningJobObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveFineTuningJob(id: String) async throws -> FineTuningJobObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func cancelFineTuningJobWith(id: String) async throws -> FineTuningJobObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listFineTuningEventsForJobWith(id: String, after lastEventId: String?, limit: Int?) async throws -> OpenAIResponse<FineTuningJobEventObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listFiles() async throws -> OpenAIResponse<FileObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func uploadFile(parameters: FileParameters) async throws -> FileObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func deleteFileWith(id: String) async throws -> DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveFileWith(id: String) async throws -> FileObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveContentForFileWith(id: String) async throws -> [[String : Any]] {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createImages(parameters: ImageCreateParameters) async throws -> OpenAIResponse<ImageObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func editImage(parameters: ImageEditParameters) async throws -> OpenAIResponse<ImageObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createImageVariations(parameters: ImageVariationParameters) async throws -> OpenAIResponse<ImageObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listModels() async throws -> OpenAIResponse<ModelObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveModelWith(id: String) async throws -> ModelObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func deleteFineTuneModelWith(id: String) async throws -> DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createModerationFromText(parameters: ModerationParameter<String>) async throws -> ModerationObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createModerationFromTexts(parameters: ModerationParameter<[String]>) async throws -> ModerationObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createAssistant(parameters: AssistantParameters) async throws -> AssistantObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveAssistant(id: String) async throws -> AssistantObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func modifyAssistant(id: String, parameters: AssistantParameters) async throws -> AssistantObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func deleteAssistant(id: String) async throws -> DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listAssistants(limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<AssistantObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createThread(parameters: CreateThreadParameters) async throws -> ThreadObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveThread(id: String) async throws -> ThreadObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func modifyThread(id: String, parameters: ModifyThreadParameters) async throws -> ThreadObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func deleteThread(id: String) async throws -> DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createMessage(threadID: String, parameters: MessageParameter) async throws -> MessageObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveMessage(threadID: String, messageID: String) async throws -> MessageObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func modifyMessage(threadID: String, messageID: String, parameters: ModifyMessageParameters) async throws -> MessageObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listMessages(threadID: String, limit: Int?, order: String?, after: String?, before: String?, runID: String?) async throws -> OpenAIResponse<MessageObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createRun(threadID: String, parameters: RunParameter) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveRun(threadID: String, runID: String) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func modifyRun(threadID: String, runID: String, parameters: ModifyRunParameters) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listRuns(threadID: String, limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<RunObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func cancelRun(threadID: String, runID: String) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func submitToolOutputsToRun(threadID: String, runID: String, parameters: RunToolsOutputParameter) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createThreadAndRun(parameters: CreateThreadAndRunParameter) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveRunstep(threadID: String, runID: String, stepID: String) async throws -> RunStepObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listRunSteps(threadID: String, runID: String, limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<RunStepObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createThreadAndRunStream(parameters: CreateThreadAndRunParameter) async throws -> AsyncThrowingStream<AssistantStreamEvent, Error> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createRunStream(threadID: String, parameters: RunParameter) async throws -> AsyncThrowingStream<AssistantStreamEvent, Error> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func submitToolOutputsToRunStream(threadID: String, runID: String, parameters: RunToolsOutputParameter) async throws -> AsyncThrowingStream<AssistantStreamEvent, Error> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createBatch(parameters: BatchParameter) async throws -> BatchObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveBatch(id: String) async throws -> BatchObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func cancelBatch(id: String) async throws -> BatchObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listBatch(after: String?, limit: Int?) async throws -> OpenAIResponse<BatchObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createVectorStore(parameters: VectorStoreParameter) async throws -> VectorStoreObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listVectorStores(limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<VectorStoreObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveVectorStore(id: String) async throws -> VectorStoreObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func modifyVectorStore(parameters: VectorStoreParameter, id: String) async throws -> VectorStoreObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func deleteVectorStore(id: String) async throws -> DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createVectorStoreFile(vectorStoreID: String, parameters: VectorStoreFileParameter) async throws -> VectorStoreFileObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listVectorStoreFiles(vectorStoreID: String, limit: Int?, order: String?, after: String?, before: String?, filter: String?) async throws -> OpenAIResponse<VectorStoreFileObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveVectorStoreFile(vectorStoreID: String, fileID: String) async throws -> VectorStoreFileObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func deleteVectorStoreFile(vectorStoreID: String, fileID: String) async throws -> DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func createVectorStoreFileBatch(vectorStoreID: String, parameters: VectorStoreFileBatchParameter) async throws -> VectorStoreFileBatchObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func retrieveVectorStoreFileBatch(vectorStoreID: String, batchID: String) async throws -> VectorStoreFileBatchObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func cancelVectorStoreFileBatch(vectorStoreID: String, batchID: String) async throws -> VectorStoreFileBatchObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   func listVectorStoreFilesInABatch(vectorStoreID: String, batchID: String, limit: Int?, order: String?, after: String?, before: String?, filter: String?) async throws -> OpenAIResponse<VectorStoreFileObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
}
