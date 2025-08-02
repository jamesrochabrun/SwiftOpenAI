//
//  OpenAIService.swift
//
//
//  Created by James Rochabrun on 10/17/23.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

// MARK: - APIError

public enum APIError: Error {
  case requestFailed(description: String)
  case responseUnsuccessful(description: String, statusCode: Int)
  case invalidData
  case jsonDecodingFailure(description: String)
  case dataCouldNotBeReadMissingData(description: String)
  case bothDecodingStrategiesFailed
  case timeOutError

  public var displayDescription: String {
    switch self {
    case .requestFailed(let description): description
    case .responseUnsuccessful(let description, _): description
    case .invalidData: "Invalid data"
    case .jsonDecodingFailure(let description): description
    case .dataCouldNotBeReadMissingData(let description): description
    case .bothDecodingStrategiesFailed: "Decoding strategies failed."
    case .timeOutError: "Time Out Error."
    }
  }
}

// MARK: - Authorization

public enum Authorization {
  case apiKey(String)
  case bearer(String)

  var headerField: String {
    switch self {
    case .apiKey:
      "api-key"
    case .bearer:
      "Authorization"
    }
  }

  var value: String {
    switch self {
    case .apiKey(let value):
      value
    case .bearer(let value):
      "Bearer \(value)"
    }
  }
}

// MARK: - OpenAIEnvironment

/// Represents the configuration for interacting with the OpenAI API.
public struct OpenAIEnvironment {
  /// The base URL for the OpenAI API.
  /// Example: "https://api.openai.com"
  let baseURL: String

  /// An optional path for proxying requests.
  /// Example: "/proxy-path"
  let proxyPath: String?

  /// An optional version of the OpenAI API to use.
  /// Example: "v1"
  let version: String?
}

// MARK: - OpenAIService

/// A protocol defining the required services for interacting with OpenAI's API.
///
/// The protocol outlines methods for fetching data and streaming responses,
/// as well as handling JSON decoding and networking tasks.
public protocol OpenAIService {
  /// The HTTP client responsible for executing all network requests.
  ///
  /// This client is used for tasks like sending and receiving data.
  var httpClient: HTTPClient { get }

  /// The `JSONDecoder` instance used for decoding JSON responses.
  ///
  /// This decoder is used to parse the JSON responses returned by the API
  /// into model objects that conform to the `Decodable` protocol.
  var decoder: JSONDecoder { get }

  /// A computed property representing the current OpenAI environment configuration.
  var openAIEnvironment: OpenAIEnvironment { get }

  // MARK: Audio

  /// - Parameter parameters: The audio transcription parameters.
  /// - Returns: Transcriped text details.
  /// - Throws: An error if the process fails.
  ///
  /// For more information, refer to [OpenAI's Audio Transcription API documentation](https://platform.openai.com/docs/api-reference/audio/createTranscription).
  func createTranscription(
    parameters: AudioTranscriptionParameters)
    async throws -> AudioObject

  /// - Parameter parameters: The audio translation parameters.
  /// - Returns: Translated text details.
  /// - Throws: An error if the process fails.
  ///
  /// For more information, refer to [OpenAI's Audio Translation API documentation](https://platform.openai.com/docs/api-reference/audio/createTranslation).
  func createTranslation(
    parameters: AudioTranslationParameters)
    async throws -> AudioObject

  /// - Parameter parameters: The audio speech parameters.
  /// - Returns: The audio file content.
  /// - Throws: An error if the process fails.
  ///
  /// For more information, refer to [OpenAI's Audio Speech API documentation](https://platform.openai.com/docs/api-reference/audio/createSpeech).
  func createSpeech(
    parameters: AudioSpeechParameters)
    async throws -> AudioSpeechObject

  // MARK: Chat

  /// - Parameter parameters: Parameters for the chat completion request.
  /// - Returns: A [ChatCompletionObject](https://platform.openai.com/docs/api-reference/chat/object).
  /// - Throws: An error if the chat initiation fails.
  ///
  /// For more information, refer to [OpenAI's Chat completion API documentation](https://platform.openai.com/docs/api-reference/chat/create).
  func startChat(
    parameters: ChatCompletionParameters)
    async throws -> ChatCompletionObject

  /// - Parameter parameters: Parameters for the chat completion request.
  /// - Returns: A streamed sequence of [ChatCompletionChunkObject](https://platform.openai.com/docs/api-reference/chat/streaming) objects.
  /// - Throws: An error if the chat initiation fails.
  ///
  /// For more information, refer to [OpenAI's Chat completion API documentation](https://platform.openai.com/docs/api-reference/chat/create).
  func startStreamedChat(
    parameters: ChatCompletionParameters)
    async throws -> AsyncThrowingStream<ChatCompletionChunkObject, Error>

  // MARK: Embeddings

  /// - Parameter parameters: Parameters for the embedding request.
  /// - Returns: An `OpenAIResponse<EmbeddingObject>` containing the generated [embedding objects](https://platform.openai.com/docs/api-reference/embeddings/object).
  /// - Throws: An error if the embedding creation fails.
  ///
  /// For more information, refer to [OpenAI's Embedding API documentation](https://platform.openai.com/docs/api-reference/embeddings/create).
  func createEmbeddings(
    parameters: EmbeddingParameter)
    async throws -> OpenAIResponse<EmbeddingObject>

  // MARK: Fine-tuning

  /// - Parameter parameters: Parameters for the fine-tuning job request.
  /// - Returns: A [FineTuningJobObject](https://platform.openai.com/docs/api-reference/fine-tuning/object) containing details of the created job.
  /// - Throws: An error if the fine-tuning job creation fails.
  ///
  /// For more information, refer to [OpenAI's Fine-Tuning API documentation](https://platform.openai.com/docs/api-reference/fine-tuning/create).
  func createFineTuningJob(
    parameters: FineTuningJobParameters)
    async throws -> FineTuningJobObject

  /// Retrieves a paginated list of fine-tuning jobs.
  ///
  /// - Parameters:
  ///   - lastJobID: Identifier for the last job from the previous pagination request. Optional.
  ///   - limit: Number of fine-tuning jobs to retrieve. If `nil`, the API defaults to 20.
  /// - Returns: An `OpenAIResponse<FineTuningJobObject>` containing a list of paginated [fine-tuning job objects](https://platform.openai.com/docs/api-reference/fine-tuning/object).
  /// - Throws: An error if the retrieval process fails.
  ///
  /// For more information, refer to [OpenAI's Fine-Tuning API documentation](https://platform.openai.com/docs/api-reference/fine-tuning/list).
  func listFineTuningJobs(
    after lastJobID: String?,
    limit: Int?)
    async throws -> OpenAIResponse<FineTuningJobObject>

