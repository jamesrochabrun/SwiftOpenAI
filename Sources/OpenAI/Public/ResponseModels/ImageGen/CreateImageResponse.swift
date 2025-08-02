//
//  CreateImageResponse.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 4/24/25.
//

import Foundation

/// Response from the 'Create Image' endpoint:
/// https://platform.openai.com/docs/api-reference/images/create
import Foundation

public struct CreateImageResponse: Decodable {
    public struct ImageData: Decodable, Equatable {
        /// Base64-encoded image data (only present for gpt-image-1 or if `response_format = b64_json`)
        public let b64JSON: String?

        /// The URL of the generated image (default for DALL·E 2 and 3, absent for gpt-image-1)
        public let url: String?

        /// The revised prompt used (DALL·E 3 only)
        public let revisedPrompt: String?

        enum CodingKeys: String, CodingKey {
            case b64JSON = "b64_json"
            case url
            case revisedPrompt = "revised_prompt"
        }
    }

    public struct Usage: Decodable {
        public struct InputTokensDetails: Decodable {
            public let textTokens: Int
            public let imageTokens: Int

            enum CodingKeys: String, CodingKey {
                case textTokens = "text_tokens"
                case imageTokens = "image_tokens"
            }
        }

        /// The number of input tokens (text + image)
        public let inputTokens: Int

        /// The number of output tokens (image)
        public let outputTokens: Int

        /// Total token usage
        public let totalTokens: Int

        /// Input token details (optional)
        public let inputTokensDetails: InputTokensDetails?

        enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
            case totalTokens = "total_tokens"
            case inputTokensDetails = "input_tokens_details"
        }
    }

    /// The Unix timestamp (in seconds) of when the image was created
    public let created: TimeInterval?

    /// The list of generated images
    public let data: [ImageData]?

    /// Token usage info (only for gpt-image-1)
    public let usage: Usage?

    enum CodingKeys: String, CodingKey {
        case created
        case data
        case usage
    }
}
