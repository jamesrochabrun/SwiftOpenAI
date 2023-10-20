//
//  OptionsListView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftUI
import SwiftOpenAI

struct OptionsListView: View {
   
   var openAIService: OpenAIService
   
   @State private var selection: APIOption? = nil
   
   /// https://platform.openai.com/docs/api-reference
   enum APIOption: String, CaseIterable, Identifiable {
      case audio = "Audio"
      case chat = "Chat"
      case embeddings = "Embeddings"
      case fineTuning = "Fine Tuning"
      case files = "Files"
      case images = "Images"
      case models = "Models"
      case moderations = "Moderations"
      
      var id: String {
         rawValue
      }
   }
   
   var body: some View {
      List(APIOption.allCases, id: \.self, selection: $selection) { option in
         Text(option.rawValue)
            .sheet(item: $selection) { selection in
               switch selection {
               case .audio:
                  AudioDemoView(service: openAIService, title: selection.rawValue)
               case .chat:
                  ChatDemoView(service: openAIService, title: selection.rawValue)
               default:
                  EmptyView()
               }
            }
      }
   }
}

