//
//  AzureOpenAIConfiguration.swift
//
//
//  Created by James Rochabrun on 1/23/24.
//

import Foundation

// [Reference](https://learn.microsoft.com/en-us/azure/ai-services/openai/reference)
public struct AzureOpenAIConfiguration {
   
   /// The name of your Azure OpenAI Resource.
   let resourceName: String
   
   /// The OpenAI API Key
   let openAIAPIKey: String
   
   /// The API version to use for this operation. This follows the YYYY-MM-DD format.
   let apiVersion: String
}
