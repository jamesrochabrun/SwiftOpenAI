//
//  MicrophonePCMSampleVendorCommon.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

@preconcurrency import AVFoundation
import OSLog

private let logger = Logger(subsystem: "com.swiftopenai", category: "Audio")

// MARK: - MicrophonePCMSampleVendorCommon

/// This protocol is used as a mixin.
/// Please see MicrophonePCMSampleVendor.swift for the protocol that defines a user interface.
nonisolated final class MicrophonePCMSampleVendorCommon {
  var bufferAccumulator: AVAudioPCMBuffer?
  var audioConverter: AVAudioConverter?

  func resampleAndAccumulate(_ pcm16Buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
    if
      let resampledBuffer = convertPCM16BufferToExpectedSampleRate(pcm16Buffer),
      let accumulatedBuffer = accummulateAndVendIfFull(resampledBuffer)
    {
      return accumulatedBuffer
    }
    return nil
  }

  private func convertPCM16BufferToExpectedSampleRate(_ pcm16Buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
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
      audioConverter = AVAudioConverter(from: pcm16Buffer.format, to: audioFormat)
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
    let targetFrameLength = pcm16Buffer.frameLength
    let _ = converter.convert(to: outputBuffer, error: &error) { numberOfFrames, outStatus in
      guard
        ptr < targetFrameLength,
        let workingCopy = advancedPCMBuffer_noCopy(pcm16Buffer, offset: ptr)
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
    var returnBuffer: AVAudioPCMBuffer? = nil
    let targetAccumulatorLength = 2400
    if bufferAccumulator == nil {
      bufferAccumulator = AVAudioPCMBuffer(pcmFormat: buf.format, frameCapacity: AVAudioFrameCount(targetAccumulatorLength * 2))
    }
    guard let accumulator = bufferAccumulator else { return nil }

    let copyFrames = min(buf.frameLength, accumulator.frameCapacity - accumulator.frameLength)
    let dst = accumulator.int16ChannelData![0].advanced(by: Int(accumulator.frameLength))
    let src = buf.int16ChannelData![0]

    dst.update(from: src, count: Int(copyFrames))
    accumulator.frameLength += copyFrames
    if accumulator.frameLength >= targetAccumulatorLength {
      returnBuffer = accumulator
      bufferAccumulator = nil
    }
    return returnBuffer
  }
}

nonisolated private func advancedPCMBuffer_noCopy(_ originalBuffer: AVAudioPCMBuffer, offset: UInt32) -> AVAudioPCMBuffer? {
  let audioBufferList = originalBuffer.mutableAudioBufferList
  guard
    audioBufferList.pointee.mNumberBuffers == 1,
    audioBufferList.pointee.mBuffers.mNumberChannels == 1
  else {
    logger.error("Broken programmer assumption. Audio conversion depends on single channel PCM16 as input")
    return nil
  }
  guard let audioBufferData = audioBufferList.pointee.mBuffers.mData else {
    logger.error("Could not get audio buffer data from the original PCM16 buffer")
    return nil
  }
  // advanced(by:) is O(1)
  audioBufferList.pointee.mBuffers.mData = audioBufferData.advanced(
    by: Int(offset) * MemoryLayout<UInt16>.size)
  return AVAudioPCMBuffer(
    pcmFormat: originalBuffer.format,
    bufferListNoCopy: audioBufferList)
}
