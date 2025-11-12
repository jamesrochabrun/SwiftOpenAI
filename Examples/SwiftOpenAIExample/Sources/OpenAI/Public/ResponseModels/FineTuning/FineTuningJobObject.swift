//
//  FineTuningJobObject.swift
//
//
//  Created by James Rochabrun on 10/17/23.
//

import Foundation

// MARK: - FineTuningJobObject

/// The fine_tuning.job object represents a [fine-tuning job](https://platform.openai.com/docs/api-reference/fine-tuning/object) that has been created through the API.
public struct FineTuningJobObject: Decodable {
  public enum Status: String {
    case validatingFiles = "validating_files"
    case queued
    case running
    case succeeded
    case failed
    case cancelled
  }

  public struct HyperParameters: Decodable {
    /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset. "auto" decides the optimal number of epochs based on the size of the dataset. If setting the number manually, we support any number between 1 and 50 epochs.
    public let nEpochs: IntOrStringValue

    enum CodingKeys: String, CodingKey {
      case nEpochs = "n_epochs"
    }
  }

  /// The object identifier, which can be referenced in the API endpoints.
  public let id: String
  /// The Unix timestamp (in seconds) for when the fine-tuning job was created.
  public let createdAt: Int
  /// For fine-tuning jobs that have failed, this will contain more information on the cause of the failure.
  public let error: OpenAIErrorResponse.Error?
  /// The name of the fine-tuned model that is being created. The value will be null if the fine-tuning job is still running.
  public let fineTunedModel: String?
  /// The Unix timestamp (in seconds) for when the fine-tuning job was finished. The value will be null if the fine-tuning job is still running.
  public let finishedAt: Int?
  /// The hyperparameters used for the fine-tuning job. See the [fine-tuning guide](https://platform.openai.com/docs/guides/fine-tuning)  for more details.
  public let hyperparameters: HyperParameters
  /// The base model that is being fine-tuned.
  public let model: String
  /// The object type, which is always "fine_tuning.job".
  public let object: String
  /// The organization that owns the fine-tuning job.
  public let organizationId: String
  /// The compiled results file ID(s) for the fine-tuning job. You can retrieve the results with the [Files API](https://platform.openai.com/docs/api-reference/files/retrieve-contents).
  public let resultFiles: [String]
  /// The current status of the fine-tuning job, which can be either `validating_files`, `queued`, `running`, `succeeded`, `failed`, or `cancelled`.
  public let status: String
  /// The total number of billable tokens processed by this fine-tuning job. The value will be null if the fine-tuning job is still running.
  public let trainedTokens: Int?

  /// The file ID used for training. You can retrieve the training data with the [Files API](https://platform.openai.com/docs/api-reference/files/retrieve-contents).
  public let trainingFile: String
  /// The file ID used for validation. You can retrieve the validation results with the [Files API](https://platform.openai.com/docs/api-reference/files/retrieve-contents).
  public let validationFile: String?

  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case error
    case fineTunedModel = "fine_tuned_model"
    case finishedAt = "finished_at"
    case hyperparameters
    case model
    case object
    case organizationId = "organization_id"
    case resultFiles = "result_files"
    case status
    case trainedTokens = "trained_tokens"
    case trainingFile = "training_file"
    case validationFile = "validation_file"
  }
}

// MARK: - IntOrStringValue

public enum IntOrStringValue: Decodable {
  case int(Int)
  case string(String)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let intValue = try? container.decode(Int.self) {
      self = .int(intValue)
      return
    }
    if let stringValue = try? container.decode(String.self) {
      self = .string(stringValue)
      return
    }
    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value for IntOrStringValue")
  }
}
