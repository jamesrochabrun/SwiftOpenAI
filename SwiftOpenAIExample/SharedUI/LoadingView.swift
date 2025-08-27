//
//  LoadingView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/4/23.
//

import SwiftUI

struct LoadingView: View {
  @State private var dotsCount = 0

  let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

  var body: some View {
    HStack {
      Text("\(getDots())")
        .font(.title)
        .onReceive(timer) { _ in
          withAnimation {
            dotsCount = (dotsCount + 1) % 4
          }
        }
    }
    .frame(minHeight: 40)
  }

  func getDots() -> String {
    String(repeating: ".", count: dotsCount)
  }
}
