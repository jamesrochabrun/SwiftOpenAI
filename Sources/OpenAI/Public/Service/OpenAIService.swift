//
//  OpenAIService.swift
//
//
//  Created by James Rochabrun on 10/17/23.
//

import Foundation

// MARK: Error

public enum APIError: Error {
   
   case requestFailed(description: String)
   case responseUnsuccessful(description: String)
   case invalidData
   case jsonDecodingFailure(description: String)
   case dataCouldNotBeReadMissingData(description: String)
   case bothDecodingStrategiesFailed
   case timeOutError
   
   public var displayDescription: String {
      switch self {
      case .requestFailed(let description): return description
      case .responseUnsuccessful(let description): return description
      case .invalidData: return "Invalid data"
      case .jsonDecodingFailure(let description): return description
      case .dataCouldNotBeReadMissingData(let description): return description
      case .bothDecodingStrategiesFailed: return "Decoding strategies failed."
      case .timeOutError: return "Time Out Error."
      }
   }
}

// MARK: Service

/// A protocol defining the required services for interacting with OpenAI's API.
///
/// The protocol outlines methods for fetching data and streaming responses,
/// as well as handling JSON decoding and networking tasks.
public protocol OpenAIService {
   
   /// The `URLSession` responsible for executing all network requests.
   ///
   /// This session is configured according to the needs of OpenAI's API,
   /// and it's used for tasks like sending and receiving data.
   var session: URLSession { get }
   /// The `JSONDecoder` instance used for decoding JSON responses.
   ///
   /// This decoder is used to parse the JSON responses returned by the API
   /// into model objects that conform to the `Decodable` protocol.
   var decoder: JSONDecoder { get }
   
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
   /// - Returns: A `FileObject.DeletionStatus` indicating the outcome of the deletion.
   /// - Throws: An error if the deletion process fails.
   /// For more details, refer to [OpenAI's File Upload API documentation](https://platform.openai.com/docs/api-reference/files/delete).
   func deleteFileWith(
      id: String)
   async throws -> FileObject.DeletionStatus
   
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
   func createImages(
      parameters: ImageCreateParameters)
   async throws -> OpenAIResponse<ImageObject>
   
   /// - Parameter parameters: Settings for the image edit request.
   /// - Returns: An `OpenAIResponse` containing a list of [ImageObject](https://platform.openai.com/docs/api-reference/images/object) instances that represent the edited images.
   /// - Throws: An error if the image editing process fails.
   ///
   /// For more information, refer to [OpenAI's Image API documentation](https://platform.openai.com/docs/api-reference/images/createEdit).
   func editImage(
      parameters: ImageEditParameters)
   async throws -> OpenAIResponse<ImageObject>
   
   /// - Parameter parameters: Settings for the image variation request.
   /// - Returns: An `OpenAIResponse` containing a list of [ImageObject](https://platform.openai.com/docs/api-reference/images/object) instances that represent the created image variations.
   /// - Throws: An error if the image variation creation process fails.
   ///
   /// For more information, refer to [OpenAI's Image API documentation](https://platform.openai.com/docs/api-reference/images/createVariation).
   func createImageVariations(
      parameters: ImageVariationParameters)
   async throws -> OpenAIResponse<ImageObject>
   
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
   /// - Returns: A `ModelObject.DeletionStatus` indicating the outcome of the deletion process.
   /// - Throws: An error if the deletion process fails.
   ///
   /// For more information, refer to [OpenAI's Models API documentation](https://platform.openai.com/docs/api-reference/models/delete).
   func deleteFineTuneModelWith(
      id: String)
   async throws -> ModelObject.DeletionStatus
   
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
   async throws -> AssistantObject.DeletionStatus
   
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
   
   
   // MARK: AssistantsFileObject [BETA]
   
   /// Create an assistant file by attaching a [File](https://platform.openai.com/docs/api-reference/files) to an [assistant](https://platform.openai.com/docs/api-reference/assistants).
   ///
   /// - Parameter parameters: The parameters needed to build an assistant file object
   /// - Parameter assistantID: The ID of the assistant for which to create a File.
   /// - Returns: A [AssistantFileObject](https://platform.openai.com/docs/api-reference/assistants/file-object)
   /// - Throws: An error if the request fails
   ///
   /// For more information, refer to [OpenAI's Assistants File API documentation](https://platform.openai.com/docs/api-reference/assistants/createAssistantFile).
   func createAssistantFile(
      assistantID: String,
      parameters: AssistantFileParamaters)
   async throws -> AssistantFileObject
   
