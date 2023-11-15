//
//  AudioProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import AVFoundation
import SwiftUI
import SwiftOpenAI

@Observable class AudioProvider {
   
   var transcription: String = ""
   var translation: String = ""
   var speechErrorMessage: String = ""
   var audioPlayer: AVAudioPlayer?
   
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
   
   func speech(
      parameters: AudioSpeechParameters)
      async throws
   {
      do {
         let speech = try await service.createSpeech(parameters: parameters).output
         playAudio(from: speech)
      } catch let error as APIError {
         speechErrorMessage = error.displayDescription
      } catch {
         speechErrorMessage = "\(error)"
      }
   }
   
   private func playAudio(from data: Data) {
       do {
           // Initialize the audio player with the data
           audioPlayer = try AVAudioPlayer(data: data)
           audioPlayer?.prepareToPlay()
           audioPlayer?.play()
       } catch {
           // Handle errors
           print("Error playing audio: \(error.localizedDescription)")
       }
   }
}
