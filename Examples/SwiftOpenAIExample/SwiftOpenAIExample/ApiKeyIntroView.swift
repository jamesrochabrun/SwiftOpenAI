//
//  ContentView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftUI
import SwiftOpenAI

struct ApiKeyIntroView: View {
   
   let service = OpenAIServiceFactory.service(apiKey: "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", overrideBaseURL: "https://api.deepseek.com", debugEnabled: true)
   
   @State private var apiKey = "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"
   @State private var organizationIdentifier = ""
   @State private var localOrganizationID: String? = nil
   
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
            NavigationLink(destination: OptionsListView(openAIService: service, options: OptionsListView.APIOption.allCases.filter({ $0 != .localChat }))) {
               Text("Continue")
                  .padding()
                  .padding(.horizontal, 48)
                  .foregroundColor(.white)
                  .background(
                     Capsule()
                        .foregroundColor(apiKey.isEmpty ? .gray.opacity(0.2) : Color(red: 64/255, green: 195/255, blue: 125/255)))
            }
            .disabled(apiKey.isEmpty)
            Spacer()
            Group {
               Text("If you don't have a valid API KEY yet, you can visit ") + Text("[this link](https://platform.openai.com/account/api-keys)") + Text(" to get started.")
            }
            .font(.caption)
         }
         .padding()
         .navigationTitle("Enter OpenAI API KEY")
      }
   }
}

#Preview {
   ApiKeyIntroView()
}
