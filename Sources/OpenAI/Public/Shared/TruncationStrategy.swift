//
//  TruncationStrategy.swift
//  
//
//  Created by James Rochabrun on 4/13/24.
//

import Foundation

public struct TruncationStrategy: Codable {
   /// The truncation strategy to use for the thread. The default is auto. If set to last_messages, the thread will be truncated to the n most recent messages in the thread. When set to auto, messages in the middle of the thread will be dropped to fit the context length of the model, max_prompt_tokens.
   let type: String
   /// The number of most recent messages from the thread when constructing the context for the run.
   let lastMessage: Int?
   
   enum CodingKeys: String, CodingKey {
      case type
      case lastMessage = "last_messages"
   }
}
