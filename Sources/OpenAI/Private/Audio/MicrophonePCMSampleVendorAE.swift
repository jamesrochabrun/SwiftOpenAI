//
//  MicrophonePCMSampleVendorAE.swift
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

// MARK: - MicrophonePCMSampleVendorAE

/// This is an AVAudioEngine-based implementation that vends PCM16 microphone samples.
///
/// ## Requirements
///
/// - Assumes an `NSMicrophoneUsageDescription` description has been added to Target > Info
/// - Assumes that microphone permissions have already been granted
///
/// #Usage
///
///     ```
///     let microphoneVendor = try MicrophonePCMSampleVendorAE()
///     let micStream = try microphoneVendor.start()
///     Task {
///         for await buffer in micStream {
///             // Use buffer
///         }
///     }
///     // ... some time later ...
///     microphoneVendor.stop()
///     ```
///
/// References:
/// Apple sample code: https://developer.apple.com/documentation/avfaudio/using-voice-processing
/// Apple technical note: https://developer.apple.com/documentation/technotes/tn3136-avaudioconverter-performing-sample-rate-conversions
/// My apple forum question: https://developer.apple.com/forums/thread/771530
@RealtimeActor
class MicrophonePCMSampleVendorAE: MicrophonePCMSampleVendor {
  init(audioEngine: AVAudioEngine) throws {
    self.audioEngine = audioEngine
    inputNode = self.audioEngine.inputNode

    if !AudioUtils.headphonesConnected {
      try inputNode.setVoiceProcessingEnabled(true)
    }

    let debugText = """
      Using AudioEngine based PCM sample vendor.
      The input node's input format is: \(inputNode.inputFormat(forBus: 0))
      The input node's output format is: \(inputNode.outputFormat(forBus: 0))
      """
    logger.debug("\(debugText)")
  }

  deinit {
    logger.debug("MicrophonePCMSampleVendorAE is being freed")
  }

  public func start() throws -> AsyncStream<AVAudioPCMBuffer> {
    guard
      let desiredTapFormat = AVAudioFormat(
        commonFormat: .pcmFormatInt16,
        sampleRate: inputNode.outputFormat(forBus: 0).sampleRate,
        channels: 1,
        interleaved: false)
    else {
      throw OpenAIError.audioConfigurationError("Could not create the desired tap format for realtime")
    }

    // The buffer size argument specifies the target number of audio frames.
    // For a single channel, a single audio frame has a single audio sample.
    //
    // Try to get 50ms updates.
    // 50ms is half the granularity of our target accumulator (we accumulate into 100ms payloads that we send up to OpenAI)
    //
    // There is a note on the installTap documentation that says AudioEngine may
    // adjust the bufferSize internally.
    let targetBufferSize = UInt32(desiredTapFormat.sampleRate / 20) // 50ms buffers
    logger.info("PCMSampleVendorAE target buffer size is: \(targetBufferSize)")

    return AsyncStream<AVAudioPCMBuffer> { [weak self] continuation in
      guard let this = self else { return }
      this.continuation = continuation
      this.inputNode.installTap(onBus: 0, bufferSize: targetBufferSize, format: desiredTapFormat) { [weak this] sampleBuffer, _ in
        if let accumulatedBuffer = this?.microphonePCMSampleVendorCommon.resampleAndAccumulate(sampleBuffer) {
          // If the buffer has accumulated to a sufficient level, give it back to the caller
          Task { @RealtimeActor in
            this?.continuation?.yield(accumulatedBuffer)
          }
        }
      }
    }
  }

  func stop() {
    continuation?.finish()
    continuation = nil
    inputNode.removeTap(onBus: 0)
    try? inputNode.setVoiceProcessingEnabled(false)
    microphonePCMSampleVendorCommon.audioConverter = nil
  }

  private let audioEngine: AVAudioEngine
  private let inputNode: AVAudioInputNode
  private let microphonePCMSampleVendorCommon = MicrophonePCMSampleVendorCommon()
  private var continuation: AsyncStream<AVAudioPCMBuffer>.Continuation?

}
#endif
