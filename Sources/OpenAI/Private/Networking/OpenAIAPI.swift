//
//  File.swift
//  
//
//  Created by James Rochabrun on 10/10/23.
//

import Foundation

// MARK: OpenAIAPI

enum OpenAIAPI {
   
   case audio(AudioCategory) // https://platform.openai.com/docs/api-reference/audio
   case chat /// https://platform.openai.com/docs/api-reference/chat
   case embeddings // https://platform.openai.com/docs/api-reference/embeddings
   case fineTuning(FineTuningCategory) // https://platform.openai.com/docs/api-reference/fine-tuning
   case file(FileCategory) // https://platform.openai.com/docs/api-reference/files
   case images(ImageCategory) // https://platform.openai.com/docs/api-reference/images
   case model(ModelCategory) // https://platform.openai.com/docs/api-reference/models
   case moderations // https://platform.openai.com/docs/api-reference/moderations
   
   enum AudioCategory: String {
      case transcriptions
      case translations
   }
   
   enum FineTuningCategory {
      case create
      case list
      case retrieve(jobID: String)
      case cancel(jobID: String)
      case events(jobID: String)
   }
   
   enum FileCategory {
      case list
      case upload
      case delete(fileID: String)
      case retrieve(fileID: String)
      case retrieveFileContent(fileID: String)
   }
   
   enum ImageCategory: String {
      case generations
      case edits
      case variations
   }
   
   enum ModelCategory {
      case list
      case retrieve(modelID: String)
      case deleteFineTuneModel(modelID: String)
   }
}

// MARK: OpenAIAPI+Endpoint

extension OpenAIAPI: Endpoint {
   
   var base: String {
      "https://api.openai.com"
   }
   
   var path: String {
      switch self {
      case .model(let category):
         switch category {
         case .list: return "/v1/models"
         case .retrieve(let modelID), .deleteFineTuneModel(let modelID): return "/v1/models/\(modelID)"
         }
      case .moderations: return "/v1/moderations"
      case .images(let category): return "/v1/images/\(category.rawValue)"
      case .chat: return "/v1/chat/completions"
      case .audio(let category): return "/v1/audio/\(category.rawValue)"
      case .embeddings: return "/v1/embeddings"
      case .fineTuning(let category):
         switch category {
         case .create, .list: return "/v1/fine_tuning/jobs"
         case .retrieve(let jobID): return "/v1/fine_tuning/jobs/\(jobID)"
         case .cancel(let jobID): return "/v1/fine_tuning/jobs/\(jobID)/cancel"
         case .events(let jobID): return "/v1/fine_tuning/jobs/\(jobID)/events"
         }
      case .file(let category):
         switch category {
         case .list, .upload: return "/v1/files"
         case .delete(let fileID), .retrieve(let fileID): return "/v1/files/\(fileID)"
         case .retrieveFileContent(let fileID): return "/v1/files/\(fileID)/content"
         }
      }
   }
}

