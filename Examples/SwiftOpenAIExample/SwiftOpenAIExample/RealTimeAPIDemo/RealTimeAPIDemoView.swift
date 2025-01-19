//
//  RealTimeAPIDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 1/18/25.
//

import SwiftUI
import AVFoundation
import SwiftOpenAI

struct RealTimeAPIDemoView: View {
   
   @State private var realTimeAPIViewModel: RealTimeAPIViewModel
   @State private var microphonePermission: AVAudioSession.RecordPermission
   
   init(service: OpenAIService) {
      realTimeAPIViewModel = .init(service: service)
      // TODO: Update this with latest API.
      _microphonePermission = State(initialValue: AVAudioSession.sharedInstance().recordPermission)
   }
   
   var body: some View {
      Group {
         switch microphonePermission {
         case .undetermined:
            requestPermissionButton
         case .denied:
            deniedPermissionView
         case .granted:
            actionButtons
         default:
            Text("Unknown permission state")
         }
      }
      .onAppear {
         updateMicrophonePermission()
      }
   }
   
   private var actionButtons: some View {
      VStack(spacing: 40) {
         startSessionButton
         endSessionButton
      }
   }
   
   private var startSessionButton: some View {
      Button {
         Task {
            await realTimeAPIViewModel.testOpenAIRealtime()
         }
      } label: {
         Label("Start session", systemImage: "microphone")
      }
   }
   
   public var endSessionButton: some View {
      Button {
         Task {
            await realTimeAPIViewModel.disconnect()
         }
      } label: {
         Label("Stop session", systemImage: "stop")
      }
   }
   
   private var requestPermissionButton: some View {
      Button {
         requestMicrophonePermission()
      } label: {
         Label("Allow microphone access", systemImage: "mic.slash")
      }
   }
   
   private var deniedPermissionView: some View {
      VStack(spacing: 12) {
         Image(systemName: "mic.slash.circle")
            .font(.largeTitle)
            .foregroundColor(.red)
         
         Text("Microphone access is required")
            .font(.headline)
         
         Button("Open Settings") {
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
               UIApplication.shared.open(settingsUrl)
            }
         }
      }
   }
   
   private func updateMicrophonePermission() {
      microphonePermission = AVAudioSession.sharedInstance().recordPermission
   }
   
   private func requestMicrophonePermission() {
      AVAudioSession.sharedInstance().requestRecordPermission { granted in
         DispatchQueue.main.async {
            microphonePermission = granted ? .granted : .denied
         }
      }
   }
}
