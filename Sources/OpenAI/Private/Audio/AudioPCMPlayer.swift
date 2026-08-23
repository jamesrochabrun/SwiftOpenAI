//
//  AudioPCMPlayer.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

#if canImport(AVFoundation)
@preconcurrency import AVFoundation
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.swiftopenai", category: "Audio")

private final class AudioPlayerNodeStopper: @unchecked Sendable {
  init(playerNode: AVAudioPlayerNode) {
    self.playerNode = playerNode
  }

  func stop() async {
    await withCheckedContinuation { continuation in
      queue.async {
        self.playerNode.stop()
        continuation.resume()
      }
    }
  }

  func stopWithoutWaiting() {
    queue.async {
      self.playerNode.stop()
    }
  }

  private let playerNode: AVAudioPlayerNode
  private let queue = DispatchQueue(
    label: "com.swiftopenai.audio-player-stop",
    qos: .default)
}

// MARK: - AudioPCMPlayer

/// Playback shares its `AVAudioEngine` with microphone capture. Keeping both directions in this
/// graph lets the engine's voice-processing I/O node use playback as its echo-cancellation reference.
@RealtimeActor
final class AudioPCMPlayer {

  init(audioEngine: AVAudioEngine) async throws {
    self.audioEngine = audioEngine
    guard
      let inputFormat = AVAudioFormat(
        commonFormat: .pcmFormatInt16,
        sampleRate: 24000,
        channels: 1,
        interleaved: true)
    else {
      throw AudioPCMPlayerError.couldNotConfigureAudioEngine(
        "Could not create input format for AudioPCMPlayer")
    }

    guard
      let playableFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: 24000,
        channels: 1,
        interleaved: true)
    else {
      throw AudioPCMPlayerError.couldNotConfigureAudioEngine(
        "Could not create playback format for AudioPCMPlayer")
    }

    let node = AVAudioPlayerNode()

    audioEngine.attach(node)
    // Route through the main mixer: connecting a 24 kHz mono format straight into the output
    // node fails AUGraph initialization (-10875) on devices whose hardware format differs;
    // the mixer performs the sample-rate conversion to the hardware format.
    audioEngine.connect(node, to: audioEngine.mainMixerNode, format: playableFormat)

