//
//  ChatMessageView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/13/23.
//

import SwiftUI

struct ChatMessageView: View {
   
   let message: ChatMessageDisplayModel

   @ViewBuilder
   var header: some View {
      switch message.origin {
      case .received(let source):
         switch source {
         case .gpt:
            headerWith("wand.and.stars", title: "CHATGPT")
         case .dalle:
            EmptyView()
         }
      case .sent:
         headerWith("person.circle", title: "USER")
      }
   }
   
   var body: some View {
      VStack(alignment: .leading, spacing: 8) {
         header
         Group {
            switch message.content {
            case .content(let mediaType):
               VStack(alignment: .leading, spacing: Sizes.spacingMedium) {
                  imagesFrom(urls: mediaType.urls ?? [])
                  chatMessageViewWith(mediaType.text)
               }
               .transition(.opacity)
            case .error(let error):
               Text(error)
                  .padding()
                  .font(.callout)
                  .background(
                     RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.red.opacity(0.7))
                  )

            }
         }
         .padding(.leading, 23)
      }
   }
   
   @ViewBuilder
   func chatMessageViewWith(
      _ text: String?)
      -> some View
   {
      if let text = text {
         if text.isEmpty {
            LoadingView()
         } else {
            Text(text)
               .font(.body)
         }
      } else {
         EmptyView()
      }
   }
   
   func headerWith(
      _ systemImageName: String,
      title: String)
      -> some View
   {
      HStack {
         Image(systemName: systemImageName)
            .resizable()
            .frame(width: 16, height: 16)
         Text(title)
            .font(.caption2)
      }
      .foregroundColor(.gray.opacity(0.9))
   }
   
   func imagesFrom(
      urls: [URL])
      -> some View
   {
      ScrollView(.horizontal, showsIndicators: false) {
         HStack(spacing: 8) {
            ForEach(urls, id: \.self) { url in
               URLImageView(url: url)
            }
         }
      }
   }
}
