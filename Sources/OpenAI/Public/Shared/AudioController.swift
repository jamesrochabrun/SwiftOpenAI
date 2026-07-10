//
//  AudioController.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

#if canImport(AVFoundation)
import AVFoundation
import OSLog

private let logger = Logger(subsystem: "com.swiftopenai", category: "Audio")

// MARK: - AudioController

/// Use this class to control the streaming of mic data and playback of PCM16 data.
/// When recording and playback are enabled together, both directions use the same
/// `AVAudioEngine` voice-processing graph so playback is available to acoustic echo cancellation.
///
/// ## Implementor's note
/// We use AVAudioEngine for full-duplex capture and playback. A record-only controller may use
/// AudioToolbox when no headphones are attached because it has no playback reference to share.
/// The following arrangement provides for the best user experience:
///
///     +----------------------+---------------+------------------+
///     | Modes                | Headphones    | Capture API      |
///     +----------------------+---------------+------------------+
///     | Record + playback    | Any           | AudioEngine      |
///     | Record only          | Yes           | AudioEngine      |
///     | Record only          | No            | AudioToolbox     |
///     +----------------------+---------------+------------------+
///
@RealtimeActor
public final class AudioController {
  public init(modes: [Mode]) async throws {
    self.modes = modes
    #if os(iOS)
    try? AVAudioSession.sharedInstance().setCategory(
      .playAndRecord,
      mode: .voiceChat,
      options: [.defaultToSpeaker, .allowBluetooth])
    try? AVAudioSession.sharedInstance().setActive(true, options: [])

    #elseif os(watchOS)
    try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
    try? await AVAudioSession.sharedInstance().activate(options: [])
    #endif

    audioEngine = AVAudioEngine()

    if modes.contains(.record) {
      #if os(macOS) || os(iOS)
      let needsSharedPlaybackReference = modes.contains(.playback)
      if needsSharedPlaybackReference || AudioUtils.headphonesConnected {
        microphonePCMSampleVendor = try MicrophonePCMSampleVendorAE(audioEngine: audioEngine)
        usesAudioEngineForCapture = true
      } else {
        microphonePCMSampleVendor = MicrophonePCMSampleVendorAT()
      }
      #else
      microphonePCMSampleVendor = try MicrophonePCMSampleVendorAE(audioEngine: audioEngine)
      usesAudioEngineForCapture = true
      #endif
    }

    if modes.contains(.playback) {
      audioPCMPlayer = try await AudioPCMPlayer(audioEngine: audioEngine)
    }

    // Capture installs its input tap in `micStream()`. Starting the engine before that tap exists
    // can leave voice-processing input silent, particularly in Simulator. Playback-only controllers
    // have no capture tap to wait for and can start immediately.
    if !modes.contains(.record) {
      try startAudioEngineIfNeeded()
    }
  }

  public enum Mode {
    case record
    case playback
  }

  public let modes: [Mode]

  /// Installs the microphone tap and starts the shared audio engine. Call this once before expecting
  /// playback from a controller configured with both record and playback modes.
  public func micStream() throws -> AsyncStream<AVAudioPCMBuffer> {
    guard
      modes.contains(.record),
      let microphonePCMSampleVendor
    else {
      throw OpenAIError.assertion("Please pass [.record] to the AudioController initializer")
    }
    guard !hasStartedMicrophone else {
      throw OpenAIError.assertion("AudioController supports one active microphone stream")
    }

    let stream = try microphonePCMSampleVendor.start()
    do {
      if usesAudioEngineForCapture || modes.contains(.playback) {
        try startAudioEngineIfNeeded()
      }
      hasStartedMicrophone = true
      return stream
    } catch {
      microphonePCMSampleVendor.stop()
      throw error
    }
  }

  public func stop() {
    _ = audioPCMPlayer?.interruptPlayback()
    audioEngine.stop()
    microphonePCMSampleVendor?.stop()
  }

  public func playPCM16Audio(base64String: String, itemID: String? = nil) {
    guard
      modes.contains(.playback),
      let audioPCMPlayer
    else {
      logger.error("Please pass [.playback] to the AudioController initializer")
      return
    }
    guard audioEngine.isRunning else {
      logger.error("Call micStream() before playing audio on a record-and-playback controller")
      return
    }
    audioPCMPlayer.playPCM16Audio(from: base64String, itemID: itemID)
  }

  /// Stops queued playback and returns how many milliseconds of the current item were heard.
  @discardableResult
  public func interruptPlayback() -> Int? {
    guard
      modes.contains(.playback),
      let audioPCMPlayer
    else {
      logger.error("Please pass [.playback] to the AudioController initializer")
      return nil
    }
    return audioPCMPlayer.interruptPlayback()
  }

  /// Suspends until all currently queued audio buffers have played.
  public func waitUntilPlaybackFinishes() async {
    guard
      modes.contains(.playback),
      let audioPCMPlayer
    else {
      return
    }
    await audioPCMPlayer.waitUntilPlaybackFinishes()
  }

  private let audioEngine: AVAudioEngine
  private var hasStartedMicrophone = false
  private var microphonePCMSampleVendor: MicrophonePCMSampleVendor? = nil
  private var audioPCMPlayer: AudioPCMPlayer? = nil
  private var usesAudioEngineForCapture = false

  private func startAudioEngineIfNeeded() throws {
    guard !audioEngine.isRunning else { return }
    audioEngine.prepare()
    try audioEngine.start()
    logger.info("Audio engine started with its configured capture and playback graph")
  }

}
#endif