   /// Retrieves an AssistantFile.
   ///
   /// - Parameter assistantID: The ID of the assistant who the file belongs to.
   /// - Parameter fileID: The ID of the file we're getting.
   /// - Returns: The [assistant file object](https://platform.openai.com/docs/api-reference/assistants/file-object) matching the specified ID.
   /// - Throws: An error if the request fails
   ///
   /// For more information, refer to [OpenAI's Assistants File API documentation](https://platform.openai.com/docs/api-reference/assistants/getAssistantFile).
   func retrieveAssistantFile(
      assistantID: String,
      fileID: String)
   async throws -> AssistantFileObject
   
   /// Delete an assistant file.
   ///
   /// - Parameter assistantID: The ID of the assistant who the file belongs to.
   /// - Parameter fileID: The ID of the file to delete.
   /// - Returns: Deletion status.
   /// - Throws: An error if the request fails
   ///
   /// For more information, refer to [OpenAI's Assistants File API documentation](https://platform.openai.com/docs/api-reference/assistants/deleteAssistantFile).
   func deleteAssistantFile(
      assistantID: String,
      fileID: String)
   async throws -> AssistantFileObject.DeletionStatus
   
   /// Returns a list of assistant files.
   ///
   /// - Parameter assistantID: The ID of the assistant who the file belongs to.
   /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
   /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.
   /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
   /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
   /// - Returns: A list of [assistant file](https://platform.openai.com/docs/api-reference/assistants/file-object) objects.
   /// - Throws: An error if the request fails
   ///
   /// For more information, refer to [OpenAI's Assistants File API documentation](https://platform.openai.com/docs/api-reference/assistants/listAssistantFiles).
   func listAssistantFiles(
      assistantID: String,
      limit: Int?,
      order: String?,
      after: String?,
      before: String?)
   async throws -> OpenAIResponse<AssistantFileObject>
   
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
   async throws -> ThreadObject.DeletionStatus
   
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
   
   /// Returns a list of messages for a given thread.
   ///
   /// - Parameter threadID: The ID of the [thread](https://platform.openai.com/docs/api-reference/threads) the messages belong to.
   /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
   /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order. Defaults to desc
   /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
   /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
   /// - Returns: A list of [message](https://platform.openai.com/docs/api-reference/messages) objects.
   /// - Throws: An error if the request fails
   ///
   /// For more information, refer to [OpenAI's Message API documentation](https://platform.openai.com/docs/api-reference/messages/listMessages).
   func listMessages(
      threadID: String,
      limit: Int?,
      order: String?,
      after: String?,
      before: String?)
   async throws -> OpenAIResponse<MessageObject>
   
   // MARK: Message File [BETA]
   
   /// Retrieves a message file.
   ///
   /// - Parameter threadID: The ID of the thread to which the message and File belong.
   /// - Parameter messageID: The ID of the message the file belongs to.
   /// - Parameter fileID: The ID of the file being retrieved.
   /// - Returns: The [message](https://platform.openai.com/docs/api-reference/messages/file-object) file object.
   /// - Throws: An error if the request fails
   ///
   /// For more information, refer to [OpenAI's Message File API documentation](https://platform.openai.com/docs/api-reference/messages/getMessageFile).
   func retrieveMessageFile(
      threadID: String,
      messageID: String,
      fileID: String)
   async throws -> MessageFileObject
   
   /// Returns a list of message files.
   ///
   /// - Parameter threadID: The ID of the thread that the message and files belong to.
   /// - Parameter messageID: The ID of the message that the files belongs to.
   /// - Parameter limit: A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
   /// - Parameter order: Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order. Defaults to desc
   /// - Parameter after: A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
   /// - Parameter before: A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
   /// - Returns: A list of message file objects.
   /// - Throws: An error if the request fails
   ///
   /// For more information, refer to [OpenAI's Message File API documentation](https://platform.openai.com/docs/api-reference/messages/listMessageFiles).
   func listMessageFiles(
      threadID: String,
      messageID: String,
      limit: Int?,
      order: String?,
      after: String?,
      before: String?)
   async throws -> OpenAIResponse<MessageFileObject>
   
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
}
