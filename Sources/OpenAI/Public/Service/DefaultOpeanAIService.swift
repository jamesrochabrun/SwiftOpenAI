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
   private let apiKey: String
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
      self.apiKey = apiKey
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
}


extension DefaultOpenAIService {
   
   /// Asynchronously fetches the contents of a file that has been uploaded to OpenAI's service.
   ///
   /// This method is used exclusively for retrieving the content of uploaded files.
   ///
   /// - Parameter request: The `URLRequest` describing the API request to fetch the file.
   /// - Throws: An error if the request fails.
   /// - Returns: A dictionary array representing the file contents.
   private func fetchContentsOfFile(
      request: URLRequest)
      async throws -> [[String: Any]]
   {
      printCurlCommand(request)
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
         throw APIError.requestFailed(description: "invalid response unable to get a valid HTTPURLResponse")
      }
      printHTTPURLResponse(httpResponse)
      guard httpResponse.statusCode == 200 else {
         var errorMessage = "status code \(httpResponse.statusCode)"
         do {
            let error = try decoder.decode(OpenAIErrorResponse.self, from: data)
            errorMessage += " \(error.error.message ?? "NO ERROR MESSAGE PROVIDED")"
         } catch {
            // If decoding fails, proceed with a general error message
            errorMessage = "status code \(httpResponse.statusCode)"
         }
         throw APIError.responseUnsuccessful(description: errorMessage)
      }
      var content: [[String: Any]] = []
      if let jsonString = String(data: data, encoding: .utf8) {
         let lines = jsonString.split(separator: "\n")
         for line in lines {
            #if DEBUG
            print("DEBUG Received line:\n\(line)")
            #endif
            if let lineData = line.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: lineData, options: .allowFragments) as? [String: Any] {
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
   private func fetchAudio(
      with request: URLRequest)
      async throws -> Data
   {
      printCurlCommand(request)
      let (data, response) = try await session.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
         throw APIError.requestFailed(description: "Invalid response: unable to get a valid HTTPURLResponse")
      }
      printHTTPURLResponse(httpResponse)
      guard httpResponse.statusCode == 200 else {
         var errorMessage = "Status code \(httpResponse.statusCode)"
         do {
            let errorResponse = try decoder.decode(OpenAIErrorResponse.self, from: data)
            errorMessage += " \(errorResponse.error.message ?? "NO ERROR MESSAGE PROVIDED")"
         } catch {
            if let errorString = String(data: data, encoding: .utf8), !errorString.isEmpty {
               errorMessage += " - \(errorString)"
            } else {
               errorMessage += " - No error message provided"
            }
         }
         throw APIError.responseUnsuccessful(description: errorMessage)
      }
      return data
   }
   
   /// Asynchronously fetches a decodable data type from OpenAI's API.
   ///
   /// - Parameters:
   ///   - type: The `Decodable` type that the response should be decoded to.
   ///   - request: The `URLRequest` describing the API request.
   /// - Throws: An error if the request fails or if decoding fails.
   /// - Returns: A value of the specified decodable type.
   private func fetch<T: Decodable>(
      type: T.Type,
      with request: URLRequest)
      async throws -> T
   {
      printCurlCommand(request)
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
         throw APIError.requestFailed(description: "invalid response unable to get a valid HTTPURLResponse")
      }
      printHTTPURLResponse(httpResponse)
      guard httpResponse.statusCode == 200 else {
         var errorMessage = "status code \(httpResponse.statusCode)"
         do {
            let error = try decoder.decode(OpenAIErrorResponse.self, from: data)
            errorMessage += " \(error.error.message ?? "NO ERROR MESSAGE PROVIDED")"
         } catch {
            // If decoding fails, proceed with a general error message
            errorMessage = "status code \(httpResponse.statusCode)"
         }
         throw APIError.responseUnsuccessful(description: errorMessage)
      }
      #if DEBUG
      print("DEBUG JSON FETCH API = \(try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
      #endif
      do {
         return try decoder.decode(type, from: data)
      } catch let DecodingError.keyNotFound(key, context) {
         let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
         let codingPath = "codingPath: \(context.codingPath)"
         let debugMessage = debug + codingPath
      #if DEBUG
         print(debugMessage)
      #endif
         throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
      } catch {
      #if DEBUG
         print("\(error)")
      #endif
         throw APIError.jsonDecodingFailure(description: error.localizedDescription)
      }
   }
   
   /// Asynchronously fetches a stream of decodable data types from OpenAI's API for chat completions.
   ///
   /// This method is primarily used for streaming chat completions.
   ///
   /// - Parameters:
   ///   - type: The `Decodable` type that each streamed response should be decoded to.
   ///   - request: The `URLRequest` describing the API request.
   /// - Throws: An error if the request fails or if decoding fails.
   /// - Returns: An asynchronous throwing stream of the specified decodable type.
   private func fetchStream<T: Decodable>(
      type: T.Type,
      with request: URLRequest)
      async throws -> AsyncThrowingStream<T, Error>
   {
      printCurlCommand(request)
      
      let (data, response) = try await session.bytes(for: request)
      try Task.checkCancellation()
      guard let httpResponse = response as? HTTPURLResponse else {
         throw APIError.requestFailed(description: "invalid response unable to get a valid HTTPURLResponse")
      }
      printHTTPURLResponse(httpResponse)
      guard httpResponse.statusCode == 200 else {
         var errorMessage = "status code \(httpResponse.statusCode)"
         do {
            let data = try await data.reduce(into: Data()) { data, byte in
               data.append(byte)
            }
            let error = try decoder.decode(OpenAIErrorResponse.self, from: data)
            errorMessage += " \(error.error.message ?? "NO ERROR MESSAGE PROVIDED")"
         } catch {
            // If decoding fails, proceed with a general error message
            errorMessage = "status code \(httpResponse.statusCode)"
         }
         throw APIError.responseUnsuccessful(description: errorMessage)
      }
      return AsyncThrowingStream { continuation in
         Task {
            do {
               for try await line in data.lines {
                  try Task.checkCancellation()
                  if line.hasPrefix("data:") && line != "data: [DONE]",
                     let data = line.dropFirst(5).data(using: .utf8) {
                     #if DEBUG
                     print("DEBUG JSON STREAM LINE = \(try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])")
                     #endif
                     do {
                        let decoded = try self.decoder.decode(T.self, from: data)
                        continuation.yield(decoded)
                     } catch let DecodingError.keyNotFound(key, context) {
                        let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
                        let codingPath = "codingPath: \(context.codingPath)"
                        let debugMessage = debug + codingPath
                     #if DEBUG
                        print(debugMessage)
                     #endif
                        throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
                     } catch {
                     #if DEBUG
                        debugPrint("CONTINUATION ERROR DECODING \(error.localizedDescription)")
                     #endif
                        continuation.finish(throwing: error)
                     }
                  }
               }
               continuation.finish()
            } catch let DecodingError.keyNotFound(key, context) {
               let debug = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
               let codingPath = "codingPath: \(context.codingPath)"
               let debugMessage = debug + codingPath
               #if DEBUG
               print(debugMessage)
               #endif
               throw APIError.dataCouldNotBeReadMissingData(description: debugMessage)
            } catch {
               #if DEBUG
               print("CONTINUATION ERROR DECODING \(error.localizedDescription)")
               #endif
               continuation.finish(throwing: error)
            }
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
         let prettyPrintedString = String(data: prettyData, encoding: .utf8) else { return "Could not print JSON - invalid format" }
      return prettyPrintedString
   }
   
   private func printHTTPURLResponse(
      _ response: HTTPURLResponse,
      data: Data? = nil)
   {
   #if DEBUG
      print("\n- - - - - - - - - - INCOMING RESPONSE - - - - - - - - - -\n")
      print("URL: \(response.url?.absoluteString ?? "No URL")")
      print("Status Code: \(response.statusCode)")
      print("Headers: \(response.allHeaderFields)")
      if let mimeType = response.mimeType {
         print("MIME Type: \(mimeType)")
      }
      if let data = data, response.mimeType == "application/json" {
         print("Body: \(prettyPrintJSON(data))")
      } else if let data = data, let bodyString = String(data: data, encoding: .utf8) {
         print("Body: \(bodyString)")
      }
      print("\n- - - - - - - - - - - - - - - - - - - - - - - - - - - -\n")
   #endif
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
   
}
