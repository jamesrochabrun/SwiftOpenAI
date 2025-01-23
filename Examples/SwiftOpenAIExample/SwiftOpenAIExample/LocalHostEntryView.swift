//
//  LocalHostEntryView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 6/24/24.
//

import SwiftUI
import SwiftOpenAI

struct LocalHostEntryView: View {
   
   @State private var url = ""
   
   var body: some View {
      NavigationStack {
         VStack {
            Spacer()
            TextField("Enter URL", text: $url)
            .padding()
            .textFieldStyle(.roundedBorder)
            NavigationLink(destination: OptionsListView(openAIService: OpenAIServiceFactory.service(baseURL: url, debugEnabled: true), options: [.localChat])) {
               Text("Continue")
                  .padding()
                  .padding(.horizontal, 48)
                  .foregroundColor(.white)
                  .background(
                     Capsule()
                        .foregroundColor(url.isEmpty ? .gray.opacity(0.2) : Color(red: 64/255, green: 195/255, blue: 125/255)))
            }
            .disabled(url.isEmpty)
            Spacer()
         }
         .padding()
         .navigationTitle("Enter URL")
      }
   }
}

#Preview {
   ApiKeyIntroView()
}
