//
//  ChatDisplayMessageView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/4/23.
//

import SwiftUI

struct ChatDisplayMessageView: View {
  let message: ChatDisplayMessage

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      headerFor(message: message)
      Group {
        switch message.content {
        case .content(let content):
          let text = content.compactMap { contentItem -> String? in
            if case .text(let text) = contentItem {
              return text
            } else {
              return nil
            }
          }.first ?? ""

          let urls = content.compactMap { contentItem -> URL? in
            if case .imageUrl(let imageDetail) = contentItem {
              return imageDetail.url
            } else {
              return nil
            }
          }
          VStack(alignment: .leading, spacing: 8) {
            chatImagesViewFrom(urls: urls)
            chatMessageViewWith(text)
          }

        case .error(let error):
          Text(error)
            .padding()
            .font(.callout)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.red.opacity(0.7)))

        case .text(let text):
          chatMessageViewWith(text)

        case .images(let urls):
          chatImagesViewFrom(urls: urls)
        }
      }
      .padding(.leading, 23)
    }
  }

  @ViewBuilder
  func chatMessageViewWith(
    _ text: String)
    -> some View
  {
    if text.isEmpty {
      ChatMessageLoadingView(animationDuration: 0.5)
        .frame(width: 10, height: 10)
    } else {
      Text(text)
        .font(.body)
    }
  }

  func headerFor(
    message: ChatDisplayMessage)
    -> some View
  {
    HStack {
      Image(systemName: message.type == .sent ? "person.circle" : "wand.and.stars")
        .resizable()
        .frame(width: 15, height: 15)
      Text(message.type == .sent ? "USER" : "CHATGPT")
        .font(.caption2)
    }
    .foregroundColor(.gray.opacity(0.9))
  }

  func chatImagesViewFrom(
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

  @State private var urls: [URL] = []
}

#Preview {
  VStack(alignment: .leading) {
    ChatDisplayMessageView(message: .init(content: .text("How are you?"), type: .sent, delta: nil))
    ChatDisplayMessageView(message: .init(content: .text("I am ok"), type: .received, delta: nil))
    ChatDisplayMessageView(message: .init(content: .images([]), type: .received, delta: nil))
  }
  .padding()
  .frame(maxWidth: .infinity, alignment: .leading)
}
