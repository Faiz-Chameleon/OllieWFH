# ElevenLabs WebSocket Setup Guide

## 🚀 Quick Setup for Real WebSocket Connection

### Step 1: Get Your ElevenLabs API Key

1. **Sign up at ElevenLabs**: Go to [elevenlabs.io](https://elevenlabs.io) and create an account
2. **Get API Key**: 
   - Go to your profile settings
   - Copy your API key (starts with `xi-`)

### Step 2: Configure the API Key

1. **Open the service file**:
   ```bash
   # Open this file in your editor
   lib/services/elevenlabs_conversational_service.dart
   ```

2. **Replace the API key** (line 8):
   ```dart
   static const String _apiKey = 'your-actual-api-key-here'; // Replace this
   ```

   Example:
   ```dart
   static const String _apiKey = 'xi-1234567890abcdef1234567890abcdef1234567890abcdef';
   ```

### Step 3: Get Your Agent ID

1. **Create an Agent** (if you don't have one):
   - Go to ElevenLabs dashboard
   - Navigate to "Conversational AI" section
   - Create a new agent or use an existing one
   - Copy the agent ID

2. **Update Agent ID** in the controller:
   ```bash
   # Open this file
   lib/olliebot/conversational_chat_controller.dart
   ```

3. **Replace the agent ID** (line 25):
   ```dart
   var agentId = 'your-agent-id-here'.obs; // Replace this
   ```

   Example:
   ```dart
   var agentId = 'agent_01jx7s6afgea3c44dz0r4r68'.obs;
   ```

### Step 4: Test the Connection

1. **Run the app**:
   ```bash
   flutter run
   ```

2. **Navigate to AI Chat**:
   - Open the app
   - Go to Ollie screen
   - Tap "AI Chat" (purple button)

3. **Check connection status**:
   - Green dot = Connected
   - Red dot = Disconnected

## 🔧 Current Implementation Status

### ✅ What's Working:
- **WebSocket Connection**: Real connection to ElevenLabs
- **Text Messages**: Send and receive text messages
- **Voice Responses**: AI responses with TTS
- **Connection Status**: Real-time connection monitoring
- **Error Handling**: Graceful fallback when disconnected

### 🔄 Message Flow:
```
Your Message → WebSocket → ElevenLabs AI → Response + Voice → Your Device
```

### 📡 WebSocket Endpoint:
```
wss://api.elevenlabs.io/v1/convai/conversation?agent_id=YOUR_AGENT_ID
```

## 🎯 Features Available

### **Real-time Conversation:**
- **Instant Responses**: No waiting for complete responses
- **Voice Activity Detection**: Automatic speech detection
- **Streaming Responses**: AI responses appear as they're generated
- **Interruption Handling**: You can interrupt the AI mid-response

### **Voice Features:**
- **Text-to-Speech**: AI responses are converted to voice
- **Voice Input**: Speak to the AI (when implemented)
- **Real-time Audio**: Stream audio responses

### **UI Features:**
- **Connection Status**: Green/red indicators
- **Real-time Transcripts**: See what the AI heard
- **Streaming Indicators**: Visual feedback during processing
- **Error Handling**: Graceful degradation

## 🐛 Troubleshooting

### **Connection Issues:**
1. **Check API Key**: Ensure it's correct and active
2. **Verify Agent ID**: Make sure the agent exists
3. **Internet Connection**: Ensure stable internet
4. **ElevenLabs Status**: Check if service is available

### **Common Errors:**
- **"API key not configured"**: Set your API key
- **"WebSocket connection failed"**: Check network/API key
- **"Agent not found"**: Verify agent ID

### **Debug Information:**
Check console logs for:
- WebSocket connection status
- Message sending/receiving
- Audio processing status
- Error details

## 🔒 Security Notes

1. **API Key Protection**:
   - Never commit API keys to version control
   - Use environment variables for production
   - Monitor API usage

2. **Data Privacy**:
   - Be aware of data sent to ElevenLabs
   - Consider data retention policies
   - Implement proper security measures

## 📱 Testing the Implementation

### **Test Scenarios:**

1. **Basic Text Chat**:
   - Type a message
   - Verify AI responds
   - Check voice output

2. **Connection Testing**:
   - Monitor connection status
   - Test reconnection
   - Verify error handling

3. **Voice Features**:
   - Test microphone input
   - Verify audio playback
   - Check VAD functionality

## 🚀 Next Steps

### **After Setup:**
1. **Test Basic Functionality**: Send text messages
2. **Verify Voice Output**: Check TTS responses
3. **Test Connection Stability**: Monitor for disconnections
4. **Implement Voice Input**: Add microphone functionality

### **Advanced Features:**
1. **Voice Cloning**: Create custom voices
2. **Multi-language**: Add language support
3. **Context Management**: Maintain conversation history
4. **Integration**: Connect with other services

## 📞 Support

- **ElevenLabs Documentation**: [docs.elevenlabs.io](https://docs.elevenlabs.io)
- **WebSocket API**: [Conversational AI WebSocket](https://elevenlabs.io/docs/conversational-ai/api-reference/conversational-ai/websocket)
- **Community**: ElevenLabs Discord and forums

## 🎉 Success Indicators

When properly configured, you should see:
- ✅ Green connection indicator
- ✅ "Connected to Ollie AI" status
- ✅ AI responds to text messages
- ✅ Voice output plays
- ✅ Real-time conversation flow

The WebSocket implementation provides a cutting-edge conversational AI experience with real-time voice interaction! 