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
   
   /// Asynchronously fetches a decodable data type from OpenAI's API.
   ///
   /// - Parameters:
   ///   - type: The `Decodable` type that the response should be decoded to.
   ///   - request: The `URLRequest` describing the API request.
   /// - Throws: An error if the request fails or if decoding fails.
   /// - Returns: A value of the specified decodable type.
   func fetch<T: Decodable>(
      type: T.Type,
      with request: URLRequest)
      async throws -> T
   
   /// Asynchronously fetches a stream of decodable data types from OpenAI's API for chat completions.
   ///
   /// This method is primarily used for streaming chat completions.
   ///
   /// - Parameters:
   ///   - type: The `Decodable` type that each streamed response should be decoded to.
   ///   - request: The `URLRequest` describing the API request.
   /// - Throws: An error if the request fails or if decoding fails.
   /// - Returns: An asynchronous throwing stream of the specified decodable type.
   func fetchStream<T: Decodable>(
      type: T.Type,
      with request: URLRequest)
      async throws -> AsyncThrowingStream<T, Error>
   
   /// Asynchronously fetches the contents of a file that has been uploaded to OpenAI's service.
   ///
   /// This method is used exclusively for retrieving the content of uploaded files.
   ///
   /// - Parameter request: The `URLRequest` describing the API request to fetch the file.
   /// - Throws: An error if the request fails.
   /// - Returns: A dictionary array representing the file contents.
   func fetchContentsOfFile(
      request: URLRequest)
      async throws -> [[String: Any]]
      
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
   
   // MARK: Chat
      
   /// - Parameter parameters: Parameters for the chat completion request.
   /// - Returns: A [ChatCompletionObject](https://platform.openai.com/docs/api-reference/chat/object).
   /// - Throws: An error if the chat initiation fails.
   ///
   /// For more information, refer to [OpenAI's Audio Translation API documentation](https://platform.openai.com/docs/api-reference/chat/create).
   func startChat(
      parameters: ChatCompletionParameters)
      async throws -> ChatCompletionObject
                                                  
   /// - Parameter parameters: Parameters for the chat completion request.
   /// - Returns: A streamed sequence of [ChatCompletionChunkObject](https://platform.openai.com/docs/api-reference/chat/streaming) objects.
   /// - Throws: An error if the chat initiation fails.
   ///
   /// For more information, refer to [OpenAI's Audio Translation API documentation](https://platform.openai.com/docs/api-reference/chat/create).
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
   func retrieveFileContentForFileWith(
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
}


extension OpenAIService {
   
   public func fetchContentsOfFile(
      request: URLRequest)
      async throws -> [[String: Any]]
   {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
         throw APIError.requestFailed(description: "invalid response")
      }

      guard httpResponse.statusCode == 200 else {
         throw APIError.responseUnsuccessful(description: "status code \(httpResponse.statusCode)")
      }
      
      var content: [[String: Any]] = []
      if let jsonString = String(data: data, encoding: .utf8) {
          let lines = jsonString.split(separator: "\n")
          for line in lines {
             debugPrint("Received line:\n\(line)")
              if let lineData = line.data(using: .utf8),
                 let jsonObject = try? JSONSerialization.jsonObject(with: lineData, options: .allowFragments) as? [String: Any] {
                 content.append(jsonObject)
              }
          }
      }
      return content

   }
   
   public func fetch<T: Decodable>(
      type: T.Type,
      with request: URLRequest)
      async throws -> T
   {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
         throw APIError.requestFailed(description: "invalid response")
      }
      if let jsonString = String(data: data, encoding: .utf8) {
         debugPrint("Received data:\n\(jsonString)")
      } else {
         throw APIError.invalidData
      }
      guard httpResponse.statusCode == 200 else {
         throw APIError.responseUnsuccessful(description: "status code \(httpResponse.statusCode)")
      }
      debugPrint("\(try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
      do {
         return try decoder.decode(type, from: data)
      } catch let DecodingError.keyNotFound(key, context) {
         let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
         let codingPath = "codingPath: \(context.codingPath)"
         let debugMessage = debug + codingPath
         debugPrint(debugMessage)
         throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
     } catch {
         throw APIError.jsonDecodingFailure(description: error.localizedDescription)
      }
   }
   
   public func fetchStream<T: Decodable>(
      type: T.Type,
      with request: URLRequest)
      async throws -> AsyncThrowingStream<T, Error>
   {
      let (data, response) = try await session.bytes(for: request)
      try Task.checkCancellation()
      guard let httpResponse = response as? HTTPURLResponse else {
         throw APIError.requestFailed(description: "invalid response")
      }
      guard httpResponse.statusCode == 200 else {
         throw APIError.responseUnsuccessful(description: "status code \(httpResponse.statusCode)")
      }
      
      return AsyncThrowingStream { continuation in
         Task {
            do {
               for try await line in data.lines {
                  try Task.checkCancellation()
                  if line.hasPrefix("data:") && line != "data: [DONE]",
                     let data = line.dropFirst(5).data(using: .utf8) {
                     debugPrint("\(try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
                     decoder.keyDecodingStrategy = .convertFromSnakeCase
                     let decoded = try decoder.decode(type, from: data)
                     continuation.yield(decoded)
                  }
               }
               continuation.finish()
            } catch {
               continuation.finish(throwing: error)
            }
         }
      }
   }
}
