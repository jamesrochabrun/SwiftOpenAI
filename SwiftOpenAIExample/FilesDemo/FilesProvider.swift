//
//  FilesProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftOpenAI
import SwiftUI

@Observable
class FilesProvider {
  init(service: OpenAIService) {
    self.service = service
  }

  var files: [FileObject] = []
  var uploadedFile: FileObject?
  var deletedStatus: DeletionStatus?
  var retrievedFile: FileObject?
  var fileContent: [[String: Any]] = []

  func listFiles() async throws {
    files = try await service.listFiles().data
  }

  func uploadFile(
    parameters: FileParameters)
    async throws
  {
    uploadedFile = try await service.uploadFile(parameters: parameters)
  }

  func deleteFileWith(
    id: String)
    async throws
  {
    deletedStatus = try await service.deleteFileWith(id: id)
  }

  func retrieveFileWith(
    id: String)
    async throws
  {
    retrievedFile = try await service.retrieveFileWith(id: id)
  }

  func retrieveContentForFileWith(
    id: String)
    async throws
  {
    fileContent = try await service.retrieveContentForFileWith(id: id)
  }

  private let service: OpenAIService
}
