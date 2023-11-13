//
//  FilesDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftUI
import SwiftOpenAI

struct FilesDemoView: View {
   
   @State private var filesProvider: FilesProvider
   @State private var isLoading = false
   private let contentLoader = ContentLoader()
   @State private var errorMessage = ""
   @State private var selectedSegment: Config = .list
   
   enum Config {
      case list
      case moreOptions
   }
   
   init(service: OpenAIService) {
      _filesProvider = State(initialValue: FilesProvider(service: service))
   }
   
   var body: some View {
      VStack {
         picker
         if !errorMessage.isEmpty {
            Text("Error \(errorMessage)")
               .bold()
         }
         switch selectedSegment {
         case .list:
            listView
         case .moreOptions:
            moreOptionsView
         }
      }
      .overlay(
         Group {
            if isLoading {
               ProgressView()
            } else {
               EmptyView()
            }
         }
      )
   }
   
   var picker: some View {
      Picker("Options", selection: $selectedSegment) {
         Text("Shows List").tag(Config.list)
         Text("Show More options").tag(Config.moreOptions)
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding()
   }
   
   var moreOptionsView: some View {
      ScrollView {
         VStack() {
            uploadFileButton
            Text("This button will load a file that has been added to this app bundle.")
            if let uploadedFile = filesProvider.uploadedFile {
               FileObjectView(file: uploadedFile)
            }
         }
      }
   }
   
   var listView: some View {
      VStack(spacing: 0) {
         listFilesButton
         list
      }
   }
   
   var listFilesButton: some View {
      Button("List Files") {
         Task {
            isLoading = true
            defer { isLoading = false }  // ensure isLoading is set to false when the
            do {
               try await filesProvider.listFiles()
            } catch {
               errorMessage = "\(error)"
            }
         }
      }
      .buttonStyle(.borderedProminent)
   }
   
   var uploadFileButton: some View {
      Button("Upload File") {
         Task {
            isLoading = true
            defer { isLoading = false }  // ensure isLoading is set to false when the
            do {
               let fileData = try contentLoader.loadBundledContent(fromFileNamed: "WorldCupData", ext: "jsonl")
               try await filesProvider.uploadFile(parameters: .init(fileName: "WorldCupData", file: fileData, purpose: "fine-tune"))
            } catch {
               errorMessage = "\(error)"
            }
         }
      }
      .buttonStyle(.borderedProminent)
   }
      
   var list: some View {
      List {
         ForEach(Array(filesProvider.files.enumerated()), id: \.offset) { _, file in
            FileObjectView(file: file)
         }
      }
   }
}

struct FileObjectView: View {
   
   private let file: FileObject
   
   init(file: FileObject) {
      self.file = file
   }
   var body: some View {
      VStack(alignment: .leading, spacing: 4) {
         Text("File name = \(file.filename)")
            .font(.title2)
         VStack(alignment: .leading, spacing: 2) {
            Text("ID = \(file.id)")
            Text("Created = \(file.createdAt)")
            Text("Object = \(file.object)")
            Text("Purpose = \(file.purpose)")
            Text("Status = \(file.status)")
            Text("Status Details = \(file.statusDetails ?? "NO DETAILS")")
         }
         .font(.callout)
      }
      .foregroundColor(.primary)
      .padding()
      .background(
         RoundedRectangle(cornerSize: .init(width: 20, height: 20))
            .foregroundColor(.mint)
      )
   }
}
