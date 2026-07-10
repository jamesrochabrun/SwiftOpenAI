# OpenAI Realtime API Example

This example demonstrates SwiftOpenAI's Realtime API support for bidirectional voice conversations with `gpt-realtime-2.1` and local function tool calling.

## Features

- Bidirectional audio streaming over WebSocket
- Semantic VAD for automatic turn-taking
- User and assistant transcripts
- Local function tools with `function_call_output`
- Playback interruption when the user starts speaking

## Requirements

- iOS 15+, macOS 12+, or watchOS 9+
- Microphone permissions
- OpenAI API key

## Setup

Add microphone permission to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for voice conversations with AI</string>
```

For macOS sandboxed apps, enable outgoing network connections and audio input.

## Basic Usage

```swift
let service = OpenAIServiceFactory.service(apiKey: "your-api-key")

let configuration = OpenAIRealtimeSessionConfiguration(
    inputAudioFormat: .pcm16,
    inputAudioTranscription: .init(model: Model.gptRealtimeWhisper.value, delay: .low, language: "en"),
    instructions: "You are a concise realtime voice assistant.",
    maxResponseOutputTokens: .int(4096),
    modalities: [.audio],
    outputAudioFormat: .pcm16,
    parallelToolCalls: true,
    reasoning: .init(effort: .low),
    turnDetection: .init(type: .semanticVAD(eagerness: .auto, createResponse: true, interruptResponse: true)),
    voice: "marin"
)

let session = try await service.realtimeSession(
    model: Model.gptRealtime21.value,
    configuration: configuration
)

let audioController = try await AudioController(modes: [.playback, .record])
var isSessionReady = false
var currentAudioItemID: String?

Task {
    let micStream = try audioController.micStream()
    for await buffer in micStream {
        if isSessionReady,
           let base64Audio = AudioUtils.base64EncodeAudioPCMBuffer(from: buffer) {
            await session.sendMessage(OpenAIRealtimeInputAudioBufferAppend(audio: base64Audio))
        }
    }
}

Task {
    for await message in session.receiver {
        switch message {
        case .sessionUpdated:
            isSessionReady = true
        case .responseAudioDelta(let itemID, _, let audio):
            currentAudioItemID = itemID
            audioController.playPCM16Audio(base64String: audio, itemID: itemID)
        case .inputAudioBufferSpeechStarted:
            if let currentAudioItemID,
               let audioEndMS = audioController.interruptPlayback() {
                await session.sendMessage(OpenAIRealtimeConversationItemTruncate(
                    itemID: currentAudioItemID,
                    audioEndMS: audioEndMS
                ))
            }
            currentAudioItemID = nil
        default:
            break
        }
    }
}
```

## Function Calling

Add a function tool to the session:

```swift
let tool = OpenAIRealtimeSessionConfiguration.RealtimeTool.function(.init(
    name: "get_demo_context",
    description: "Get current context from this SwiftOpenAI Realtime example.",
    parameters: [
        "type": "object",
        "properties": [
            "topic": [
                "type": "string",
                "enum": ["time", "session"]
            ]
        ],
        "required": ["topic"],
        "additionalProperties": false
    ]
))
```

Handle the tool call and continue the response:

```swift
var pendingToolResponseID: String?

case .responseFunctionCallArgumentsDone(let name, let arguments, let callID, _, let responseID):
    let output = handleFunctionCall(name: name, arguments: arguments)
    await session.sendMessage(OpenAIRealtimeFunctionCallOutput(callID: callID, output: output))
    pendingToolResponseID = responseID

case .responseDone(let responseID, let status, _):
    if pendingToolResponseID == responseID {
        pendingToolResponseID = nil
        if status == "completed" {
            await session.sendMessage(OpenAIRealtimeResponseCreate())
        }
    }
```

## Troubleshooting

- Verify the API key has access to Realtime models.
- Use `Model.gptRealtime21.value` for the latest voice-agent model.
- Ensure microphone permissions are granted.
- Keep capture and playback on the same `AudioController`; separate audio graphs prevent echo cancellation from using model playback as its reference.
- On macOS, enable outgoing connections and audio input in sandbox settings.

## Resources

- [OpenAI Realtime API documentation](https://developers.openai.com/api/docs/guides/realtime)
- [Realtime with tools](https://developers.openai.com/api/docs/guides/realtime-mcp)
