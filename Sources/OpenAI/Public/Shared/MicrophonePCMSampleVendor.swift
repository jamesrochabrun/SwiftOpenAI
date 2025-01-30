//
//  MicrophonePCMSampleVendor.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/18/25.
//

import AVFoundation
import Foundation

/// This is an AVAudioEngine-based implementation that vends PCM16 microphone samples at a
/// sample rate that OpenAI's realtime models expect.
///
/// ## Requirements
///
/// - Assumes an `NSMicrophoneUsageDescription` description has been added to Target > Info
/// - Assumes that microphone permissions have already been granted
///
/// ## Usage
///
/// ```
///     let microphoneVendor = MicrophonePCMSampleVendor()
///     try microphoneVendor.start(useVoiceProcessing: true) { sample in
///        // Do something with `sample`
///
///     }
///     // some time later...
///     microphoneVendor.stop()
/// ```
///
///
/// References:
/// Apple sample code: https://developer.apple.com/documentation/avfaudio/using-voice-processing
/// Apple technical note: https://developer.apple.com/documentation/technotes/tn3136-avaudioconverter-performing-sample-rate-conversions
/// My apple forum question: https://developer.apple.com/forums/thread/771530
/// This stackoverflow answer is important to eliminate pops: https://stackoverflow.com/questions/64553738/avaudioconverter-corrupts-data
@RealtimeActor
open class MicrophonePCMSampleVendor {
   
   private var avAudioEngine: AVAudioEngine?
   private var inputNode: AVAudioInputNode?
   private var continuation: AsyncStream<AVAudioPCMBuffer>.Continuation?
   private var audioConverter: AVAudioConverter?
   
   public init() {}
   
   deinit {
      debugPrint("MicrophonePCMSampleVendor is going away")
   }
   
   public func start(useVoiceProcessing: Bool) throws -> AsyncStream<AVAudioPCMBuffer> {
      let avAudioEngine = AVAudioEngine()
      let inputNode = avAudioEngine.inputNode
      // Important! This call changes inputNode.inputFormat(forBus: 0).
      // Turning on voice processing changes the mic input format from a single channel to five channels, and
      // those five channels do not play nicely with AVAudioConverter.
      // So instead of using an AVAudioConverter ourselves, we specify the desired format
      // on the input tap and let AudioEngine deal with the conversion itself.
      try inputNode.setVoiceProcessingEnabled(useVoiceProcessing)
      
      guard let desiredTapFormat = AVAudioFormat(
         commonFormat: .pcmFormatInt16,
         sampleRate: inputNode.inputFormat(forBus: 0).sampleRate,
         channels: 1,
         interleaved: false
      ) else {
         throw APIError.assertion(description: "Could not create the desired tap format for realtime")
      }
      
      // The buffer size argument specifies the target number of audio frames.
      // For a single channel, a single audio frame has a single audio sample.
      // So we are shooting for 1 sample every 100 ms with this calulation.
      //
      // There is a note on the installTap documentation that says AudioEngine may
      // adjust the bufferSize internally.
      let targetBufferSize = UInt32(desiredTapFormat.sampleRate / 10)
      
      let stream = AsyncStream<AVAudioPCMBuffer> { [weak self] continuation in
         inputNode.installTap(onBus: 0, bufferSize: targetBufferSize, format: desiredTapFormat) { sampleBuffer, _ in
            if let resampledBuffer = self?.convertPCM16BufferToExpectedSampleRate(sampleBuffer) {
               continuation.yield(resampledBuffer)
            }
         }
         self?.continuation = continuation
      }
      avAudioEngine.prepare()
      try avAudioEngine.start()
      self.avAudioEngine = avAudioEngine
      self.inputNode = inputNode
      return stream
   }
   
   public func stop() {
      self.continuation?.finish()
      self.inputNode?.removeTap(onBus: 0)
      try? self.inputNode?.setVoiceProcessingEnabled(false)
      self.inputNode = nil
      self.avAudioEngine?.stop()
      self.avAudioEngine = nil
   }
   
