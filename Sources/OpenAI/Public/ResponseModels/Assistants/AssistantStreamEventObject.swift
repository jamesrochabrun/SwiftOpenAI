//
//  AssistantStreamEventObject.swift
//
//
//  Created by James Rochabrun on 3/22/24.
//

import Foundation

/// Represents an [event](https://platform.openai.com/docs/api-reference/assistants-streaming/events) emitted when streaming a Run.
/// Each event in a server-sent events stream has an event and data property:
public enum AssistantStreamEventObject: String {
  /// Occurs when a new thread is created.
  /// - data is a [thread](https://platform.openai.com/docs/api-reference/threads/object)
  case threadCreated = "thread.created"

  /// Occurs during the life cycle of a run.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRun = "thread.run"

  /// Occurs when a new run is created.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRunCreated = "thread.run.created"

  /// Occurs when a run moves to a queued status.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRunQueued = "thread.run.queued"

  /// Occurs when a run moves to an in_progress status.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRunInProgress = "thread.run.in_progress"

  /// Occurs when a run moves to a requires_action status.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRunRequiresAction = "thread.run.requires_action"

  /// Occurs when a run is completed.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRunCompleted = "thread.run.completed"

  /// Occurs when a run fails.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRunFailed = "thread.run.failed"

  /// Occurs when a run moves to a cancelling status.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRunCancelling = "thread.run.cancelling"

  /// Occurs when a run is cancelled.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRunCancelled = "thread.run.cancelled"

  /// Occurs when a run expires.
  /// - data is a [run](https://platform.openai.com/docs/api-reference/runs/object)
  case threadRunExpired = "thread.run.expired"

  /// Occurs when a run step is created.
  /// - data is a [run step](https://platform.openai.com/docs/api-reference/runs/step-object)
  case threadRunStepCreated = "thread.run.step.created"

  /// Occurs when a run step moves to an in_progress state.
  /// - data is a [run step](https://platform.openai.com/docs/api-reference/runs/step-object)
  case threadRunStepInProgress = "thread.run.step.in_progress"

  /// Occurs when parts of a run step are being streamed.
  /// - data is a [run step delta](https://platform.openai.com/docs/api-reference/assistants-streaming/run-step-delta-object)
  case threadRunStepDelta = "thread.run.step.delta"

  /// Occurs when a run step is completed.
  /// - data is a [run step](https://platform.openai.com/docs/api-reference/runs/step-object)
  case threadRunStepCompleted = "thread.run.step.completed"

  /// Occurs when a run step fails.
  /// - data is a [run step](https://platform.openai.com/docs/api-reference/runs/step-object)
  case threadRunStepFailed = "thread.run.step.failed"

  /// Occurs when a run step is cancelled.
  /// - data is a [run step](https://platform.openai.com/docs/api-reference/runs/step-object)
  case threadRunStepCancelled = "thread.run.step.cancelled"

  /// Occurs when a run step expires.
  /// - data is a [run step](https://platform.openai.com/docs/api-reference/runs/step-object)
  case threadRunStepExpired = "thread.run.step.expired"

  /// Occurs when a message is created.
  /// - data is a [message](https://platform.openai.com/docs/api-reference/messages/object)
  case threadMessageCreated = "thread.message.created"

  /// Occurs when a message moves to an in_progress state.
  /// - data is a [message](https://platform.openai.com/docs/api-reference/messages/object)
  case threadMessageInProgress = "thread.message.in_progress"

  /// Not documented
  case threadMessage = "thread.message"

  /// Occurs when parts of a message are being streamed.
  /// - data is a [message delta](https://platform.openai.com/docs/api-reference/assistants-streaming/message-delta-object)
  case threadMessageDelta = "thread.message.delta"

  /// Occurs when a message is completed.
  /// - data is a [message](https://platform.openai.com/docs/api-reference/messages/object)
  case threadMessageCompleted = "thread.message.completed"

  /// Occurs when a message ends before it is completed.
  /// - data is a [message](https://platform.openai.com/docs/api-reference/messages/object)
  case threadMessageIncomplete = "thread.message.incomplete"

  /// Occurs when an error occurs. This can happen due to an internal server error or a timeout.
  /// - data is an error
  case error

  /// Occurs when a stream ends.
  /// - data is [DONE]
  case done
}
