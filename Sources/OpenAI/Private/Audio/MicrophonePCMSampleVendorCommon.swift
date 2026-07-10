//
//  MicrophonePCMSampleVendorCommon.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

#if canImport(AVFoundation)
@preconcurrency import AVFoundation
import OSLog

private let logger = Logger(subsystem: "com.swiftopenai", category: "Audio")

// MARK: - MicrophonePCMSampleVendorCommon

/// This protocol is used as a mixin.
/// Please see MicrophonePCMSampleVendor.swift for the protocol that defines a user interface.
nonisolated final class MicrophonePCMSampleVendorCommon {
  var bufferAccumulator: AVAudioPCMBuffer?
  var audioConverter: AVAudioConverter?

  func resampleAndAccumulate(_ inputBuffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
    if
      let resampledBuffer = convertToRealtimeFormat(inputBuffer),
      let accumulatedBuffer = accummulateAndVendIfFull(resampledBuffer)
    {
      return accumulatedBuffer
    }
    return nil
  }

  private func convertToRealtimeFormat(_ inputBuffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
    guard
      let audioFormat = AVAudioFormat(
        commonFormat: .pcmFormatInt16,
        sampleRate: 24000.0,
        channels: 1,
        interleaved: false)
    else {
      logger.error("Could not create target audio format")
      return nil
    }

    if audioConverter == nil {
      audioConverter = AVAudioConverter(from: inputBuffer.format, to: audioFormat)
    }

    guard let converter = audioConverter else {
      logger.error("There is no audio converter to use for PCM16 resampling")
      return nil
    }

    guard
      let outputBuffer = AVAudioPCMBuffer(
        pcmFormat: audioFormat,
        frameCapacity: AVAudioFrameCount(audioFormat.sampleRate * 2.0))
    else {
      logger.error("Could not create output buffer for PCM16 resampling")
      return nil
    }

    // See the docstring on AVAudioConverterInputBlock in AVAudioConverter.h
    //
    // The block will keep getting invoked until either the frame capacity is
    // reached or outStatus.pointee is set to `.noDataNow` or `.endStream`.
    var error: NSError?
    nonisolated(unsafe) var ptr: UInt32 = 0
    let targetFrameLength = inputBuffer.frameLength
    let _ = converter.convert(to: outputBuffer, error: &error) { numberOfFrames, outStatus in
      guard
        ptr < targetFrameLength,
        let workingCopy = advancedPCMBufferNoCopy(inputBuffer, offset: ptr)
      else {
        outStatus.pointee = .noDataNow
        return nil
      }
      let amountToFill = min(numberOfFrames, targetFrameLength - ptr)
      outStatus.pointee = .haveData
      ptr += amountToFill
      workingCopy.frameLength = amountToFill
      return workingCopy
    }

    if let error {
      logger.error("Error converting to expected sample rate: \(error.localizedDescription)")
      return nil
    }

    return outputBuffer
  }

  /// The incoming buffer here must be guaranteed at 24kHz in PCM16Int format.
  private func accummulateAndVendIfFull(_ buf: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
    let targetAccumulatorLength = 2400
    guard let source = buf.int16ChannelData?[0] else {
      logger.error("Converted microphone buffer did not contain PCM16 channel data")
      return nil
    }

    var completedBuffer: AVAudioPCMBuffer?
    var sourceOffset = 0
    while sourceOffset < Int(buf.frameLength) {
      if bufferAccumulator == nil {
        bufferAccumulator = AVAudioPCMBuffer(
          pcmFormat: buf.format,
          frameCapacity: AVAudioFrameCount(targetAccumulatorLength))
      }
      guard
        let accumulator = bufferAccumulator,
        let destination = accumulator.int16ChannelData?[0]
      else {
        logger.error("Could not create the realtime microphone accumulator")
        return completedBuffer
      }

      let remainingTargetFrames = targetAccumulatorLength - Int(accumulator.frameLength)
      let copyFrames = min(Int(buf.frameLength) - sourceOffset, remainingTargetFrames)
      destination
        .advanced(by: Int(accumulator.frameLength))
        .update(from: source.advanced(by: sourceOffset), count: copyFrames)
      accumulator.frameLength += AVAudioFrameCount(copyFrames)
      sourceOffset += copyFrames

      if accumulator.frameLength == targetAccumulatorLength {
        if completedBuffer == nil {
          completedBuffer = accumulator
        }
        bufferAccumulator = nil
      }
    }
    return completedBuffer
  }
}

nonisolated private func advancedPCMBufferNoCopy(
  _ originalBuffer: AVAudioPCMBuffer,
  offset: UInt32)
  -> AVAudioPCMBuffer?
{
  let audioBufferList = originalBuffer.mutableAudioBufferList
  guard
    audioBufferList.pointee.mNumberBuffers == 1,
    audioBufferList.pointee.mBuffers.mNumberChannels == 1
  else {
    logger.error("Audio conversion depends on single-channel noninterleaved input")
    return nil
  }
  guard let audioBufferData = audioBufferList.pointee.mBuffers.mData else {
    logger.error("Could not get audio buffer data from the original PCM16 buffer")
    return nil
  }
  // advanced(by:) is O(1)
  let bytesPerFrame = Int(originalBuffer.format.streamDescription.pointee.mBytesPerFrame)
  guard bytesPerFrame > 0 else {
    logger.error("Could not determine input audio bytes per frame")
    return nil
  }
  audioBufferList.pointee.mBuffers.mData = audioBufferData.advanced(
    by: Int(offset) * bytesPerFrame)
  return AVAudioPCMBuffer(
    pcmFormat: originalBuffer.format,
    bufferListNoCopy: audioBufferList)
}
#endif
