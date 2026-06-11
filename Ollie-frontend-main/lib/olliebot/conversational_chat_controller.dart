// ignore_for_file: unused_field, unused_import

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/services/chatbot_service.dart';
import 'package:ollie/services/elevenlabs_conversational_service.dart';
import 'package:ollie/services/elevenlabs_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:http/http.dart' as http;

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
  var pendingToolCall = Rx<Map<String, dynamic>?>(null);
  var isProcessingTool = false.obs;

  final ElevenLabsConversationalService _conversationalService = ElevenLabsConversationalService();
  final ChatbotService _chatbotService = ChatbotService();
  ElevenLabsService? _elevenLabsService;
  final stt.SpeechToText speech = stt.SpeechToText();

  // Configuration
  var agentId = 'agent_8701k4dytec6e43ar0ms2v7ryn9e'.obs;
  var voiceId = '21m00Tcm4TlvDq8ikWAM'.obs;
  var enableVoiceInput = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeConversationalAI();
  }

  Future<void> _initializeConversationalAI() async {
    try {
      connectionStatus.value = 'Connecting to ElevenLabs Conversational AI...';
      debugPrint('🔌 Initializing ElevenLabs Conversational AI...');
      debugPrint('🔑 Agent ID: ${agentId.value}');

      await _conversationalService.initialize(
        agentId: agentId.value,
        voiceId: voiceId.value,
        customPrompt: "You are Ollie, a friendly and helpful AI assistant. Keep responses conversational and helpful.",
        firstMessage: "Hi! I'm Ollie, your AI assistant. How can I help you today?",
        language: 'en',
      );

      _setupServiceListeners();
      debugPrint('🚀 Conversational AI initialization started...');
    } catch (e) {
      debugPrint('❌ Error initializing Conversational AI: $e');
      isConnected.value = false;
      connectionStatus.value = 'Failed to connect to Conversational AI';
    }
  }

  void _setupServiceListeners() {
    _conversationalService.connectionStream.listen((connected) {
      isConnected.value = connected;
      if (connected) {
        connectionStatus.value = 'Connected to ElevenLabs Conversational AI ✅';
        debugPrint('✅ Conversational AI is ready!');
      } else {
        connectionStatus.value = 'Disconnected from Conversational AI';
        debugPrint('❌ Conversational AI disconnected');
      }
    });

    _conversationalService.responseStream.listen((response) {
      debugPrint('🤖 AI Response: $response');
      _handleAgentMessage(response);
    });

    _conversationalService.toolCallStream.listen((toolCall) {
      debugPrint('🔧 Tool call: $toolCall');
      handleToolCall(toolCall);
    });

    _conversationalService.transcriptStream.listen((transcript) {
      if (!transcript.toLowerCase().contains('error')) {
        debugPrint('🎤 User said: $transcript');
        currentTranscript.value = transcript;
      } else {
        debugPrint('❌ Transcript error: $transcript');
      }
    });
  }

  void _handleAgentMessage(String message) {
    // Remove streaming indicator
    if (messages.isNotEmpty && messages.last.isStreaming) {
      messages.removeLast();
    }

    // Add the response
    messages.add(ChatMessage(text: message, isUser: false));
    isStreaming.value = false;
  }

  void _handleError(String error) {
    debugPrint('❌ Error: $error');
    if (messages.isNotEmpty && messages.last.isStreaming) {
      messages.removeLast();
    }
    messages.add(ChatMessage(text: "I encountered an error: $error", isUser: false));
    isStreaming.value = false;
  }

  void sendMessage() async {
    final message = currentMessage.value.trim();
    if (message.isEmpty) return;

    messages.add(ChatMessage(text: message, isUser: true));

    messages.add(ChatMessage(text: '...', isUser: false, isStreaming: true));
    isStreaming.value = true;

    try {
      if (isConnected.value) {
        debugPrint('📤 Sending to Conversational AI: "$message"');
        await _conversationalService.sendTextMessage(message);

        // Extend timeout to 30 seconds for ElevenLabs
        Timer(Duration(seconds: 30), () {
          if (isStreaming.value) {
            debugPrint('⚠️ AI response timeout after 30 seconds');
            _handleTimeout();
          }
        });
      } else {
        debugPrint('❌ Not connected to Conversational AI');
        _handleNotConnected();
      }
    } catch (e) {
      debugPrint('❌ Error sending to Conversational AI: $e');
      _handleError('Failed to send message: $e');
    }
  }

  void _handleTimeout() {
    if (messages.isNotEmpty && messages.last.isStreaming) {
      messages.removeLast();
    }
    messages.add(ChatMessage(text: "I'm taking longer than usual to respond. Please try again.", isUser: false));
    isStreaming.value = false;
  }

  void _handleNotConnected() {
    if (messages.isNotEmpty && messages.last.isStreaming) {
      messages.removeLast();
    }
    messages.add(ChatMessage(text: "I'm not connected to the AI service right now. Please wait a moment and try again.", isUser: false));
    isStreaming.value = false;
  }

  void handleToolCall(Map<String, dynamic> toolCall) {
    final toolName = toolCall['name'];
    final parameters = toolCall['parameters'] ?? {};
    final toolCallId = toolCall['id'];

    debugPrint('🔧 AI wants to use tool: $toolName');

    _conversationalService.sendToolResponse(
      toolCallId: toolCallId,
      result: {'status': 'acknowledged', 'message': 'Tool call received but not implemented yet', 'tool': toolName, 'parameters': parameters},
      success: true,
    );
  }

  void toggleMic() async {
    if (isListening.value) {
      speech.stop();
      isListening.value = false;
      currentTranscript.value = '';
    } else {
      bool available = await speech.initialize();
      if (available && isConnected.value) {
        isListening.value = true;
        speech.listen(
          onResult: (result) {
            currentTranscript.value = result.recognizedWords;
            if (result.finalResult) {
              currentMessage.value = result.recognizedWords;
              sendMessage();
            }
          },
          localeId: 'en_US',
          listenOptions: stt.SpeechListenOptions(listenMode: stt.ListenMode.confirmation),
        );
      } else if (!isConnected.value) {
        debugPrint('❌ Voice requires Conversational AI connection');
        Get.snackbar('Voice Not Available', 'Please wait for AI to connect', snackPosition: SnackPosition.BOTTOM);
      } else {
        debugPrint('❌ Speech recognition not available');
        isListening.value = false;
      }
    }
  }

  void testConnection() async {
    debugPrint('🧪 Testing Conversational AI connection...');
    connectionStatus.value = 'Testing connection...';

    try {
      // Don't await dispose() since it returns void
      _conversationalService.dispose();

      // Add a small delay to ensure cleanup is complete
      await Future.delayed(Duration(milliseconds: 500));

      await _initializeConversationalAI();
      debugPrint('✅ Connection test completed');
    } catch (e) {
      debugPrint('❌ Connection test failed: $e');
      connectionStatus.value = 'Connection test failed';
    }
  }

  void stopAudio() async {
    await _conversationalService.stopAudio();
  }

  void setAgentId(String newAgentId) {
    agentId.value = newAgentId;
    _initializeConversationalAI();
  }

  void setVoiceId(String newVoiceId) {
    voiceId.value = newVoiceId;
    _initializeConversationalAI();
  }

  // Add this method to test with a simple message:

  void sendTestMessage() async {
    if (!isConnected.value) {
      debugPrint('❌ Not connected for test');
      return;
    }

    debugPrint('🧪 Sending test message...');

    try {
      await _conversationalService.sendTextMessage("Hello");

      // Wait 10 seconds for response
      await Future.delayed(Duration(seconds: 10));

      if (isStreaming.value) {
        debugPrint('⚠️ Test message timeout');
      }
    } catch (e) {
      debugPrint('❌ Test message error: $e');
    }
  }

  // Add this method to test direct connection:

  void sendSimpleTest() async {
    if (!isConnected.value) {
      debugPrint('❌ Not connected for simple test');
      return;
    }

    debugPrint('🧪 Sending simple test message...');

    // Add test message to UI
    messages.add(ChatMessage(text: "Hello", isUser: true));
    messages.add(ChatMessage(text: '...', isUser: false, isStreaming: true));
    isStreaming.value = true;

    try {
      await _conversationalService.sendTextMessage("Hello");

      // Wait for response
      Timer(Duration(seconds: 10), () {
        if (isStreaming.value) {
          debugPrint('⚠️ Simple test timeout');
          _handleTimeout();
        }
      });
    } catch (e) {
      debugPrint('❌ Simple test error: $e');
      _handleError('Simple test failed: $e');
    }
  }

  void debugAgent() async {
    debugPrint('🔍 Debug Agent Info:');
    debugPrint('Agent ID: ${agentId.value}');
    debugPrint('Voice ID: ${voiceId.value}');
    debugPrint('Connected: ${isConnected.value}');
    debugPrint('Conversation ID: ${_conversationalService.conversationId}');

    // Test if the agent exists by making a simple HTTP request
    try {
      final response = await http.get(
        Uri.parse('https://api.elevenlabs.io/v1/convai/agents/${agentId.value}'),
        headers: {
          'Authorization': 'Bearer sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd', // Fixed: Uncommented and added Bearer
          'Content-Type': 'application/json',
        },
      );

      debugPrint('🔍 Agent API Response: ${response.statusCode}');
      debugPrint('🔍 Agent Details: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Agent exists and is configured correctly!');
      } else if (response.statusCode == 404) {
        debugPrint('❌ Agent not found - check your agent ID');
      } else if (response.statusCode == 401) {
        debugPrint('❌ API key is invalid or expired');
      } else {
        debugPrint('❌ Unexpected response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error checking agent: $e');
    }
  }

  @override
  void onClose() {
    _conversationalService.dispose();
    _conversationalService.endConversation(
      notifyText: 'User has left the chat.', // optional
    );
    try {
      speech.stop();
    } catch (_) {}
    super.onClose();
  }
}
