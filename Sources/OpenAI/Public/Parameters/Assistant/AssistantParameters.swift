//
//  AssistantParameters.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// https://platform.openai.com/docs/api-reference/assistants/createAssistant
struct AssistantParameters: Encodable {
   
   /// ID of the model to use. You can use the [List models](https://platform.openai.com/docs/api-reference/models/list) API to see all of your available models, or see our [Model overview](https://platform.openai.com/docs/models/overview) for descriptions of them.
   let model: String
   
}
