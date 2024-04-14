//
//  Model.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation


/// [Models](https://platform.openai.com/docs/models)
public enum Model {
   
   /// Chat completion
   case gpt35Turbo
   case gpt35Turbo1106 // Most updated - Supports parallel function calls
   /// The latest GPT-3.5 Turbo model with higher accuracy at responding in requested formats and a fix for a bug which caused a text encoding issue for non-English language function calls. Returns a maximum of 4,096 output tokens. [Learn more](https://openai.com/blog/new-embedding-models-and-api-updates#:~:text=Other%20new%20models%20and%20lower%20pricing).
   case gpt35Turbo0125
   case gpt4 // 8,192 tokens
   case gpt41106Preview // Most updated - Supports parallel function calls 128,000 tokens
   case gpt35Turbo0613 // To be deprecated "2024-06-13"
   case gpt35Turbo16k0613 // To be deprecated "2024-06-13"
   case gpt4TurboPreview // Currently points to gpt-4-0125-preview.
   /// The latest GPT-4 model intended to reduce cases of “laziness” where the model doesn’t complete a task. Returns a maximum of 4,096 output tokens. [Learn more.](https://openai.com/blog/new-embedding-models-and-api-updates)
   case gpt40125Preview // 128,000 tokens
   /// GPT-4 Turbo with Vision model. Vision requests can now use JSON mode and function calling. gpt-4-turbo currently points to this version.
   /// 128,000 tokens
   /// Up to Dec 2023
   case gpt4Turbo20240409
   /// GPT-4 Turbo with Vision
   /// The latest GPT-4 Turbo model with vision capabilities. Vision requests can now use JSON mode and function calling. Currently points to gpt-4-turbo-2024-04-09.
   /// 128,000 tokens
   /// Up to Dec 2023
   case gpt4turbo
   
   /// Vision
   case gpt4VisionPreview // Vision
   
   /// Images
   case dalle2
   case dalle3
   
   // custom
   case custom(String)
   
   public var value: String {
      switch self {
      case .gpt35Turbo: return "gpt-3.5-turbo"
      case .gpt35Turbo1106: return "gpt-3.5-turbo-1106"
      case .gpt35Turbo0125: return "gpt-3.5-turbo-0125"
      case .gpt4: return "gpt-4"
      case .gpt41106Preview: return "gpt-4-1106-preview"
      case .gpt35Turbo0613: return "gpt-3.5-turbo-0613"
      case .gpt35Turbo16k0613: return "gpt-3.5-turbo-16k-0613"
      case .gpt4VisionPreview: return "gpt-4-vision-preview"
      case .dalle2: return "dall-e-2"
      case .dalle3: return "dall-e-3"
      case .gpt4TurboPreview: return "gpt-4-turbo-preview"
      case .gpt40125Preview: return "gpt-4-0125-preview"
      case .gpt4Turbo20240409: return "gpt-4-turbo-2024-04-09"
      case .gpt4turbo: return "gpt-4-turbo"
      case .custom(let model): return model
      }
   }
}
