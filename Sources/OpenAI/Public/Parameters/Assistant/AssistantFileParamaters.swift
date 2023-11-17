//
//  AssistantFileParamaters.swift
//
//
//  Created by James Rochabrun on 11/16/23.
//

import Foundation

/// [Creates an assistant file.](https://platform.openai.com/docs/api-reference/assistants/createAssistantFile)
public struct AssistantFileParamaters: Encodable {
   
   /// A [File](https://platform.openai.com/docs/api-reference/files) ID (with purpose="assistants") that the assistant should use.
   /// Useful for tools like retrieval and code_interpreter that can access files.
   let fileID: String
   
   enum CodingKeys: String, CodingKey {
      case fileID = "file_id"
   }
}
