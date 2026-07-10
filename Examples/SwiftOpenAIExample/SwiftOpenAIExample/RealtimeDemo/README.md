# Realtime demo architecture

The demo separates conversation state from transport and UI so its core can move into another app without bringing the demo screen with it.

- `RealtimeConversation` is a deterministic reducer. It merges transcript deltas by server `item_id`, applies final transcripts, and maintains server conversation order.
- `RealtimeConversationProvider` owns the session, audio controller, event loop, tool execution, and the small connection state machine.
- The SwiftUI files only render observable state and forward user actions.

## Event rules

1. Request microphone permission explicitly. Create the Realtime session first, then configure the audio controller and install its microphone tap before starting the audio engine. The SDK buffers session events during that setup so `session.created` and `session.updated` are not lost.
2. Consume microphone buffers on `RealtimeActor`, not the main actor. Open a separate microphone gate after `session.updated` and keep it open while the model speaks. `AudioController` uses one `AVAudioEngine` voice-processing graph for record and playback, giving echo cancellation the model-audio reference it needs.
3. Use `item_id` as UI identity. Append delta events to the matching item and replace them with the terminal transcript from the corresponding `done` event.
4. Enable `interrupt_response`. On `input_audio_buffer.speech_started`, stop local playback immediately and send `conversation.item.truncate` with the heard playback duration.
5. Send function output as a conversation item, then bind the pending continuation to the tool call's `response_id`. Only a matching `response.done` with `completed` status may send `response.create`; cancellation yields to the user's VAD-created turn.
6. Treat function-argument deltas, item completion, audio completion, and rate-limit updates as normal lifecycle events. Treat an ended receiver stream as a disconnect and tear down microphone, playback, and session state together.
7. Do not report the session as listening until the microphone produces its first buffer. A startup watchdog should turn a silent audio graph into a visible error instead of leaving the UI stuck in a false listening state.

When migrating, keep the reducer and event rules intact. Replace the provider's tool implementation and the SwiftUI views with application-specific versions.
