//
//  BatchParameter.swift
//
//
//  Created by James Rochabrun on 4/27/24.
//

import Foundation

/// [Create large batches of API requests for asynchronous processing. The Batch API returns completions within 24 hours for a 50% discount.](https://platform.openai.com/docs/api-reference/batch/create)
public struct BatchParameter: Encodable {
  /// The ID of an uploaded file that contains requests for the new batch.
  /// See [upload file](https://platform.openai.com/docs/api-reference/files/create) for how to upload a file.
  /// Your input file must be formatted as a [JSONL file](https://platform.openai.com/docs/api-reference/batch/requestInput), and must be uploaded with the purpose batch.
  let inputFileID: String
  /// The endpoint to be used for all requests in the batch. Currently only /v1/chat/completions is supported.
  let endpoint: String
  /// The time frame within which the batch should be processed. Currently only 24h is supported.
  let completionWindow: String
  /// Optional custom metadata for the batch.
  let metadata: [String: String]?

  enum CodingKeys: String, CodingKey {
    case inputFileID = "input_file_id"
    case endpoint
    case completionWindow = "completion_window"
    case metadata
  }
}
