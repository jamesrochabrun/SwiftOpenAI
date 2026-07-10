//
//  RealtimeConversationProvider.swift
//  SwiftOpenAIExample
//

import AVFoundation
import Foundation
import Observation
import SwiftOpenAI

@MainActor
@Observable
final class RealtimeConversationProvider {
  init(service: OpenAIService) {
    self.service = service
  }

  enum Phase: Equatable {
    case connecting
    case idle
    case listening
    case responding
  }

  private(set) var conversation = RealtimeConversation()
  private(set) var errorMessage: String?
  private(set) var phase = Phase.idle

  var canSendToolPrompt: Bool {
    phase == .listening
  }

  var isConnected: Bool {
    phase == .listening || phase == .responding
  }

  func start() async {
    guard phase == .idle else { return }

    phase = .connecting
    errorMessage = nil
    conversation.reset()
    hasReceivedMicrophoneBuffer = false
    turnCoordinator.reset()
    await microphoneGate.close()

    guard await Self.requestMicrophonePermission() else {
      errorMessage = "Microphone permission is required for realtime voice."
      phase = .idle
      return
    }

    do {
      let realtimeSession = try await service.realtimeSession(
        model: Self.model,
        configuration: Self.sessionConfiguration)
      session = realtimeSession

      let audioController = try await AudioController(modes: [.playback, .record])
      self.audioController = audioController
      let microphoneStream = try await audioController.micStream()

      startReceivingEvents(audioController: audioController, session: realtimeSession)
      startMicrophoneStream(microphoneStream, session: realtimeSession)
      startMicrophoneWatchdog()
    } catch {
      errorMessage = error.localizedDescription
      await tearDownResources()
      phase = .idle
    }
  }

  func stop() async {
    guard phase != .idle || session != nil || audioController != nil else { return }
    phase = .idle
    errorMessage = nil
    await tearDownResources()
  }

  func askToolPrompt() async {
    guard let session, canSendToolPrompt else { return }

    let itemID = "item_demo_\(UUID().uuidString.replacing("-", with: ""))"
    let visiblePrompt = "What is the current demo context?"
    conversation.appendUserText(visiblePrompt, itemID: itemID)
    turnCoordinator.responseDidStart()
    phase = .responding

    await session.sendMessage(OpenAIRealtimeConversationItemCreate(
      item: .init(
        id: itemID,
        role: "user",
        text: "Use the get_demo_context tool and summarize the current demo context.")))
    await session.sendMessage(OpenAIRealtimeResponseCreate())
  }

  private static let model = Model.gptRealtime21.value

  private static let sessionConfiguration = OpenAIRealtimeSessionConfiguration(
    inputAudioFormat: .pcm16,
    inputAudioTranscription: .init(model: Model.gptRealtimeWhisper.value, delay: .low, language: "en"),
    instructions: """
      You are a concise realtime voice assistant in the SwiftOpenAI demo app.
      When the user asks about the current time, device, app state, or demo context, call get_demo_context before answering.
      Keep spoken answers brief and natural.
      """,
    maxResponseOutputTokens: .int(4096),
    modalities: [.audio],
    outputAudioFormat: .pcm16,
    parallelToolCalls: true,
    reasoning: .init(effort: .low),
    tools: [.function(demoContextTool)],
    toolChoice: .auto,
    turnDetection: .init(type: .semanticVAD(eagerness: .auto, createResponse: true, interruptResponse: true)),
    voice: "marin")

  private static let demoContextTool = OpenAIRealtimeSessionConfiguration.FunctionTool(
    name: "get_demo_context",
    description: "Get current context from the SwiftOpenAI realtime demo app.",
    parameters: [
      "type": "object",
      "properties": [
        "topic": [
          "type": "string",
          "description": "The context to retrieve.",
          "enum": ["time", "device", "session"],
        ],
      ],
      "required": ["topic"],
      "additionalProperties": false,
    ])

  private let service: OpenAIService
  private var audioController: AudioController?
  private var currentAudioItemID: String?
  private var hasReceivedMicrophoneBuffer = false
  private let microphoneGate = RealtimeMicrophoneGate()
  private var micTask: Task<Void, Never>?
  private var microphoneWatchdogTask: Task<Void, Never>?
  private var playbackDrainTask: Task<Void, Never>?
  private var receiveTask: Task<Void, Never>?
  private var session: OpenAIRealtimeSession?
  private var turnCoordinator = RealtimeTurnCoordinator()

