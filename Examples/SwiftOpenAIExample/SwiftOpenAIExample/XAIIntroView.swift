//
//  XAIIntroView.swift
//  SwiftOpenAIExample
//
//  Created for xAI/Grok API integration
//

import SwiftOpenAI
import SwiftUI

struct XAIIntroView: View {
  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        VStack(spacing: 24) {
          TextField("Enter xAI API Key", text: $apiKey)
          TextField("Enter Base URL", text: $baseURL)
            .onChange(of: baseURL) { _, newValue in
              if newValue.isEmpty {
                baseURL = "https://api.x.ai"
              }
            }
          TextField("Enter API Version", text: $apiVersion)
            .onChange(of: apiVersion) { _, newValue in
              if newValue.isEmpty {
                apiVersion = "v1"
              }
            }
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        NavigationLink(destination: OptionsListView(
          openAIService: OpenAIServiceFactory.service(
            apiKey: apiKey,
            overrideBaseURL: baseURL,
            overrideVersion: apiVersion,
            debugEnabled: true),
          options: OptionsListView.APIOption.allCases.filter { $0 != .localChat }))
        {
          Text("Continue")
            .padding()
            .padding(.horizontal, 48)
            .foregroundColor(.white)
            .background(
              Capsule()
                .foregroundColor(apiKey.isEmpty ? .gray.opacity(0.2) : Color(red: 64 / 255, green: 195 / 255, blue: 125 / 255)))
        }
        .disabled(apiKey.isEmpty || baseURL.isEmpty || apiVersion.isEmpty)
        Spacer()
        Group {
          Text("Configure your xAI/Grok API settings. ") +
            Text("[Learn more about xAI API](https://docs.x.ai/)")
        }
        .font(.caption)
      }
      .padding()
      .navigationTitle("Configure xAI/Grok")
    }
  }

  @State private var apiKey = ""
  @State private var baseURL = "https://api.x.ai"
  @State private var apiVersion = "v1"
}

#Preview {
  XAIIntroView()
}
