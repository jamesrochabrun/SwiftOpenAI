//
//  OpenAIRealtimeSession.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/18/25.
//

import Foundation
import AVFoundation

// MARK: OpenAIRealtimeMessage

public enum OpenAIRealtimeMessage {
   case responseAudioDelta(String) // = "response.audio.delta" //OpenAIRealtimeResponseAudioDelta)
   case sessionUpdated // = "session.updated"// OpenAIRealtimeSessionUpdated
   case inputAudioBufferSpeechStarted // = "input_audio_buffer.speech_started"
   case sessionCreated //= "session.created"
}

@RealtimeActor
open class OpenAIRealtimeSession {
   public enum ConnectionState {
      case pending
      case connected
      case disconnected
   }
   
   public private(set) var connectionState = ConnectionState.pending
   private let webSocketTask: URLSessionWebSocketTask
   
   private var continuation: AsyncStream<OpenAIRealtimeMessage>.Continuation?
   
   let sessionConfiguration: OpenAIRealtimeSessionUpdate.SessionConfiguration
   
   init(
      webSocketTask: URLSessionWebSocketTask,
      sessionConfiguration: OpenAIRealtimeSessionUpdate.SessionConfiguration
   ) {
      self.webSocketTask = webSocketTask
      self.sessionConfiguration = sessionConfiguration
      
       // Add logging here
       if let url = webSocketTask.currentRequest?.url {
          print("🔌 WebSocket connecting to: \(url)")
          print("📝 Session configuration: \(String(describing: sessionConfiguration))")
       }
       
       Task {
          try await self.sendMessage(OpenAIRealtimeSessionUpdate(session: self.sessionConfiguration))
       }
       self.webSocketTask.resume()
       self.receiveMessage()
   }
   
   public var receiver: AsyncStream<OpenAIRealtimeMessage> {
      return AsyncStream { continuation in
         self.continuation = continuation
      }
   }

   
   /// Close the ws connection
   public func disconnect() {
      self.continuation?.finish()
      self.continuation = nil
      self.webSocketTask.cancel()
      self.connectionState = .disconnected
      InternalAudioPlayer.interruptPlayback()
   }
   
   
   /// Sends a message through the websocket connection
//   public func sendMessage(_ encodable: Encodable) async throws {
//      guard self.connectionState != .disconnected else {
//         debugPrint("Can't send a websocket message. WS disconnected.")
//         return
//      }
//      let wsMessage = URLSessionWebSocketTask.Message.data(try encodable.serialize())
//      try await self.webSocketTask.send(wsMessage)
//   }
//   
   public func sendMessage(_ encodable: Encodable) async throws {
      guard self.connectionState != .disconnected else {
         debugPrint("Can't send a websocket message. WS disconnected.")
         return
      }
      
      // Add logging here
      print("📤 Sending message: \(String(describing: encodable))")
      if let data: Data = try? encodable.serialize(),
         let jsonString = String(data: data, encoding: .utf8) {
         print("📦 Raw message data: \(jsonString)")
      }
      
      let wsMessage = URLSessionWebSocketTask.Message.string(try encodable.serialize())
      try await self.webSocketTask.send(wsMessage)
   }
   
   /// Tells the websocket task to receive a new message
   func receiveMessage() {
      self.webSocketTask.receive { result in
         switch result {
         case .failure(let error as NSError):
            self.didReceiveWebSocketError(error)
         case .success(let message):
            self.didReceiveWebSocketMessage(message)
         }
      }
   }
   
   /// We disconnect on all errors
   private func didReceiveWebSocketError(_ error: NSError) {
      if (error.code == 57) {
         debugPrint("Received ws disconnect. \(error.localizedDescription)")
      } else {
         debugPrint("Received ws error: \(error.localizedDescription)")
      }
      self.disconnect()
   }
   
   private func didReceiveWebSocketMessage(_ message: URLSessionWebSocketTask.Message) {
      switch message {
      case .string(let text):
         if let data = text.data(using: .utf8) {
            self.didReceiveWebSocketData(data)
         }
      case .data(let data):
         self.didReceiveWebSocketData(data)
      @unknown default:
         debugPrint("Received an unknown websocket message format")
         self.disconnect()
      }
   }
   
   private func didReceiveWebSocketData(_ data: Data) {

      if let jsonString = String(data: data, encoding: .utf8) {
         print("📥 Received WebSocket data: \(jsonString)")
      }

      guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let messageType = json["type"] as? String else {
         debugPrint("Received websocket data that we don't understand")
         self.disconnect()
         return
      }
      
      debugPrint("Received over ws: \(messageType)")
      
      switch messageType {
      case "session.created":
         self.continuation?.yield(.sessionCreated)
      case "response.audio.delta":
         print("Received audio data")
         if let base64Audio = json["delta"] as? String {
            self.continuation?.yield(.responseAudioDelta(base64Audio))
         }
      case "session.updated":
         self.continuation?.yield(.sessionUpdated)
      case "input_audio_buffer.speech_started":
         self.continuation?.yield(.inputAudioBufferSpeechStarted)
         InternalAudioPlayer.interruptPlayback()
      default:
         break
      }
      
      if messageType == "error" {
         let errorBody = String(describing: json["error"] as? [String: Any])
         print("Received error from websocket: \(errorBody)")
         self.disconnect()
      } else {
         if self.connectionState != .disconnected {
            self.receiveMessage()
         }
      }
   }
}


func base64EncodeChannelData(p1: UnsafeMutablePointer<Int16>, frameLength: UInt32) -> String {
   // Use with:
   //    let p1: UnsafeMutablePointer<Int16> = inputInt16ChannelData[0]
   //    return base64EncodeChannelData(p1: p1, frameLength: buffer.frameLength)
   // Calculate the byte count (each Int16 is 2 bytes)
   let byteCount = Int(frameLength) * 2 * MemoryLayout<Int16>.size
   
   // Create a Data object from the pointer
   let data = Data(bytes: p1, count: byteCount)
   
   // Base64 encode the Data
   let base64String = data.base64EncodedString()
   
   return base64String
}



// See technical note: https://developer.apple.com/documentation/technotes/tn3136-avaudioconverter-performing-sample-rate-conversions
// Do not try to change the sampling rate!
// Or if I do, use the more complete method detailed in the technical note
func convertExpectedToPlayableBuffer(_ pcm16Buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer {
   let audioFormat = AVAudioFormat(
      commonFormat: .pcmFormatFloat32,
      sampleRate: pcm16Buffer.format.sampleRate,
      channels: 1,
      interleaved: false)! // interleaved doesn't matter for a single channel.
   guard let converter = AVAudioConverter(from: pcm16Buffer.format, to: audioFormat) else {
      fatalError()
   }
   let newLength = AVAudioFrameCount(pcm16Buffer.frameLength)
   guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: newLength) else {
      fatalError()
   }
   outputBuffer.frameLength = newLength
   
   try! converter.convert(to: outputBuffer, from: pcm16Buffer)
   return outputBuffer
}
