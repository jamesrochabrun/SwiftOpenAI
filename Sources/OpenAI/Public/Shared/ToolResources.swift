//
//  ToolResources.swift
//
//
//  Created by James Rochabrun on 4/25/24.
//

import Foundation

/// tool_resources
/// object or null
///
/// A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
///
/// code_interpreter
/// properties
/// file_ids (array)
/// A list of file IDs made available to the `code_interpreter`` tool. There can be a maximum of 20 files associated with the tool.
///
/// file_search
/// properties
/// vector_store_id (array)
/// The ID of the vector store attached to this assistant. There can be a maximum of 1 vector store attached to the assistant.
public struct ToolResources: Codable {
   
   let fileSearch: FileSearch?
   let codeInterpreter: CodeInterpreter?
   
   struct FileSearch: Codable {
      
      let vectorStoreIds: [String]
      
      enum CodingKeys: String, CodingKey {
         case vectorStoreIds = "vector_store_ids"
      }
   }
   
   struct CodeInterpreter: Codable {
      
      let fileIds: [String]
      
      enum CodingKeys: String, CodingKey {
         case fileIds = "file_ids"
      }
   }
   
   enum CodingKeys: String, CodingKey {
      case fileSearch = "file_search"
      case codeInterpreter = "code_interpreter"
   }
}


