//
//  AudioPCMPlayer.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

#if canImport(AVFoundation)
import AVFoundation
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.swiftopenai", category: "Audio")

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
    audioEngine.connect(node, to: audioEngine.outputNode, format: playableFormat)

    playerNode = node
    self.inputFormat = inputFormat
    self.playableFormat = playableFormat
  }

  deinit {
    logger.debug("AudioPCMPlayer is being freed")
  }

  public func playPCM16Audio(from base64String: String, itemID: String?) {
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

    if audioEngine.isRunning {
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
  }

  public func interruptPlayback() -> Int? {
    guard hasActivePlayback else {
      playerNode.stop()
      return nil
    }
    logger.debug("Interrupting playback")
    let playedMilliseconds = Int((Double(playedFrameCount) / playableFormat.sampleRate) * 1000)
    playerNode.stop()
    playbackGeneration += 1
    pendingBufferCount = 0
    resumePlaybackWaiters()
    activeItemID = nil
    hasActivePlayback = false
    playbackStartSampleTime = nil
    scheduledFrameCount = 0
    return playedMilliseconds
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
