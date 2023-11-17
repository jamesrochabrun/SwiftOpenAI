//
//  ThreadParameters.swift
//
//
//  Created by James Rochabrun on 11/16/23.
//

import Foundation

/// Create a [Thread](https://platform.openai.com/docs/api-reference/threads/createThread)
public struct ThreadParameters: Encodable {
   
   /// A list of [messages](https://platform.openai.com/docs/api-reference/messages) to start the thread with.
   let messages: [MessageObject]
   
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   let metadata: [String: String]
}
