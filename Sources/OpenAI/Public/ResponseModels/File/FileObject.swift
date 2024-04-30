//
//  FileObject.swift
//
//
//  Created by James Rochabrun on 10/16/23.
//

import Foundation

/// The [File object](https://platform.openai.com/docs/api-reference/files/object) represents a document that has been uploaded to OpenAI.
public struct FileObject: Decodable {
   
   /// The file identifier, which can be referenced in the API endpoints.
   public let id: String
   /// The size of the file in bytes.
   public let bytes: Int?
   /// The Unix timestamp (in seconds) for when the file was created.
   public let createdAt: Int
   /// The name of the file.
   public let filename: String
   /// The object type, which is always "file".
   public let object: String
   /// The intended purpose of the file. Currently, only "fine-tune" is supported.
   public let purpose: String
   /// Deprecated. The current status of the file, which can be either uploaded, processed, or error.
   @available(*, deprecated, message: "Deprecated")
   public let status: String?
   /// Additional details about the status of the file. If the file is in the error state, this will include a message describing the error.
   @available(*, deprecated, message: "Deprecated. For details on why a fine-tuning training file failed validation, see the error field on fine_tuning.job")
   public let statusDetails: String?
   
   public enum Status: String {
      case uploaded
      case processed
      case pending
      case error
      case deleting
      case deleted
   }
   
   enum CodingKeys: String, CodingKey {
      case id
      case bytes
      case createdAt = "created_at"
      case filename
      case object
      case purpose
      case status
      case statusDetails = "status_details"
   }
   
   public init(
      id: String,
      bytes: Int,
      createdAt: Int,
      filename: String,
      object: String,
      purpose: String,
      status: Status,
      statusDetails: String?)
   {
      self.id = id
      self.bytes = bytes
      self.createdAt = createdAt
      self.filename = filename
      self.object = object
      self.purpose = purpose
      self.status = status.rawValue
      self.statusDetails = statusDetails
   }
}
