//
//  RunStepDeltaObject.swift
//
//
//  Created by James Rochabrun on 3/17/24.
//

import Foundation

/// Represents a [run step delta](https://platform.openai.com/docs/api-reference/assistants-streaming/run-step-delta-object) i.e. any changed fields on a run step during streaming.
public struct RunStepDeltaObject: Delta {
  /// The identifier of the run step, which can be referenced in API endpoints.
  public let id: String
  /// The object type, which is always thread.run.step.delta.
  public let object: String
  /// The delta containing the fields that have changed on the run step.
  public let delta: Delta

  public struct Delta: Decodable {
    /// The details of the run step.
    public let stepDetails: RunStepDetails

    private enum CodingKeys: String, CodingKey {
      case stepDetails = "step_details"
    }
  }
}
