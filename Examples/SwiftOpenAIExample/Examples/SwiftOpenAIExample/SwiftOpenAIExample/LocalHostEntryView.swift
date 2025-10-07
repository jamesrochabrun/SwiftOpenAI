//
//  LocalHostEntryView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 6/24/24.
//

import SwiftOpenAI
import SwiftUI

struct LocalHostEntryView: View {
  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        TextField("Enter URL", text: $url)
          .padding()
          .textFieldStyle(.roundedBorder)
        NavigationLink(destination: OptionsListView(
          openAIService: OpenAIServiceFactory.service(baseURL: url),
          options: [.localChat]))
        {
          Text("Continue")
            .padding()
            .padding(.horizontal, 48)
            .foregroundColor(.white)
            .background(
              Capsule()
                .foregroundColor(url.isEmpty ? .gray.opacity(0.2) : Color(red: 64 / 255, green: 195 / 255, blue: 125 / 255)))
        }
        .disabled(url.isEmpty)
        Spacer()
      }
      .padding()
      .navigationTitle("Enter URL")
    }
  }

  @State private var url = ""
}

#Preview {
  ApiKeyIntroView()
}
