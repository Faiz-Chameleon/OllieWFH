import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/services/chatbot_service.dart';
import 'package:ollie/services/elevenlabs_conversational_service.dart';
import 'package:ollie/services/elevenlabs_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async'; // Added for Timer

// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isStreaming;
  ChatMessage({required this.text, required this.isUser, this.isStreaming = false});
}

// Conversational AI chat controller
class ConversationalChatController extends GetxController {
  var messages = <ChatMessage>[ChatMessage(text: "Hi! I'm Ollie, your helpful companion. How can I assist you today?", isUser: false)].obs;

  var currentMessage = ''.obs;
  var isConnected = false.obs;
  var isListening = false.obs;
  var isStreaming = false.obs;
  var currentTranscript = ''.obs;
  var connectionStatus = 'Initializing...'.obs;

  final ElevenLabsConversationalService _conversationalService = ElevenLabsConversationalService();
  final ChatbotService _chatbotService = ChatbotService();
  ElevenLabsService? _elevenLabsService;
  final stt.SpeechToText speech = stt.SpeechToText();

  // Configuration
  var agentId = 'agent_01jx7s6f6afgea3c44dz0r4r68'.obs; // Replace with your agent ID
  var voiceId = '21m00Tcm4TlvDq8ikWAM'.obs;
  var enableVoiceInput = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeConversationalAI();
  }

  Future<void> _initializeConversationalAI() async {
    try {
      connectionStatus.value = 'Initializing Ollie AI...';
      print('🔌 Initializing Conversational AI...');

      // For free tier, use basic TTS instead of Conversational AI
      print('ℹ️ Using basic TTS mode (free tier limitation)');
      connectionStatus.value = 'Connected to Ollie AI (Basic Mode)';
      isConnected.value = true;

      // Set up basic TTS service
      _elevenLabsService = ElevenLabsService();

      print('✅ Basic TTS mode initialized successfully');
    } catch (e) {
      print('❌ Error initializing: $e');
      isConnected.value = false;
      connectionStatus.value = 'Connection failed - Using fallback mode';
    }
  }

  void _handleAgentResponse(String response) {
    // Remove any existing streaming message
    if (messages.isNotEmpty && messages.last.isStreaming) {
      messages.removeLast();
    }

    // Add the complete response
    messages.add(ChatMessage(text: response, isUser: false));
    isStreaming.value = false;
  }

  void toggleMic() async {
    if (isListening.value) {
      speech.stop();
      isListening.value = false;
      currentTranscript.value = '';
    } else {
      bool available = await speech.initialize();
      if (available) {
        isListening.value = true;
        speech.listen(
          onResult: (result) {
            currentMessage.value = result.recognizedWords;
            print('Speech recognition: ${result.recognizedWords}');
            if (result.finalResult) {
              sendMessage();
            }
          },
        );
      } else {
        print('Speech recognition not available');
        isListening.value = false;
      }
    }
  }

  void sendMessage() async {
    final message = currentMessage.value.trim();
    if (message.isEmpty) return;

    print('📤 Sending message: "$message"');
    print('🔗 Connection status: ${isConnected.value}');

    // Add user message
    messages.add(ChatMessage(text: message, isUser: true));
    currentMessage.value = '';

    // Add streaming indicator
    messages.add(ChatMessage(text: '...', isUser: false, isStreaming: true));
    isStreaming.value = true;

    try {
      if (isConnected.value) {
        print('✅ Connected - using basic TTS mode');

        // Get response from chatbot service
        final response = await ChatbotService.getHybridResponse(message);

        // Remove streaming indicator
        if (messages.isNotEmpty && messages.last.isStreaming) {
          messages.removeLast();
        }

        // Add the response
        messages.add(ChatMessage(text: response, isUser: false));
        isStreaming.value = false;

        // Play TTS if available
        if (_elevenLabsService != null) {
          try {
            final audioPath = await _elevenLabsService!.textToSpeech(text: response);
            if (audioPath != null) {
              await _elevenLabsService!.playAudio(audioPath);
            }
          } catch (e) {
            print('TTS Error: $e');
          }
        }
      } else {
        print('❌ Not connected - using fallback response');
        // Fallback to simple response
        await Future.delayed(Duration(seconds: 1));
        if (messages.isNotEmpty && messages.last.isStreaming) {
          messages.removeLast();
        }
        messages.add(ChatMessage(text: "I'm sorry, I'm having trouble connecting right now. Please try again later.", isUser: false));
        isStreaming.value = false;
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      // Remove streaming indicator and add error message
      if (messages.isNotEmpty && messages.last.isStreaming) {
        messages.removeLast();
      }
      messages.add(ChatMessage(text: "Sorry, I encountered an error. Please try again.", isUser: false));
      isStreaming.value = false;
    }
  }

  void sendContextualUpdate(String context) async {
    if (isConnected.value) {
      await _conversationalService.sendContextualUpdate(context);
    }
  }

  void stopAudio() async {
    await _conversationalService.stopAudio();
  }

  void setAgentId(String newAgentId) {
    agentId.value = newAgentId;
    // Reinitialize with new agent
    _initializeConversationalAI();
  }

  void setVoiceId(String newVoiceId) {
    voiceId.value = newVoiceId;
    // Reinitialize with new voice
    _initializeConversationalAI();
  }

  @override
  void onClose() {
    _conversationalService.dispose();
    super.onClose();
  }
}
