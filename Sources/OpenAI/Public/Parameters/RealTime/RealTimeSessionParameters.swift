//
//  RealTimeSessionParameters.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 1/3/25.
//

import Foundation

public struct RealTimeSessionParameters: Encodable {
   
   /// The set of modalities the model can respond with. To disable audio, set this to ["text"].
   public var modalities: [String]?
   
   /// The Realtime model used for this session.
   public let model: String
   
   /// The default system instructions (i.e. system message) prepended to model calls. This field allows the client to guide the model on desired responses. The model can be instructed on response content and format, (e.g. "be extremely succinct", "act friendly", "here are examples of good responses") and on audio behavior (e.g. "talk quickly", "inject emotion into your voice", "laugh frequently"). The instructions are not guaranteed to be followed by the model, but they provide guidance to the model on the desired behavior.
   /// Note that the server sets default instructions which will be used if this field is not set and are visible in the session.created event at the start of the session.
   public var instructions: String?
   
   /// The voice the model uses to respond. Voice cannot be changed during the session once the model has responded with audio at least once. Current voice options are alloy, ash, ballad, coral, echo sage, shimmer and verse.
   public var voice: String?
   
   /// The format of input audio. Options are pcm16, g711_ulaw, or g711_alaw.
   public var inputAudioFormat: String?
   
   /// The format of output audio. Options are `pcm16`, `g711_ulaw`, or `g711_alaw`.
   public var outputAudioFormat: String?
   
   /// Configuration for input audio transcription, defaults to off and can be set to null to turn off once on. Input audio transcription is not native to the model, since the model consumes audio directly. Transcription runs asynchronously through Whisper and should be treated as rough guidance rather than the representation understood by the model.
   public var inputAudioTranscription: AudioTranscription?
   
   /// Configuration for turn detection. Can be set to null to turn off. Server VAD means that the model will detect the start and end of speech based on audio volume and respond at the end of user speech.
   public var turnDetection: TurnDetection?
   
   /// Tools (functions) available to the model
   public var tools: [Tool]?
   
   /// How the model chooses tools. Options are auto, none, required, or specify a function.
   public var toolChoice: String?
   
   /// Sampling temperature for the model, limited to [0.6, 1.2]. Defaults to 0.8
   public var temperature: Double?
   
   /// Maximum number of output tokens for a single assistant response, inclusive of tool calls. Provide an integer between 1 and 4096 to limit output tokens, or inf for the maximum available tokens for a given model. Defaults to inf.
   /// Defaults to inf.
   public var maxResponseOutputTokens: TokenLimit?
   
   public enum TokenLimit: Encodable {
      case finite(Int)
      case infinite
   }
   
   enum CodingKeys: String, CodingKey {
      case modalities
      case model
      case instructions
      case voice
      case inputAudioFormat = "input_audio_format"
      case outputAudioFormat = "output_audio_format"
      case inputAudioTranscription = "input_audio_transcription"
      case turnDetection = "turn_detection"
      case tools
      case toolChoice = "tool_choice"
      case temperature
      case maxResponseOutputTokens = "max_response_output_tokens"
   }
   
   public init(
      modalities: [String]? = nil,
      model: Model,
      instructions: String? = nil,
      voice: Voice? = nil,
      inputAudioFormat: AudioInput? = nil,
      outputAudioFormat: AudioInput? = nil,
      inputAudioTranscription: AudioTranscription? = nil,
      turnDetection: TurnDetection? = nil,
      tools: [Tool]? = nil,
      toolChoice: String? = nil,
      temperature: Double? = nil,
      maxResponseOutputTokens: TokenLimit? = nil)
   {
      self.modalities = modalities
      self.model = model.value
      self.instructions = instructions
      self.voice = voice?.rawValue
      self.inputAudioFormat = inputAudioFormat?.rawValue
      self.outputAudioFormat = outputAudioFormat?.rawValue
      self.inputAudioTranscription = inputAudioTranscription
      self.turnDetection = turnDetection
      self.tools = tools
      self.toolChoice = toolChoice
      self.temperature = temperature
      self.maxResponseOutputTokens = maxResponseOutputTokens
   }
}