  /// Retrieves a specific fine-tuning job by its ID.
  ///
  /// - Parameter id: The identifier of the fine-tuning job to retrieve.
  /// - Returns: A [FineTuningJobObject](https://platform.openai.com/docs/api-reference/fine-tuning/object) containing the details of the fine-tuning job.
  /// - Throws: An error if the retrieval process fails.
  ///
  /// For more information, refer to [OpenAI's Fine-Tuning API documentation](https://platform.openai.com/docs/api-reference/fine-tuning/retrieve).
  func retrieveFineTuningJob(
    id: String)
    async throws -> FineTuningJobObject

  /// Cancels an ongoing fine-tuning job specified by its ID.
  ///
  /// - Parameter id: The identifier of the fine-tuning job to cancel.
  /// - Returns: A [FineTuningJobObject](https://platform.openai.com/docs/api-reference/fine-tuning/object) reflecting the cancelled status.
  /// - Throws: An error if the cancellation process fails.
  ///
  /// For more information, refer to [OpenAI's Fine-Tuning API documentation](https://platform.openai.com/docs/api-reference/fine-tuning/cancel).
  func cancelFineTuningJobWith(
    id: String)
    async throws -> FineTuningJobObject

  /// Retrieves a list of events for a specified fine-tuning job, with optional pagination.
  ///
  /// - Parameter id: The identifier of the fine-tuning job for which to fetch events.
  /// - Parameter after: The ID of the last event retrieved in a previous pagination request.
  /// - Parameter limit: The number of events to retrieve; if `nil`, the API defaults to 20.
  /// - Returns: An `OpenAIResponse<FineTuningJobEventObject>` containing the list of events in [fine-tuning job](https://platform.openai.com/docs/api-reference/fine-tuning/object).
  /// - Throws: An error if the retrieval process fails.
  ///
  /// For more information, refer to [OpenAI's Fine-Tuning API documentation](https://platform.openai.com/docs/api-reference/fine-tuning/list-events).
  func listFineTuningEventsForJobWith(
    id: String,
    after lastEventId: String?,
    limit: Int?)
    async throws -> OpenAIResponse<FineTuningJobEventObject>

  // MARK: Files

  /// Retrieves a list of files that belong to the user's organization.
  ///
  /// - Returns: An `OpenAIResponse<FileObject>` containing a list of [file objects](https://platform.openai.com/docs/api-reference/files/object) associated with the user's organization.
  /// - Throws: An error if the retrieval process fails.
  ///
  /// For more information, see [OpenAI's File API documentation](https://platform.openai.com/docs/api-reference/files/list).
  func listFiles()
    async throws -> OpenAIResponse<FileObject>

  /// - Parameter parameters: The parameters and data needed for the file upload.
  /// - Returns: A [FileObject](https://platform.openai.com/docs/api-reference/files/object) representing the uploaded file.
  /// - Throws: An error if the upload process fails.
  ///
  /// For more details, refer to [OpenAI's File Upload API documentation](https://platform.openai.com/docs/api-reference/files/create).
  func uploadFile(
    parameters: FileParameters)
    async throws -> FileObject

  /// Deletes a file with the specified ID and returns its deletion status.
  ///
  /// - Parameter id: The identifier of the file to be deleted.
  /// - Returns: A `DeletionStatus` indicating the outcome of the deletion.
  /// - Throws: An error if the deletion process fails.
  /// For more details, refer to [OpenAI's File Upload API documentation](https://platform.openai.com/docs/api-reference/files/delete).
  func deleteFileWith(
    id: String)
    async throws -> DeletionStatus

  /// - Parameter id: The ID of the file to retrieve.
  /// - Returns: A [FileObject](https://platform.openai.com/docs/api-reference/files/object) containing the details of the retrieved file.
  /// - Throws: An error if the retrieval process fails.
  ///
  /// For more information, refer to [OpenAI's File API documentation](https://platform.openai.com/docs/api-reference/files/retrieve).
  func retrieveFileWith(
    id: String)
    async throws -> FileObject

  /// - Parameter id: The ID of the file whose content is to be retrieved.
  /// - Returns: An array of dictionaries containing the file content.
  /// - Throws: An error if the content retrieval process fails.
  ///  For more information, refer to [OpenAI's File API documentation](https://platform.openai.com/docs/api-reference/files/retrieve-contents).
  func retrieveContentForFileWith(
    id: String)
    async throws -> [[String: Any]]

  // MARK: Images

  /// - Parameter parameters: Settings for the image creation request.
  /// - Returns: An `OpenAIResponse` containing a list of [ImageObject](https://platform.openai.com/docs/api-reference/images/object) instances that represent the created images.
  /// - Throws: An error if the image creation process fails.
  ///
  /// For more information, refer to [OpenAI's Image API documentation](https://platform.openai.com/docs/api-reference/images/create).
  func legacyCreateImages(
    parameters: ImageCreateParameters)
    async throws -> OpenAIResponse<ImageObject>

  /// - Parameter parameters: Settings for the image edit request.
  /// - Returns: An `OpenAIResponse` containing a list of [ImageObject](https://platform.openai.com/docs/api-reference/images/object) instances that represent the edited images.
  /// - Throws: An error if the image editing process fails.
  ///
  /// For more information, refer to [OpenAI's Image API documentation](https://platform.openai.com/docs/api-reference/images/createEdit).
  func legacyEditImage(
    parameters: ImageEditParameters)
    async throws -> OpenAIResponse<ImageObject>

  /// - Parameter parameters: Settings for the image variation request.
  /// - Returns: An `OpenAIResponse` containing a list of [ImageObject](https://platform.openai.com/docs/api-reference/images/object) instances that represent the created image variations.
  /// - Throws: An error if the image variation creation process fails.
  ///
  /// For more information, refer to [OpenAI's Image API documentation](https://platform.openai.com/docs/api-reference/images/createVariation).
  func legacyCreateImageVariations(
    parameters: ImageVariationParameters)
    async throws -> OpenAIResponse<ImageObject>

  /// - Parameter parameters: Settings for the image creation request.
  /// - Returns: An `OpenAIResponse` containing image generation results.
  /// - Throws: An error if the image creation process fails.
  ///
  /// For more information, refer to [OpenAI's Image API documentation](https://platform.openai.com/docs/api-reference/images/create).
  func createImages(
    parameters: CreateImageParameters)
    async throws -> CreateImageResponse

  /// - Parameter parameters: Settings for the image edit request.
  /// - Returns: An `OpenAIResponse` containing edited image results.
  /// - Throws: An error if the image editing process fails.
  ///
  /// For more information, refer to [OpenAI's Image API documentation](https://platform.openai.com/docs/api-reference/images/createEdit).
  func editImage(
    parameters: CreateImageEditParameters)
    async throws -> CreateImageResponse

