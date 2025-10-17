import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  static const String _apiKey = 'sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd';
  // sk_17ea44ebc250eed72a654a1a7f167bec8ecb9b3132dc5466'; // Replace with your actual API key

  AudioPlayer? _audioPlayer;

  // Get available voices
  Future<List<Map<String, dynamic>>> getVoices() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/voices'), headers: {'xi-api-key': _apiKey, 'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['voices']);
      } else {
        throw Exception('Failed to load voices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting voices: $e');
    }
  }

  // Convert text to speech
  Future<String?> textToSpeech({
    required String text,
    String voiceId = '21m00Tcm4TlvDq8ikWAM', // Default voice ID (Rachel)
    double stability = 0.5,
    double similarityBoost = 0.5,
  }) async {
    try {
      // Check if API key is configured
      if (_apiKey == 'sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd') {
        print('Warning: ElevenLabs API key not configured. Using mock response.');
        return null;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/text-to-speech/$voiceId'),
        headers: {'xi-api-key': _apiKey, 'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {'stability': stability, 'similarity_boost': similarityBoost},
        }),
      );

      if (response.statusCode == 200) {
        // Save audio to temporary file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/tts_audio.mp3');
        await tempFile.writeAsBytes(response.bodyBytes);
        return tempFile.path;
      } else {
        print('TTS Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('TTS Error: $e');
      return null;
    }
  }

  // Play audio file
  Future<void> playAudio(String audioPath) async {
    try {
      // Initialize audio player only when needed
      _audioPlayer ??= AudioPlayer();

      await _audioPlayer!.play(DeviceFileSource(audioPath));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  // Stop audio playback
  Future<void> stopAudio() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
      }
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  // Check if audio is playing
  bool get isPlaying {
    if (_audioPlayer != null) {
      return _audioPlayer!.state == PlayerState.playing;
    }
    return false;
  }

  // Listen to audio completion
  Stream<void> get onPlayerComplete {
    if (_audioPlayer != null) {
      return _audioPlayer!.onPlayerComplete;
    }
    return Stream.empty();
  }

  // Dispose resources
  void dispose() {
    try {
      _audioPlayer?.dispose();
      _audioPlayer = null;
    } catch (e) {
      print('Error disposing AudioPlayer: $e');
    }
  }
}
