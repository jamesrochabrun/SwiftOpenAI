//
//  EmbeddingParameter.swift
//
//
//  Created by James Rochabrun on 10/12/23.
//

import Foundation

/// [Creates](https://platform.openai.com/docs/api-reference/embeddings/create) an embedding vector representing the input text.
public struct EmbeddingParameter: Encodable {
  public init(
    input: String,
    model: Model = .textEmbeddingAda002,
    encodingFormat: String?,
    dimensions: Int?,
    user: String? = nil)
  {
    self.input = input
    self.model = model.rawValue
    self.encodingFormat = encodingFormat
    self.dimensions = dimensions
    self.user = user
  }

  public enum Model: String {
    case textEmbeddingAda002 = "text-embedding-ada-002"
    case textEmbedding3Large = "text-embedding-3-large"
    case textEmbedding3Small = "text-embedding-3-small"
  }

  enum CodingKeys: String, CodingKey {
    case input
    case model
    case encodingFormat = "encoding_format"
    case dimensions
    case user
  }

  /// Input text to embed, encoded as a string or array of tokens. To embed multiple inputs in a single request, pass an array of strings or array of token arrays. Each input must not exceed the max input tokens for the model (8191 tokens for text-embedding-ada-002) and cannot be an empty string. [How to Count Tokens with `tiktoken`](https://cookbook.openai.com/examples/how_to_count_tokens_with_tiktoken)
  let input: String
  /// ID of the model to use. You can use the List models API to see all of your available models, or see our [Model overview ](https://platform.openai.com/docs/models/overview) for descriptions of them.
  let model: String
  /// The format to return the embeddings in. Can be either float or [base64](https://pypi.org/project/pybase64/).
  /// Defaults to "float"
  let encodingFormat: String?
  /// The number of dimensions the resulting output embeddings should have. Only supported in text-embedding-3 and later models.
  let dimensions: Int?
  /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more.](https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids)
  let user: String?
}