  /// - Parameter parameters: Settings for the image variation request.
  /// - Returns: An `OpenAIResponse` containing image variation results.
  /// - Throws: An error if the image variation creation process fails.
  ///
  /// For more information, refer to [OpenAI's Image API documentation](https://platform.openai.com/docs/api-reference/images/createVariation).
  func createImageVariations(
    parameters: CreateImageVariationParameters)
    async throws -> CreateImageResponse

  // MARK: Models

  /// - Returns: An `OpenAIResponse` containing a list of [ModelObject](https://platform.openai.com/docs/api-reference/models/object) instances, detailing each available model's owner and availability.
  /// - Throws: An error if the retrieval process fails.
  ///
  /// For more information, refer to [OpenAI's Models API documentation](https://platform.openai.com/docs/api-reference/models/list).
  func listModels()
    async throws -> OpenAIResponse<ModelObject>

  /// - Parameter id: The identifier of the model to be retrieved.
  /// - Returns: A [ModelObject](https://platform.openai.com/docs/api-reference/models/object) containing details of the model matching the specified ID.
  /// - Throws: An error if the retrieval process fails.
  ///
  /// For more information, refer to [OpenAI's Models API documentation](https://platform.openai.com/docs/api-reference/models/retrieve).
  func retrieveModelWith(
    id: String)
    async throws -> ModelObject

  /// Deletes a fine-tuned model from OpenAI's service by its ID.
  ///
  /// - Parameter id: The identifier of the fine-tuned model to be deleted.
  /// - Returns: A `DeletionStatus` indicating the outcome of the deletion process.
  /// - Throws: An error if the deletion process fails.
  ///
  /// For more information, refer to [OpenAI's Models API documentation](https://platform.openai.com/docs/api-reference/models/delete).
  func deleteFineTuneModelWith(
    id: String)
    async throws -> DeletionStatus

  // MARK: Moderations

  /// - Parameter parameters: The text to be moderated according to the specified settings.
  /// - Returns: A [ModerationObject](https://platform.openai.com/docs/api-reference/moderations/object) detailing the results of the moderation process.
  /// - Throws: An error if the moderation process fails.
  ///
  /// For more information, refer to [OpenAI's Moderation API documentation](https://platform.openai.com/docs/api-reference/moderations/create).
  func createModerationFromText(
    parameters: ModerationParameter<String>)
    async throws -> ModerationObject

  /// - Parameter parameters: The array of texts to be moderated according to the specified settings.
  /// - Returns: A [ModerationObject](https://platform.openai.com/docs/api-reference/moderations/object) detailing the results of the moderation process.
  /// - Throws: An error if the moderation process fails.
  ///
  /// For more information, refer to [OpenAI's Moderation API documentation](https://platform.openai.com/docs/api-reference/moderations/create).
  func createModerationFromTexts(
    parameters: ModerationParameter<[String]>)
    async throws -> ModerationObject

  // MARK: Assistants [BETA]

  /// Create an assistant with a model and instructions.
  ///
  /// - Parameter parameters: The parameters needed to build an assistant
  /// - Returns: A [AssistantObject](https://platform.openai.com/docs/api-reference/assistants/object)
  /// - Throws: An error if the request fails
  ///
  /// For more information, refer to [OpenAI's Assistants API documentation](https://platform.openai.com/docs/api-reference/assistants/createAssistant).
  func createAssistant(
    parameters: AssistantParameters)
    async throws -> AssistantObject

  /// Retrieves an assitant object by its ID.
  ///
  /// - Parameter id: The ID of the assistant to retrieve.
  /// - Returns: The [AssistantObject](https://platform.openai.com/docs/api-reference/assistants/object) object matching the specified ID.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Assistants API documentation](https://platform.openai.com/docs/api-reference/assistants/getAssistant).
  func retrieveAssistant(
    id: String)
    async throws -> AssistantObject

