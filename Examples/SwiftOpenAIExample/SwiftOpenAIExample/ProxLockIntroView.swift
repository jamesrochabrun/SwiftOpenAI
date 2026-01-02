//
//  ProxLockIntroView.swift
//  SwiftOpenAIExample
//
//  Created by Morris Richman on 1/2/2026.
//

import SwiftOpenAI
import SwiftUI

struct ProxLockIntroView: View {
  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        VStack(spacing: 24) {
          TextField("Enter partial key", text: $partialKey)
          TextField("Enter your association ID", text: $associationID)
        }
        .padding()
        .textFieldStyle(.roundedBorder)

        Text("You receive a partial key and association ID when you configure an app in the ProxLock dashboard")
          .font(.caption)

        NavigationLink(destination: OptionsListView(
          openAIService: proxlockService,
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
            "ProxLock keeps your OpenAI API key secure. To configure ProxLock for your project, or to learn more about how it works, please see the docs ") +
            Text("[here](https://docs.proxlock.dev).")
        }
        .font(.caption)
      }
      .padding()
      .navigationTitle("ProxLock Configuration")
    }
  }

  @State private var partialKey = ""
  @State private var associationID = ""

  private var canProceed: Bool {
    !(partialKey.isEmpty || associationID.isEmpty)
  }

  private var proxlockService: OpenAIService {
    OpenAIServiceFactory.service(proxLockPartialKey: partialKey, proxLockAssociationID: associationID)
  }
}

#Preview {
  ApiKeyIntroView()
}
