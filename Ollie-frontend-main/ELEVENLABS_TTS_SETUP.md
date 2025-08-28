# ElevenLabs Text-to-Speech Integration Setup

This guide will help you set up ElevenLabs text-to-speech functionality in your Ollie Flutter app.

## Prerequisites

1. An ElevenLabs account (sign up at [elevenlabs.io](https://elevenlabs.io))
2. An API key from ElevenLabs

## Setup Instructions

### 1. Get Your ElevenLabs API Key

1. Go to [elevenlabs.io](https://elevenlabs.io) and create an account
2. Navigate to your profile settings
3. Copy your API key

### 2. Configure the API Key

1. Open `lib/services/elevenlabs_service.dart`
2. Replace `'YOUR_ELEVENLABS_API_KEY'` with your actual API key:

```dart
static const String _apiKey = 'your-actual-api-key-here';
```

### 3. Install Dependencies

Run the following command to install the required dependencies:

```bash
flutter pub get
```

### 4. Platform-Specific Setup

#### Android
Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS
Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for voice input.</string>
```

### 5. Test the Integration

1. Run the app: `flutter run`
2. Navigate to the Ollie bot screen
3. Tap the settings icon in the top-right corner
4. Configure TTS settings and test the voice

## Features

### Main Ollie Screen
- Welcome message with TTS on app launch
- TTS status indicator showing when Ollie is speaking
- Settings button to configure TTS options

### Chat Screen
- Automatic TTS for bot responses
- TTS toggle button in the app bar
- Visual indicator when TTS is playing
- Stop button to interrupt TTS playback

### TTS Settings Screen
- Enable/disable TTS functionality
- Voice selection from available ElevenLabs voices
- Test voice button to preview selected voice
- Setup instructions for API key configuration

## Available Voices

The app uses ElevenLabs' default voices. You can:
- Use the default Rachel voice (ID: `21m00Tcm4TlvDq8ikWAM`)
- Select from other available voices in the settings
- Create custom voices in your ElevenLabs dashboard

## Troubleshooting

### Common Issues

1. **"Failed to load voices" error**
   - Check your API key is correct
   - Ensure you have an active ElevenLabs subscription
   - Verify internet connectivity

2. **Audio not playing**
   - Check device volume
   - Ensure audio permissions are granted
   - Verify the audio file was generated successfully

3. **API rate limits**
   - ElevenLabs has rate limits based on your subscription
   - Check your usage in the ElevenLabs dashboard

### Debug Information

Enable debug logging by checking the console output for:
- TTS API responses
- Audio file generation status
- Error messages

## Security Notes

- Never commit your API key to version control
- Consider using environment variables for production
- Monitor your API usage to avoid unexpected charges

## Support

For ElevenLabs API issues, refer to their [documentation](https://docs.elevenlabs.io/).
For app-specific issues, check the Flutter console for error messages. 