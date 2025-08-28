# ElevenLabs Conversational AI Setup Guide

This guide will help you set up ElevenLabs' Conversational AI WebSocket functionality for real-time voice conversations with your Ollie bot.

## Overview

The Conversational AI feature provides:
- **Real-time voice conversations** - No waiting for complete responses
- **Voice Activity Detection (VAD)** - Automatic detection of when user is speaking
- **Streaming responses** - AI responses are streamed as they're generated
- **Interruption handling** - Users can interrupt the AI mid-response
- **Contextual updates** - Real-time context management

## Prerequisites

1. **ElevenLabs Account** - Sign up at [elevenlabs.io](https://elevenlabs.io)
2. **API Key** - Get your API key from ElevenLabs dashboard
3. **Agent ID** - Create or use an existing agent ID

## Setup Instructions

### 1. Get Your ElevenLabs API Key

1. Go to [elevenlabs.io](https://elevenlabs.io) and create an account
2. Navigate to your profile settings
3. Copy your API key

### 2. Configure the API Key

1. Open `lib/services/elevenlabs_conversational_service.dart`
2. Replace `'YOUR_ELEVENLABS_API_KEY'` with your actual API key:

```dart
static const String _apiKey = 'your-actual-api-key-here';
```

### 3. Set Your Agent ID

1. Open `lib/olliebot/conversational_chat_controller.dart`
2. Replace the agent ID with your own:

```dart
var agentId = 'your-agent-id-here'.obs;
```

### 4. Install Dependencies

The required dependencies are already added to `pubspec.yaml`:

```yaml
web_socket_channel: ^2.4.0
audioplayers: ^5.2.1
path_provider: ^2.1.2
```

Run:
```bash
flutter pub get
```

## Features

### 🎯 Conversational AI Features

1. **Real-time WebSocket Connection**
   - Maintains persistent connection for instant responses
   - Automatic reconnection handling
   - Connection status indicators

2. **Voice Activity Detection**
   - Automatically detects when user starts/stops speaking
   - Real-time transcript display
   - VAD score monitoring

3. **Streaming Responses**
   - AI responses appear as they're generated
   - Visual streaming indicators
   - Smooth conversation flow

4. **Contextual Updates**
   - Send real-time context to the AI
   - Maintain conversation state
   - Dynamic variable updates

5. **Fallback System**
   - Graceful degradation when WebSocket fails
   - Local response system as backup
   - Connection status monitoring

### 📱 UI Features

1. **Connection Status**
   - Green indicator when connected
   - Red indicator when disconnected
   - Status messages in UI

2. **Transcript Display**
   - Real-time display of user speech
   - Visual feedback during voice input
   - Clear indication of what was heard

3. **Streaming Indicators**
   - Loading spinners during response generation
   - Smooth text appearance
   - Visual feedback for AI processing

4. **Dual Chat Options**
   - Basic Chat: Traditional TTS approach
   - AI Chat: Conversational AI with WebSocket

## Usage

### For Users

1. **Access AI Chat**
   - Tap the "AI Chat" button on the main Ollie screen
   - This opens the Conversational AI interface

2. **Voice Interaction**
   - Tap the microphone button to start speaking
   - Speak naturally - the AI will respond in real-time
   - You can interrupt the AI mid-response

3. **Text Input**
   - Type messages in the text field
   - Press enter or tap send to submit
   - AI responds with voice and text

4. **Monitor Connection**
   - Green dot indicates active connection
   - Red dot indicates fallback mode
   - Status bar shows connection details

### For Developers

1. **Customize Agent**
   - Modify the agent prompt in `conversational_chat_controller.dart`
   - Adjust temperature and max tokens
   - Set custom first message

2. **Add Context**
   - Use `sendContextualUpdate()` to provide real-time context
   - Update dynamic variables
   - Maintain conversation state

3. **Handle Audio**
   - Customize audio playback settings
   - Implement custom audio processing
   - Add audio effects or filters

## Technical Implementation

### Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter UI    │    │   GetX Controller│    │ ElevenLabs API  │
│                 │◄──►│                  │◄──►│                 │
│ - Chat Screen   │    │ - State Mgmt     │    │ - WebSocket     │
│ - Status Display│    │ - Stream Handling│    │ - TTS           │
│ - Voice Input   │    │ - Error Handling │    │ - VAD           │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Key Components

1. **ElevenLabsConversationalService**
   - WebSocket connection management
   - Message handling and routing
   - Audio processing and playback

2. **ConversationalChatController**
   - State management with GetX
   - Stream handling and UI updates
   - Error handling and fallbacks

3. **ConversationalChatScreen**
   - Real-time UI updates
   - Connection status display
   - Voice and text input handling

### Message Flow

1. **Initialization**
   ```
   App Start → Initialize WebSocket → Send Init Data → Receive Metadata
   ```

2. **User Input**
   ```
   Voice/Text → Controller → WebSocket → ElevenLabs → Response Stream
   ```

3. **Response Processing**
   ```
   Audio Chunks → Decode → Play → Update UI
   Text Response → Stream → Display → Update Chat
   ```

## Configuration Options

### Agent Configuration

```dart
await _conversationalService.initialize(
  agentId: 'your-agent-id',
  customPrompt: "Your custom prompt here",
  firstMessage: "Custom first message",
  voiceId: '21m00Tcm4TlvDq8ikWAM',
  language: 'en',
);
```

### LLM Settings

```dart
'custom_llm_extra_body': {
  'temperature': 0.7,    // Creativity level (0.0-1.0)
  'max_tokens': 150,     // Response length limit
}
```

### Voice Settings

```dart
'tts': {
  'voice_id': '21m00Tcm4TlvDq8ikWAM',  // Voice selection
}
```

## Troubleshooting

### Common Issues

1. **WebSocket Connection Failed**
   - Check API key configuration
   - Verify agent ID is correct
   - Ensure internet connectivity
   - Check ElevenLabs service status

2. **Audio Not Playing**
   - Verify audio permissions
   - Check device volume
   - Ensure audio player initialization
   - Check temporary file permissions

3. **Voice Input Not Working**
   - Grant microphone permissions
   - Check speech-to-text initialization
   - Verify device microphone functionality

4. **Responses Not Streaming**
   - Check WebSocket connection status
   - Verify response stream handling
   - Ensure proper message parsing

### Debug Information

Enable debug logging by checking console output for:
- WebSocket connection status
- Message type handling
- Audio processing status
- Error messages and stack traces

## Security Considerations

1. **API Key Protection**
   - Never commit API keys to version control
   - Use environment variables for production
   - Implement key rotation

2. **WebSocket Security**
   - Use secure WebSocket connections (WSS)
   - Implement proper authentication
   - Monitor connection usage

3. **Data Privacy**
   - Be aware of data sent to ElevenLabs
   - Implement data retention policies
   - Consider local processing for sensitive data

## Performance Optimization

1. **Connection Management**
   - Implement connection pooling
   - Handle reconnection efficiently
   - Monitor connection health

2. **Audio Processing**
   - Optimize audio chunk size
   - Implement audio buffering
   - Reduce latency in audio playback

3. **Memory Management**
   - Dispose of resources properly
   - Implement stream cleanup
   - Monitor memory usage

## Next Steps

### Potential Enhancements

1. **Multi-language Support**
   - Add language detection
   - Support multiple voice languages
   - Implement language switching

2. **Advanced Voice Features**
   - Voice cloning integration
   - Emotion detection
   - Voice customization

3. **Enhanced Context**
   - Conversation history management
   - User preference learning
   - Personalized responses

4. **Integration Opportunities**
   - Calendar integration
   - Task management
   - Smart home control
   - Weather updates

## Support

- **ElevenLabs Documentation**: [docs.elevenlabs.io](https://docs.elevenlabs.io)
- **WebSocket API Reference**: [Conversational AI WebSocket](https://elevenlabs.io/docs/conversational-ai/api-reference/conversational-ai/websocket)
- **Community Support**: ElevenLabs Discord and forums

## Files Created

- `lib/services/elevenlabs_conversational_service.dart` - WebSocket service
- `lib/olliebot/conversational_chat_controller.dart` - GetX controller
- `lib/olliebot/conversational_chat_screen.dart` - UI screen
- `CONVERSATIONAL_AI_SETUP.md` - This setup guide

The Conversational AI implementation provides a cutting-edge voice interaction experience that goes beyond traditional TTS, offering real-time, natural conversations with your Ollie assistant. 