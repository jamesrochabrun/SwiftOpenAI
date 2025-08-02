//
//  FileAttachmentView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 5/29/24.
//

import SwiftOpenAI
import SwiftUI

// MARK: - FileAttachmentView

struct FileAttachmentView: View {
  init(
    service: OpenAIService,
    action: FilePickerAction,
    fileUploadedCompletion: @escaping (_ file: FileObject) -> Void,
    fileDeletedCompletion: @escaping (_ parameters: FilePickerAction, _ id: String) -> Void)
  {
    fileProvider = FilesPickerProvider(service: service)
    self.action = action
    self.fileUploadedCompletion = fileUploadedCompletion
    self.fileDeletedCompletion = fileDeletedCompletion
  }

  var body: some View {
    Group {
      switch action {
      case .request(let parameters):
        newUploadedFileView(parameters: parameters)
      case .retrieveAndDisplay(let id):
        previousUploadedFileView(id: id)
      }
    }
    .onChange(of: deleted) { oldValue, newValue in
      if oldValue != newValue, newValue {
        Task {
          if let fileObject {
            fileDeleteStatus = try await fileProvider.deleteFileWith(id: fileObject.id)
          }
        }
      }
    }
    .onChange(of: fileDeleteStatus) { oldValue, newValue in
      if oldValue != newValue, let newValue, newValue.deleted {
        fileDeletedCompletion(action, newValue.id)
      }
    }
  }

  func newUploadedFileView(
    parameters: FileParameters)
    -> some View
  {
    AttachmentView(
      fileName: (fileObject?.filename ?? parameters.fileName) ?? "",
      actionTrigger: $deleted,
      isLoading: fileObject == nil || deleted)
      .disabled(fileObject == nil)
      .opacity(fileObject == nil ? 0.3 : 1)
      .onFirstAppear {
        Task {
          fileObject = try await fileProvider.uploadFile(parameters: parameters)
        }
      }
      .onChange(of: fileObject) { oldValue, newValue in
        if oldValue != newValue, let newValue {
          fileUploadedCompletion(newValue)
        }
      }
  }

  func previousUploadedFileView(
    id: String)
    -> some View
  {
    AttachmentView(fileName: fileObject?.filename ?? "Document", actionTrigger: $deleted, isLoading: fileObject == nil || deleted)
      .onFirstAppear {
        Task {
          fileObject = try await fileProvider.retrieveFileWith(id: id)
        }
      }
  }

  @State private var fileObject: FileObject?
  @State private var fileDeleteStatus: DeletionStatus?
  @State private var deleted = false

  private let fileProvider: FilesPickerProvider
  private let fileUploadedCompletion: (_ file: FileObject) -> Void
  private let fileDeletedCompletion: (_ action: FilePickerAction, _ id: String) -> Void
  private let action: FilePickerAction
}

// MARK: - OnFirstAppear

private struct OnFirstAppear: ViewModifier {
  let perform: () -> Void

  @State private var firstTime = true

  func body(content: Content) -> some View {
    content.onAppear {
      if firstTime {
        firstTime = false
        perform()
      }
    }
  }
}

extension View {
  func onFirstAppear(perform: @escaping () -> Void) -> some View {
    modifier(OnFirstAppear(perform: perform))
  }
}

extension DeletionStatus: @retroactive Equatable {
  public static func ==(lhs: DeletionStatus, rhs: DeletionStatus) -> Bool {
    lhs.id == rhs.id
  }
}
