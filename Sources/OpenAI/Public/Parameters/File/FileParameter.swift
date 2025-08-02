//
//  FileParameter.swift
//
//
//  Created by James Rochabrun on 10/16/23.
//

import Foundation

// MARK: - FileParameters

/// [Upload a file](https://platform.openai.com/docs/api-reference/files/create) that can be used across various endpoints/features. Currently, the size of all the files uploaded by one organization can be up to 1 GB. Please contact us if you need to increase the storage limit.
public struct FileParameters: Encodable {
  /// The name of the file asset is not documented in OpenAI's official documentation; however, it is essential for constructing the multipart request.
  public let fileName: String?
  /// The file object (not file name) to be uploaded.
  /// If the purpose is set to "fine-tune", the file will be used for fine-tuning.
  public let file: Data
  /// The intended purpose of the uploaded file.
  /// Use "fine-tune" for [fine-tuning](https://platform.openai.com/docs/api-reference/fine-tuning). This allows us to validate the format of the uploaded file is correct for fine-tuning.
  public let purpose: String

  public init(
    fileName: String?,
    file: Data,
    purpose: String)
  {
    self.fileName = fileName
    self.file = file
    self.purpose = purpose
  }
}

// MARK: MultipartFormDataParameters

extension FileParameters: MultipartFormDataParameters {
  public func encode(boundary: String) -> Data {
    MultipartFormDataBuilder(boundary: boundary, entries: [
      .file(paramName: "file", fileName: fileName, fileData: file, contentType: "application/x-ndjson"),
      .string(paramName: "purpose", value: purpose),
    ]).build()
  }
}
