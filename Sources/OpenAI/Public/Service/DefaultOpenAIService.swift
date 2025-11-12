//
//  DefaultOpenAIService.swift
//
//
//  Created by James Rochabrun on 10/17/23.
//

import Foundation

struct DefaultOpenAIService: OpenAIService {
  init(
    apiKey: String,
    organizationID: String? = nil,
    baseURL: String? = nil,
    proxyPath: String? = nil,
    overrideVersion: String? = nil,
    extraHeaders: [String: String]? = nil,
    httpClient: HTTPClient,
    decoder: JSONDecoder = .init(),
    debugEnabled: Bool)
  {
    self.httpClient = httpClient
    self.decoder = decoder
    self.apiKey = .bearer(apiKey)
    self.organizationID = organizationID
    self.extraHeaders = extraHeaders
    openAIEnvironment = OpenAIEnvironment(
      baseURL: baseURL ?? "https://api.openai.com",
      proxyPath: proxyPath,
      version: overrideVersion ?? "v1")
    self.debugEnabled = debugEnabled
  }

  let httpClient: HTTPClient
  let decoder: JSONDecoder
  let openAIEnvironment: OpenAIEnvironment

  // MARK: Audio

  func createTranscription(
    parameters: AudioTranscriptionParameters)
    async throws -> AudioObject
  {
    let request = try OpenAIAPI.audio(.transcriptions).multiPartRequest(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters)
    return try await fetch(debugEnabled: debugEnabled, type: AudioObject.self, with: request)
  }

  func createTranslation(
    parameters: AudioTranslationParameters)
    async throws -> AudioObject
  {
    let request = try OpenAIAPI.audio(.translations).multiPartRequest(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters)
    return try await fetch(debugEnabled: debugEnabled, type: AudioObject.self, with: request)
  }

  func createSpeech(
    parameters: AudioSpeechParameters)
    async throws -> AudioSpeechObject
  {
    let request = try OpenAIAPI.audio(.speech).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    let data = try await fetchAudio(with: request)
    return AudioSpeechObject(output: data)
  }

  #if canImport(AVFoundation)
  func realtimeSession(
    model: String,
    configuration: OpenAIRealtimeSessionConfiguration)
    async throws -> OpenAIRealtimeSession
  {
    // Build the WebSocket URL
    let baseURL = openAIEnvironment.baseURL.replacingOccurrences(of: "https://", with: "wss://")
    let version = openAIEnvironment.version ?? "v1"
    let path = openAIEnvironment.proxyPath.map { "\($0)/\(version)" } ?? version
    let urlString = "\(baseURL)/\(path)/realtime?model=\(model)"

    guard let url = URL(string: urlString) else {
      throw APIError.requestFailed(description: "Invalid realtime session URL")
    }

    // Create the WebSocket request with auth headers
    var request = URLRequest(url: url)
    request.setValue(apiKey.value, forHTTPHeaderField: apiKey.headerField)
    request.setValue("realtime=v1", forHTTPHeaderField: "openai-beta")

    if let organizationID {
      request.setValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
    }

    // Add any extra headers
    extraHeaders?.forEach { key, value in
      request.setValue(value, forHTTPHeaderField: key)
    }

    // Create the WebSocket task
    let webSocketTask = URLSession.shared.webSocketTask(with: request)

    // Return the realtime session
    return OpenAIRealtimeSession(
      webSocketTask: webSocketTask,
      sessionConfiguration: configuration)
  }
  #endif

  // MARK: Chat

