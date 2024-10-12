//
//  OverridableURLProxyPathIntroView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/11/24.
//

import Foundation
import SwiftOpenAI
import SwiftUI

struct OverridableURLProxyPathIntroView: View {
   
   @State private var apiKey = ""
   @State private var url = ""
   @State private var proxyPath: String? = nil
   
   private var isReady: Bool {
      !apiKey.isEmpty && !url.isEmpty
   }
   
   var body: some View {
      NavigationStack {
         VStack {
            Spacer()
            VStack(spacing: 24) {
               TextField("Enter API Key", text: $apiKey)
               TextField("Enter url e.g: https://api.groq.com", text: $url)
               TextField("Enter proxy path e.g: openai", text: .init(get: {
                  proxyPath ?? ""
               }, set: { new in
                  proxyPath = new
               }))
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            NavigationLink(destination: OptionsListView(
               openAIService: OpenAIServiceFactory.service(
                  apiKey: apiKey,
                  overrideBaseURL: url,
                  proxyPath: proxyPath), options: OptionsListView.APIOption.allCases.filter({ $0 != .localChat }))) {
               Text("Continue")
                  .padding()
                  .padding(.horizontal, 48)
                  .foregroundColor(.white)
                  .background(
                     Capsule()
                        .foregroundColor(!isReady ? .gray.opacity(0.2) : Color(red: 64/255, green: 195/255, blue: 125/255)))
            }
            .disabled(!isReady)
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
