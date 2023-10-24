//
//  AudioDemo.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftUI
import SwiftOpenAI

struct AudioDemoView: View {
   
   @State private var audioProvider: AudioProvider
   @State private var isLoading: Bool = false
   private let contentLoader = ContentLoader()
   
   init(service: OpenAIService) {
      _audioProvider = State(initialValue: AudioProvider(service: service))
   }
   
   var transcriptionView: some View {
      VStack {
         Text("Tap this button to use the transcript API, a `m4a` file has been added to the app's bundle.")
            .font(.callout)
            .padding()
         Button("Transcript") {
            Task {
               isLoading = true
               defer { isLoading = false }  // ensure isLoading is set to false when the function exits
               /// ['flac', 'm4a', 'mp3', 'mp4', 'mpeg', 'mpga', 'oga', 'ogg', 'wav', 'webm'] (supported formats)
               let data = try contentLoader.loadBundledContent(fromFileNamed: "narcos", ext: "m4a")
               try await audioProvider.transcript(parameters: .init(fileName: "narcos.m4a", file: data))
            }
         }
         .buttonStyle(.borderedProminent)
         Text(audioProvider.transcription)
            .padding()
      }
   }
   
   var translationView: some View {
      VStack {
         Text("Tap this button to use the translationView API, a `m4a` file in German has been added to the app's bundle.")
            .font(.callout)
            .padding()
         Button("Translate") {
            Task {
               isLoading = true
               defer { isLoading = false }  // ensure isLoading is set to false when the function exits
               /// ['flac', 'm4a', 'mp3', 'mp4', 'mpeg', 'mpga', 'oga', 'ogg', 'wav', 'webm'] (supported formats)
               let data = try contentLoader.loadBundledContent(fromFileNamed: "german", ext: "m4a")
               try await audioProvider.translate(parameters: .init(fileName: "german.m4a", file: data))
            }
         }
         .buttonStyle(.borderedProminent)
         Text(audioProvider.translation)
            .padding()
      }
   }
   
   var body: some View {
      ScrollView {
         VStack {
            transcriptionView
               .padding()
            Divider()
            translationView
               .padding()
         }
      }.overlay(
         Group {
            if isLoading {
               ProgressView()
            } else {
               EmptyView()
            }
         }
      )
      .safeAreaPadding()
   }
}
