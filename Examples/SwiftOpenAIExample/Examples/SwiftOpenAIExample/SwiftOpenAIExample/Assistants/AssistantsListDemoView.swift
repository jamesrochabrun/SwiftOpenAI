//
//  AssistantsListDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 3/19/24.
//

import SwiftOpenAI
import SwiftUI

// MARK: - AssistantObject + Identifiable

extension AssistantObject: Identifiable { }

// MARK: - AssistantsListDemoView

public struct AssistantsListDemoView: View {
  public var body: some View {
    NavigationView {
      ForEach(assistants) { assistant in
        NavigationLink(destination: AssistantStartThreadScreen(assistant: assistant, service: service)) {
          VStack(alignment: .leading) {
            Text(assistant.name ?? "No name")
              .font(.title).bold()
            Text(assistant.description ?? "No Description")
              .font(.subheadline).fontWeight(.medium)
            Text(assistant.id)
              .font(.caption).fontWeight(.bold)
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background {
            RoundedRectangle(cornerRadius: 25.0)
              .fill(.mint)
          }
          .padding()
        }
      }
    }
  }

  let assistants: [AssistantObject]
  let service: OpenAIService
}
