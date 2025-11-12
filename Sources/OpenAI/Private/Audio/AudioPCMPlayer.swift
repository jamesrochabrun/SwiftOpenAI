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

/// # Warning
/// The order that you initialize `AudioPCMPlayer()` and `MicrophonePCMSampleVendor()` matters, unfortunately.
///
/// The voice processing audio unit on iOS has a volume bug that is not present on macOS.
/// The volume of playback depends on the initialization order of AVAudioEngine and the `kAudioUnitSubType_VoiceProcessingIO` Audio Unit.
/// We use AudioEngine for playback in this file, and the voice processing audio unit in MicrophonePCMSampleVendor.
///
/// I find the best result to be initializing `AudioPCMPlayer()` first. Otherwise, the playback volume is too quiet on iOS.
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

  public func playPCM16Audio(from base64String: String) {
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
      playerNode.scheduleBuffer(outPCMBuf, at: nil, options: [], completionHandler: { })
      playerNode.play()
    }
  }

  public func interruptPlayback() {
    logger.debug("Interrupting playback")
    playerNode.stop()
  }

  let audioEngine: AVAudioEngine

  private let inputFormat: AVAudioFormat
  private let playableFormat: AVAudioFormat
  private let playerNode: AVAudioPlayerNode

}
#endif