  /// Modifies an assistant.
  ///
  /// - Parameter id: The ID of the assistant to modify.
  /// - Parameter parameters: The parameters needed to modify an assistant
  /// - Returns: The modified [AssistantObject](https://platform.openai.com/docs/api-reference/assistants/object)
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Assistants documentation](https://platform.openai.com/docs/api-reference/assistants/modifyAssistant).
  func modifyAssistant(
    id: String,
    parameters: AssistantParameters)
    async throws -> AssistantObject

  /// Delete an assistant.
  ///
  /// - Parameter id: The ID of the assistant to delete.
  /// - Returns: Deletion Status
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Assistants documentation](https://platform.openai.com/docs/api-reference/assistants/deleteAssistant).
  func deleteAssistant(
    id: String)
    async throws -> DeletionStatus

  /// Returns a list of assistants.
  ///
  /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.  Defaults to desc.
  /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
  /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
  /// - Returns: An `OpenAIResponse<AssistantObject>` containing the list of [assistants](https://platform.openai.com/docs/api-reference/assistants/object).
  /// - Throws: An error if the retrieval process fails.
  ///
  /// For more information, refer to [OpenAI's Assistants API documentation](https://platform.openai.com/docs/api-reference/assistants/listAssistants).
  func listAssistants(
    limit: Int?,
    order: String?,
    after: String?,
    before: String?)
    async throws -> OpenAIResponse<AssistantObject>

  // MARK: Thread [BETA]

  /// Create a thread.
  ///
  /// - Parameter parameters: The parameters needed to build a thread.
  /// - Returns: A [thread](https://platform.openai.com/docs/api-reference/threads) object.
  /// - Throws: An error if the request fails
  ///
  /// For more information, refer to [OpenAI's Thread API documentation](https://platform.openai.com/docs/api-reference/threads/createThread).
  func createThread(
    parameters: CreateThreadParameters)
    async throws -> ThreadObject

  /// Retrieves a thread.
  ///
  /// - Parameter id: The ID of the thread to retrieve.
  /// - Returns: The [thread](https://platform.openai.com/docs/api-reference/threads/object) object matching the specified ID.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Thread API documentation](https://platform.openai.com/docs/api-reference/threads/getThread).
  func retrieveThread(
    id: String)
    async throws -> ThreadObject

  /// Modifies a thread.
  ///
  /// - Parameter id: The ID of the thread to modify. Only the metadata can be modified.
  /// - Parameter parameters: The parameters needed to modify a thread. Only the metadata can be modified.
  /// - Returns: The modified [thread](https://platform.openai.com/docs/api-reference/threads/object) object matching the specified ID.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Thread API documentation](https://platform.openai.com/docs/api-reference/threads/modifyThread).
  func modifyThread(
    id: String,
    parameters: ModifyThreadParameters)
    async throws -> ThreadObject

  /// Delete a thread.
  ///
  /// - Parameter id: The ID of the thread to delete.
  /// - Returns: Deletion status.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Thread API documentation](https://platform.openai.com/docs/api-reference/threads/deleteThread).
  func deleteThread(
    id: String)
    async throws -> DeletionStatus

  // MARK: Message [BETA]

  /// Create a message.
  ///
  /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) to create a message for.
  /// - Parameter parameters: The parameters needed to build a message.
  /// - Returns: A [message](https://platform.openai.com/docs/api-reference/messages/object) object.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Message API documentation](https://platform.openai.com/docs/api-reference/messages/createMessage).
  func createMessage(
    threadID: String,
    parameters: MessageParameter)
    async throws -> MessageObject

  /// Retrieve a message.
  ///
  /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) to which this message belongs.
  /// - Parameter messageID: The ID of the message to retrieve.
  /// - Returns: The [message](https://platform.openai.com/docs/api-reference/threads/messages/object) object matching the specified ID.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Message API documentation](https://platform.openai.com/docs/api-reference/messages/getMessage).
  func retrieveMessage(
    threadID: String,
    messageID: String)
    async throws -> MessageObject

  /// Modifies a message.
  ///
  /// - Parameter threadID: The ID of the thread to which this message belongs.
  /// - Parameter messageID: The ID of the message to modify.
  /// - Parameter parameters: The parameters needed to modify a message metadata.
  /// - Returns: The modified [message](https://platform.openai.com/docs/api-reference/threads/messages/object) object.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Message API documentation](https://platform.openai.com/docs/api-reference/messages/modifyMessage).
  func modifyMessage(
    threadID: String,
    messageID: String,
    parameters: ModifyMessageParameters)
    async throws -> MessageObject

  /// Deletes a message.
  ///
  /// - Parameter threadID: The ID of the thread to which this message belongs.
  /// - Parameter messageID: The ID of the message to modify.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Message API documentation](https://platform.openai.com/docs/api-reference/messages/deleteMessage).
  func deleteMessage(
    threadID: String,
    messageID: String)
    async throws -> DeletionStatus

  /// Returns a list of messages for a given thread.
  ///
  /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) the messages belong to.
  /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order. Defaults to desc
  /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
  /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
  /// - Parameter runID: Filter messages by the run ID that generated them.
  /// - Returns: A list of [message](https://platform.openai.com/docs/api-reference/messages) objects.
  /// - Throws: An error if the request fails
  ///
  /// For more information, refer to [OpenAI's Message API documentation](https://platform.openai.com/docs/api-reference/messages/listMessages).
  func listMessages(
    threadID: String,
    limit: Int?,
    order: String?,
    after: String?,
    before: String?,
    runID: String?)
    async throws -> OpenAIResponse<MessageObject>

  // MARK: Run [BETA]

  /// Create a run.
  ///
  /// - Parameter threadID: The ID of the thread to run.
  /// - Parameter parameters: The parameters needed to build a Run.
  /// - Returns: A [run](https://platform.openai.com/docs/api-reference/runs/object) object.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/createRun).
  func createRun(
    threadID: String,
    parameters: RunParameter)
    async throws -> RunObject

  /// Retrieves a run.
  ///
  /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) that was run.
  /// - Parameter runID: The ID of the run to retrieve.
  /// - Returns: The [run](https://platform.openai.com/docs/api-reference/runs/object) object matching the specified ID.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/getRun).
  func retrieveRun(
    threadID: String,
    runID: String)
    async throws -> RunObject

  /// Modifies a run.
  ///
  /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) that was run.
  /// - Parameter runID: The ID of the run to modify.
  /// - Parameter parameters: The parameters needed to modify a run metadata.
  /// - Returns: The modified [run](https://platform.openai.com/docs/api-reference/runs/object) object matching the specified ID.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/modifyRun).
  func modifyRun(
    threadID: String,
    runID: String,
    parameters: ModifyRunParameters)
    async throws -> RunObject

  ///  Returns a list of runs belonging to a thread.
  ///
  /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) the run belongs to.
  /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order. Defaults to desc
  /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
  /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
  /// - Returns: A list of [run](https://platform.openai.com/docs/api-reference/runs/object) objects.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/listRuns).
  func listRuns(
    threadID: String,
    limit: Int?,
    order: String?,
    after: String?,
    before: String?)
    async throws -> OpenAIResponse<RunObject>

  /// Cancels a run that is in_progress.
  ///
  /// - Parameter threadID: The ID of the thread to which this run belongs.
  /// - Parameter runID: The ID of the run to cancel.
  /// - Returns: The modified [run](https://platform.openai.com/docs/api-reference/runs/object) object matching the specified ID.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/cancelRun).
  func cancelRun(
    threadID: String,
    runID: String)
    async throws -> RunObject

  /// When a run has the status: "requires_action" and required_action.type is submit_tool_outputs, this endpoint can be used to submit the outputs from the tool calls once they're all completed. All outputs must be submitted in a single request.
  ///
  /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) to which this run belongs.
  /// - Parameter runID: The ID of the run that requires the tool output submission.
  /// - Parameter parameters: The parameters needed for the run tools output.
  /// - Returns: The modified [run](https://platform.openai.com/docs/api-reference/runs/object) object matching the specified ID.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs).
  func submitToolOutputsToRun(
    threadID: String,
    runID: String,
    parameters: RunToolsOutputParameter)
    async throws -> RunObject

  /// Create a thread and run it in one request.
  ///
  /// - Parameter parameters: The parameters needed to create a thread and run.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/createThreadAndRun).
  func createThreadAndRun(
    parameters: CreateThreadAndRunParameter)
    async throws -> RunObject

  // MARK: Run Step [BETA]

  /// Retrieves a run step.
  ///
  /// - Parameter threadID: The ID of the thread to which the run and run step belongs.
  /// - Parameter runID: The ID of the run to which the run step belongs.
  /// - Parameter stepID: The ID of the run step to retrieve.
  /// - Returns: The [run step](https://platform.openai.com/docs/api-reference/runs/step-object) object matching the specified ID.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run step API documentation](https://platform.openai.com/docs/api-reference/runs/getRunStep).
  func retrieveRunstep(
    threadID: String,
    runID: String,
    stepID: String)
    async throws -> RunStepObject

  /// Returns a list of run steps belonging to a run.
  ///
  /// - Parameter threadID: The ID of the thread the run and run steps belong to.
  /// - Parameter runID: The ID of the run the run steps belong to.
  /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.  Defaults to desc.
  /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
  /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
  /// - Returns: A list of [run step](https://platform.openai.com/docs/api-reference/runs/step-object) objects.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run step API documentation](https://platform.openai.com/docs/api-reference/runs/listRunSteps).
  func listRunSteps(
    threadID: String,
    runID: String,
    limit: Int?,
    order: String?,
    after: String?,
    before: String?)
    async throws -> OpenAIResponse<RunStepObject>

  /// Creates a thread and run with stream enabled.
  ///
  /// - Parameter parameters: The parameters needed to create a thread and run.
  /// - Returns: An AsyncThrowingStream of [AssistantStreamEvent](https://platform.openai.com/docs/api-reference/assistants-streaming/events) objects.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/createThreadAndRun).
  func createThreadAndRunStream(
    parameters: CreateThreadAndRunParameter)
    async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>

  /// Create a run with stream enabled.
  ///
  /// - Parameter threadID: The ID of the thread to run.
  /// - Parameter parameters: The parameters needed to build a Run.
  /// - Returns: An AsyncThrowingStream of [AssistantStreamEvent](https://platform.openai.com/docs/api-reference/assistants-streaming/events) objects.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/createRun).
  func createRunStream(
    threadID: String,
    parameters: RunParameter)
    async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>

  /// When a run has the status: "requires_action" and required_action.type is submit_tool_outputs, this endpoint can be used to submit the outputs from the tool calls once they're all completed. All outputs must be submitted in a single request. Stream enabled
  ///
  /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) to which this run belongs.
  /// - Parameter runID: The ID of the run that requires the tool output submission.
  /// - Parameter parameters: The parameters needed for the run tools output.
  /// - Returns: An AsyncThrowingStream of [AssistantStreamEvent](https://platform.openai.com/docs/api-reference/assistants-streaming/events) objects.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Run API documentation](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs).
  func submitToolOutputsToRunStream(
    threadID: String,
    runID: String,
    parameters: RunToolsOutputParameter)
    async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>

  // MARK: Batch

  /// Creates and executes a batch from an uploaded file of requests
  ///
  /// - Parameter parameters: The parameters needed to create a batch.
  /// - Returns: A [batch](https://platform.openai.com/docs/api-reference/batch/object) object.
  /// - Throws: An error if the request fails
  ///
  /// For more information, refer to [OpenAI's Batch API documentation](https://platform.openai.com/docs/api-reference/batch/create).
  func createBatch(
    parameters: BatchParameter)
    async throws -> BatchObject

  /// Retrieves a batch.
  ///
  /// - Parameter id: The identifier of the batch to retrieve.
  /// - Returns: A [BatchObject](https://platform.openai.com/docs/api-reference/batch/object) matching the specified ID..
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Batch documentation](https://platform.openai.com/docs/api-reference/batch/retrieve).
  func retrieveBatch(
    id: String)
    async throws -> BatchObject

  /// Cancels an in-progress batch.
  ///
  /// - Parameter id: The identifier of the batch to cancel.
  /// - Returns: A [BatchObject](https://platform.openai.com/docs/api-reference/batch/object) matching the specified ID..
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Batch documentation](https://platform.openai.com/docs/api-reference/batch/cancel)
  func cancelBatch(
    id: String)
    async throws -> BatchObject

  /// List your organization's batches.
  ///
  /// - Parameters:
  ///   - after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
  ///   - limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  /// - Returns: An `OpenAIResponse<BatchObject>` containing a list of paginated [Batch](https://platform.openai.com/docs/api-reference/batch/object) objects.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Batch API documentation](https://platform.openai.com/docs/api-reference/batch/list).
  func listBatch(
    after: String?,
    limit: Int?)
    async throws -> OpenAIResponse<BatchObject>

  // MARK: Vector Store

  /// Create a vector store.
  ///
  /// - Parameter parameters: The parameters needed to create a vector store.
  /// - Returns: A [Vector store](https://platform.openai.com/docs/api-reference/vector-stores) object.
  /// - Throws: An error if the request fails
  ///
  /// For more information, refer to [OpenAI's Vector store API documentation](https://platform.openai.com/docs/api-reference/vector-stores/create).
  func createVectorStore(
    parameters: VectorStoreParameter)
    async throws -> VectorStoreObject

  /// Returns a list of vector stores.
  ///
  /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.
  /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
  /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
  /// - Returns: A list of [VectorStoreObject](https://platform.openai.com/docs/api-reference/vector-stores) objects.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Vector stores API documentation](https://platform.openai.com/docs/api-reference/vector-stores/list).
  func listVectorStores(
    limit: Int?,
    order: String?,
    after: String?,
    before: String?)
    async throws -> OpenAIResponse<VectorStoreObject>

  /// Retrieves a vector store.
  ///
  /// - Parameter id: The ID of the vector store to retrieve.
  /// - Returns: A [Vector Store](https://platform.openai.com/docs/api-reference/vector-stores) matching the specified ID..
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Batch documentation](https://platform.openai.com/docs/api-reference/vector-stores/retrieve).
  func retrieveVectorStore(
    id: String)
    async throws -> VectorStoreObject

  /// Modifies a vector store.
  ///
  /// - Parameter id: The ID of the vector store to modify.
  /// - Parameter parameters: The parameters needed to modify a vector store.
  /// - Returns: A [Vector Store](https://platform.openai.com/docs/api-reference/vector-stores) matching the specified ID..
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Batch documentation](https://platform.openai.com/docs/api-reference/vector-stores/modify).
  func modifyVectorStore(
    parameters: VectorStoreParameter,
    id: String)
    async throws -> VectorStoreObject

  /// Delete a vector store.
  ///
  /// - Parameter id: The ID of the vector store to delete.
  /// - Returns: A Deletion status.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Batch documentation](https://platform.openai.com/docs/api-reference/vector-stores/modify).
  func deleteVectorStore(
    id: String)
    async throws -> DeletionStatus

  // MARK: Vector Store Files

  /// Create a vector store file by attaching a [File](https://platform.openai.com/docs/api-reference/files) to a vector store.
  ///
  /// - Parameter vectorStoreID: The ID of the vector store for which to create a File.
  /// - Parameter parameters: The paramaters needed to create a vector store File.
  /// - Returns: A [VectorStoreFileObject](https://platform.openai.com/docs/api-reference/vector-stores-files/file-object)
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Vectore store file documentation.](https://platform.openai.com/docs/api-reference/vector-stores-files/createFile).
  func createVectorStoreFile(
    vectorStoreID: String,
    parameters: VectorStoreFileParameter)
    async throws -> VectorStoreFileObject

  /// Returns a list of vector store files.
  ///
  /// - Parameter vectorStoreID: The ID of the vector store that the files belong to.
  /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.
  /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
  /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
  /// - Parameter filter: Filter by file status. One of `in_progress`, `completed`, `failed`, `cancelled`.
  /// - Returns: A list of [VectorStoreFileObject](https://platform.openai.com/docs/api-reference/vector-stores-files/file-object) objects.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Vector stores API documentation](https://platform.openai.com/docs/api-reference/vector-stores-files/listFiles).
  func listVectorStoreFiles(
    vectorStoreID: String,
    limit: Int?,
    order: String?,
    after: String?,
    before: String?,
    filter: String?)
    async throws -> OpenAIResponse<VectorStoreFileObject>

  /// Retrieves a vector store file.
  ///
  /// - Parameter vectorStoreID: The ID of the vector store that the file belongs to.
  /// - Parameter fileID: The ID of the file being retrieved.
  /// - Returns: A [vector store file object](https://platform.openai.com/docs/api-reference/vector-stores-files/file-object)
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Vector stores API documentation](https://platform.openai.com/docs/api-reference/vector-stores-files/getFile).
  func retrieveVectorStoreFile(
    vectorStoreID: String,
    fileID: String)
    async throws -> VectorStoreFileObject

  /// Delete a vector store file. This will remove the file from the vector store but the file itself will not be deleted. To delete the file, use the [delete file](https://platform.openai.com/docs/api-reference/files/delete) endpoint.
  ///
  /// - Parameter vectorStoreID: The ID of the vector store that the file belongs to.
  /// - Parameter fileID: The ID of the file to delete.
  /// - Returns: A deletion status.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Vector stores API documentation](https://platform.openai.com/docs/api-reference/vector-stores-files/deleteFile).
  func deleteVectorStoreFile(
    vectorStoreID: String,
    fileID: String)
    async throws -> DeletionStatus

  // MARK: Vector Store File Batch

  /// Create a vector store file batch.
  ///
  /// - Parameter vectorStoreID: The ID of the vector store for which to create a File Batch.
  /// - Parameter parameters: The paramaters needed to create a vector store File Batch.
  /// - Returns: A [VectorStoreFileBatchObject](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/batch-object)
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's Vectore store file batch documentation.](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/createBatch).
  func createVectorStoreFileBatch(
    vectorStoreID: String,
    parameters: VectorStoreFileBatchParameter)
    async throws -> VectorStoreFileBatchObject

  /// Retrieves a vector store file batch.
  ///
  /// - Parameter vectorStoreID: The ID of the vector store that the file batch belongs to.
  /// - Parameter batchID: The ID of the file batch being retrieved.
  /// - Returns: A [vector store file batch object](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/batch-object)
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Vector stores file batch API documentation](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/getBatch).
  func retrieveVectorStoreFileBatch(
    vectorStoreID: String,
    batchID: String)
    async throws -> VectorStoreFileBatchObject

  /// Cancel a vector store file batch. This attempts to cancel the processing of files in this batch as soon as possible.
  ///
  /// - Parameter vectorStoreID: The ID of the vector store that the file batch belongs to.
  /// - Parameter batchID: The ID of the file batch to cancel.
  /// - Returns: The modified [vector store file batch object.](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/batch-object)
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Vector stores file batch API documentation](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/cancelBatch).
  func cancelVectorStoreFileBatch(
    vectorStoreID: String,
    batchID: String)
    async throws -> VectorStoreFileBatchObject

  /// Returns a list of vector store files in a batch.
  ///
  /// - Parameter vectorStoreID: The ID of the vector store that the files belong to.
  /// - Parameter batchID: The ID of the file batch that the files belong to.
  /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
  /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.
  /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
  /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
  /// - Parameter filter: Filter by file status. One of `in_progress`, `completed`, `failed`, `cancelled`.
  /// - Returns: A list of [VectorStoreFileObject](https://platform.openai.com/docs/api-reference/vector-stores-files/file-object) objects in a batch.
  /// - Throws: An error if the request fails.
  ///
  /// For more information, refer to [OpenAI's  Vector stores file batch API documentation](https://platform.openai.com/docs/api-reference/vector-stores-file-batches/listBatchFiles).
  func listVectorStoreFilesInABatch(
    vectorStoreID: String,
    batchID: String,
    limit: Int?,
    order: String?,
    after: String?,
    before: String?,
    filter: String?)
    async throws -> OpenAIResponse<VectorStoreFileObject>

  // MARK: Response

  /// Returns a [Response](https://platform.openai.com/docs/api-reference/responses/object) object.
  ///
  /// - Parameter ModelResponseParameter: The response model parameters
  func responseCreate(
    _ parameters: ModelResponseParameter)
    async throws -> ResponseModel

  /// [The Response object matching the specified ID.](https://platform.openai.com/docs/api-reference/responses/get)
  ///
  /// - Parameter id: The ID of the ResponseModel
  func responseModel(
    id: String)
    async throws -> ResponseModel

  /// Returns a streaming [Response](https://platform.openai.com/docs/api-reference/responses/object) object.
  ///
  /// - Parameter parameters: The response model parameters with stream set to true
  /// - Returns: An AsyncThrowingStream of ResponseStreamEvent objects
  func responseCreateStream(
    _ parameters: ModelResponseParameter)
    async throws -> AsyncThrowingStream<ResponseStreamEvent, Error>
}

