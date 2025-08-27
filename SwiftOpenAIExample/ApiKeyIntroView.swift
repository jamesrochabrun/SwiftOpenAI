//
//  ApiKeyIntroView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftOpenAI
import SwiftUI

struct ApiKeyIntroView: View {
  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        VStack(spacing: 24) {
          TextField("Enter API Key", text: $apiKey)
          TextField("Enter Organization ID (Optional)", text: $organizationIdentifier)
            .onChange(of: organizationIdentifier) { _, newValue in
              if !newValue.isEmpty {
                localOrganizationID = newValue
              }
            }
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        NavigationLink(destination: OptionsListView(
          openAIService: OpenAIServiceFactory.service(apiKey: apiKey, organizationID: localOrganizationID, debugEnabled: true),
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
        .disabled(apiKey.isEmpty)
        Spacer()
        Group {
          Text("If you don't have a valid API KEY yet, you can visit ") +
            Text("[this link](https://platform.openai.com/account/api-keys)") + Text(" to get started.")
        }
        .font(.caption)
      }
      .padding()
      .navigationTitle("Enter OpenAI API KEY")
    }
  }

  @State private var apiKey = ""
  @State private var organizationIdentifier = ""
  @State private var localOrganizationID: String? = nil
}

#Preview {
  ApiKeyIntroView()
}
