//
//  AssistantsListDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 3/19/24.
//

import SwiftUI
import SwiftOpenAI

extension AssistantObject: Identifiable {}

public struct AssistantsListDemoView: View {
   
   let assistants: [AssistantObject]
   let service: OpenAIService

   public var body: some View {
      NavigationView {
         ForEach(assistants) { assistant in
            NavigationLink(destination: AssistantStartThreadScreen(assistant: assistant, service: service)) {
               VStack(alignment: .leading) {
                  Text(assistant.name ??  "No name")
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
}


