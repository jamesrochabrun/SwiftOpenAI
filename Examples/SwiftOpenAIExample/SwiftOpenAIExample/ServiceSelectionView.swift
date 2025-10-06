//
//  ServiceSelectionView.swift
//  SwiftOpenAIExample
//
//  Created by Lou Zell on 3/27/24.
//

import SwiftUI

struct ServiceSelectionView: View {
  var body: some View {
    NavigationStack {
      List {
        Section("Select Service") {
          NavigationLink(destination: ApiKeyIntroView()) {
            VStack(alignment: .leading) {
              Text("Default OpenAI Service")
                .padding(.bottom, 10)
              Group {
                Text("Use this service to test SwiftOpenAI functionality by providing your own OpenAI key.")
              }
              .font(.caption)
              .fontWeight(.light)
            }
          }

          NavigationLink(destination: AIProxyIntroView()) {
            VStack(alignment: .leading) {
              Text("AIProxy Service")
                .padding(.bottom, 10)
              Group {
                Text(
                  "Use this service to test SwiftOpenAI functionality with requests proxied through AIProxy for key protection.")
              }
              .font(.caption)
              .fontWeight(.light)
            }
          }

          NavigationLink(destination: LocalHostEntryView()) {
            VStack(alignment: .leading) {
              Text("Ollama")
                .padding(.bottom, 10)
              Group {
                Text("Use this service to test SwiftOpenAI functionality by providing your own local host.")
              }
              .font(.caption)
              .fontWeight(.light)
            }
          }
        }
      }
    }
  }
}

#Preview {
  ServiceSelectionView()
}
