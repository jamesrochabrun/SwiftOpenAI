//
//  AIProxyIntroView.swift
//  SwiftOpenAIExample
//
//  Created by Lou Zell on 3/27/24.
//

import SwiftUI
import SwiftOpenAI

struct AIProxyIntroView: View {

   @State private var partialKey = ""

   var body: some View {
      NavigationStack {
         VStack {
            Spacer()
            VStack(spacing: 24) {
               TextField("Enter partial key", text: $partialKey)
            }
            .padding()
            .textFieldStyle(.roundedBorder)

            Text("You receive a partial key when you configure an app in the AIProxy dashboard")
               .font(.caption)

            NavigationLink(destination: OptionsListView(openAIService: aiproxyService, options: OptionsListView.APIOption.allCases.filter({ $0 != .localChat }))) {
               Text("Continue")
                  .padding()
                  .padding(.horizontal, 48)
                  .foregroundColor(.white)
                  .background(
                     Capsule()
                        .foregroundColor(partialKey.isEmpty ? .gray.opacity(0.2) : Color(red: 64/255, green: 195/255, blue: 125/255)))
            }
            .disabled(partialKey.isEmpty)
            Spacer()
            Group {
               Text("You can now use SwiftOpenAI for development and production! AIProxy keeps your OpenAI API key secure. To configure AIProxy for your project, or to learn more about how it works, please see the docs at ") + Text("[this link](https://www.aiproxy.pro/docs).")
            }
            .font(.caption)
         }
         .padding()
         .navigationTitle("AIProxy Configuration")
      }
   }

   private var aiproxyService: some OpenAIService {
      OpenAIServiceFactory.service(aiproxyPartialKey: partialKey)
   }
}

#Preview {
   ApiKeyIntroView()
}