extension OpenAIService {
  /// Asynchronously fetches the contents of a file that has been uploaded to OpenAI's service.
  ///
  /// This method is used exclusively for retrieving the content of uploaded files.
  ///
  /// - Parameter request: The `URLRequest` describing the API request to fetch the file.
  /// - Throws: An error if the request fails.
  /// - Returns: A dictionary array representing the file contents.
  public func fetchContentsOfFile(
    request: URLRequest)
    async throws -> [[String: Any]]
  {
    printCurlCommand(request)

    // Convert URLRequest to HTTPRequest
    let httpRequest = try HTTPRequest(from: request)

    let (data, response) = try await httpClient.data(for: httpRequest)

    guard response.statusCode == 200 else {
      var errorMessage = "status code \(response.statusCode)"
      do {
        let error = try decoder.decode(OpenAIErrorResponse.self, from: data)
        errorMessage = error.error.message ?? "NO ERROR MESSAGE PROVIDED"
      } catch {
        // If decoding fails, keep the original error message with status code
      }
      throw APIError.responseUnsuccessful(
        description: errorMessage,
        statusCode: response.statusCode)
    }
    var content: [[String: Any]] = []
    if let jsonString = String(data: data, encoding: String.Encoding.utf8) {
      let lines = jsonString.split(separator: "\n")
      for line in lines {
        #if DEBUG
        print("DEBUG Received line:\n\(line)")
        #endif
        if
          let lineData = String(line).data(using: String.Encoding.utf8),
          let jsonObject = try? JSONSerialization.jsonObject(with: lineData, options: .allowFragments) as? [String: Any]
        {
          content.append(jsonObject)
        }
      }
    }
    return content
  }

