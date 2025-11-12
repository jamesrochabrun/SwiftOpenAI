//
//  ChatMessageLoadingView.swift
//
//
//  Created by James Rochabrun on 3/28/24.
//

import Foundation
import SwiftUI

struct ChatMessageLoadingView: View {
  var animationDuration: Double
  @State private var isScaledUp = false

  var body: some View {
    Circle()
      .scaleEffect(isScaledUp ? 1.5 : 1) // 1.5 is 150% size, 1 is 100% size
      .onAppear {
        withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
          isScaledUp.toggle()
        }
      }
  }
}

#Preview {
  ChatMessageLoadingView(animationDuration: 0.2)
}
