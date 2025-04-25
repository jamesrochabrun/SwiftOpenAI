//
//  CreateImageResponse.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 4/24/25.
//

import Foundation

/// Response from the 'Create Image' endpoint:
/// https://platform.openai.com/docs/api-reference/images/create
public struct CreateImageResponse: Decodable {
   
   /// The Unix timestamp (in seconds) of when the image was created
   public let created: TimeInterval
   
   /// The list of generated images
   public let data: [ImageData]
   
   /// Token usage information for the image generation (for gpt-image-1 only)
   public let usage: Usage?
   
   /// The structure containing image data
   public struct ImageData: Decodable, Equatable {
      
      /// Base64-encoded JSON string of the generated image
      /// Default value for gpt-image-1, and only present if response_format is set to b64_json for dall-e-2 and dall-e-3
      public let b64JSON: String?
      
      /// URL where the image can be accessed (provided when response_format is url)
      /// The URL is only valid for a short period of time (typically 1 hour)
      /// Unsupported for gpt-image-1
      public let url: String?
      
      /// For dall-e-3 only, the revised prompt that was used to generate the image
      /// This might be different from the original prompt if the model needed
      /// to make adjustments for safety or quality reasons
      public let revisedPrompt: String?
      
      enum CodingKeys: String, CodingKey {
         case b64JSON = "b64_json"
         case url
         case revisedPrompt = "revised_prompt"
      }
   }
   
   /// Token usage information for gpt-image-1
   public struct Usage: Decodable {
      
      /// The number of tokens (images and text) in the input prompt
      public let inputTokens: Int
      
      /// The number of image tokens in the output image
      public let outputTokens: Int
      
      /// The total number of tokens (images and text) used for the image generation
      public let totalTokens: Int
      
      /// The input tokens detailed information for the image generation
      public let inputTokensDetails: InputTokensDetails?
      
      /// Details about tokens used in input
      public struct InputTokensDetails: Decodable {
         
         /// Number of text tokens used
         public let textTokens: Int
         
         /// Number of image tokens used
         public let imageTokens: Int
         
         enum CodingKeys: String, CodingKey {
            case textTokens = "text_tokens"
            case imageTokens = "image_tokens"
         }
      }
      
      enum CodingKeys: String, CodingKey {
         case inputTokens = "input_tokens"
         case outputTokens = "output_tokens"
         case totalTokens = "total_tokens"
         case inputTokensDetails = "input_tokens_details"
      }
   }
   
   enum CodingKeys: String, CodingKey {
      case created
      case data
      case usage
   }
}
