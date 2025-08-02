//
//  ChatVisionDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/8/23.
//

import PhotosUI
import SwiftOpenAI
import SwiftUI

struct ChatVisionDemoView: View {
  init(service: OpenAIService) {
    _chatProvider = State(initialValue: ChatVisionProvider(service: service))
  }

  var body: some View {
    ScrollViewReader { proxy in
      VStack {
        List(chatProvider.chatMessages) { message in
          ChatDisplayMessageView(message: message)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .onChange(of: chatProvider.chatMessages.last?.content) {
          let lastMessage = chatProvider.chatMessages.last
          if let id = lastMessage?.id {
            proxy.scrollTo(id, anchor: .bottom)
          }
        }
        textArea
      }
    }
  }

  var textArea: some View {
    HStack(spacing: 0) {
      photoPicker
      VStack(alignment: .leading, spacing: 0) {
        if !selectedImages.isEmpty {
          selectedImagesView
          Divider()
            .foregroundColor(.gray)
        }
        textField
          .padding(6)
      }
      .padding(.vertical, 2)
      .padding(.horizontal, 2)
      .animation(.bouncy, value: selectedImages.isEmpty)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .stroke(.gray, lineWidth: 1))
      .padding(.horizontal, 8)
      textAreSendButton
    }
    .padding(.horizontal)
    .disabled(isLoading)
  }

  var textField: some View {
    TextField(
      "How Can I help you today?",
      text: $prompt,
      axis: .vertical)
  }

  var textAreSendButton: some View {
    Button {
      Task {
        isLoading = true
        defer {
          // ensure isLoading is set to false after the function executes.
          isLoading = false
        }
        /// Make the request
        let content: [ChatCompletionParameters.Message.ContentType.MessageContent] = [
          .text(prompt),
        ] + selectedImageURLS.map { .imageUrl(.init(url: $0)) }
        resetInput()
        try await chatProvider.startStreamedChat(parameters: .init(
          messages: [.init(role: .user, content: .contentArray(content))],
          model: .gpt4o, maxTokens: 300), content: content)
      }
    } label: {
      Image(systemName: "paperplane")
    }
    .buttonStyle(.bordered)
    .disabled(prompt.isEmpty)
  }

  var photoPicker: some View {
    PhotosPicker(selection: $selectedItems, matching: .images) {
      Image(systemName: "photo")
    }
    .onChange(of: selectedItems) {
      Task {
        selectedImages.removeAll()
        for item in selectedItems {
          if let data = try? await item.loadTransferable(type: Data.self) {
            let base64String = data.base64EncodedString()
            let url = URL(string: "data:image/jpeg;base64,\(base64String)")!
            selectedImageURLS.append(url)
            if let uiImage = UIImage(data: data) {
              let image = Image(uiImage: uiImage)
              selectedImages.append(image)
            }
          }
        }
      }
    }
  }

  var selectedImagesView: some View {
    HStack(spacing: 0) {
      ForEach(0 ..< selectedImages.count, id: \.self) { i in
        selectedImages[i]
          .resizable()
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .padding(4)
      }
    }
  }

  @State private var chatProvider: ChatVisionProvider
  @State private var isLoading = false
  @State private var prompt = ""
  @State private var selectedItems: [PhotosPickerItem] = []
  @State private var selectedImages: [Image] = []
  @State private var selectedImageURLS: [URL] = []

  /// Called when the user taps on the send button. Clears the selected images and prompt.
  private func resetInput() {
    prompt = ""
    selectedImages = []
    selectedItems = []
    selectedImageURLS = []
  }
}