  private static func executeTool(name: String, arguments: String) -> String {
    guard name == "get_demo_context" else {
      return #"{"error":"Unknown tool"}"#
    }

    let topic = decodeTopic(from: arguments) ?? "session"
    let payload: [String: String] = [
      "topic": topic,
      "model": model,
      "current_time": ISO8601DateFormatter().string(from: .now),
      "session_state": "connected",
      "audio_transport": "URLSessionWebSocketTask",
    ]

    guard
      let data = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys]),
      let json = String(data: data, encoding: .utf8)
    else {
      return #"{"error":"Could not encode tool output"}"#
    }
    return json
  }

  private static func decodeTopic(from arguments: String) -> String? {
    guard
      let data = arguments.data(using: .utf8),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      return nil
    }
    return object["topic"] as? String
  }

  private static func responseError(from statusDetails: [String: OpenAIJSONValue]?) -> String? {
    guard let statusDetails else { return nil }
    if
      case .object(let error)? = statusDetails["error"],
      case .string(let message)? = error["message"]
    {
      return message
    }
    guard
      case .object(let nestedStatusDetails)? = statusDetails["status_details"],
      case .object(let nestedError)? = nestedStatusDetails["error"],
      case .string(let message)? = nestedError["message"]
    else {
      return nil
    }
    return message
  }

  private static func transcript(from content: [[String: OpenAIJSONValue]]?) -> String? {
    content?.compactMap { part in
      if case .string(let transcript)? = part["transcript"] {
        return transcript
      }
      if case .string(let text)? = part["text"] {
        return text
      }
      return nil
    }.joined()
  }

  private static func requestMicrophonePermission() async -> Bool {
    #if os(macOS)
    let currentPermission = await AVAudioApplication.shared.recordPermission
    if currentPermission == .granted {
      return true
    }
    return await AVAudioApplication.requestRecordPermission()
    #else
    switch AVAudioSession.sharedInstance().recordPermission {
    case .granted:
      return true

    case .denied:
      return false

    case .undetermined:
      return await withCheckedContinuation { continuation in
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
          continuation.resume(returning: granted)
        }
      }

    @unknown default:
      return false
    }
    #endif
  }

  private func startMicrophoneStream(
    _ microphoneStream: AsyncStream<AVAudioPCMBuffer>,
    session: OpenAIRealtimeSession)
  {
    let microphoneGate = microphoneGate
    micTask = Task { @RealtimeActor [weak self] in
      var hasReportedFirstBuffer = false
      for await buffer in microphoneStream {
        guard !Task.isCancelled else { return }
        if !hasReportedFirstBuffer {
          hasReportedFirstBuffer = true
          await self?.microphoneDidProduceBuffer()
        }
        guard microphoneGate.isOpen else { continue }
        guard let base64Audio = AudioUtils.base64EncodeAudioPCMBuffer(from: buffer) else { continue }
        await session.sendMessage(OpenAIRealtimeInputAudioBufferAppend(audio: base64Audio))
      }
    }
  }

  private func startMicrophoneWatchdog() {
    microphoneWatchdogTask?.cancel()
    microphoneWatchdogTask = Task { [weak self] in
      do {
        try await Task.sleep(for: .seconds(5))
      } catch {
        return
      }
      guard let self, !hasReceivedMicrophoneBuffer, phase != .idle else { return }
      errorMessage = "The microphone started but did not produce audio buffers."
      await tearDownResources()
      phase = .idle
    }
  }

  private func microphoneDidProduceBuffer() {
    guard !hasReceivedMicrophoneBuffer else { return }
    hasReceivedMicrophoneBuffer = true
    microphoneWatchdogTask?.cancel()
    microphoneWatchdogTask = nil
    updateConnectedPhase()
  }

  private func updateConnectedPhase() {
    guard session != nil else { return }
    if turnCoordinator.isResponseInProgress || turnCoordinator.isWaitingForPlayback {
      phase = .responding
    } else if turnCoordinator.isSessionReady, hasReceivedMicrophoneBuffer {
      phase = .listening
    } else {
      phase = .connecting
    }
  }

  private func startReceivingEvents(
    audioController: AudioController,
    session: OpenAIRealtimeSession)
  {
    receiveTask = Task { [weak self] in
      for await message in session.receiver {
        guard !Task.isCancelled, let self else { return }
        await handle(message, audioController: audioController, session: session)
      }

      guard !Task.isCancelled, let self, phase != .idle else { return }
      await handleUnexpectedDisconnect(message: "Realtime connection closed.")
    }
  }

  private func handle(
    _ message: OpenAIRealtimeMessage,
    audioController: AudioController,
    session: OpenAIRealtimeSession)
    async
  {
    switch message {
    case .error(let message):
      errorMessage = message ?? "Unknown Realtime error"
      _ = turnCoordinator.responseDidFinish(responseID: nil, status: "failed")
      beginPlaybackDrain(audioController: audioController)

    case .disconnected(let message):
      await handleUnexpectedDisconnect(message: message)

    case .sessionUpdated:
      errorMessage = nil
      turnCoordinator.sessionDidBecomeReady()
      await microphoneGate.open()
      updateConnectedPhase()

    case .responseCreated(let responseID):
      errorMessage = nil
      playbackDrainTask?.cancel()
      playbackDrainTask = nil
      turnCoordinator.responseDidStart(responseID: responseID)
      phase = .responding

    case .responseAudioDelta(let itemID, _, let base64Audio):
      currentAudioItemID = itemID
      await audioController.playPCM16Audio(base64String: base64Audio, itemID: itemID)

    case .responseAudioDone:
      break

    case .inputAudioBufferSpeechStarted(let itemID, _):
      conversation.beginUserTurn(itemID: itemID)
      let audioEndMS = await audioController.interruptPlayback()
      if let currentAudioItemID, let audioEndMS {
        await session.sendMessage(OpenAIRealtimeConversationItemTruncate(
          itemID: currentAudioItemID,
          audioEndMS: audioEndMS))
      }
      currentAudioItemID = nil

    case .inputAudioTranscriptionDelta(let itemID, let delta):
      conversation.appendUserTranscript(delta, itemID: itemID)

    case .inputAudioTranscriptionCompleted(let itemID, let transcript):
      conversation.finishUserTranscript(transcript, itemID: itemID)

    case .responseOutputItemAdded(let itemID, let type):
      if type == "message" {
        conversation.beginAssistantTurn(itemID: itemID, responseID: nil)
      }

    case .responseTranscriptDelta(let itemID, let responseID, let delta),
         .responseTextDelta(let itemID, let responseID, let delta):
      conversation.appendAssistantTranscript(delta, itemID: itemID, responseID: responseID)

    case .responseTranscriptDone(let itemID, let responseID, let transcript):
      conversation.finishAssistantTranscript(transcript, itemID: itemID, responseID: responseID)

    case .responseTextDone(let itemID, let responseID, let text):
      conversation.finishAssistantTranscript(text, itemID: itemID, responseID: responseID)

    case .responseOutputItemDone(let itemID, let type, let content):
      if type == "message" {
        conversation.finishAssistantItem(itemID: itemID, text: Self.transcript(from: content))
      }

    case .conversationItemCreated(let itemID, let type, let role, let previousItemID):
      conversation.registerItem(
        itemID: itemID,
        type: type,
        role: role,
        previousItemID: previousItemID)

    case .conversationItemDone(let itemID, let type, let role, let previousItemID, let content):
      conversation.registerItem(
        itemID: itemID,
        type: type,
        role: role,
        previousItemID: previousItemID)
      let transcript = Self.transcript(from: content)
      if role == "assistant" {
        conversation.finishAssistantItem(itemID: itemID, text: transcript)
      } else if role == "user", let transcript {
        conversation.finishUserTranscript(transcript, itemID: itemID)
      }

    case .responseFunctionCallArgumentsDelta, .rateLimitsUpdated:
      break

    case .responseFunctionCallArgumentsDone(let name, let arguments, let callID, _, let responseID):
      let output = Self.executeTool(name: name, arguments: arguments)
      conversation.recordToolCall(name: name, callID: callID)
      await session.sendMessage(OpenAIRealtimeFunctionCallOutput(callID: callID, output: output))
      turnCoordinator.toolOutputWasSent(responseID: responseID)

    case .responseDone(let responseID, let status, let statusDetails):
      conversation.finishResponse()
      let completion = turnCoordinator.responseDidFinish(responseID: responseID, status: status)

      if status == "failed" || status == "incomplete" {
        errorMessage = Self.responseError(from: statusDetails) ?? "Response \(status)."
      }

      if completion.shouldCreateToolContinuation {
        await sendToolContinuation(session: session)
      } else if completion.didFinishCurrentResponse {
        beginPlaybackDrain(audioController: audioController)
      }

    default:
      break
    }
  }

  private func sendToolContinuation(session: OpenAIRealtimeSession) async {
    turnCoordinator.responseDidStart()
    phase = .responding
    await session.sendMessage(OpenAIRealtimeResponseCreate())
  }

  private func beginPlaybackDrain(audioController: AudioController) {
    playbackDrainTask?.cancel()
    turnCoordinator.playbackDrainDidStart()
    phase = .responding
    playbackDrainTask = Task { [weak self] in
      await audioController.waitUntilPlaybackFinishes()
      guard !Task.isCancelled, let self else { return }
      turnCoordinator.playbackDidFinish()
      playbackDrainTask = nil
      currentAudioItemID = nil
      if turnCoordinator.canStreamMicrophone, hasReceivedMicrophoneBuffer, session != nil {
        phase = .listening
      } else if !turnCoordinator.isSessionReady, session != nil {
        phase = .connecting
      }
    }
  }

  private func handleUnexpectedDisconnect(message: String?) async {
    if let message, !message.isEmpty {
      errorMessage = message
    }
    phase = .idle
    await tearDownResources(disconnectSession: false)
  }

  private func tearDownResources(disconnectSession: Bool = true) async {
    currentAudioItemID = nil
    hasReceivedMicrophoneBuffer = false
    turnCoordinator.reset()
    await microphoneGate.close()

    micTask?.cancel()
    microphoneWatchdogTask?.cancel()
    playbackDrainTask?.cancel()
    receiveTask?.cancel()
    micTask = nil
    microphoneWatchdogTask = nil
    playbackDrainTask = nil
    receiveTask = nil

    let audioController = audioController
    let session = session
    self.audioController = nil
    self.session = nil

    if let audioController {
      await audioController.stop()
    }
    if disconnectSession, let session {
      await session.disconnect()
    }
  }
}