    playerNode = node
    playerNodeStopper = AudioPlayerNodeStopper(playerNode: node)
    self.inputFormat = inputFormat
    self.playableFormat = playableFormat
  }

  deinit {
    logger.debug("AudioPCMPlayer is being freed")
  }

  public var isPlaybackActive: Bool {
    hasActivePlayback
  }

  public func playPCM16Audio(from base64String: String, itemID: String?) {
    // `isRunning` alone does not prove the graph is alive: after a voice-processing stream
    // timeout (`AUVPAggregate`, -10877) the engine reports running while its IO thread never
    // cycles, and `AVAudioPlayerNode.play()` raises an uncatchable NSException ("player did
    // not see an IO cycle") in that state. A valid sample time on the output node is the
    // evidence that the render loop has actually produced cycles.
    guard
      audioEngine.isRunning,
      audioEngine.outputNode.lastRenderTime?.isSampleTimeValid == true
    else {
      logger.warning("Dropping assistant audio: engine is not rendering IO cycles")
      return
    }

    guard let audioData = Data(base64Encoded: base64String) else {
      logger.error("Could not decode base64 string for audio playback")
      return
    }

    var bufferList = AudioBufferList(
      mNumberBuffers: 1,
      mBuffers:
      AudioBuffer(
        mNumberChannels: 1,
        mDataByteSize: UInt32(audioData.count),
        mData: UnsafeMutableRawPointer(mutating: (audioData as NSData).bytes)))

    guard
      let inPCMBuf = AVAudioPCMBuffer(
        pcmFormat: inputFormat,
        bufferListNoCopy: &bufferList)
    else {
      logger.error("Could not create input buffer for audio playback")
      return
    }

    guard
      let outPCMBuf = AVAudioPCMBuffer(
        pcmFormat: playableFormat,
        frameCapacity: AVAudioFrameCount(UInt32(audioData.count) * 2))
    else {
      logger.error("Could not create output buffer for audio playback")
      return
    }

    guard let converter = AVAudioConverter(from: inputFormat, to: playableFormat) else {
      logger.error("Could not create audio converter needed to map from pcm16int to pcm32float")
      return
    }

    do {
      try converter.convert(to: outPCMBuf, from: inPCMBuf)
    } catch {
      logger.error("Could not map from pcm16int to pcm32float: \(error.localizedDescription)")
      return
    }

    if !hasActivePlayback || activeItemID != itemID {
      hasActivePlayback = true
      activeItemID = itemID
      playbackStartSampleTime = currentSampleTime
      scheduledFrameCount = 0
    }
    scheduledFrameCount += AVAudioFramePosition(outPCMBuf.frameLength)
    let generation = playbackGeneration
    pendingBufferCount += 1
    playerNode.scheduleBuffer(
      outPCMBuf,
      at: nil,
      options: [],
      completionCallbackType: .dataPlayedBack)
    { [weak self] _ in
      Task { @RealtimeActor [weak self] in
        self?.didFinishBuffer(generation: generation)
      }
    }
    playerNode.play()
    if playbackStartSampleTime == nil {
      playbackStartSampleTime = currentSampleTime ?? 0
    }
  }

  public func interruptPlayback() async -> Int? {
    guard hasActivePlayback else {
      await playerNodeStopper.stop()
      return nil
    }
    logger.debug("Interrupting playback")
    let playedMilliseconds = Int((Double(playedFrameCount) / playableFormat.sampleRate) * 1000)
    playbackGeneration += 1
    pendingBufferCount = 0
    resumePlaybackWaiters()
    activeItemID = nil
    hasActivePlayback = false
    playbackStartSampleTime = nil
    scheduledFrameCount = 0
    await playerNodeStopper.stop()
    return playedMilliseconds
  }

  public func stop() {
    playbackGeneration += 1
    pendingBufferCount = 0
    resumePlaybackWaiters()
    activeItemID = nil
    hasActivePlayback = false
    playbackStartSampleTime = nil
    scheduledFrameCount = 0
    playerNodeStopper.stopWithoutWaiting()
  }

  public func waitUntilPlaybackFinishes() async {
    guard pendingBufferCount > 0 else { return }
    await withCheckedContinuation { continuation in
      playbackWaiters.append(continuation)
    }
  }

  let audioEngine: AVAudioEngine

  private let inputFormat: AVAudioFormat
  private let playableFormat: AVAudioFormat
  private let playerNode: AVAudioPlayerNode
  private let playerNodeStopper: AudioPlayerNodeStopper
  private var activeItemID: String?
  private var hasActivePlayback = false
  private var playbackStartSampleTime: AVAudioFramePosition?
  private var scheduledFrameCount: AVAudioFramePosition = 0
  private var pendingBufferCount = 0
  private var playbackGeneration = 0
  private var playbackWaiters = [CheckedContinuation<Void, Never>]()

  private var currentSampleTime: AVAudioFramePosition? {
    guard
      let renderTime = playerNode.lastRenderTime,
      let playerTime = playerNode.playerTime(forNodeTime: renderTime)
    else {
      return nil
    }
    return playerTime.sampleTime
  }

  private var playedFrameCount: AVAudioFramePosition {
    guard let playbackStartSampleTime, let currentSampleTime else { return 0 }
    return min(max(0, currentSampleTime - playbackStartSampleTime), scheduledFrameCount)
  }

  private func didFinishBuffer(generation: Int) {
    guard generation == playbackGeneration, pendingBufferCount > 0 else { return }
    pendingBufferCount -= 1
    if pendingBufferCount == 0 {
      hasActivePlayback = false
      activeItemID = nil
      resumePlaybackWaiters()
    }
  }

  private func resumePlaybackWaiters() {
    let waiters = playbackWaiters
    playbackWaiters.removeAll(keepingCapacity: true)
    for waiter in waiters { waiter.resume() }
  }

}
#endif
