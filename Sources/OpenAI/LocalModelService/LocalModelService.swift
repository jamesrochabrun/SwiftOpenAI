//
//  LocalModelService.swift
//
//
//  Created by James Rochabrun on 6/30/24.
//

import Foundation

struct LocalModelService: OpenAIService {
  public init(
    apiKey: Authorization = .apiKey(""),
    baseURL: String,
    proxyPath: String? = nil,
    overrideVersion: String? = nil,
    httpClient: HTTPClient,
    decoder: JSONDecoder = .init(),
    debugEnabled: Bool)
  {
    self.httpClient = httpClient
    self.decoder = decoder
    self.apiKey = apiKey
    openAIEnvironment = OpenAIEnvironment(baseURL: baseURL, proxyPath: proxyPath, version: overrideVersion ?? "v1")
    self.debugEnabled = debugEnabled
  }

  public func createImages(
    parameters _: CreateImageParameters)
    async throws -> CreateImageResponse
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  public func editImage(
    parameters _: CreateImageEditParameters)
    async throws -> CreateImageResponse
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  public func createImageVariations(
    parameters _: CreateImageVariationParameters)
    async throws -> CreateImageResponse
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  let httpClient: HTTPClient
  let decoder: JSONDecoder
  let openAIEnvironment: OpenAIEnvironment