  /// Asynchronously fetches audio data.
  ///
  /// This method is used exclusively for handling audio data responses.
  ///
  /// - Parameter request: The `URLRequest` describing the API request to fetch the file.
  /// - Throws: An error if the request fails.
  /// - Returns: The audio Data
  public func fetchAudio(
    with request: URLRequest)
    async throws -> Data
  {
    printCurlCommand(request)

    // Convert URLRequest to HTTPRequest
    let httpRequest = try HTTPRequest(from: request)

    let (data, response) = try await httpClient.data(for: httpRequest)

    guard response.statusCode == 200 else {
      var errorMessage = "Status code \(response.statusCode)"
      do {
        let errorResponse = try decoder.decode(OpenAIErrorResponse.self, from: data)
        errorMessage = errorResponse.error.message ?? "NO ERROR MESSAGE PROVIDED"
      } catch {
        if let errorString = String(data: data, encoding: .utf8), !errorString.isEmpty {
          errorMessage += " - \(errorString)"
        } else {
          errorMessage += " - No error message provided"
        }
      }
      throw APIError.responseUnsuccessful(
        description: errorMessage,
        statusCode: response.statusCode)
    }
    return data
  }

  /// Asynchronously fetches a decodable data type from OpenAI's API.
  ///
  /// - Parameters:
  ///   - debugEnabled: If true the service will print events on DEBUG builds.
  ///   - type: The `Decodable` type that the response should be decoded to.
  ///   - request: The `URLRequest` describing the API request.
  /// - Throws: An error if the request fails or if decoding fails.
  /// - Returns: A value of the specified decodable type.
  public func fetch<T: Decodable>(
    debugEnabled: Bool,
    type: T.Type,
    with request: URLRequest)
    async throws -> T
  {
    if debugEnabled {
      printCurlCommand(request)
    }

    // Convert URLRequest to HTTPRequest
    let httpRequest = try HTTPRequest(from: request)

    let (data, response) = try await httpClient.data(for: httpRequest)

    if debugEnabled {
      printHTTPResponse(response)
    }

    guard response.statusCode == 200 else {
      var errorMessage = "status code \(response.statusCode)"
      do {
        let error = try decoder.decode(OpenAIErrorResponse.self, from: data)
        errorMessage = error.error.message ?? "NO ERROR MESSAGE PROVIDED"
      } catch {
        // If decoding fails, keep the original error message with status code
      }
      throw APIError.responseUnsuccessful(
        description: errorMessage,
        statusCode: response.statusCode)
    }
    #if DEBUG
    if debugEnabled {
      try print("DEBUG JSON FETCH API = \(JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
    }
    #endif
    do {
      return try decoder.decode(type, from: data)
    } catch DecodingError.keyNotFound(let key, let context) {
      let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
      let codingPath = "codingPath: \(context.codingPath)"
      let debugMessage = debug + codingPath
      #if DEBUG
      if debugEnabled {
        print(debugMessage)
      }
      #endif
      throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
    } catch {
      #if DEBUG
      if debugEnabled {
        print("\(error)")
      }
      #endif
      throw APIError.jsonDecodingFailure(description: error.localizedDescription)
    }
  }

  /// Asynchronously fetches a stream of decodable data types from OpenAI's API for chat completions.
  ///
  /// This method is primarily used for streaming chat completions.
  ///
  /// - Parameters:
  ///   - debugEnabled: If true the service will print events on DEBUG builds.
  ///   - type: The `Decodable` type that each streamed response should be decoded to.
  ///   - request: The `URLRequest` describing the API request.
  /// - Throws: An error if the request fails or if decoding fails.
  /// - Returns: An asynchronous throwing stream of the specified decodable type.
  public func fetchStream<T: Decodable>(
    debugEnabled: Bool,
    type _: T.Type,
    with request: URLRequest)
    async throws -> AsyncThrowingStream<T, Error>
  {
    if debugEnabled {
      printCurlCommand(request)
    }

    // Convert URLRequest to HTTPRequest
    let httpRequest = try HTTPRequest(from: request)

    let (byteStream, response) = try await httpClient.bytes(for: httpRequest)

    if debugEnabled {
      printHTTPResponse(response)
    }

    guard response.statusCode == 200 else {
      var errorMessage = "status code \(response.statusCode)"
      do {
        // For error responses, we need to get the raw data instead of using the stream
        // as error responses are regular JSON, not streaming data
        let (errorData, _) = try await httpClient.data(for: httpRequest)
        let error = try decoder.decode(OpenAIErrorResponse.self, from: errorData)
        errorMessage = error.error.message ?? "NO ERROR MESSAGE PROVIDED"
      } catch {
        // If decoding fails, keep the original error message with status code
      }
      throw APIError.responseUnsuccessful(
        description: errorMessage,
        statusCode: response.statusCode)
    }

    // Create a stream from the lines
    guard case .lines(let lineStream) = byteStream else {
      throw APIError.requestFailed(description: "Expected line stream but got byte stream")
    }

    return AsyncThrowingStream { continuation in
      let fetchTask = Task {
        do {
          for try await line in lineStream {
            if
              line.hasPrefix("data:"), line != "data: [DONE]",
              let data = String(line.dropFirst(5)).data(using: .utf8)
            {
              #if DEBUG
              if debugEnabled {
                try print(
                  "DEBUG JSON STREAM LINE = \(JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
              }
              #endif
              do {
                let decoded = try self.decoder.decode(T.self, from: data)
                continuation.yield(decoded)
              } catch DecodingError.keyNotFound(let key, let context) {
                let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
                let codingPath = "codingPath: \(context.codingPath)"
                let debugMessage = debug + codingPath
                #if DEBUG
                if debugEnabled {
                  print(debugMessage)
                }
                #endif
                throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
              } catch {
                #if DEBUG
                if debugEnabled {
                  debugPrint("CONTINUATION ERROR DECODING \(error.localizedDescription)")
                }
                #endif
                continuation.finish(throwing: error)
              }
            }
          }
          continuation.finish()
        } catch DecodingError.keyNotFound(let key, let context) {
          let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
          let codingPath = "codingPath: \(context.codingPath)"
          let debugMessage = debug + codingPath
          #if DEBUG
          if debugEnabled {
            print(debugMessage)
          }
          #endif
          throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
        } catch {
          #if DEBUG
          if debugEnabled {
            print("CONTINUATION ERROR DECODING \(error.localizedDescription)")
          }
          #endif
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { @Sendable _ in
        fetchTask.cancel()
      }
    }
  }

  public func fetchAssistantStreamEvents(
    with request: URLRequest,
    debugEnabled: Bool)
    async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
  {
    printCurlCommand(request)

    // Convert URLRequest to HTTPRequest
    let httpRequest = try HTTPRequest(from: request)

    let (byteStream, response) = try await httpClient.bytes(for: httpRequest)

    printHTTPResponse(response)

    guard response.statusCode == 200 else {
      var errorMessage = "status code \(response.statusCode)"
      do {
        // For error responses, we need to get the raw data instead of using the stream
        // as error responses are regular JSON, not streaming data
        let (errorData, _) = try await httpClient.data(for: httpRequest)
        let error = try decoder.decode(OpenAIErrorResponse.self, from: errorData)
        errorMessage = error.error.message ?? "NO ERROR MESSAGE PROVIDED"
      } catch {
        // If decoding fails, keep the original error message with status code
      }
      throw APIError.responseUnsuccessful(
        description: errorMessage,
        statusCode: response.statusCode)
    }

    // Create a stream from the lines
    guard case .lines(let lineStream) = byteStream else {
      throw APIError.requestFailed(description: "Expected line stream but got byte stream")
    }

    return AsyncThrowingStream { continuation in
      let streamTask = Task {
        do {
          for try await line in lineStream {
            if
              line.hasPrefix("data:"), line != "data: [DONE]",
              let data = String(line.dropFirst(5)).data(using: .utf8)
            {
              do {
                if
                  let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let object = json["object"] as? String,
                  let eventObject = AssistantStreamEventObject(rawValue: object)
                {
                  switch eventObject {
                  case .threadMessageDelta:
                    let decoded = try self.decoder.decode(MessageDeltaObject.self, from: data)
                    continuation.yield(.threadMessageDelta(decoded))
                  case .threadRunStepDelta:
                    let decoded = try self.decoder.decode(RunStepDeltaObject.self, from: data)
                    continuation.yield(.threadRunStepDelta(decoded))
                  case .threadRun:
                    // We expect a object of type "thread.run.SOME_STATE" in the data object
                    // However what we get is a `thread.run` object but we can check the status
                    // of the decoded run to determine the stream event.
                    // If we check the event line instead, this will contain the expected "event: thread.run.step.completed" for example.
                    // Therefore the need to stream this event in the following way.
                    let decoded = try self.decoder.decode(RunObject.self, from: data)
                    switch RunObject.Status(rawValue: decoded.status) {
                    case .queued:
                      continuation.yield(.threadRunQueued(decoded))
                    case .inProgress:
                      continuation.yield(.threadRunInProgress(decoded))
                    case .requiresAction:
                      continuation.yield(.threadRunRequiresAction(decoded))
                    case .cancelling:
                      continuation.yield(.threadRunCancelling(decoded))
                    case .cancelled:
                      continuation.yield(.threadRunCancelled(decoded))
                    case .failed:
                      continuation.yield(.threadRunFailed(decoded))
                    case .completed:
                      continuation.yield(.threadRunCompleted(decoded))
                    case .expired:
                      continuation.yield(.threadRunExpired(decoded))
                    default:
                      #if DEBUG
                      if debugEnabled {
                        try print(
                          "DEBUG threadRun status not found = \(JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
                      }
                      #endif
                    }
                  default:
                    #if DEBUG
                    if debugEnabled {
                      try print(
                        "DEBUG EVENT \(eventObject.rawValue) IGNORED = \(JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
                    }
                    #endif
                  }
                } else {
                  #if DEBUG
                  if debugEnabled {
                    try print(
                      "DEBUG EVENT DECODE IGNORED = \(JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
                  }
                  #endif
                }
              } catch DecodingError.keyNotFound(let key, let context) {
                #if DEBUG
                if debugEnabled {
                  try print(
                    "DEBUG Decoding Object Failed = \(JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
                }
                #endif
                let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
                let codingPath = "codingPath: \(context.codingPath)"
                let debugMessage = debug + codingPath
                #if DEBUG
                if debugEnabled {
                  print(debugMessage)
                }
                #endif
                throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
              } catch {
                #if DEBUG
                if debugEnabled {
                  debugPrint("CONTINUATION ERROR DECODING \(error.localizedDescription)")
                }
                #endif
                continuation.finish(throwing: error)
              }
            }
          }

          continuation.finish()
        } catch DecodingError.keyNotFound(let key, let context) {
          let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
          let codingPath = "codingPath: \(context.codingPath)"
          let debugMessage = debug + codingPath
          #if DEBUG
          if debugEnabled {
            print(debugMessage)
          }
          #endif
          throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
        } catch {
          #if DEBUG
          if debugEnabled {
            print("CONTINUATION ERROR DECODING \(error.localizedDescription)")
          }
          #endif
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { @Sendable _ in
        streamTask.cancel()
      }
    }
  }

  // MARK: Debug Helpers

  private func prettyPrintJSON(
    _ data: Data)
    -> String?
  {
    guard
      let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
      let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
      let prettyPrintedString = String(data: prettyData, encoding: .utf8)
    else { return nil }
    return prettyPrintedString
  }

  private func printCurlCommand(
    _ request: URLRequest)
  {
    guard let url = request.url, let httpMethod = request.httpMethod else {
      debugPrint("Invalid URL or HTTP method.")
      return
    }

    var baseCommand = "curl \(url.absoluteString)"

    // Add method if not GET
    if httpMethod != "GET" {
      baseCommand += " -X \(httpMethod)"
    }

    // Add headers if any, masking the Authorization token
    if let headers = request.allHTTPHeaderFields {
      for (header, value) in headers {
        let maskedValue = header.lowercased() == "authorization" ? maskAuthorizationToken(value) : value
        baseCommand += " \\\n-H \"\(header): \(maskedValue)\""
      }
    }

    // Add body if present
    if let httpBody = request.httpBody, let bodyString = prettyPrintJSON(httpBody) {
      // The body string is already pretty printed and should be enclosed in single quotes
      baseCommand += " \\\n-d '\(bodyString)'"
    }

    // Print the final command
    #if DEBUG
    print(baseCommand)
    #endif
  }

  private func prettyPrintJSON(
    _ data: Data)
    -> String
  {
    guard
      let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
      let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
      let prettyPrintedString = String(data: prettyData, encoding: .utf8)
    else { return "Could not print JSON - invalid format" }
    return prettyPrintedString
  }

  private func maskAuthorizationToken(_ token: String) -> String {
    if token.count > 6 {
      let prefix = String(token.prefix(3))
      let suffix = String(token.suffix(3))
      return "\(prefix)................\(suffix)"
    } else {
      return "INVALID TOKEN LENGTH"
    }
  }

  /// Print HTTP Response information for debugging
  /// - Parameter response: The HTTP response to print
  private func printHTTPResponse(_ response: HTTPResponse) {
    print("STATUS CODE: \(response.statusCode)")
    print("HEADERS: \(response.headers)")
  }
}
