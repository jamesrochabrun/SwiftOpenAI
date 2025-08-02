//
//  ImagesProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftOpenAI
import SwiftUI

@Observable
class ImagesProvider {
  init(service: OpenAIService) {
    self.service = service
  }

  var images: [URL] = []

  func createImages(
    parameters: ImageCreateParameters)
    async throws
  {
    let urls = try await service.legacyCreateImages(
      parameters: parameters).data.map(\.url)
    images = urls.compactMap(\.self)
  }

  func editImages(
    parameters: ImageEditParameters)
    async throws
  {
    let urls = try await service.legacyEditImage(
      parameters: parameters).data.map(\.url)
    images = urls.compactMap(\.self)
  }

  func createImageVariations(
    parameters: ImageVariationParameters)
    async throws
  {
    let urls = try await service.legacyCreateImageVariations(parameters: parameters).data.map(\.url)
    images = urls.compactMap(\.self)
  }

  private let service: OpenAIService
}
