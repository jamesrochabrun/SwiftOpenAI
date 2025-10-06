//
//  OpenAIAPI.swift
//
//
//  Created by James Rochabrun on 10/10/23.
//

import Foundation

// MARK: - OpenAIAPI

enum OpenAIAPI {
    case assistant(AssistantCategory) // https://platform.openai.com/docs/api-reference/assistants
    case audio(AudioCategory) // https://platform.openai.com/docs/api-reference/audio
    case chat /// https://platform.openai.com/docs/api-reference/chat
    case embeddings // https://platform.openai.com/docs/api-reference/embeddings
    case file(FileCategory) // https://platform.openai.com/docs/api-reference/files
    case fineTuning(FineTuningCategory) // https://platform.openai.com/docs/api-reference/fine-tuning
    case images(ImageCategory) // https://platform.openai.com/docs/api-reference/images
    case message(MessageCategory) // https://platform.openai.com/docs/api-reference/messages
    case model(ModelCategory) // https://platform.openai.com/docs/api-reference/models
    case moderations // https://platform.openai.com/docs/api-reference/moderations
    case run(RunCategory) // https://platform.openai.com/docs/api-reference/runs
    case runStep(RunStepCategory) // https://platform.openai.com/docs/api-reference/runs/step-object
    case thread(ThreadCategory) // https://platform.openai.com/docs/api-reference/threads
    case batch(BatchCategory) // https://platform.openai.com/docs/api-reference/batch
    case vectorStore(VectorStoreCategory) // https://platform.openai.com/docs/api-reference/vector-stores
    case vectorStoreFile(VectorStoreFileCategory) // https://platform.openai.com/docs/api-reference/vector-stores-files
    case vectorStoreFileBatch(VectorStoreFileBatch) // https://platform.openai.com/docs/api-reference/vector-stores-file-batches

    /// OpenAI's most advanced interface for generating model responses. Supports text and image inputs, and text outputs. Create stateful interactions with the model, using the output of previous responses as input. Extend the model's capabilities with built-in tools for file search, web search, computer use, and more. Allow the model access to external systems and data using function calling.
    case response(ResponseCategory) // https://platform.openai.com/docs/api-reference/responses

    /// Conversations
    /// Create and manage conversations to store and retrieve conversation state across Response API calls.
    case conversantions(ConversationCategory) // https://platform.openai.com/docs/api-reference/conversations

    enum AssistantCategory {
        case create
        case list
        case retrieve(assistantID: String)
        case modify(assistantID: String)
        case delete(assistantID: String)
    }

    enum AudioCategory: String {
        case transcriptions
        case translations
        case speech
    }

    enum FileCategory {
        case list
        case upload
        case delete(fileID: String)
        case retrieve(fileID: String)
        case retrieveFileContent(fileID: String)
    }

    enum FineTuningCategory {
        case create
        case list
        case retrieve(jobID: String)
        case cancel(jobID: String)
        case events(jobID: String)
    }

    enum ImageCategory: String {
        case generations
        case edits
        case variations
    }

    enum MessageCategory {
        case create(threadID: String)
        case retrieve(threadID: String, messageID: String)
        case modify(threadID: String, messageID: String)
        case delete(threadID: String, messageID: String)
        case list(threadID: String)
    }

    enum ModelCategory {
        case list
        case retrieve(modelID: String)
        case deleteFineTuneModel(modelID: String)
    }

    enum RunCategory {
        case create(threadID: String)
        case retrieve(threadID: String, runID: String)
        case modify(threadID: String, runID: String)
        case list(threadID: String)
        case cancel(threadID: String, runID: String)
        case submitToolOutput(threadID: String, runID: String)
        case createThreadAndRun
    }

    enum RunStepCategory {
        case retrieve(threadID: String, runID: String, stepID: String)
        case list(threadID: String, runID: String)
    }

    enum ThreadCategory {
        case create
        case retrieve(threadID: String)
        case modify(threadID: String)
        case delete(threadID: String)
    }

