#if canImport(AVFoundation)
import AVFoundation
import XCTest

@testable import SwiftOpenAI

final class RealtimeAudioConversionTests: XCTestCase {
  func testNativeFloatMicrophoneBuffersConvertToRealtimePCM16() throws {
    let inputFormat = try XCTUnwrap(AVAudioFormat(
      commonFormat: .pcmFormatFloat32,
      sampleRate: 48_000,
      channels: 1,
      interleaved: false))
    let inputBuffer = try XCTUnwrap(AVAudioPCMBuffer(
      pcmFormat: inputFormat,
      frameCapacity: 2_400))
    inputBuffer.frameLength = 2_400
    let samples = try XCTUnwrap(inputBuffer.floatChannelData?[0])
    samples.update(repeating: 0.25, count: Int(inputBuffer.frameLength))

    let converter = MicrophonePCMSampleVendorCommon()
    var convertedBuffer: AVAudioPCMBuffer?
    for _ in 0..<4 where convertedBuffer == nil {
      convertedBuffer = converter.resampleAndAccumulate(inputBuffer)
    }

    let output = try XCTUnwrap(convertedBuffer)
    XCTAssertEqual(output.format.commonFormat, .pcmFormatInt16)
    XCTAssertEqual(output.format.sampleRate, 24_000)
    XCTAssertEqual(output.format.channelCount, 1)
    XCTAssertEqual(output.frameLength, 2_400)
  }
}
#endif
