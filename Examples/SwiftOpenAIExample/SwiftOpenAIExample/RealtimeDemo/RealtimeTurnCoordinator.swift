//
//  RealtimeTurnCoordinator.swift
//  SwiftOpenAIExample
//

/// Owns response and tool-continuation state independently from transport and UI concerns.
struct RealtimeTurnCoordinator {
  struct ResponseCompletion: Equatable {
    let didFinishCurrentResponse: Bool
    let shouldCreateToolContinuation: Bool
  }

  private(set) var isResponseInProgress = false
  private(set) var isWaitingForPlayback = false
  private(set) var isSessionReady = false

  /// Full-duplex capture remains open while the model speaks so server VAD can detect barge-in.
  var canStreamMicrophone: Bool {
    isSessionReady
  }

  mutating func reset() {
    currentResponseID = nil
    hasPendingToolContinuation = false
    isResponseInProgress = false
    isWaitingForPlayback = false
    isSessionReady = false
    pendingToolResponseID = nil
  }

  mutating func sessionDidBecomeReady() {
    isSessionReady = true
  }

  mutating func responseDidStart(responseID: String? = nil) {
    currentResponseID = responseID ?? currentResponseID
    isResponseInProgress = true
    isWaitingForPlayback = false
  }

  mutating func toolOutputWasSent(responseID: String?) {
    guard isResponseInProgress else { return }
    hasPendingToolContinuation = true
    pendingToolResponseID = responseID ?? currentResponseID
  }

  mutating func responseDidFinish(
    responseID: String?,
    status: String)
    -> ResponseCompletion
  {
    let didFinishCurrentResponse = isResponseInProgress
      && responseIDsMatch(currentResponseID, responseID)
    if didFinishCurrentResponse {
      currentResponseID = nil
      isResponseInProgress = false
    }

    let didFinishToolResponse = hasPendingToolContinuation
      && responseIDsMatch(pendingToolResponseID, responseID)
    let shouldCreateToolContinuation = didFinishToolResponse && status == "completed"
    if didFinishToolResponse {
      hasPendingToolContinuation = false
      pendingToolResponseID = nil
    }

    return ResponseCompletion(
      didFinishCurrentResponse: didFinishCurrentResponse,
      shouldCreateToolContinuation: shouldCreateToolContinuation)
  }

  mutating func playbackDrainDidStart() {
    isWaitingForPlayback = true
  }

  mutating func playbackDidFinish() {
    isWaitingForPlayback = false
  }

  private var currentResponseID: String?
  private var hasPendingToolContinuation = false
  private var pendingToolResponseID: String?

  private func responseIDsMatch(_ lhs: String?, _ rhs: String?) -> Bool {
    guard let lhs, let rhs else { return true }
    return lhs == rhs
  }
}
