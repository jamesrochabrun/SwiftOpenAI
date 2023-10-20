//
//  AudioProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import SwiftUI
import SwiftOpenAI

@Observable class AudioProvider {
   
   var transcription: String = ""
   var translation: String = ""
   
   private let service: OpenAIService
   
   init(service: OpenAIService) {
      self.service = service
   }
   
   func transcript(
      parameters: AudioTranscriptionParameters)
      async throws
   {
      do {
         transcription = try await service.createTranscription(parameters: parameters).text
      } catch {
         transcription = "\(error)"
      }
   }
   
   func translate(
      parameters: AudioTranslationParameters)
      async throws
   {
      do {
         translation = try await service.createTranslation(parameters: parameters).text
      } catch {
         translation = "\(error)"
      }
   }
}
