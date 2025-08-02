//
//  ModerationProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/24/23.
//

import SwiftOpenAI
import SwiftUI

@Observable
class ModerationProvider {
  init(service: OpenAIService) {
    self.service = service
  }

  var isFlagged = false

  func createModerationFromText(
    parameters: ModerationParameter<String>)
    async throws
  {
    isFlagged = try await service.createModerationFromText(parameters: parameters).isFlagged
  }

  func createModerationFromTexts(
    parameters: ModerationParameter<[String]>)
    async throws
  {
    isFlagged = try await service.createModerationFromTexts(parameters: parameters).isFlagged
  }

  private let service: OpenAIService
}
