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
/// Audio played using the `playPCM16Audio` method does not interfere with the mic data streaming out of the `micStream` AsyncStream.
/// That is, if you use this to control audio in an OpenAI realtime session, the model will not hear itself.
///
/// ## Implementor's note
/// We use either AVAudioEngine or AudioToolbox for mic data, depending on the platform and whether headphones are attached.
/// The following arrangement provides for the best user experience:
///
///     +----------+---------------+------------------+
///     | Platform | Headphones    | Audio API        |
///     +----------+---------------+------------------+
///     | macOS    | Yes           | AudioEngine      |
///     | macOS    | No            | AudioToolbox     |
///     | iOS      | Yes           | AudioEngine      |
///     | iOS      | No            | AudioToolbox     |
///     | watchOS  | Yes           | AudioEngine      |
///     | watchOS  | No            | AudioEngine      |
///     +----------+---------------+------------------+
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
      microphonePCMSampleVendor = AudioUtils.headphonesConnected
        ? try MicrophonePCMSampleVendorAE(audioEngine: audioEngine)
        : MicrophonePCMSampleVendorAT()
      #else
      microphonePCMSampleVendor = try MicrophonePCMSampleVendorAE(audioEngine: audioEngine)
      #endif
    }

    if modes.contains(.playback) {
      audioPCMPlayer = try await AudioPCMPlayer(audioEngine: audioEngine)
    }

    audioEngine.prepare()

    // Nesting `start` in a Task is necessary on watchOS.
    // There is some sort of race, and letting the runloop tick seems to "fix" it.
    // If I call `prepare` and `start` in serial succession, then there is no playback on watchOS (sometimes).
    Task {
      try self.audioEngine.start()
    }
  }

  public enum Mode {
    case record
    case playback
  }

  public let modes: [Mode]

  public func micStream() throws -> AsyncStream<AVAudioPCMBuffer> {
    guard
      modes.contains(.record),
      let microphonePCMSampleVendor
    else {
      throw OpenAIError.assertion("Please pass [.record] to the AudioController initializer")
    }
    return try microphonePCMSampleVendor.start()
  }

  public func stop() {
    microphonePCMSampleVendor?.stop()
    audioPCMPlayer?.interruptPlayback()
  }

  public func playPCM16Audio(base64String: String) {
    guard
      modes.contains(.playback),
      let audioPCMPlayer
    else {
      logger.error("Please pass [.playback] to the AudioController initializer")
      return
    }
    audioPCMPlayer.playPCM16Audio(from: base64String)
  }

  public func interruptPlayback() {
    guard
      modes.contains(.playback),
      let audioPCMPlayer
    else {
      logger.error("Please pass [.playback] to the AudioController initializer")
      return
    }
    audioPCMPlayer.interruptPlayback()
  }

  private let audioEngine: AVAudioEngine
  private var microphonePCMSampleVendor: MicrophonePCMSampleVendor? = nil
  private var audioPCMPlayer: AudioPCMPlayer? = nil

}
#endif
