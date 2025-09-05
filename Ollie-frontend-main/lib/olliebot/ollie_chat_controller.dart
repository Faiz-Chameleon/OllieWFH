import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ollie/services/elevenlabs_service.dart';
import 'package:ollie/services/chatbot_service.dart';

// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// Chat controller with voice input and TTS logic
class OllieChatController extends GetxController {
  var messages = <ChatMessage>[
    ChatMessage(text: "Hi Ollie, can you tell me the tasks i have for the day?", isUser: true),
    ChatMessage(text: "I'm Ollie, your helping hand. Let's set things up just for you!", isUser: false),
    ChatMessage(text: "I'm Ollie, your helping hand. Let's set things up just for you!", isUser: true),
    ChatMessage(text: "...", isUser: false),
  ].obs;

  var currentMessage = ''.obs;
  late stt.SpeechToText speech;
  var isListening = false.obs;
  var isPlayingTTS = false.obs;

  // ElevenLabs service
  final ElevenLabsService _elevenLabsService = ElevenLabsService();

  // TTS settings
  var enableTTS = true.obs;
  var selectedVoiceId = '21m00Tcm4TlvDq8ikWAM'.obs; // Default voice (Rachel)

  @override
  void onInit() {
    super.onInit();
    speech = stt.SpeechToText();
    _initializeElevenLabs();
  }

  void _initializeElevenLabs() async {
    try {
      // You can load available voices here if needed
      final voices = await _elevenLabsService.getVoices();
      // print('Available voices: ${voices.length}');
    } catch (e) {
      print('Error initializing ElevenLabs: $e');
    }
  }

  void toggleMic() async {
    if (isListening.value) {
      speech.stop();
      isListening.value = false;
    } else {
      bool available = await speech.initialize();
      if (available) {
        isListening.value = true;
        speech.listen(
          onResult: (result) {
            currentMessage.value = result.recognizedWords;
          },
        );
      }
    }
  }

  void sendMessage() async {
    if (currentMessage.value.trim().isNotEmpty) {
      messages.add(ChatMessage(text: currentMessage.value.trim(), isUser: true));
      currentMessage.value = '';

      // Get bot response from chatbot service
      final userMessage = currentMessage.value.trim();
      final botResponse = await ChatbotService.getHybridResponse(userMessage);
      messages.add(ChatMessage(text: botResponse, isUser: false));

      // Play TTS for bot response
      if (enableTTS.value) {
        await _playBotResponse(botResponse);
      }
    }
  }

  Future<void> _playBotResponse(String text) async {
    try {
      isPlayingTTS.value = true;

      // Convert text to speech
      final audioPath = await _elevenLabsService.textToSpeech(text: text, voiceId: selectedVoiceId.value);

      if (audioPath != null) {
        // Play the audio
        await _elevenLabsService.playAudio(audioPath);

        // Listen for audio completion
        _elevenLabsService.onPlayerComplete.listen((_) {
          isPlayingTTS.value = false;
        });
      } else {
        // TTS not available, just show text
        print('TTS not available, showing text only');
        isPlayingTTS.value = false;
      }
    } catch (e) {
      print('Error playing TTS: $e');
      isPlayingTTS.value = false;
    }
  }

  void toggleTTS() {
    enableTTS.value = !enableTTS.value;
  }

  void setVoice(String voiceId) {
    selectedVoiceId.value = voiceId;
  }

  void stopTTS() async {
    await _elevenLabsService.stopAudio();
    isPlayingTTS.value = false;
  }

  @override
  void onClose() {
    _elevenLabsService.dispose();
    super.onClose();
  }
}
