//
//  AzureOpenAIAPI.swift
//
//
//  Created by James Rochabrun on 1/23/24.
//

import Foundation

// MARK: - AzureOpenAIAPI

enum AzureOpenAIAPI {
    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/assistants-reference?tabs=python
    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/assistant
    case assistant(AssistantCategory)
    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/reference#chat-completions
    case chat(deploymentID: String)
    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/assistants-reference-messages?tabs=python
    case message(MessageCategory)
    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/assistants-reference-runs?tabs=python
    case run(RunCategory)
    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/assistants-reference-runs?tabs=python#list-run-steps
    case runStep(RunStepCategory)
    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/assistants-reference-threads?tabs=python#create-a-thread
    case thread(ThreadCategory)
    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/file-search?tabs=python#vector-stores
    case vectorStore(VectorStoreCategory)
    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/file-search?tabs=python#vector-stores
    case vectorStoreFile(VectorStoreFileCategory)

    /// OpenAI's most advanced interface for generating model responses. Supports text and image inputs, and text outputs. Create stateful interactions with the model, using the output of previous responses as input. Extend the model's capabilities with built-in tools for file search, web search, computer use, and more. Allow the model access to external systems and data using function calling.
    case response(ResponseCategory) // https://platform.openai.com/docs/api-reference/responses

    enum AssistantCategory {
        case create
        case list
        case retrieve(assistantID: String)
        case modify(assistantID: String)
        case delete(assistantID: String)
    }

    enum MessageCategory {
        case create(threadID: String)
        case retrieve(threadID: String, messageID: String)
        case modify(threadID: String, messageID: String)
        case delete(threadID: String, messageID: String)
        case list(threadID: String)
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

    enum VectorStoreCategory {
        case create
        case list
        case retrieve(vectorStoreID: String)
        case modify(vectorStoreID: String)
        case delete(vectorStoreID: String)
    }

    /// https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/file-search?tabs=python#file-search-support
    enum VectorStoreFileCategory {
        case create(vectorStoreID: String)
        case list(vectorStoreID: String)
        case retrieve(vectorStoreID: String, fileID: String)
        case delete(vectorStoreID: String, fileID: String)
    }

    enum ResponseCategory {
        case create(deploymentID: String)
        case retrieve(responseID: String)
    }
}

// MARK: Endpoint

extension AzureOpenAIAPI: Endpoint {
    func path(in _: OpenAIEnvironment) -> String {
        switch self {
        case let .chat(deploymentID): "/openai/deployments/\(deploymentID)/chat/completions"

        case let .assistant(category):
            switch category {
            case .create, .list: "/openai/assistants"
            case let .retrieve(assistantID), let .modify(assistantID), let .delete(assistantID): "/openai/assistants/\(assistantID)"
            }

        case let .message(category):
            switch category {
            case let .create(threadID), let .list(threadID): "/openai/threads/\(threadID)/messages"
            case let .retrieve(threadID, messageID), let .modify(threadID, messageID),
                 let .delete(threadID, messageID): "/openai/threads/\(threadID)/messages/\(messageID)"
            }

        case let .run(category):
            switch category {
            case let .create(threadID), let .list(threadID): "/openai/threads/\(threadID)/runs"
            case let .retrieve(threadID, runID), let .modify(threadID, runID): "/openai/threads/\(threadID)/runs/\(runID)"
            case let .cancel(threadID, runID): "/openai/threads/\(threadID)/runs/\(runID)/cancel"
            case let .submitToolOutput(threadID, runID): "/openai/threads/\(threadID)/runs/\(runID)/submit_tool_outputs"
            case .createThreadAndRun: "/openai/threads/runs"
            }

        case let .runStep(category):
            switch category {
            case let .retrieve(threadID, runID, stepID): "/openai/threads/\(threadID)/runs/\(runID)/steps/\(stepID)"
            case let .list(threadID, runID): "/openai/threads/\(threadID)/runs/\(runID)/steps"
            }

        case let .thread(category):
            switch category {
            case .create: "/openai/threads"
            case let .retrieve(threadID), let .modify(threadID), let .delete(threadID): "/openai/threads/\(threadID)"
            }

        case let .vectorStore(category):
            switch category {
            case .create, .list: "/openai/vector_stores"
            case let .retrieve(vectorStoreID), let .modify(vectorStoreID),
                 let .delete(vectorStoreID): "/openai/vector_stores/\(vectorStoreID)"
            }

        case let .vectorStoreFile(category):
            switch category {
            case let .create(vectorStoreID), let .list(vectorStoreID): "/openai/vector_stores/\(vectorStoreID)/files"
            case let .retrieve(vectorStoreID, fileID),
                 let .delete(vectorStoreID, fileID): "/openai/vector_stores/\(vectorStoreID)/files/\(fileID)"
            }

        case let .response(category):
            switch category {
            case let .create(deploymentID): "/openai/deployments/\(deploymentID)/responses"
            case let .retrieve(responseID): "/openai/responses/\(responseID)"
            }
        }
    }
}
