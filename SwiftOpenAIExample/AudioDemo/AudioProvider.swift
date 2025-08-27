//
//  AudioProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import AVFoundation
import SwiftOpenAI
import SwiftUI

@Observable
class AudioProvider {
  init(service: OpenAIService) {
    self.service = service
  }

  var transcription = ""
  var translation = ""
  var speechErrorMessage = ""
  var audioPlayer: AVAudioPlayer?

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

  private let service: OpenAIService

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
