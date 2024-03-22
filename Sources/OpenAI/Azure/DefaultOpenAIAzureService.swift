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
      decoder: JSONDecoder = .init())
   {
      session = URLSession(configuration: urlSessionConfiguration)
      self.decoder = decoder
      AzureOpenAIAPI.azureOpenAIResource = azureConfiguration.resourceName
      apiKey = azureConfiguration.openAIAPIKey
      apiVersion = azureConfiguration.apiVersion
   }
   
   public let session: URLSession
   public let decoder: JSONDecoder
   private let apiKey: Authorization
   private let apiVersion: String
   
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
      let queryItems: [URLQueryItem]  = [.init(name: "api-version", value: apiVersion)]
      let request = try AzureOpenAIAPI.chat(deploymentID: parameters.model).request(
         apiKey: apiKey,
         organizationID: nil,
         method: .post,
         params: chatParameters,
         queryItems: queryItems)
      return try await fetch(type: ChatCompletionObject.self, with: request)
   }
   
   public func startStreamedChat(parameters: ChatCompletionParameters) async throws -> AsyncThrowingStream<ChatCompletionChunkObject, Error> {
      var chatParameters = parameters
      chatParameters.stream = true
      let queryItems: [URLQueryItem]  = [.init(name: "api-version", value: apiVersion)]
      let request = try AzureOpenAIAPI.chat(deploymentID: parameters.model).request(
         apiKey: apiKey,
         organizationID: nil,
         method: .post,
         params: chatParameters,
         queryItems: queryItems
      )
      return try await fetchStream(type: ChatCompletionChunkObject.self, with: request)
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
   
   public func deleteFileWith(id: String) async throws -> FileObject.DeletionStatus {
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
   
   public func deleteFineTuneModelWith(id: String) async throws -> ModelObject.DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createModerationFromText(parameters: ModerationParameter<String>) async throws -> ModerationObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createModerationFromTexts(parameters: ModerationParameter<[String]>) async throws -> ModerationObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createAssistant(parameters: AssistantParameters) async throws -> AssistantObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveAssistant(id: String) async throws -> AssistantObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func modifyAssistant(id: String, parameters: AssistantParameters) async throws -> AssistantObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func deleteAssistant(id: String) async throws -> AssistantObject.DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listAssistants(limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<AssistantObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createAssistantFile(assistantID: String, parameters: AssistantFileParamaters) async throws -> AssistantFileObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveAssistantFile(assistantID: String, fileID: String) async throws -> AssistantFileObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func deleteAssistantFile(assistantID: String, fileID: String) async throws -> AssistantFileObject.DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listAssistantFiles(assistantID: String, limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<AssistantFileObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createThread(parameters: CreateThreadParameters) async throws -> ThreadObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveThread(id: String) async throws -> ThreadObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func modifyThread(id: String, parameters: ModifyThreadParameters) async throws -> ThreadObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func deleteThread(id: String) async throws -> ThreadObject.DeletionStatus {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createMessage(threadID: String, parameters: MessageParameter) async throws -> MessageObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveMessage(threadID: String, messageID: String) async throws -> MessageObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func modifyMessage(threadID: String, messageID: String, parameters: ModifyMessageParameters) async throws -> MessageObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listMessages(threadID: String, limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<MessageObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveMessageFile(threadID: String, messageID: String, fileID: String) async throws -> MessageFileObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listMessageFiles(threadID: String, messageID: String, limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<MessageFileObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createRun(threadID: String, parameters: RunParameter) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveRun(threadID: String, runID: String) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func modifyRun(threadID: String, runID: String, parameters: ModifyRunParameters) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listRuns(threadID: String, limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<RunObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func cancelRun(threadID: String, runID: String) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func submitToolOutputsToRun(threadID: String, runID: String, parameters: RunToolsOutputParameter) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createThreadAndRun(parameters: CreateThreadAndRunParameter) async throws -> RunObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func retrieveRunstep(threadID: String, runID: String, stepID: String) async throws -> RunStepObject {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func listRunSteps(threadID: String, runID: String, limit: Int?, order: String?, after: String?, before: String?) async throws -> OpenAIResponse<RunStepObject> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createThreadAndRunStream(
      parameters: CreateThreadAndRunParameter)
   async throws -> AsyncThrowingStream<AssistantStreamEvent, Error> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func createRunStream(
      threadID: String,
      parameters: RunParameter)
      async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
   {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
   
   public func submitToolOutputsToRunStream(
      threadID: String,
      runID: String,
      parameters: RunToolsOutputParameter)
   async throws -> AsyncThrowingStream<AssistantStreamEvent, Error> {
      fatalError("Currently, this API is not supported. We welcome and encourage contributions to our open-source project. Please consider opening an issue or submitting a pull request to add support for this feature.")
   }
}
