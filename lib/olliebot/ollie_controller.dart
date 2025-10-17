import 'package:get/get.dart';
import 'package:ollie/services/elevenlabs_service.dart';

class OllieController extends GetxController {
  var isChatVisible = false.obs;
  var isPlayingTTS = false.obs;

  // ElevenLabs service
  final ElevenLabsService _elevenLabsService = ElevenLabsService();

  // TTS settings
  var enableTTS = true.obs;
  var selectedVoiceId = '21m00Tcm4TlvDq8ikWAM'.obs; // Default voice (Rachel)

  @override
  void onInit() {
    super.onInit();
    _initializeElevenLabs();
  }

  void _initializeElevenLabs() async {
    try {
      // Initialize ElevenLabs service
      print('ElevenLabs TTS initialized');
    } catch (e) {
      print('Error initializing ElevenLabs: $e');
    }
  }

  void toggleChatVisibility() {
    isChatVisible.value = !isChatVisible.value;
  }

  void setChatText(String text) {
    chatText.value = text;
  }

  var chatText = ''.obs;

  // TTS Methods
  Future<void> speakWelcomeMessage() async {
    if (!enableTTS.value) return;

    try {
      isPlayingTTS.value = true;

      final welcomeText = "Hello! I'm Ollie, your companion. I'm here to help you. What can I do for you today?";

      final audioPath = await _elevenLabsService.textToSpeech(text: welcomeText, voiceId: selectedVoiceId.value);

      if (audioPath != null) {
        await _elevenLabsService.playAudio(audioPath);

        _elevenLabsService.onPlayerComplete.listen((_) {
          isPlayingTTS.value = false;
        });
      } else {
        // TTS not available, just show text
        print('TTS not available, showing text only');
        isPlayingTTS.value = false;
      }
    } catch (e) {
      print('Error playing welcome message: $e');
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
