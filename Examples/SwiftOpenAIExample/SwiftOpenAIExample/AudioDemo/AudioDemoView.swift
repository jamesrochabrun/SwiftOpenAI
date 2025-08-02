//
//  AudioDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftOpenAI
import SwiftUI

struct AudioDemoView: View {
  init(service: OpenAIService) {
    _audioProvider = State(initialValue: AudioProvider(service: service))
  }

  var textArea: some View {
    HStack(spacing: 4) {
      TextField("Enter message to convert to speech", text: $prompt, axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .padding()
      Button {
        Task {
          isLoading = true
          defer { isLoading = false } // ensure isLoading is set to false when the
          try await audioProvider.speech(parameters: .init(model: .tts1, input: prompt, voice: .shimmer))
        }
      } label: {
        Image(systemName: "paperplane")
      }
      .buttonStyle(.bordered)
    }
    .padding()
  }

  var transcriptionView: some View {
    VStack {
      Text("Tap this button to use the transcript API, a `m4a` file has been added to the app's bundle.")
        .font(.callout)
        .padding()
      Button("Transcript") {
        Task {
          isLoading = true
          defer { isLoading = false } // ensure isLoading is set to false when the function exits
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
          defer { isLoading = false } // ensure isLoading is set to false when the function exits
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
        VStack {
          Text("Add a text to convert to speech")
          textArea
        }
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
      })
      .safeAreaPadding()
  }

  @State private var audioProvider: AudioProvider
  @State private var isLoading = false
  @State private var prompt = ""

  private let contentLoader = ContentLoader()
}
