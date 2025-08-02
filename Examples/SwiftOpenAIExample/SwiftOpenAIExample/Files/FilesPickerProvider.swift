//
//  FilesPickerProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 5/29/24.
//

import SwiftOpenAI
import SwiftUI

final class FilesPickerProvider {
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
    async throws -> FileObject?
  {
    try await service.uploadFile(parameters: parameters)
  }

  func deleteFileWith(
    id: String)
    async throws -> DeletionStatus?
  {
    try await service.deleteFileWith(id: id)
  }

  func retrieveFileWith(
    id: String)
    async throws -> FileObject?
  {
    try await service.retrieveFileWith(id: id)
  }

  func retrieveContentForFileWith(
    id: String)
    async throws
  {
    fileContent = try await service.retrieveContentForFileWith(id: id)
  }

  private let service: OpenAIService
}