    enum BatchCategory {
        case create
        case retrieve(batchID: String)
        case cancel(batchID: String)
        case list
    }

    enum VectorStoreCategory {
        case create
        case list
        case retrieve(vectorStoreID: String)
        case modify(vectorStoreID: String)
        case delete(vectorStoreID: String)
    }

    enum VectorStoreFileCategory {
        case create(vectorStoreID: String)
        case list(vectorStoreID: String)
        case retrieve(vectorStoreID: String, fileID: String)
        case delete(vectorStoreID: String, fileID: String)
    }

    enum VectorStoreFileBatch {
        case create(vectorStoreID: String)
        case retrieve(vectorStoreID: String, batchID: String)
        case cancel(vectorStoreID: String, batchID: String)
        case list(vectorStoreID: String, batchID: String)
    }

    enum ResponseCategory {
        case create
        case get(responseID: String)
        case delete(responseID: String)
        case cancel(responseID: String)
        case inputItems(responseID: String)
    }

    enum ConversationCategory {
        case create
        case get(conversationID: String)
        case update(conversationID: String)
        case delete(conversationID: String)
        case items(conversationID: String)
        case createItems(conversationID: String)
        case item(conversationID: String, itemID: String)
        case deleteItem(conversationID: String, itemID: String)
    }
}

// MARK: Endpoint

extension OpenAIAPI: Endpoint {
    /// Builds the final path that includes:
    ///
    ///   - optional proxy path (e.g. "/my-proxy")
    ///   - version if non-nil (e.g. "/v1")
    ///   - then the specific endpoint path (e.g. "/assistants")
    func path(in openAIEnvironment: OpenAIEnvironment) -> String {
        // 1) Potentially prepend proxy path if `proxyPath` is non-empty
        let proxyPart =
            if let envProxyPart = openAIEnvironment.proxyPath, !envProxyPart.isEmpty {
                "/\(envProxyPart)"
            } else {
                ""
            }
        let mainPart = openAIPath(in: openAIEnvironment)

        return proxyPart + mainPart // e.g. "/my-proxy/v1/assistants"
    }

