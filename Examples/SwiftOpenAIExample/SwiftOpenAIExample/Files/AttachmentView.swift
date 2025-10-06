//
//  AttachmentView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 5/29/24.
//

import SwiftUI

struct AttachmentView: View {
  let fileName: String
  @Binding var actionTrigger: Bool
  let isLoading: Bool

  var body: some View {
    HStack(spacing: Sizes.spacingExtraSmall) {
      HStack {
        if isLoading == true {
          ProgressView()
            .frame(width: 10, height: 10)
            .padding(.horizontal, Sizes.spacingExtraSmall)
        } else {
          Image(systemName: "doc")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 10)
            .foregroundColor(.secondary)
        }
        Text(fileName)
          .font(.caption2)
      }
      Button {
        actionTrigger = true

      } label: {
        Image(systemName: "xmark.circle.fill")
      }
      .disabled(isLoading)
    }
    .padding(.leading, Sizes.spacingMedium)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .stroke(.gray.opacity(0.5), lineWidth: 0.5))
  }
}

#Preview {
  AttachmentView(fileName: "Mydocument.pdf", actionTrigger: .constant(true), isLoading: true)
}