  func startChat(
    parameters: ChatCompletionParameters)
    async throws -> ChatCompletionObject
  {
    var chatParameters = parameters
    chatParameters.stream = false
    let request = try OpenAIAPI.chat.request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: chatParameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ChatCompletionObject.self, with: request)
  }

  func startStreamedChat(
    parameters: ChatCompletionParameters)
    async throws -> AsyncThrowingStream<ChatCompletionChunkObject, Error>
  {
    var chatParameters = parameters
    chatParameters.stream = true
    let request = try OpenAIAPI.chat.request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: chatParameters,
      extraHeaders: extraHeaders)
    return try await fetchStream(debugEnabled: debugEnabled, type: ChatCompletionChunkObject.self, with: request)
  }

  // MARK: Embeddings

  func createEmbeddings(
    parameters: EmbeddingParameter)
    async throws -> OpenAIResponse<EmbeddingObject>
  {
    let request = try OpenAIAPI.embeddings.request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<EmbeddingObject>.self, with: request)
  }

  // MARK: Fine-tuning

  func createFineTuningJob(
    parameters: FineTuningJobParameters)
    async throws -> FineTuningJobObject
  {
    let request = try OpenAIAPI.fineTuning(.create).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: FineTuningJobObject.self, with: request)
  }

  func listFineTuningJobs(
    after lastJobID: String? = nil,
    limit: Int? = nil)
    async throws -> OpenAIResponse<FineTuningJobObject>
  {
    var queryItems = [URLQueryItem]()
    if let lastJobID, let limit {
      queryItems = [.init(name: "after", value: lastJobID), .init(name: "limit", value: "\(limit)")]
    } else if let lastJobID {
      queryItems = [.init(name: "after", value: lastJobID)]
    } else if let limit {
      queryItems = [.init(name: "limit", value: "\(limit)")]
    }

    let request = try OpenAIAPI.fineTuning(.list).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<FineTuningJobObject>.self, with: request)
  }

  func retrieveFineTuningJob(
    id: String)
    async throws -> FineTuningJobObject
  {
    let request = try OpenAIAPI.fineTuning(.retrieve(jobID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: FineTuningJobObject.self, with: request)
  }

  func cancelFineTuningJobWith(
    id: String)
    async throws -> FineTuningJobObject
  {
    let request = try OpenAIAPI.fineTuning(.cancel(jobID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: FineTuningJobObject.self, with: request)
  }

  func listFineTuningEventsForJobWith(
    id: String,
    after lastEventId: String? = nil,
    limit: Int? = nil)
    async throws -> OpenAIResponse<FineTuningJobEventObject>
  {
    var queryItems = [URLQueryItem]()
    if let lastEventId, let limit {
      queryItems = [.init(name: "after", value: lastEventId), .init(name: "limit", value: "\(limit)")]
    } else if let lastEventId {
      queryItems = [.init(name: "after", value: lastEventId)]
    } else if let limit {
      queryItems = [.init(name: "limit", value: "\(limit)")]
    }
    let request = try OpenAIAPI.fineTuning(.events(jobID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<FineTuningJobEventObject>.self, with: request)
  }

  // MARK: Files

  func listFiles()
    async throws -> OpenAIResponse<FileObject>
  {
    let request = try OpenAIAPI.file(.list).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<FileObject>.self, with: request)
  }

  func uploadFile(
    parameters: FileParameters)
    async throws -> FileObject
  {
    let request = try OpenAIAPI.file(.upload).multiPartRequest(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters)
    return try await fetch(debugEnabled: debugEnabled, type: FileObject.self, with: request)
  }

  func deleteFileWith(
    id: String)
    async throws -> DeletionStatus
  {
    let request = try OpenAIAPI.file(.delete(fileID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
  }

  func retrieveFileWith(
    id: String)
    async throws -> FileObject
  {
    let request = try OpenAIAPI.file(.retrieve(fileID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: FileObject.self, with: request)
  }

  func retrieveContentForFileWith(
    id: String)
    async throws -> [[String: Any]]
  {
    let request = try OpenAIAPI.file(.retrieveFileContent(fileID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      extraHeaders: extraHeaders)
    return try await fetchContentsOfFile(request: request)
  }

  // MARK: Images

  func legacyCreateImages(
    parameters: ImageCreateParameters)
    async throws -> OpenAIResponse<ImageObject>
  {
    let request = try OpenAIAPI.images(.generations).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<ImageObject>.self, with: request)
  }

  func legacyEditImage(
    parameters: ImageEditParameters)
    async throws -> OpenAIResponse<ImageObject>
  {
    let request = try OpenAIAPI.images(.edits).multiPartRequest(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<ImageObject>.self, with: request)
  }

  func legacyCreateImageVariations(
    parameters: ImageVariationParameters)
    async throws -> OpenAIResponse<ImageObject>
  {
    let request = try OpenAIAPI.images(.variations).multiPartRequest(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<ImageObject>.self, with: request)
  }

  func createImages(
    parameters: CreateImageParameters)
    async throws -> CreateImageResponse
  {
    let request = try OpenAIAPI.images(.generations).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: CreateImageResponse.self, with: request)
  }

  func editImage(
    parameters: CreateImageEditParameters)
    async throws -> CreateImageResponse
  {
    let request = try OpenAIAPI.images(.edits).multiPartRequest(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters)
    return try await fetch(debugEnabled: debugEnabled, type: CreateImageResponse.self, with: request)
  }

  func createImageVariations(
    parameters: CreateImageVariationParameters)
    async throws -> CreateImageResponse
  {
    let request = try OpenAIAPI.images(.variations).multiPartRequest(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters)
    return try await fetch(debugEnabled: debugEnabled, type: CreateImageResponse.self, with: request)
  }

  // MARK: Models

  func listModels()
    async throws -> OpenAIResponse<ModelObject>
  {
    let request = try OpenAIAPI.model(.list).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<ModelObject>.self, with: request)
  }

  func retrieveModelWith(
    id: String)
    async throws -> ModelObject
  {
    let request = try OpenAIAPI.model(.retrieve(modelID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ModelObject.self, with: request)
  }

  func deleteFineTuneModelWith(
    id: String)
    async throws -> DeletionStatus
  {
    let request = try OpenAIAPI.model(.deleteFineTuneModel(modelID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
  }

  // MARK: Moderations

  func createModerationFromText(
    parameters: ModerationParameter<String>)
    async throws -> ModerationObject
  {
    let request = try OpenAIAPI.moderations.request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ModerationObject.self, with: request)
  }

  func createModerationFromTexts(
    parameters: ModerationParameter<[String]>)
    async throws -> ModerationObject
  {
    let request = try OpenAIAPI.moderations.request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ModerationObject.self, with: request)
  }

  // MARK: Assistants [BETA]

  func createAssistant(
    parameters: AssistantParameters)
    async throws -> AssistantObject
  {
    let request = try OpenAIAPI.assistant(.create).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: AssistantObject.self, with: request)
  }

  func retrieveAssistant(
    id: String)
    async throws -> AssistantObject
  {
    let request = try OpenAIAPI.assistant(.retrieve(assistantID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: AssistantObject.self, with: request)
  }

  func modifyAssistant(
    id: String,
    parameters: AssistantParameters)
    async throws -> AssistantObject
  {
    let request = try OpenAIAPI.assistant(.modify(assistantID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: AssistantObject.self, with: request)
  }

  func deleteAssistant(
    id: String)
    async throws -> DeletionStatus
  {
    let request = try OpenAIAPI.assistant(.delete(assistantID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
  }

  func listAssistants(
    limit: Int? = nil,
    order: String? = nil,
    after: String? = nil,
    before: String? = nil)
    async throws -> OpenAIResponse<AssistantObject>
  {
    var queryItems = [URLQueryItem]()
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
    let request = try OpenAIAPI.assistant(.list).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<AssistantObject>.self, with: request)
  }

  // MARK: Thread [BETA]

  func createThread(
    parameters: CreateThreadParameters)
    async throws -> ThreadObject
  {
    let request = try OpenAIAPI.thread(.create).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ThreadObject.self, with: request)
  }

  func retrieveThread(id: String)
    async throws -> ThreadObject
  {
    let request = try OpenAIAPI.thread(.retrieve(threadID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ThreadObject.self, with: request)
  }

  func modifyThread(
    id: String,
    parameters: ModifyThreadParameters)
    async throws -> ThreadObject
  {
    let request = try OpenAIAPI.thread(.modify(threadID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ThreadObject.self, with: request)
  }

  func deleteThread(
    id: String)
    async throws -> DeletionStatus
  {
    let request = try OpenAIAPI.thread(.delete(threadID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
  }

  // MARK: Message [BETA]

  func createMessage(
    threadID: String,
    parameters: MessageParameter)
    async throws -> MessageObject
  {
    let request = try OpenAIAPI.message(.create(threadID: threadID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: MessageObject.self, with: request)
  }

  func retrieveMessage(
    threadID: String,
    messageID: String)
    async throws -> MessageObject
  {
    let request = try OpenAIAPI.message(.retrieve(threadID: threadID, messageID: messageID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: MessageObject.self, with: request)
  }

  func modifyMessage(
    threadID: String,
    messageID: String,
    parameters: ModifyMessageParameters)
    async throws -> MessageObject
  {
    let request = try OpenAIAPI.message(.modify(threadID: threadID, messageID: messageID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: MessageObject.self, with: request)
  }

  func deleteMessage(
    threadID: String,
    messageID: String)
    async throws -> DeletionStatus
  {
    let request = try OpenAIAPI.message(.delete(threadID: threadID, messageID: messageID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
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
    var queryItems = [URLQueryItem]()
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
    let request = try OpenAIAPI.message(.list(threadID: threadID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<MessageObject>.self, with: request)
  }

  // MARK: Run [BETA]

  func createRun(
    threadID: String,
    parameters: RunParameter)
    async throws -> RunObject
  {
    let request = try OpenAIAPI.run(.create(threadID: threadID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
  }

  func retrieveRun(
    threadID: String,
    runID: String)
    async throws -> RunObject
  {
    let request = try OpenAIAPI.run(.retrieve(threadID: threadID, runID: runID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
  }

  func modifyRun(
    threadID: String,
    runID: String,
    parameters: ModifyRunParameters)
    async throws -> RunObject
  {
    let request = try OpenAIAPI.run(.modify(threadID: threadID, runID: runID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
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
    var queryItems = [URLQueryItem]()
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
    let request = try OpenAIAPI.run(.list(threadID: threadID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<RunObject>.self, with: request)
  }

  func cancelRun(
    threadID: String,
    runID: String)
    async throws -> RunObject
  {
    let request = try OpenAIAPI.run(.cancel(threadID: threadID, runID: runID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
  }

  func submitToolOutputsToRun(
    threadID: String,
    runID: String,
    parameters: RunToolsOutputParameter)
    async throws -> RunObject
  {
    let request = try OpenAIAPI.run(.submitToolOutput(threadID: threadID, runID: runID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
  }

  func createThreadAndRun(
    parameters: CreateThreadAndRunParameter)
    async throws -> RunObject
  {
    let request = try OpenAIAPI.run(.createThreadAndRun).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: RunObject.self, with: request)
  }

  // MARK: Run Step [BETA]

  func retrieveRunstep(
    threadID: String,
    runID: String,
    stepID: String)
    async throws -> RunStepObject
  {
    let request = try OpenAIAPI.runStep(.retrieve(threadID: threadID, runID: runID, stepID: stepID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
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
    var queryItems = [URLQueryItem]()
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
    let request = try OpenAIAPI.runStep(.list(threadID: threadID, runID: runID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<RunStepObject>.self, with: request)
  }

  func createRunStream(
    threadID: String,
    parameters: RunParameter)
    async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
  {
    var runParameters = parameters
    runParameters.stream = true
    let request = try OpenAIAPI.run(.create(threadID: threadID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: runParameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetchAssistantStreamEvents(with: request, debugEnabled: debugEnabled)
  }

  func createThreadAndRunStream(
    parameters: CreateThreadAndRunParameter)
    async throws -> AsyncThrowingStream<AssistantStreamEvent, Error>
  {
    var runParameters = parameters
    runParameters.stream = true
    let request = try OpenAIAPI.run(.createThreadAndRun).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
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
    let request = try OpenAIAPI.run(.submitToolOutput(threadID: threadID, runID: runID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: runToolsOutputParameter,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetchAssistantStreamEvents(with: request, debugEnabled: debugEnabled)
  }

  // MARK: Batch

  func createBatch(
    parameters: BatchParameter)
    async throws -> BatchObject
  {
    let request = try OpenAIAPI.batch(.create).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: BatchObject.self, with: request)
  }

  func retrieveBatch(
    id: String)
    async throws -> BatchObject
  {
    let request = try OpenAIAPI.batch(.retrieve(batchID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: BatchObject.self, with: request)
  }

  func cancelBatch(
    id: String)
    async throws -> BatchObject
  {
    let request = try OpenAIAPI.batch(.cancel(batchID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: BatchObject.self, with: request)
  }

  func listBatch(
    after: String? = nil,
    limit: Int? = nil)
    async throws -> OpenAIResponse<BatchObject>
  {
    var queryItems = [URLQueryItem]()
    if let limit {
      queryItems.append(.init(name: "limit", value: "\(limit)"))
    }
    if let after {
      queryItems.append(.init(name: "after", value: after))
    }
    let request = try OpenAIAPI.batch(.list).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<BatchObject>.self, with: request)
  }

  // MARK: Vector Store

  func createVectorStore(
    parameters: VectorStoreParameter)
    async throws -> VectorStoreObject
  {
    let request = try OpenAIAPI.vectorStore(.create).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: VectorStoreObject.self, with: request)
  }

  func listVectorStores(
    limit: Int? = nil,
    order: String? = nil,
    after: String? = nil,
    before: String? = nil)
    async throws -> OpenAIResponse<VectorStoreObject>
  {
    var queryItems = [URLQueryItem]()
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
    let request = try OpenAIAPI.vectorStore(.list).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<VectorStoreObject>.self, with: request)
  }

  func retrieveVectorStore(
    id: String)
    async throws -> VectorStoreObject
  {
    let request = try OpenAIAPI.vectorStore(.retrieve(vectorStoreID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: VectorStoreObject.self, with: request)
  }

  func modifyVectorStore(
    parameters: VectorStoreParameter,
    id: String)
    async throws -> VectorStoreObject
  {
    let request = try OpenAIAPI.vectorStore(.modify(vectorStoreID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: VectorStoreObject.self, with: request)
  }

  func deleteVectorStore(
    id: String)
    async throws -> DeletionStatus
  {
    let request = try OpenAIAPI.vectorStore(.modify(vectorStoreID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
  }

  // MARK: Vector Store Files

  func createVectorStoreFile(
    vectorStoreID: String,
    parameters: VectorStoreFileParameter)
    async throws -> VectorStoreFileObject
  {
    let request = try OpenAIAPI.vectorStoreFile(.create(vectorStoreID: vectorStoreID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
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
    var queryItems = [URLQueryItem]()
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
    let request = try OpenAIAPI.vectorStoreFile(.list(vectorStoreID: vectorStoreID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<VectorStoreFileObject>.self, with: request)
  }

  func retrieveVectorStoreFile(
    vectorStoreID: String,
    fileID: String)
    async throws -> VectorStoreFileObject
  {
    let request = try OpenAIAPI.vectorStoreFile(.retrieve(vectorStoreID: vectorStoreID, fileID: fileID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileObject.self, with: request)
  }

  func deleteVectorStoreFile(
    vectorStoreID: String,
    fileID: String)
    async throws -> DeletionStatus
  {
    let request = try OpenAIAPI.vectorStoreFile(.delete(vectorStoreID: vectorStoreID, fileID: fileID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
  }

  // MARK: Vector Store File Batch

  func createVectorStoreFileBatch(
    vectorStoreID: String,
    parameters: VectorStoreFileBatchParameter)
    async throws -> VectorStoreFileBatchObject
  {
    let request = try OpenAIAPI.vectorStoreFileBatch(.create(vectorStoreID: vectorStoreID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileBatchObject.self, with: request)
  }

  func retrieveVectorStoreFileBatch(
    vectorStoreID: String,
    batchID: String)
    async throws -> VectorStoreFileBatchObject
  {
    let request = try OpenAIAPI.vectorStoreFileBatch(.retrieve(vectorStoreID: vectorStoreID, batchID: batchID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: VectorStoreFileBatchObject.self, with: request)
  }

  func cancelVectorStoreFileBatch(
    vectorStoreID: String,
    batchID: String)
    async throws -> VectorStoreFileBatchObject
  {
    let request = try OpenAIAPI.vectorStoreFileBatch(.cancel(vectorStoreID: vectorStoreID, batchID: batchID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
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
    var queryItems = [URLQueryItem]()
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
    let request = try OpenAIAPI.vectorStoreFileBatch(.list(vectorStoreID: vectorStoreID, batchID: batchID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      betaHeaderField: Self.assistantsBetaV2,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<VectorStoreFileObject>.self, with: request)
  }

  // MARK: Response

  func responseCreate(
    _ parameters: ModelResponseParameter)
    async throws -> ResponseModel
  {
    var responseParameters = parameters
    responseParameters.stream = false
    let request = try OpenAIAPI.response(.create).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: responseParameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ResponseModel.self, with: request)
  }

  func responseModel(
    id: String,
    parameters: GetResponseParameter? = nil)
    async throws -> ResponseModel
  {
    var queryItems = [URLQueryItem]()

    if let parameters {
      if let include = parameters.include {
        for item in include {
          queryItems.append(URLQueryItem(name: "include", value: item))
        }
      }
      if let includeObfuscation = parameters.includeObfuscation {
        queryItems.append(URLQueryItem(name: "include_obfuscation", value: String(includeObfuscation)))
      }
      if let startingAfter = parameters.startingAfter {
        queryItems.append(URLQueryItem(name: "starting_after", value: String(startingAfter)))
      }
      if let stream = parameters.stream {
        queryItems.append(URLQueryItem(name: "stream", value: String(stream)))
      }
    }

    let request = try OpenAIAPI.response(.get(responseID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ResponseModel.self, with: request)
  }

  func responseModelStream(
    id: String,
    parameters: GetResponseParameter? = nil)
    async throws -> AsyncThrowingStream<ResponseStreamEvent, Error>
  {
    var streamParameters = parameters ?? GetResponseParameter()
    streamParameters.stream = true

    var queryItems = [URLQueryItem]()

    if let include = streamParameters.include {
      for item in include {
        queryItems.append(URLQueryItem(name: "include", value: item))
      }
    }
    if let includeObfuscation = streamParameters.includeObfuscation {
      queryItems.append(URLQueryItem(name: "include_obfuscation", value: String(includeObfuscation)))
    }
    if let startingAfter = streamParameters.startingAfter {
      queryItems.append(URLQueryItem(name: "starting_after", value: String(startingAfter)))
    }
    if let stream = streamParameters.stream {
      queryItems.append(URLQueryItem(name: "stream", value: String(stream)))
    }

    let request = try OpenAIAPI.response(.get(responseID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      extraHeaders: extraHeaders)
    return try await fetchStream(debugEnabled: debugEnabled, type: ResponseStreamEvent.self, with: request)
  }

  func responseCreateStream(
    _ parameters: ModelResponseParameter)
    async throws -> AsyncThrowingStream<ResponseStreamEvent, Error>
  {
    var responseParameters = parameters
    responseParameters.stream = true
    let request = try OpenAIAPI.response(.create).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: responseParameters,
      extraHeaders: extraHeaders)
    return try await fetchStream(debugEnabled: debugEnabled, type: ResponseStreamEvent.self, with: request)
  }

  func responseDelete(
    id: String)
    async throws -> DeletionStatus
  {
    let request = try OpenAIAPI.response(.delete(responseID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
  }

  func responseCancel(
    id: String)
    async throws -> ResponseModel
  {
    let request = try OpenAIAPI.response(.cancel(responseID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ResponseModel.self, with: request)
  }

  func responseInputItems(
    id: String,
    parameters: GetInputItemsParameter?)
    async throws -> OpenAIResponse<InputItem>
  {
    var queryItems = [URLQueryItem]()

    if let parameters {
      if let after = parameters.after {
        queryItems.append(URLQueryItem(name: "after", value: after))
      }
      if let include = parameters.include {
        for item in include {
          queryItems.append(URLQueryItem(name: "include", value: item))
        }
      }
      if let limit = parameters.limit {
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
      }
      if let order = parameters.order {
        queryItems.append(URLQueryItem(name: "order", value: order))
      }
    }

    let request = try OpenAIAPI.response(.inputItems(responseID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<InputItem>.self, with: request)
  }

  // MARK: - Conversations

  func conversationCreate(
    parameters: CreateConversationParameter?)
    async throws -> ConversationModel
  {
    let request = try OpenAIAPI.conversantions(.create).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ConversationModel.self, with: request)
  }

  func getConversation(
    id: String)
    async throws -> ConversationModel
  {
    let request = try OpenAIAPI.conversantions(.get(conversationID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ConversationModel.self, with: request)
  }

  func updateConversation(
    id: String,
    parameters: UpdateConversationParameter)
    async throws -> ConversationModel
  {
    let request = try OpenAIAPI.conversantions(.update(conversationID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: parameters,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ConversationModel.self, with: request)
  }

  func deleteConversation(
    id: String)
    async throws -> DeletionStatus
  {
    let request = try OpenAIAPI.conversantions(.delete(conversationID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: DeletionStatus.self, with: request)
  }

  func getConversationItems(
    id: String,
    parameters: GetConversationItemsParameter?)
    async throws -> OpenAIResponse<InputItem>
  {
    var queryItems = [URLQueryItem]()
    if let parameters {
      if let after = parameters.after {
        queryItems.append(URLQueryItem(name: "after", value: after))
      }
      if let include = parameters.include {
        for item in include {
          queryItems.append(URLQueryItem(name: "include", value: item))
        }
      }
      if let limit = parameters.limit {
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
      }
      if let order = parameters.order {
        queryItems.append(URLQueryItem(name: "order", value: order))
      }
    }
    let request = try OpenAIAPI.conversantions(.items(conversationID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<InputItem>.self, with: request)
  }

  func createConversationItems(
    id: String,
    parameters: CreateConversationItemsParameter)
    async throws -> OpenAIResponse<InputItem>
  {
    var queryItems = [URLQueryItem]()
    if let include = parameters.include {
      for item in include {
        queryItems.append(URLQueryItem(name: "include", value: item))
      }
    }

    // Create a body-only parameter struct for encoding
    struct BodyParameters: Codable {
      let items: [InputItem]
    }
    let bodyParams = BodyParameters(items: parameters.items)

    let request = try OpenAIAPI.conversantions(.createItems(conversationID: id)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .post,
      params: bodyParams,
      queryItems: queryItems,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: OpenAIResponse<InputItem>.self, with: request)
  }

  func getConversationItem(
    conversationID: String,
    itemID: String,
    parameters: GetConversationItemParameter?)
    async throws -> InputItem
  {
    var queryItems = [URLQueryItem]()
    if let parameters, let include = parameters.include {
      for item in include {
        queryItems.append(URLQueryItem(name: "include", value: item))
      }
    }
    let request = try OpenAIAPI.conversantions(.item(conversationID: conversationID, itemID: itemID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .get,
      queryItems: queryItems,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: InputItem.self, with: request)
  }

  func deleteConversationItem(
    conversationID: String,
    itemID: String)
    async throws -> ConversationModel
  {
    let request = try OpenAIAPI.conversantions(.deleteItem(conversationID: conversationID, itemID: itemID)).request(
      apiKey: apiKey,
      openAIEnvironment: openAIEnvironment,
      organizationID: organizationID,
      method: .delete,
      extraHeaders: extraHeaders)
    return try await fetch(debugEnabled: debugEnabled, type: ConversationModel.self, with: request)
  }

  private static let assistantsBetaV2 = "assistants=v2"

  /// [authentication](https://platform.openai.com/docs/api-reference/authentication)
  private let apiKey: Authorization
  /// [organization](https://platform.openai.com/docs/api-reference/organization-optional)
  private let organizationID: String?
  /// Set this flag to TRUE if you need to print request events in DEBUG builds.
  private let debugEnabled: Bool
  /// Extra headers for the request.
  private let extraHeaders: [String: String]?
}
