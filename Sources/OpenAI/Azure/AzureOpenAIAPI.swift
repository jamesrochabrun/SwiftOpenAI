//
//  AzureOpenAIAPI.swift
//
//
//  Created by James Rochabrun on 1/23/24.
//

import Foundation

// MARK: - AzureOpenAIAPI

enum AzureOpenAIAPI {
   
   static var azureOpenAIResource: String = ""
   
   case chat(deploymentID: String) // https://learn.microsoft.com/en-us/azure/ai-services/openai/reference#chat-completions
}

// MARK: Endpoint

extension AzureOpenAIAPI: Endpoint {
   
   var base: String {
      "https://\(Self.azureOpenAIResource)/openai.azure.com"
   }
   
   var path: String {
      switch self {
      case .chat(let deploymentID): "/openai/deployments/\(deploymentID)/chat/completions"
      }
   }
}
