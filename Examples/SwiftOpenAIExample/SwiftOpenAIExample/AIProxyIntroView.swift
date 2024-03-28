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
   @State private var deviceCheckBypass = ""

   var body: some View {
      NavigationStack {
         VStack {
            Spacer()
            VStack(spacing: 24) {
               TextField("Enter partial key", text: $partialKey)
               TextField("Enter DeviceCheck bypass", text: $deviceCheckBypass)
            }
            .padding()
            .textFieldStyle(.roundedBorder)

            NavigationLink(destination: OptionsListView(openAIService: aiproxyService)) {
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
               Text("You can now use SwiftOpenAI for development and production! AI Proxy keeps your OpenAI API key secure. To configure AI Proxy for your project, or to learn more about how it works, please see the docs at ") + Text("[this link](https://www.aiproxy.pro/docs).")
            }
            .font(.caption)
         }
         .padding()
         .navigationTitle("AIProxy Configuration")
      }
   }

   private var aiproxyService: some OpenAIService {
      // Attention AI Proxy customers!
      //
      // Please do not let a `deviceCheckBypass` slip into an archived version of your app that you distribute (including through TestFlight).
      // Doing so would allow an attacker to use the bypass themselves.
      // The bypass is intended to only be used by developers during development in the iOS simulator (where DeviceCheck does not exist).
      //
      // Please retain these conditional checks if you copy this example into your own code.
      // Your integration code should look like this:
      //
      //     #if DEBUG && targetEnvironment(simulator)
      //           OpenAIServiceFactory.service(
      //              aiproxyPartialKey: "hardcode-partial-key-here",
      //              aiproxyDeviceCheckBypass: "hardcode-device-check-bypass-here"
      //           )
      //     #else
      //           OpenAIServiceFactory.service(aiproxyPartialKey: "hardcode-partial-key-here")
      //     #endif
      #if DEBUG && targetEnvironment(simulator)
      OpenAIServiceFactory.service(aiproxyPartialKey: partialKey, aiproxyDeviceCheckBypass: deviceCheckBypass)
      #else
      OpenAIServiceFactory.service(aiproxyPartialKey: partialKey)
      #endif
   }
}

#Preview {
   ApiKeyIntroView()
}
