# OpenAI Realtime API Example

This example demonstrates how to use SwiftOpenAI's Realtime API for bidirectional voice conversations with OpenAI's GPT-4o models.

## Features

- Real-time bidirectional audio streaming
- Voice Activity Detection (VAD) for automatic turn-taking
- Audio transcription of both user and AI speech
- Function calling support
- Interrupt handling when user starts speaking

## Requirements

- iOS 15+, macOS 12+, watchOS 9+
- Microphone permissions
- OpenAI API key

## Setup

### 1. Add Microphone Permission

Add the following to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for voice conversations with AI</string>
```

### 2. macOS Sandbox Configuration

If targeting macOS, enable the following in your target's Signing & Capabilities:

- **App Sandbox**:
  - Outgoing Connections (Client) ✓
  - Audio Input ✓
- **Hardened Runtime**:
  - Audio Input ✓

## Usage

### Basic Example

```swift
import SwiftUI
import OpenAI

struct ContentView: View {
    let realtimeManager = RealtimeManager()
    @State private var isActive = false

    var body: some View {
        Button(isActive ? "Stop" : "Start") {
            isActive.toggle()
            if isActive {
                Task {
                    try? await realtimeManager.startConversation()
                }
            } else {
                Task {
                    await realtimeManager.stopConversation()
                }
            }
        }
    }
}

@RealtimeActor
final class RealtimeManager {
    private var session: OpenAIRealtimeSession?
    private var audioController: AudioController?

    func startConversation() async throws {
        // Initialize service
        let service = OpenAIServiceFactory.service(apiKey: "your-api-key")

        // Configure session
        let config = OpenAIRealtimeSessionConfiguration(
            inputAudioFormat: .pcm16,
            inputAudioTranscription: .init(model: "whisper-1"),
            instructions: "You are a helpful assistant",
            modalities: [.audio, .text],
            outputAudioFormat: .pcm16,
            voice: "shimmer"
        )

        // Create session
        session = try await service.realtimeSession(
            model: "gpt-4o-mini-realtime-preview-2024-12-17",
            configuration: config
        )

        // Setup audio
        audioController = try await AudioController(modes: [.playback, .record])

        // Handle microphone input
        Task {
            let micStream = try audioController!.micStream()
            for await buffer in micStream {
                if let base64Audio = AudioUtils.base64EncodeAudioPCMBuffer(from: buffer) {
                    await session?.sendMessage(
                        OpenAIRealtimeInputAudioBufferAppend(audio: base64Audio)
                    )
                }
            }
        }

        // Handle AI responses
        Task {
            for await message in session!.receiver {
                switch message {
                case .responseAudioDelta(let audio):
                    audioController?.playPCM16Audio(base64String: audio)
                case .inputAudioBufferSpeechStarted:
                    audioController?.interruptPlayback()
                default:
                    break
                }
            }
        }
    }

    func stopConversation() {
        audioController?.stop()
        session?.disconnect()
    }
}
```

## Configuration Options

### Voice Options

- `alloy` - Neutral and balanced
- `echo` - Friendly and warm
- `shimmer` - Gentle and calming

### Turn Detection

#### Server VAD (Voice Activity Detection)

```swift
turnDetection: .init(type: .serverVAD(
    prefixPaddingMs: 300,  // Audio to include before speech
    silenceDurationMs: 500, // Silence duration to detect end
    threshold: 0.5         // Activation threshold (0.0-1.0)
))
```

#### Semantic VAD

```swift
turnDetection: .init(type: .semanticVAD(
    eagerness: .medium  // .low, .medium, or .high
))
```

### Modalities

```swift
modalities: [.audio, .text]  // Both audio and text
modalities: [.text]          // Text only (disables audio)
```

## Handling Different Events

```swift
for await message in session.receiver {
    switch message {
    case .error(let error):
        print("Error: \(error ?? "Unknown")")

    case .sessionCreated:
        print("Session started")

    case .sessionUpdated:
        // Trigger first response if AI speaks first
        await session.sendMessage(OpenAIRealtimeResponseCreate())

    case .responseAudioDelta(let base64Audio):
        audioController.playPCM16Audio(base64String: base64Audio)

    case .inputAudioBufferSpeechStarted:
        // User started speaking, interrupt AI
        audioController.interruptPlayback()

    case .responseTranscriptDone(let transcript):
        print("AI said: \(transcript)")

    case .inputAudioTranscriptionCompleted(let transcript):
        print("User said: \(transcript)")

    case .responseFunctionCallArgumentsDone(let name, let args, let callId):
        print("Function \(name) called with: \(args)")
        // Handle function call and return result

    default:
        break
    }
}
```

## Function Calling

Add tools to your configuration:

```swift
let config = OpenAIRealtimeSessionConfiguration(
    tools: [
        .init(
            name: "get_weather",
            description: "Get the current weather for a location",
            parameters: [
                "type": "object",
                "properties": [
                    "location": [
                        "type": "string",
                        "description": "City name"
                    ]
                ],
                "required": ["location"]
            ]
        )
    ],
    toolChoice: .auto
)
```

Handle function calls in the message loop:

```swift
case .responseFunctionCallArgumentsDone(let name, let args, let callId):
    // Parse arguments and execute function
    let result = handleFunction(name: name, args: args)

    // Return result to OpenAI
    await session.sendMessage(
        OpenAIRealtimeConversationItemCreate(
            item: .init(role: "function", text: result)
        )
    )
```

## Troubleshooting

### No Audio Output

- Check that `.playback` mode is included in AudioController initialization
- Verify audio permissions are granted
- Ensure `outputAudioFormat` is set to `.pcm16`

### No Microphone Input

- Check that `.record` mode is included in AudioController initialization
- Verify microphone permissions in Info.plist
- Check System Settings > Privacy & Security > Microphone

### WebSocket Connection Fails

- Verify API key is correct
- Check that `openai-beta: realtime=v1` header is included (SwiftOpenAI handles this automatically)
- Ensure you're using a compatible model (gpt-4o-mini-realtime-preview or newer)

## Resources

- [OpenAI Realtime API Documentation](https://platform.openai.com/docs/api-reference/realtime)
- [SwiftOpenAI GitHub](https://github.com/jamesrochabrun/SwiftOpenAI)