  func createTranscription(parameters _: AudioTranscriptionParameters) async throws -> AudioObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createTranslation(parameters _: AudioTranslationParameters) async throws -> AudioObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createSpeech(parameters _: AudioSpeechParameters) async throws -> AudioSpeechObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func startChat(
    parameters: ChatCompletionParameters)
    async throws -> ChatCompletionObject
  {
    var chatParameters = parameters
    chatParameters.stream = false
    let request = try LocalModelAPI.chat.request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: nil,
      method: .post,
      params: chatParameters)
    return try await fetch(debugEnabled: debugEnabled, type: ChatCompletionObject.self, with: request)
  }

  func startStreamedChat(
    parameters: ChatCompletionParameters)
    async throws -> AsyncThrowingStream<ChatCompletionChunkObject, Error>
  {
    var chatParameters = parameters
    chatParameters.stream = true
    chatParameters.streamOptions = .init(includeUsage: true)
    let request = try LocalModelAPI.chat.request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: nil,
      method: .post,
      params: chatParameters)
    return try await fetchStream(debugEnabled: debugEnabled, type: ChatCompletionChunkObject.self, with: request)
  }

  func createEmbeddings(parameters _: EmbeddingParameter) async throws -> OpenAIResponse<EmbeddingObject> {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createFineTuningJob(parameters _: FineTuningJobParameters) async throws -> FineTuningJobObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listFineTuningJobs(after _: String?, limit _: Int?) async throws -> OpenAIResponse<FineTuningJobObject> {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveFineTuningJob(id _: String) async throws -> FineTuningJobObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func cancelFineTuningJobWith(id _: String) async throws -> FineTuningJobObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listFineTuningEventsForJobWith(
    id _: String,
    after _: String?,
    limit _: Int?)
    async throws -> OpenAIResponse<FineTuningJobEventObject>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listFiles() async throws -> OpenAIResponse<FileObject> {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func uploadFile(parameters _: FileParameters) async throws -> FileObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func deleteFileWith(id _: String) async throws -> DeletionStatus {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveFileWith(id _: String) async throws -> FileObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveContentForFileWith(id _: String) async throws -> [[String: Any]] {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func legacyCreateImages(parameters _: ImageCreateParameters) async throws -> OpenAIResponse<ImageObject> {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func legacyEditImage(parameters _: ImageEditParameters) async throws -> OpenAIResponse<ImageObject> {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func legacyCreateImageVariations(parameters _: ImageVariationParameters) async throws -> OpenAIResponse<ImageObject> {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listModels() async throws -> OpenAIResponse<ModelObject> {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveModelWith(id _: String) async throws -> ModelObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func deleteFineTuneModelWith(id _: String) async throws -> DeletionStatus {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createModerationFromText(parameters _: ModerationParameter<String>) async throws -> ModerationObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createModerationFromTexts(parameters _: ModerationParameter<[String]>) async throws -> ModerationObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createAssistant(parameters _: AssistantParameters) async throws -> AssistantObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveAssistant(id _: String) async throws -> AssistantObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func modifyAssistant(id _: String, parameters _: AssistantParameters) async throws -> AssistantObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func deleteAssistant(id _: String) async throws -> DeletionStatus {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listAssistants(
    limit _: Int?,
    order _: String?,
    after _: String?,
    before _: String?)
    async throws -> OpenAIResponse<AssistantObject>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createThread(parameters _: CreateThreadParameters) async throws -> ThreadObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveThread(id _: String) async throws -> ThreadObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func modifyThread(id _: String, parameters _: ModifyThreadParameters) async throws -> ThreadObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func deleteThread(id _: String) async throws -> DeletionStatus {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createMessage(threadID _: String, parameters _: MessageParameter) async throws -> MessageObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveMessage(threadID _: String, messageID _: String) async throws -> MessageObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func modifyMessage(
    threadID _: String,
    messageID _: String,
    parameters _: ModifyMessageParameters)
    async throws -> MessageObject
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func deleteMessage(threadID _: String, messageID _: String) async throws -> DeletionStatus {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listMessages(
    threadID _: String,
    limit _: Int?,
    order _: String?,
    after _: String?,
    before _: String?,
    runID _: String?)
    async throws -> OpenAIResponse<MessageObject>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createRun(threadID _: String, parameters _: RunParameter) async throws -> RunObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveRun(threadID _: String, runID _: String) async throws -> RunObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func modifyRun(threadID _: String, runID _: String, parameters _: ModifyRunParameters) async throws -> RunObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listRuns(
    threadID _: String,
    limit _: Int?,
    order _: String?,
    after _: String?,
    before _: String?)
    async throws -> OpenAIResponse<RunObject>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func cancelRun(threadID _: String, runID _: String) async throws -> RunObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func submitToolOutputsToRun(
    threadID _: String,
    runID _: String,
    parameters _: RunToolsOutputParameter)
    async throws -> RunObject
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createThreadAndRun(parameters _: CreateThreadAndRunParameter) async throws -> RunObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveRunstep(threadID _: String, runID _: String, stepID _: String) async throws -> RunStepObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listRunSteps(
    threadID _: String,
    runID _: String,
    limit _: Int?,
    order _: String?,
    after _: String?,
    before _: String?)
    async throws -> OpenAIResponse<RunStepObject>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createThreadAndRunStream(parameters _: CreateThreadAndRunParameter) async throws
    -> AsyncThrowingStream<AssistantStreamEvent, Error>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createRunStream(
    threadID _: String,
    parameters _: RunParameter)
    async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func submitToolOutputsToRunStream(
    threadID _: String,
    runID _: String,
    parameters _: RunToolsOutputParameter)
    async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createBatch(parameters _: BatchParameter) async throws -> BatchObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveBatch(id _: String) async throws -> BatchObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func cancelBatch(id _: String) async throws -> BatchObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listBatch(after _: String?, limit _: Int?) async throws -> OpenAIResponse<BatchObject> {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createVectorStore(parameters _: VectorStoreParameter) async throws -> VectorStoreObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listVectorStores(
    limit _: Int?,
    order _: String?,
    after _: String?,
    before _: String?)
    async throws -> OpenAIResponse<VectorStoreObject>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveVectorStore(id _: String) async throws -> VectorStoreObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func modifyVectorStore(parameters _: VectorStoreParameter, id _: String) async throws -> VectorStoreObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func deleteVectorStore(id _: String) async throws -> DeletionStatus {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createVectorStoreFile(
    vectorStoreID _: String,
    parameters _: VectorStoreFileParameter)
    async throws -> VectorStoreFileObject
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listVectorStoreFiles(
    vectorStoreID _: String,
    limit _: Int?,
    order _: String?,
    after _: String?,
    before _: String?,
    filter _: String?)
    async throws -> OpenAIResponse<VectorStoreFileObject>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveVectorStoreFile(vectorStoreID _: String, fileID _: String) async throws -> VectorStoreFileObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func deleteVectorStoreFile(vectorStoreID _: String, fileID _: String) async throws -> DeletionStatus {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func createVectorStoreFileBatch(
    vectorStoreID _: String,
    parameters _: VectorStoreFileBatchParameter)
    async throws -> VectorStoreFileBatchObject
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func retrieveVectorStoreFileBatch(vectorStoreID _: String, batchID _: String) async throws -> VectorStoreFileBatchObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func cancelVectorStoreFileBatch(vectorStoreID _: String, batchID _: String) async throws -> VectorStoreFileBatchObject {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func listVectorStoreFilesInABatch(
    vectorStoreID _: String,
    batchID _: String,
    limit _: Int?,
    order _: String?,
    after _: String?,
    before _: String?,
    filter _: String?)
    async throws -> OpenAIResponse<VectorStoreFileObject>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  // MARK: Response

  func responseCreate(
    _: ModelResponseParameter)
    async throws -> ResponseModel
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func responseModel(
    id _: String)
    async throws -> ResponseModel
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  func responseCreateStream(
    _: ModelResponseParameter)
    async throws -> AsyncThrowingStream<ResponseStreamEvent, Error>
  {
    fatalError(
      "Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
  }

  /// [authentication](https://platform.openai.com/docs/api-reference/authentication)
  private let apiKey: Authorization
  /// Set this flag to TRUE if you need to print request events in DEBUG builds.
  private let debugEnabled: Bool
}
