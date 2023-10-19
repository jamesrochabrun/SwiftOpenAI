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
       var queryItems: [URLQueryItem]?
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
       var queryItems: [URLQueryItem]?
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
   
   func retrieveFileContentForFileWith(
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
      let request = try OpenAIAPI.model(.deleteFineTuneModel(modelID: id)).request(apiKey: apiKey, organizationID: organizationID, method: .get)
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
}