   private func convertPCM16BufferToExpectedSampleRate(_ pcm16Buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
      debugPrint("The incoming pcm16Buffer has \(pcm16Buffer.frameLength) samples")
      guard let audioFormat = AVAudioFormat(
         commonFormat: .pcmFormatInt16,
         sampleRate: 24000.0,
         channels: 1,
         interleaved: false
      ) else {
         debugPrint("Could not create target audio format")
         return nil
      }
      
      if self.audioConverter == nil {
         self.audioConverter = AVAudioConverter(from: pcm16Buffer.format, to: audioFormat)
      }
      
      guard let converter = self.audioConverter else {
         debugPrint("There is no audio converter to use for PCM16 resampling")
         return nil
      }
      
      guard let outputBuffer = AVAudioPCMBuffer(
         pcmFormat: audioFormat,
         frameCapacity: AVAudioFrameCount(audioFormat.sampleRate * 2.0)
      ) else {
         debugPrint("Could not create output buffer for PCM16 resampling")
         return nil
      }
      
#if false
      writePCM16IntValuesToFile(from: pcm16Buffer, location: "output1.txt")
#endif
      
      // See the docstring on AVAudioConverterInputBlock in AVAudioConverter.h
      //
      // The block will keep getting invoked until either the frame capacity is
      // reached or outStatus.pointee is set to `.noDataNow` or `.endStream`.
      var error: NSError?
      var ptr: UInt32 = 0
      let targetFrameLength = pcm16Buffer.frameLength
      let _ = converter.convert(to: outputBuffer, error: &error) { numberOfFrames, outStatus in
         guard ptr < targetFrameLength,
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
      
      if let error = error {
         debugPrint("Error converting to expected sample rate: \(error.localizedDescription)")
         return nil
      }
      
#if false
      writePCM16IntValuesToFile(from: outputBuffer, location: "output2.txt")
#endif
      
      return outputBuffer
   }
}

private func advancedPCMBuffer_noCopy(_ originalBuffer: AVAudioPCMBuffer, offset: UInt32) -> AVAudioPCMBuffer? {
   let audioBufferList = originalBuffer.mutableAudioBufferList
   guard audioBufferList.pointee.mNumberBuffers == 1,
         audioBufferList.pointee.mBuffers.mNumberChannels == 1
   else {
      print("Broken programmer assumption. Audio conversion depends on single channel PCM16 as input")
      return nil
   }
   guard let audioBufferData = audioBufferList.pointee.mBuffers.mData else {
      print("Could not get audio buffer data from the original PCM16 buffer")
      return nil
   }
   // advanced(by:) is O(1)
   audioBufferList.pointee.mBuffers.mData = audioBufferData.advanced(
      by: Int(offset) * MemoryLayout<UInt16>.size
   )
   return AVAudioPCMBuffer(
      pcmFormat: originalBuffer.format,
      bufferListNoCopy: audioBufferList
   )
}

// For debugging purposes only.
private func writePCM16IntValuesToFile(from buffer: AVAudioPCMBuffer, location: String) {
   guard let audioBufferList = buffer.audioBufferList.pointee.mBuffers.mData else {
      print("No audio data available to write to disk")
      return
   }
   
   // Get the samples
   let c = Int(buffer.frameLength)
   let pointer = audioBufferList.bindMemory(to: Int16.self, capacity: c)
   let samples = UnsafeBufferPointer(start: pointer, count: c)
   
   // Append them to a file for debugging
   let fileURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Downloads/\(location)")
   let content = samples.map { String($0) }.joined(separator: "\n") + "\n"
   if !FileManager.default.fileExists(atPath: fileURL.path) {
      try? content.write(to: fileURL, atomically: true, encoding: .utf8)
   } else {
      let fileHandle = try! FileHandle(forWritingTo: fileURL)
      defer { fileHandle.closeFile() }
      fileHandle.seekToEndOfFile()
      if let data = content.data(using: .utf8) {
         fileHandle.write(data)
      }
   }
}
