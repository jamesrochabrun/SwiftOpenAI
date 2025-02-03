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
}

// MARK: Endpoint

extension AzureOpenAIAPI: Endpoint {
   
   func path(in env: OpenAIEnvironment) -> String {
      switch self {
      case .chat(let deploymentID): return "/openai/deployments/\(deploymentID)/chat/completions"
      case .assistant(let category):
         switch category {
         case .create, .list: return "/openai/assistants"
         case .retrieve(let assistantID), .modify(let assistantID), .delete(let assistantID): return "/openai/assistants/\(assistantID)"
         }
      case .message(let category):
         switch category {
         case .create(let threadID), .list(let threadID): return "/openai/threads/\(threadID)/messages"
         case .retrieve(let threadID, let messageID), .modify(let threadID, let messageID), .delete(let threadID, let messageID): return "/openai/threads/\(threadID)/messages/\(messageID)"
         }
      case .run(let category):
         switch category {
         case .create(let threadID), .list(let threadID): return "/openai/threads/\(threadID)/runs"
         case .retrieve(let threadID, let runID), .modify(let threadID, let runID): return "/openai/threads/\(threadID)/runs/\(runID)"
         case .cancel(let threadID, let runID): return "/openai/threads/\(threadID)/runs/\(runID)/cancel"
         case .submitToolOutput(let threadID, let runID): return "/openai/threads/\(threadID)/runs/\(runID)/submit_tool_outputs"
         case .createThreadAndRun: return "/openai/threads/runs"
         }
      case .runStep(let category):
         switch category {
         case .retrieve(let threadID, let runID, let stepID): return "/openai/threads/\(threadID)/runs/\(runID)/steps/\(stepID)"
         case .list(let threadID, let runID): return "/openai/threads/\(threadID)/runs/\(runID)/steps"
         }
      case .thread(let category):
         switch category {
         case .create: return "/openai/threads"
         case .retrieve(let threadID), .modify(let threadID), .delete(let threadID): return "/openai/threads/\(threadID)"
         }
      case .vectorStore(let category):
         switch category {
         case .create, .list: return "/openai/vector_stores"
         case .retrieve(let vectorStoreID), .modify(let vectorStoreID), .delete(let vectorStoreID): return "/openai/vector_stores/\(vectorStoreID)"
         }
      case .vectorStoreFile(let category):
         switch category {
         case .create(let vectorStoreID), .list(let vectorStoreID): return "/openai/vector_stores/\(vectorStoreID)/files"
         case .retrieve(let vectorStoreID, let fileID), .delete(let vectorStoreID, let fileID): return "/openai/vector_stores/\(vectorStoreID)/files/\(fileID)"
         }
      }
   }
}
