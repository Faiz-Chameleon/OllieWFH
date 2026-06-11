// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';

void main() async {
  const String apiKey = 'sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd';
  const String agentId = 'agent_01jx7s6f6afgea3c44dz0r4r68';

  print('🧪 Testing ElevenLabs WebSocket Connection');
  print('==========================================');
  print('🔑 API Key: ${apiKey.substring(0, 10)}...');
  print('🤖 Agent ID: $agentId\n');

  try {
    print('🔌 Connecting to ElevenLabs WebSocket...');

    final uri = Uri.parse('wss://api.elevenlabs.io/v1/convai/conversation?agent_id=$agentId&xi-api-key=$apiKey');
    final ws = await WebSocket.connect(uri.toString());

    print('✅ WebSocket connected successfully!');

    // Send conversation initiation
    final initData = {
      'type': 'conversation_initiation_client_data',
      'conversation_config_override': {
        'agent': {
          'prompt': {'prompt': "You are a helpful assistant. Keep responses short and friendly."},
          'first_message': "Hello! How can I help you today?",
          'language': 'en',
        },
        'tts': {'voice_id': '21m00Tcm4TlvDq8ikWAM'},
      },
      'custom_llm_extra_body': {'temperature': 0.7, 'max_tokens': 100},
      'dynamic_variables': {'user_name': 'User', 'account_type': 'standard'},
    };

    print('📤 Sending conversation initiation...');
    ws.add(jsonEncode(initData));

    bool conversationStarted = false;
    bool messageSent = false;

    // Listen for messages
    ws.listen(
      (data) {
        print('📨 Received: $data');

        try {
          final message = jsonDecode(data);
          final type = message['type'];

          if (type == 'conversation_initiation_metadata') {
            conversationStarted = true;
            print('✅ Conversation started!');

            // Send a simple test message
            if (!messageSent) {
              messageSent = true;
              final testMessage = {'type': 'user_message', 'text': 'Hi'};
              print('📤 Sending test message: "Hi"');
              ws.add(jsonEncode(testMessage));
            }
          } else if (type == 'agent_response') {
            final response = message['agent_response_event']['agent_response'];
            print('🤖 Agent response: $response');
          } else if (type == 'user_transcript') {
            final transcript = message['user_transcription_event']['user_transcript'];
            print('📝 User transcript: $transcript');
          } else if (type == 'internal_tentative_agent_response') {
            final tentativeResponse = message['tentative_agent_response_internal_event']['tentative_agent_response'];
            print('🤔 Tentative response: $tentativeResponse');
          } else {
            print('📋 Other message type: $type');
          }
        } catch (e) {
          print('❌ Error parsing message: $e');
        }
      },
      onError: (error) {
        print('❌ WebSocket error: $error');
      },
      onDone: () {
        print('🔌 WebSocket connection closed');
      },
    );

    // Wait for responses
    print('⏳ Waiting for responses...');
    await Future.delayed(Duration(seconds: 20));

    if (!conversationStarted) {
      print('❌ Conversation never started');
    } else if (!messageSent) {
      print('❌ Message never sent');
    } else {
      print('✅ Test completed');
    }

    ws.close();
  } catch (e) {
    print('❌ Error: $e');
  }

  print('\n🎉 Test completed!');
}
