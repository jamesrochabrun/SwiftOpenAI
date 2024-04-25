//
//  MessageAttachment.swift
//  
//
//  Created by James Rochabrun on 4/25/24.
//

import Foundation

public struct MessageAttachment: Codable {

   let fileID: String
   let tools: [AssistantObject.Tool]
   
   enum CodingKeys: String, CodingKey {
      case fileID = "file_id"
      case tools
   }
}
