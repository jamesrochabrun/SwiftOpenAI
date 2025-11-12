//
//  AudioUtils.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

#if canImport(AVFoundation)
import AVFoundation
import Foundation
import OSLog

#if canImport(AudioToolbox)
import AudioToolbox
#endif

private let logger = Logger(subsystem: "com.swiftopenai", category: "Audio")

// MARK: - AudioUtils

public enum AudioUtils {

  nonisolated public static var headphonesConnected: Bool {
    #if os(macOS)
    return audioToolboxHeadphonesConnected()
    #else
    return audioSessionHeadphonesConnected()
    #endif
  }

  /// Encodes an AVAudioPCMBuffer to base64 string for transmission to OpenAI
  nonisolated public static func base64EncodeAudioPCMBuffer(from buffer: AVAudioPCMBuffer) -> String? {
    guard buffer.format.channelCount == 1 else {
      logger.error("This encoding routine assumes a single channel")
      return nil
    }

    guard let audioBufferPtr = buffer.audioBufferList.pointee.mBuffers.mData else {
      logger.error("No audio buffer list available to encode")
      return nil
    }

    let audioBufferLength = Int(buffer.audioBufferList.pointee.mBuffers.mDataByteSize)
    return Data(bytes: audioBufferPtr, count: audioBufferLength).base64EncodedString()
  }

  #if os(macOS)
  nonisolated static func getDefaultAudioInputDevice() -> AudioDeviceID? {
    var deviceID = AudioDeviceID()
    var propSize = UInt32(MemoryLayout<AudioDeviceID>.size)
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDefaultInputDevice,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain)
    let err = AudioObjectGetPropertyData(
      AudioObjectID(kAudioObjectSystemObject),
      &address,
      0,
      nil,
      &propSize,
      &deviceID)
    guard err == noErr else {
      logger.error("Could not query for default audio input device")
      return nil
    }
    return deviceID
  }

  nonisolated static func getAllAudioInputDevices() -> [AudioDeviceID] {
    var propSize: UInt32 = 0
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDevices,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain)
    var err = AudioObjectGetPropertyDataSize(
      AudioObjectID(kAudioObjectSystemObject),
      &address,
      0,
      nil,
      &propSize)
    guard err == noErr else {
      logger.error("Could not set propSize, needed for querying all audio devices")
      return []
    }

    var devices = [AudioDeviceID](
      repeating: 0,
      count: Int(propSize / UInt32(MemoryLayout<AudioDeviceID>.size)))
    err = AudioObjectGetPropertyData(
      AudioObjectID(kAudioObjectSystemObject),
      &address,
      0,
      nil,
      &propSize,
      &devices)
    guard err == noErr else {
      logger.error("Could not query for all audio devices")
      return []
    }
    return devices
  }
  #endif

}

#if !os(macOS)
nonisolated private func audioSessionHeadphonesConnected() -> Bool {
  let session = AVAudioSession.sharedInstance()
  let outputs = session.currentRoute.outputs

  for output in outputs {
    if
      output.portType == .headphones ||
      output.portType == .bluetoothA2DP ||
      output.portType == .bluetoothLE ||
      output.portType == .bluetoothHFP
    {
      return true
    }
  }
  return false
}
#endif

#if os(macOS)
nonisolated private func audioToolboxHeadphonesConnected() -> Bool {
  for deviceID in AudioUtils.getAllAudioInputDevices() {
    if isHeadphoneDevice(deviceID: deviceID), isDeviceAlive(deviceID: deviceID) {
      return true
    }
  }
  return false
}

nonisolated private func isHeadphoneDevice(deviceID: AudioDeviceID) -> Bool {
  guard hasOutputStreams(deviceID: deviceID) else {
    return false
  }

  let transportType = getTransportType(deviceID: deviceID)

  if
    [
      kAudioDeviceTransportTypeBluetooth,
      kAudioDeviceTransportTypeBluetoothLE,
      kAudioDeviceTransportTypeUSB,
    ].contains(transportType)
  {
    return true
  }

  // For built-in devices, we need to check the device name or UID
  if transportType == kAudioDeviceTransportTypeBuiltIn {
    return isBuiltInHeadphonePort(deviceID: deviceID)
  }

  return false
}

nonisolated private func getTransportType(deviceID: AudioDeviceID) -> UInt32 {
  var transportType = UInt32(0)
  var propSize = UInt32(MemoryLayout<UInt32>.size)
  var address = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyTransportType,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain)
  let err = AudioObjectGetPropertyData(
    deviceID,
    &address,
    0,
    nil,
    &propSize,
    &transportType)
  guard err == noErr else {
    logger.error("Could not get transport type for audio device")
    return 0
  }
  return transportType
}

nonisolated private func isBuiltInHeadphonePort(deviceID: AudioDeviceID) -> Bool {
  var deviceUID: CFString? = nil
  var propSize = UInt32(MemoryLayout<CFString>.size)
  var address = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyDeviceUID,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain)

  let err = withUnsafeMutablePointer(to: &deviceUID) { ptr -> OSStatus in
    return AudioObjectGetPropertyData(
      deviceID,
      &address,
      0,
      nil,
      &propSize,
      ptr)
  }

  guard err == noErr, let uidString = deviceUID as? String else {
    logger.error("Could not get mic's uidString from CFString")
    return false
  }

  return ["headphone", "lineout"].contains { uidString.lowercased().contains($0) }
}

nonisolated private func hasOutputStreams(deviceID: AudioDeviceID) -> Bool {
  var address = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyStreams,
    mScope: kAudioObjectPropertyScopeOutput,
    mElement: kAudioObjectPropertyElementMain)
  var propSize: UInt32 = 0
  let err = AudioObjectGetPropertyDataSize(
    deviceID,
    &address,
    0,
    nil,
    &propSize)
  guard err == noErr else {
    logger.error("Could not check for output streams on audio device")
    return false
  }
  return propSize > 0
}

nonisolated private func isDeviceAlive(deviceID: AudioDeviceID) -> Bool {
  var isAlive: UInt32 = 0
  var propSize = UInt32(MemoryLayout<UInt32>.size)
  var address = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyDeviceIsAlive,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain)
  let err = AudioObjectGetPropertyData(
    deviceID,
    &address,
    0,
    nil,
    &propSize,
    &isAlive)
  guard err == noErr else {
    logger.error("Could not check if the audio input is alive")
    return false
  }
  return isAlive != 0
}
#endif
#endif
