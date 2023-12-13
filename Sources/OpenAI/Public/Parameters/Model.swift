//
//  File.swift
//  
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

public enum Model {
   
   /// Chat completion
   case gpt35Turbo
   case gpt35Turbo1106 // Most updated - Supports parallel function calls
   case gpt4
   case gpt41106Preview // Most updated - Supports parallel function calls
   case gpt35Turbo0613 // To be deprecated "2024-06-13"
   case gpt35Turbo16k0613 // To be deprecated "2024-06-13"
   
   /// Vision
   case gpt4VisionPreview // Vision
   
   /// Images
   case dalle2
   case dalle3 
   
   // custom
   case custom(String)
   
   var value: String {
      switch self {
      case .gpt35Turbo: return "gpt-3.5-turbo"
      case .gpt35Turbo1106: return "gpt-3.5-turbo-1106"
      case .gpt4: return "gpt-4"
      case .gpt41106Preview: return "gpt-4-1106-preview"
      case .gpt35Turbo0613: return "gpt-3.5-turbo-0613"
      case .gpt35Turbo16k0613: return "gpt-3.5-turbo-16k-0613"
      case .gpt4VisionPreview: return "gpt-4-vision-preview"
      case .dalle2: return "dall-e-2"
      case .dalle3: return "dall-e-3"
      case .custom(let model): return model
      }
   }
}
