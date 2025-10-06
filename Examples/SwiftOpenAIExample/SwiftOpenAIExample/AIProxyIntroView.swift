//
//  AIProxyIntroView.swift
//  SwiftOpenAIExample
//
//  Created by Lou Zell on 3/27/24.
//

import SwiftOpenAI
import SwiftUI

struct AIProxyIntroView: View {
  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        VStack(spacing: 24) {
          TextField("Enter partial key", text: $partialKey)
          TextField("Enter your service's URL", text: $serviceURL)
        }
        .padding()
        .textFieldStyle(.roundedBorder)

        Text("You receive a partial key and service URL when you configure an app in the AIProxy dashboard")
          .font(.caption)

        NavigationLink(destination: OptionsListView(
          openAIService: aiproxyService,
          options: OptionsListView.APIOption.allCases.filter { $0 != .localChat }))
        {
          Text("Continue")
            .padding()
            .padding(.horizontal, 48)
            .foregroundColor(.white)
            .background(
              Capsule()
                .foregroundColor(canProceed ? Color(red: 64 / 255, green: 195 / 255, blue: 125 / 255) : .gray.opacity(0.2)))
        }
        .disabled(!canProceed)
        Spacer()
        Group {
          Text(
            "AIProxy keeps your OpenAI API key secure. To configure AIProxy for your project, or to learn more about how it works, please see the docs at ") +
            Text("[this link](https://www.aiproxy.pro/docs).")
        }
        .font(.caption)
      }
      .padding()
      .navigationTitle("AIProxy Configuration")
    }
  }

  @State private var partialKey = ""
  @State private var serviceURL = ""

  private var canProceed: Bool {
    !(partialKey.isEmpty || serviceURL.isEmpty)
  }

  private var aiproxyService: OpenAIService {
    OpenAIServiceFactory.service(
      aiproxyPartialKey: partialKey,
      aiproxyServiceURL: serviceURL != "" ? serviceURL : nil)
  }
}

#Preview {
  ApiKeyIntroView()
}
