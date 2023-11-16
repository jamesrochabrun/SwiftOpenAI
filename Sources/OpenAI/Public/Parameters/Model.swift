//
//  File.swift
//  
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

public enum Model: String {
   
   /// Chat completion
   case gpt35Turbo = "gpt-3.5-turbo"
   case gpt35Turbo1106 = "gpt-3.5-turbo-1106" // Most updated - Supports parallel function calls
   case gpt4 = "gpt-4"
   case gpt41106Preview = "gpt-4-1106-preview"  // Most updated - Supports parallel function calls
   case gpt35Turbo0613 = "gpt-3.5-turbo-0613" // To be deprecated "2024-06-13"
   case gpt35Turbo16k0613 = "gpt-3.5-turbo-16k-0613" // To be deprecated "2024-06-13"
   
   /// Vision
   case gpt4VisionPreview = "gpt-4-vision-preview" // Vision
   
   /// Images
   case dalle2 = "dall-e-2"
   case dalle3 = "dall-e-3"
}
