//
//  InternalAudioPlayer.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/18/25.
//

import AVFoundation
import Foundation


public struct InternalAudioPlayer {
   static var audioPlayer: AVAudioPlayer? = nil
   static var isAudioEngineStarted = false
   static var audioEngine: AVAudioEngine? = nil
   static var playerNode: AVAudioPlayerNode? = nil
   
   public static func playPCM16Audio(from base64String: String) {
      DispatchQueue.main.async {
         // Decode the base64 string into raw PCM16 data
         guard let audioData = Data(base64Encoded: base64String) else {
            print("Error: Could not decode base64 string")
            return
         }
         
         // Read Int16 samples from audioData
         let int16Samples: [Int16] = audioData.withUnsafeBytes { rawBufferPointer in
            let bufferPointer = rawBufferPointer.bindMemory(to: Int16.self)
            return Array(bufferPointer)
         }
         
         // Convert Int16 samples to Float32 samples
         let normalizationFactor = Float(Int16.max)
         let float32Samples = int16Samples.map { Float($0) / normalizationFactor }
         
         // **Convert mono to stereo by duplicating samples**
         var stereoSamples = [Float]()
         stereoSamples.reserveCapacity(float32Samples.count * 2)
         for sample in float32Samples {
            stereoSamples.append(sample) // Left channel
            stereoSamples.append(sample) // Right channel
         }
         
         // Define audio format parameters
         let sampleRate: Double = 24000.0  // 24 kHz
         let channels: AVAudioChannelCount = 2  // Stereo
         
         // Create an AVAudioFormat for PCM Float32
         guard let audioFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: channels,
            interleaved: false
         ) else {
            print("Error: Could not create audio format")
            return
         }
         
         let frameCount = stereoSamples.count / Int(channels)
         guard let audioBuffer = AVAudioPCMBuffer(
            pcmFormat: audioFormat,
            frameCapacity: AVAudioFrameCount(frameCount)
         ) else {
            print("Error: Could not create audio buffer")
            return
         }
         
         // This looks redundant from the call above, but it is necessary.
         audioBuffer.frameLength = AVAudioFrameCount(frameCount)
         
         if let channelData = audioBuffer.floatChannelData {
            let leftChannel = channelData[0]
            let rightChannel = channelData[1]
            
            for i in 0..<frameCount {
               leftChannel[i] = stereoSamples[i * 2]     // Left channel sample
               rightChannel[i] = stereoSamples[i * 2 + 1] // Right channel sample
            }
         } else {
            print("Failed to access floatChannelData")
            return
         }
         
         if !(audioEngine?.isRunning ?? false) {
#if !os(macOS)
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
#endif
            audioEngine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()
            audioEngine!.attach(playerNode!)
            audioEngine!.connect(playerNode!, to: audioEngine!.outputNode, format: audioBuffer.format)
         }
         
         guard let audioEngine = audioEngine else {
            return
         }
         
         guard let playerNode = playerNode else {
            return
         }
         
         if !audioEngine.isRunning {
            do {
               try audioEngine.start()
            } catch {
               print("Error: Could not start audio engine. \(error.localizedDescription)")
               return
            }
         }
         playerNode.scheduleBuffer(audioBuffer, at: nil, options: [], completionHandler: {})
         playerNode.play()
      }
   }
   
   static func interruptPlayback() {
      debugPrint("Interrupting playback")
      self.playerNode?.stop()
   }
}
