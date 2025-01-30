//
//  AudioUtils.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/18/25.
//

import AVFoundation
import Foundation

public struct AudioUtils {
   
   static func base64EncodedPCMData(from sampleBuffer: CMSampleBuffer) -> String? {
      let bytesPerSample = sampleBuffer.sampleSize(at: 0)
      guard bytesPerSample == 2 else {
         debugPrint("Sample buffer does not contain PCM16 data")
         return nil
      }
      
      let byteCount = sampleBuffer.numSamples * bytesPerSample
      guard byteCount > 0 else {
         return nil
      }
      
      guard let blockBuffer: CMBlockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
         debugPrint("Could not get CMSampleBuffer data")
         return nil
      }
      
      if !blockBuffer.isContiguous {
         debugPrint("There is a bug here. The audio data is not contiguous and I'm treating it like it is")
         // Alternative approach:
         // https://myswift.tips/2021/09/04/converting-an-audio-(pcm)-cmsamplebuffer-to-a-data-instance.html
      }
      
      do {
         return try blockBuffer.dataBytes().base64EncodedString()
      } catch {
         debugPrint("Could not get audio data")
         return nil
      }
   }
   
   init() {
      fatalError("This is a namespace.")
   }
   
   public static func base64EncodeAudioPCMBuffer(from buffer: AVAudioPCMBuffer) -> String? {
      guard buffer.format.channelCount == 1 else {
         debugPrint("This encoding routine assumes a single channel")
         return nil
      }
      
      guard let audioBufferPtr = buffer.audioBufferList.pointee.mBuffers.mData else {
         debugPrint("No audio buffer list available to encode")
         return nil
      }
      
      let audioBufferLenth = Int(buffer.audioBufferList.pointee.mBuffers.mDataByteSize)
      return Data(bytes: audioBufferPtr, count: audioBufferLenth).base64EncodedString()
   }
}
