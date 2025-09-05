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
  var pendingToolCall = Rx<Map<String, dynamic>?>(null);
  var isProcessingTool = false.obs;

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
      print('🔌 Initializing with Agent ID: ${agentId.value}');
      print('🔑 Using API Key: ${"sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd".substring(0, 10)}...');
      await _conversationalService.initialize(
        agentId: agentId.value,
        voiceId: voiceId.value,
        customPrompt:
            "You are Ollie, a friendly and helpful assistant who helps users stay organized and manage their tasks. Keep responses concise and friendly.",
        firstMessage: "Hi! I'm Ollie, your helpful companion. How can I assist you today?",

        language: 'en',
      );
      _setupServiceListeners();

      print('✅ Basic TTS mode initialized successfully');
    } catch (e) {
      print('❌ Error initializing: $e');
      isConnected.value = false;
      connectionStatus.value = 'Connection failed - Using fallback mode';
    }
  }

  void _setupServiceListeners() {
    // Listen to response stream
    _conversationalService.responseStream.listen((response) {
      _handleAgentMessage(response);
    });

    // Listen to connection status
    _conversationalService.connectionStream.listen((connected) {
      isConnected.value = connected;
      connectionStatus.value = connected ? 'Connected' : 'Disconnected';
      if (connected) {
        print('✅ Connected to ElevenLabs Conversational AI');
      }
    });

    // Listen to transcript/errors
    _conversationalService.transcriptStream.listen((message) {
      print('Transcript/Error: $message');
      // Handle errors or transcripts
      if (message.toLowerCase().contains('error')) {
        _handleError(message);
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
    print('❌ Error: $error');
    if (messages.isNotEmpty && messages.last.isStreaming) {
      messages.removeLast();
    }
    messages.add(ChatMessage(text: "I encountered an error: $error", isUser: false));
    isStreaming.value = false;
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

  void handleToolCall(Map<String, dynamic> toolCall) {
    final toolName = toolCall['name'];
    final parameters = toolCall['parameters'] ?? {};

    if (toolName == 'create_task') {
      _handleCreateTaskTool(toolCall);
    } else {
      print('⚠️ Unknown tool: $toolName');
      // Send error response
      _sendToolResponse(toolCallId: toolCall['id'], output: {'status': 'error', 'message': 'Unknown tool'});
    }
  }

  void _sendToolResponse({required String toolCallId, required Map<String, dynamic> output}) {
    // You'll need to implement this method to send responses back
    // This depends on how your service handles tool responses
    print('Sending tool response: $output');
  }

  void confirmTaskCreation(bool confirm) async {
    if (pendingToolCall.value == null) return;

    final toolCallId = pendingToolCall.value!['tool_call_id'];
    final parameters = pendingToolCall.value!['parameters'];

    if (confirm) {
      // try {
      //   final taskId = await _createActualTask(parameters);

      //   _sendToolResponse(toolCallId: toolCallId, output: {'status': 'success', 'task_id': taskId, 'message': 'Task created successfully'});

      //   messages.add(ChatMessage(text: '✅ Task created successfully! (ID: $taskId)', isUser: false));
      // } catch (e) {
      //   _sendToolResponse(toolCallId: toolCallId, output: {'status': 'error', 'message': 'Failed to create task: $e'});

      //   messages.add(ChatMessage(text: '❌ Failed to create task: $e', isUser: false));
      // }
    } else {
      _sendToolResponse(toolCallId: toolCallId, output: {'status': 'cancelled', 'message': 'User cancelled task creation'});

      messages.add(ChatMessage(text: '❌ Task creation cancelled', isUser: false));
    }

    pendingToolCall.value = null;
    isProcessingTool.value = false;
  }

  void _handleCreateTaskTool(Map<String, dynamic> toolCall) {
    final parameters = toolCall['parameters'] ?? {};
    final toolCallId = toolCall['id'];

    pendingToolCall.value = {'tool_call_id': toolCallId, 'parameters': parameters};

    final taskTitle = parameters['title'] ?? 'Untitled Task';
    final taskDescription = parameters['description'] ?? 'No description';
    final dueDate = parameters['due_date'] ?? 'No due date';

    final taskMessage =
        '''
📋 Task Created:
Title: $taskTitle
Description: $taskDescription
Due Date: $dueDate

Would you like to confirm creating this task?
''';

    if (messages.isNotEmpty && messages.last.isStreaming) {
      messages.removeLast();
    }

    messages.add(
      ChatMessage(
        text: taskMessage,
        isUser: false,
        // toolCall: {'type': 'create_task', 'parameters': parameters},
      ),
    );

    isStreaming.value = false;
    isProcessingTool.value = true;
  }

  void sendMessage() async {
    final message = currentMessage.value.trim();
    if (message.isEmpty) return;

    // Handle tool confirmation first
    if (isProcessingTool.value && pendingToolCall.value != null) {
      final lowerMessage = message.toLowerCase();
      if (lowerMessage.contains('yes') || lowerMessage.contains('confirm')) {
        confirmTaskCreation(true);
      } else if (lowerMessage.contains('no') || lowerMessage.contains('cancel')) {
        confirmTaskCreation(false);
      } else {
        messages.add(ChatMessage(text: "Please respond with 'yes' to confirm or 'no' to cancel the task creation.", isUser: false));
      }
      currentMessage.value = '';
      return;
    }

    // Add user message
    messages.add(ChatMessage(text: message, isUser: true));
    currentMessage.value = '';

    // Add streaming indicator
    messages.add(ChatMessage(text: '...', isUser: false, isStreaming: true));
    isStreaming.value = true;

    try {
      if (isConnected.value) {
        print('📤 Sending to ElevenLabs: "$message"');
        await _conversationalService.sendTextMessage(message);

        // Set timeout for response
        Timer(Duration(seconds: 15), () {
          if (isStreaming.value) {
            print('⚠️ No response received within 15 seconds');
            if (messages.isNotEmpty && messages.last.isStreaming) {
              messages.removeLast();
            }
            messages.add(ChatMessage(text: "I'm having trouble connecting. Please try again.", isUser: false));
            isStreaming.value = false;
          }
        });
      } else {
        print('❌ Not connected - using fallback');
        // Fallback to your existing static response
        final response = await ChatbotService.getHybridResponse(message);

        if (messages.isNotEmpty && messages.last.isStreaming) {
          messages.removeLast();
        }

        messages.add(ChatMessage(text: response, isUser: false));
        isStreaming.value = false;
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      if (messages.isNotEmpty && messages.last.isStreaming) {
        messages.removeLast();
      }
      messages.add(ChatMessage(text: "Sorry, I encountered an error. Please try again.", isUser: false));
      isStreaming.value = false;
    }
  }

  // void sendMessage() async {
  //   final message = currentMessage.value.trim();
  //   if (message.isEmpty) return;

  //   print('📤 Sending message: "$message"');
  //   print('🔗 Connection status: ${isConnected.value}');

  //   // Add user message
  //   messages.add(ChatMessage(text: message, isUser: true));
  //   currentMessage.value = '';

  //   // Add streaming indicator
  //   messages.add(ChatMessage(text: '...', isUser: false, isStreaming: true));
  //   isStreaming.value = true;

  //   try {
  //     if (isConnected.value) {
  //       print('✅ Connected - using ElevenLabs Conversational AI');

  //       // Send message to ElevenLabs Conversational AI
  //       await _conversationalService.sendTextMessage(message);

  //       // Note: The response will come back through the onMessage callback
  //       // We don't remove the streaming indicator here because we wait for the actual response
  //     } else {
  //       print('❌ Not connected to ElevenLabs - using fallback response');

  //       // Fallback to your existing static AI response
  //       final response = await ChatbotService.getHybridResponse(message);

  //       // Remove streaming indicator
  //       if (messages.isNotEmpty && messages.last.isStreaming) {
  //         messages.removeLast();
  //       }

  //       // Add the response
  //       messages.add(ChatMessage(text: response, isUser: false));
  //       isStreaming.value = false;

  //       // Play TTS if available
  //       if (_elevenLabsService != null) {
  //         try {
  //           final audioPath = await _elevenLabsService!.textToSpeech(text: response);
  //           if (audioPath != null) {
  //             await _elevenLabsService!.playAudio(audioPath);
  //           }
  //         } catch (e) {
  //           print('TTS Error: $e');
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('❌ Error sending message: $e');
  //     // Remove streaming indicator and add error message
  //     if (messages.isNotEmpty && messages.last.isStreaming) {
  //       messages.removeLast();
  //     }
  //     messages.add(ChatMessage(text: "Sorry, I encountered an error. Please try again.", isUser: false));
  //     isStreaming.value = false;
  //   }
  // }

  // void sendMessage() async {
  //   final message = currentMessage.value.trim();
  //   if (message.isEmpty) return;

  //   print('📤 Sending message: "$message"');
  //   print('🔗 Connection status: ${isConnected.value}');

  //   // Add user message
  //   messages.add(ChatMessage(text: message, isUser: true));
  //   currentMessage.value = '';

  //   // Add streaming indicator
  //   messages.add(ChatMessage(text: '...', isUser: false, isStreaming: true));
  //   isStreaming.value = true;

  //   try {
  //     if (isConnected.value) {
  //       print('✅ Connected - using basic TTS mode');

  //       // Get response from chatbot service
  //       final response = await ChatbotService.getHybridResponse(message);

  //       // Remove streaming indicator
  //       if (messages.isNotEmpty && messages.last.isStreaming) {
  //         messages.removeLast();
  //       }

  //       // Add the response
  //       messages.add(ChatMessage(text: response, isUser: false));
  //       isStreaming.value = false;

  //       // Play TTS if available
  //       if (_elevenLabsService != null) {
  //         try {
  //           final audioPath = await _elevenLabsService!.textToSpeech(text: response);
  //           if (audioPath != null) {
  //             await _elevenLabsService!.playAudio(audioPath);
  //           }
  //         } catch (e) {
  //           print('TTS Error: $e');
  //         }
  //       }
  //     } else {
  //       print('❌ Not connected - using fallback response');
  //       // Fallback to simple response
  //       await Future.delayed(Duration(seconds: 1));
  //       if (messages.isNotEmpty && messages.last.isStreaming) {
  //         messages.removeLast();
  //       }
  //       messages.add(ChatMessage(text: "I'm sorry, I'm having trouble connecting right now. Please try again later.", isUser: false));
  //       isStreaming.value = false;
  //     }
  //   } catch (e) {
  //     print('❌ Error sending message: $e');
  //     // Remove streaming indicator and add error message
  //     if (messages.isNotEmpty && messages.last.isStreaming) {
  //       messages.removeLast();
  //     }
  //     messages.add(ChatMessage(text: "Sorry, I encountered an error. Please try again.", isUser: false));
  //     isStreaming.value = false;
  //   }
  // }

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
