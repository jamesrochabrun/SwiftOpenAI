//
//  FilesPicker.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 5/29/24.
//

import SwiftUI
import SwiftOpenAI

extension FileObject: Equatable {
   public static func == (lhs: FileObject, rhs: FileObject) -> Bool {
      lhs.id == rhs.id
   }
}

extension FileParameters: Equatable, Identifiable {
   public static func == (lhs: FileParameters, rhs: FileParameters) -> Bool {
      lhs.file == rhs.file &&
      lhs.fileName == rhs.fileName &&
      lhs.purpose == rhs.purpose
   }
   
   public var id: String {
      fileName ?? ""
   }
}


// MARK: FilePickerAction

enum FilePickerAction: Identifiable, Equatable {
   
   case request(FileParameters)
   case retrieveAndDisplay(id: String)
   
   var id: String {
      switch self {
      case .request(let fileParameters): return fileParameters.id
      case .retrieveAndDisplay(let id): return id
      }
   }
}

// MARK: FilesPicker

struct FilesPicker: View {
   
   @State private var presentImporter = false
   @Binding private var actions: [FilePickerAction]
   @Binding private var fileIDS: [String]
   private let service: OpenAIService
   private let sectionTitle: String?
   private let actionTitle: String
   
   init(
      service: OpenAIService,
      sectionTitle: String? = nil,
      actionTitle: String,
      fileIDS: Binding<[String]>,
      actions: Binding<[FilePickerAction]>)
   {
      self.service = service
      self.sectionTitle = sectionTitle
      self.actionTitle = actionTitle
      _fileIDS = fileIDS
      _actions = actions
   }
      
   var body: some View {
      VStack(alignment: .leading) {
         Group {
            if let sectionTitle {
               VStack {
                  Text(sectionTitle)
                  Button {
                     presentImporter = true
                  } label: {
                     Text(actionTitle)
                  }
               }

            } else {
               Button {
                  presentImporter = true
               } label: {
                  Text(actionTitle)
               }
            }
         }
         .fileImporter(
            isPresented: $presentImporter,
            allowedContentTypes: [.pdf, .text, .mp3, .mpeg],
            allowsMultipleSelection: true) { result in
               switch result {
               case .success(let files):
                  files.forEach { file in
                     // gain access to the directory
                     let gotAccess = file.startAccessingSecurityScopedResource()
                     guard gotAccess else { return }
                     if
                        let data = try? Data(contentsOf: file.absoluteURL) {
                        let parameter = FileParameters(fileName: file.lastPathComponent, file: data, purpose: "assistants")
                        self.actions.append(.request(parameter))
                     }
                     file.stopAccessingSecurityScopedResource()
                  }
               case .failure(let error):
                  print(error)
               }
            }
         ForEach(actions, id: \.id) { action in
            FileAttachmentView(
               service: service,
               action: action) { fileResponse in
                  fileIDS.append(fileResponse.id)
               } fileDeletedCompletion: { actionToDelete, deletedFileID in
                  /// Remove file ids from network request.
                  fileIDS.removeAll(where: { id in
                     id == deletedFileID
                  })
                  /// Update UI
                  actions.removeAll { action in
                     actionToDelete.id == action.id
                  }
               }
         }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
   }
}


#Preview {
   FilesPicker(service: OpenAIServiceFactory.service(apiKey: ""), sectionTitle: "Knowledge", actionTitle: "Uplodad File", fileIDS: .constant(["s"]), actions: .constant(
      [.retrieveAndDisplay(id: "id1"),
         .retrieveAndDisplay(id: "id2"),
         .retrieveAndDisplay(id: "id3"),
         .retrieveAndDisplay(id: "id4"),
         .retrieveAndDisplay(id: "id5"),
         .retrieveAndDisplay(id: "id6")]
   ))
   .padding()
}
