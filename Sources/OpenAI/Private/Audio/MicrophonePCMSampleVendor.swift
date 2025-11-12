//
//  MicrophonePCMSampleVendor.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

import AVFoundation

@RealtimeActor
protocol MicrophonePCMSampleVendor: AnyObject {
  func start() throws -> AsyncStream<AVAudioPCMBuffer>
  func stop()
}
