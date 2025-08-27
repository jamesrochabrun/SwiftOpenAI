//
//  URLImageView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/4/23.
//

import SwiftUI

// MARK: - URLImageView

struct URLImageView: View {
  let url: URL

  var body: some View {
    AsyncImage(
      url: url,
      transaction: Transaction(animation: .easeInOut))
    { phase in
      switch phase {
      case .empty:
        ProgressView()

      case .success(let image):
        image
          .resizable()
          .frame(width: 100, height: 100)
          .transition(.opacity)

      case .failure:
        Image(systemName: "wifi.slash")

      @unknown default:
        EmptyView()
      }
    }
    .frame(width: 100, height: 100)
    .background(Color.gray)
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

let urlImageViewMockURL =
  URL(
    string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg")!

#Preview {
  ScrollView {
    VStack(spacing: 40) {
      URLImageView(url: urlImageViewMockURL)
      URLImageView(url: urlImageViewMockURL)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: 10)
      URLImageView(url: urlImageViewMockURL)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 4))
    }
  }
}