    func openAIPath(in openAIEnvironment: OpenAIEnvironment) -> String {
        let version =
            if let envOverrideVersion = openAIEnvironment.version, !envOverrideVersion.isEmpty {
                "/\(envOverrideVersion)"
            } else {
                ""
            }

        switch self {
        case let .assistant(category):
            switch category {
            case .create, .list: return "\(version)/assistants"
            case let .retrieve(assistantID), let .modify(assistantID),
                 let .delete(assistantID): return "\(version)/assistants/\(assistantID)"
            }

        case let .audio(category): return "\(version)/audio/\(category.rawValue)"

        case let .batch(category):
            switch category {
            case .create, .list: return "\(version)/batches"
            case let .retrieve(batchID): return "\(version)/batches/\(batchID)"
            case let .cancel(batchID): return "\(version)/batches/\(batchID)/cancel"
            }

        case .chat: return "\(version)/chat/completions"

        case .embeddings: return "\(version)/embeddings"

        case let .file(category):
            switch category {
            case .list, .upload: return "\(version)/files"
            case let .delete(fileID), let .retrieve(fileID): return "\(version)/files/\(fileID)"
            case let .retrieveFileContent(fileID): return "\(version)/files/\(fileID)/content"
            }

        case let .fineTuning(category):
            switch category {
            case .create, .list: return "\(version)/fine_tuning/jobs"
            case let .retrieve(jobID): return "\(version)/fine_tuning/jobs/\(jobID)"
            case let .cancel(jobID): return "\(version)/fine_tuning/jobs/\(jobID)/cancel"
            case let .events(jobID): return "\(version)/fine_tuning/jobs/\(jobID)/events"
            }

        case let .images(category): return "\(version)/images/\(category.rawValue)"

        case let .message(category):
            switch category {
            case let .create(threadID), let .list(threadID): return "\(version)/threads/\(threadID)/messages"
            case let .retrieve(threadID, messageID), let .modify(threadID, messageID),
                 let .delete(threadID, messageID): return "\(version)/threads/\(threadID)/messages/\(messageID)"
            }

        case let .model(category):
            switch category {
            case .list: return "\(version)/models"
            case let .retrieve(modelID), let .deleteFineTuneModel(modelID): return "\(version)/models/\(modelID)"
            }

        case .moderations: return "\(version)/moderations"

        case let .run(category):
            switch category {
            case let .create(threadID), let .list(threadID): return "\(version)/threads/\(threadID)/runs"
            case let .retrieve(threadID, runID),
                 let .modify(threadID, runID): return "\(version)/threads/\(threadID)/runs/\(runID)"
            case let .cancel(threadID, runID): return "\(version)/threads/\(threadID)/runs/\(runID)/cancel"
            case let .submitToolOutput(threadID, runID): return "\(version)/threads/\(threadID)/runs/\(runID)/submit_tool_outputs"
            case .createThreadAndRun: return "\(version)/threads/runs"
            }

        case let .runStep(category):
            switch category {
            case let .retrieve(threadID, runID, stepID): return "\(version)/threads/\(threadID)/runs/\(runID)/steps/\(stepID)"
            case let .list(threadID, runID): return "\(version)/threads/\(threadID)/runs/\(runID)/steps"
            }

        case let .thread(category):
            switch category {
            case .create: return "\(version)/threads"
            case let .retrieve(threadID), let .modify(threadID), let .delete(threadID): return "\(version)/threads/\(threadID)"
            }

        case let .vectorStore(category):
            switch category {
            case .create, .list: return "\(version)/vector_stores"
            case let .retrieve(vectorStoreID), let .modify(vectorStoreID),
                 let .delete(vectorStoreID): return "\(version)/vector_stores/\(vectorStoreID)"
            }

        case let .vectorStoreFile(category):
            switch category {
            case let .create(vectorStoreID), let .list(vectorStoreID): return "\(version)/vector_stores/\(vectorStoreID)/files"
            case let .retrieve(vectorStoreID, fileID),
                 let .delete(vectorStoreID, fileID): return "\(version)/vector_stores/\(vectorStoreID)/files/\(fileID)"
            }

        case let .vectorStoreFileBatch(category):
            switch category {
            case let .create(vectorStoreID): return"\(version)/vector_stores/\(vectorStoreID)/file_batches"
            case let .retrieve(vectorStoreID, batchID): return "\(version)/vector_stores/\(vectorStoreID)/file_batches/\(batchID)"
            case let .cancel(
                vectorStoreID,
                batchID
            ): return "\(version)/vector_stores/\(vectorStoreID)/file_batches/\(batchID)/cancel"
            case let .list(vectorStoreID, batchID): return "\(version)/vector_stores/\(vectorStoreID)/file_batches/\(batchID)/files"
            }

        case let .response(category):
            switch category {
            case .create: return "\(version)/responses"
            case let .get(responseID): return "\(version)/responses/\(responseID)"
            case let .delete(responseID): return "\(version)/responses/\(responseID)"
            case let .cancel(responseID): return "\(version)/responses/\(responseID)/cancel"
            case let .inputItems(responseID): return "\(version)/responses/\(responseID)/input_items"
            }

        case let .conversantions(category):
            switch category {
            case .create: return "\(version)/conversations"
            case let .get(conversationID): return "\(version)/conversations/\(conversationID)"
            case let .update(conversationID): return "\(version)/conversations/\(conversationID)"
            case let .delete(conversationID): return "\(version)/conversations/\(conversationID)"
            case let .items(conversationID): return "\(version)/conversations/\(conversationID)/items"
            case let .createItems(conversationID): return "\(version)/conversations/\(conversationID)/items"
            case let .item(conversationID, itemID): return "\(version)/conversations/\(conversationID)/items/\(itemID)"
            case let .deleteItem(conversationID, itemID): return "\(version)/conversations/\(conversationID)/items/\(itemID)"
            }
        }
    }
}
