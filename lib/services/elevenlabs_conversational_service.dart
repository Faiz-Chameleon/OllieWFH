// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ElevenLabsConversationalService {
  static const String _baseUrl =
      // "wss://api.elevenlabs.io/v1/conversational-ai/conversation";
      'wss://api.elevenlabs.io/v1/convai/conversation';

  WebSocketChannel? _channel;
  AudioPlayer? _audioPlayer;
  StreamController<String>? _transcriptController;
  StreamController<String>? _responseController;
  StreamController<Uint8List>? _audioController;
  StreamController<bool>? _connectionController;
  StreamController<Map<String, dynamic>>? _toolCallController; // Add this line
  bool _isConnected = false;
  String? _conversationId;
  Timer? _pingTimer;
  bool _isDisposing = false;

  // Streams for UI updates
  Stream<String> get transcriptStream => _transcriptController?.stream ?? Stream.empty();
  Stream<String> get responseStream => _responseController?.stream ?? Stream.empty();
  Stream<Uint8List> get audioStream => _audioController?.stream ?? Stream.empty();
  Stream<bool> get connectionStream => _connectionController?.stream ?? Stream.empty();
  Stream<Map<String, dynamic>> get toolCallStream => // Add this getter
      _toolCallController?.stream ?? Stream.empty();

  void _emitConnectionState(bool value) => _safeAdd<bool>(_connectionController, value);
  void _emitTranscript(String value) => _safeAdd<String>(_transcriptController, value);
  void _emitResponse(String value) => _safeAdd<String>(_responseController, value);
  void _emitAudio(Uint8List value) => _safeAdd<Uint8List>(_audioController, value);
  void _emitToolCall(Map<String, dynamic> value) => _safeAdd<Map<String, dynamic>>(_toolCallController, value);

  void _safeAdd<T>(StreamController<T>? controller, T value) {
    final target = controller;
    if (target == null || target.isClosed) {
      dev.log('⚠️ Tried to emit on a closed controller', name: 'ElevenLabsConversationalService');
      return;
    }
    target.add(value);
  }

  // Initialize the service
  Future<void> initialize({
    required String agentId,
    String? customPrompt,
    String? firstMessage,
    String voiceId = '21m00Tcm4TlvDq8ikWAM',
    String language = 'en',
  }) async {
    try {
      final UserController? userController = Get.isRegistered<UserController>() ? Get.find<UserController>() : null;
      final userData = userController?.user.value;
      // Initialize controllers
      _transcriptController = StreamController<String>.broadcast();
      _responseController = StreamController<String>.broadcast();
      _audioController = StreamController<Uint8List>.broadcast();
      _connectionController = StreamController<bool>.broadcast();
      _toolCallController = StreamController<Map<String, dynamic>>.broadcast();

      _audioPlayer = AudioPlayer();

      // Connect to ElevenLabs Conversational AI WebSocket
      final uri = Uri.parse('$_baseUrl?agent_id=$agentId');
      print('🔌 Connecting to: $uri');

      _channel = WebSocketChannel.connect(uri);

      // FIXED: Use the correct initialization format
      final initMessage = {
        'type': 'conversation_initiation_client_data',
        'dynamic_variables': {
          'secret__auth_token': userData?.userToken ?? '',
          'user_name': userData?.firstName ?? 'User',
          'user_context': "text",
          'current_date_time': DateTime.now().toIso8601String(),
          'latitude': 90.01234,
          'longitude': -118.011,
        },
      };

      dev.log('📤 Sending init message: ${jsonEncode(initMessage)}');
      _channel!.sink.add(jsonEncode(initMessage));

      // Listen for responses
      _channel!.stream.listen(
        (data) {
          dev.log('📨 Received: $data');
          _handleWebSocketMessage(data);
        },
        onError: (error) {
          dev.log('❌ WebSocket Error: $error');
          _isConnected = false;
          _emitConnectionState(false);
        },
        onDone: () {
          dev.log('🔌 WebSocket connection closed');
          _isConnected = false;
          _emitConnectionState(false);
          _stopPingTimer();
        },
      );

      _startPingTimer();
      print('🚀 Conversational AI initialization sent');
    } catch (e) {
      print('❌ Error initializing Conversational AI: $e');
      _isConnected = false;
      _emitConnectionState(false);
      rethrow;
    }
  }

  // Update the _handleWebSocketMessage method:

  void _handleWebSocketMessage(dynamic data) {
    try {
      final message = json.decode(data);
      final type = message['type'];

      print('📨 Message type: $type');
      print('📨 Full message: ${json.encode(message)}'); // Debug: see full message

      switch (type) {
        case 'conversation_initiation_metadata':
          _isConnected = true;
          _conversationId = message['conversation_initiation_metadata_event']?['conversation_id'];
          _emitConnectionState(true);
          print('✅ Connected! Conversation ID: $_conversationId');
          break;

        case 'agent_response':
          final text = message['agent_response_event']?['agent_response'] ?? message['agent_response'];
          if (text != null && text.isNotEmpty) {
            _emitResponse(text);
            print('🤖 Agent response: $text');
          }
          break;

        case 'agent_response_event': // Handle this case specifically
          final text = message['agent_response_event']?['agent_response'];
          if (text != null && text.isNotEmpty) {
            _emitResponse(text);
            print('🤖 Agent response (event): $text');
          }
          break;

        case 'agent_response_audio_chunk':
          final audioData = message['audio_event']?['audio_base_64'];
          if (audioData != null) {
            try {
              final audioBytes = base64.decode(audioData);
              _emitAudio(audioBytes);
              _playAudioChunk(audioBytes);
            } catch (e) {
              print('❌ Error decoding audio: $e');
            }
          }
          break;

        case 'user_transcript':
          final transcript = message['user_transcript_event']?['user_transcript'] ?? message['user_transcript'];
          if (transcript != null) {
            _emitTranscript(transcript);
            print('🎤 User transcript: $transcript');
          }
          break;

        case 'function_call':
          final functionCall = message['function_call'];
          final toolCall = {
            'name': functionCall['name'],
            'parameters': functionCall['arguments'] ?? {},
            'id': message['call_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          };
          _emitToolCall(toolCall);
          break;

        case 'ping':
          _sendPong(message['event_id'] ?? message['ping_event']?['event_id'] ?? 0);
          break;

        case 'error':
          final error = message['error']?['message'] ?? message['message'] ?? 'Unknown error';
          print('❌ Server error: $error');
          _emitTranscript('Error: $error');
          break;

        default:
          print('🔍 Unknown message type: $type');
          print('📋 Full message: ${json.encode(message)}');

          // Try to extract any agent response from unknown message types
          final possibleResponses = [
            message['agent_response_event']?['agent_response'],
            message['agent_response'],
            message['response'],
            message['text'],
          ];

          for (final response in possibleResponses) {
            if (response != null && response is String && response.isNotEmpty) {
              _emitResponse(response);
              print('🤖 Found response: $response');
              return;
            }
          }
      }
    } catch (e) {
      print('❌ Error handling WebSocket message: $e');
      print('📋 Raw data: $data');
      _emitTranscript('Error processing message: $e');
    }
  }

  // Send tool response back to ElevenLabs
  Future<void> sendToolResponse({required String toolCallId, required Map<String, dynamic> result, bool success = true}) async {
    if (!_isConnected) return;

    try {
      final message = {
        'type': 'function_call_response',
        'call_id': toolCallId,
        'response': success ? result : {'error': result['error'] ?? 'Tool execution failed'},
      };

      _channel!.sink.add(json.encode(message));
      print('🔧 Tool response sent: ${json.encode(message)}');
    } catch (e) {
      print('❌ Error sending tool response: $e');
    }
  }

  // Send text message to the AI
  Future<void> sendTextMessage(String text) async {
    if (!_isConnected) {
      print('❌ Not connected, cannot send message');
      return;
    }

    try {
      // Use the correct format for ElevenLabs
      final message = {'type': 'user_message', 'text': text};

      _channel!.sink.add(jsonEncode(message));
      print('📤 Sent message: $text');
    } catch (e) {
      print('❌ Error sending message: $e');
      _emitConnectionState(false);
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _sendPing();
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _sendPing() {
    if (_isConnected && _channel != null) {
      try {
        final pingMessage = {'type': 'ping', 'event_id': DateTime.now().millisecondsSinceEpoch};
        _channel!.sink.add(jsonEncode(pingMessage));
      } catch (e) {
        print('❌ Error sending ping: $e');
      }
    }
  }

  void _sendPong(int eventId) {
    if (!_isConnected) return;
    try {
      final message = {'type': 'pong', 'event_id': eventId};
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('❌ Error sending pong: $e');
    }
  }

  Future<void> _playAudioChunk(Uint8List audioData) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/audio_chunk_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(audioData);
      await _audioPlayer?.play(DeviceFileSource(tempFile.path));
    } catch (e) {
      print('❌ Error playing audio: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer?.stop();
    } catch (e) {
      print('❌ Error stopping audio: $e');
    }
  }

  bool get isConnected => _isConnected;
  String? get conversationId => _conversationId;

  // Update the dispose method to return Future<void>:
  Future<void> dispose() async {
    if (_isDisposing) return;
    _isDisposing = true;

    try {
      _stopPingTimer();
      await _channel?.sink.close();
      await _audioPlayer?.dispose();
      await _transcriptController?.close();
      await _responseController?.close();
      await _audioController?.close();
      await _connectionController?.close();
      await _toolCallController?.close();
      _isConnected = false;
      _channel = null;
      _audioPlayer = null;
      _transcriptController = null;
      _responseController = null;
      _audioController = null;
      _connectionController = null;
      _toolCallController = null;
      _conversationId = null;
    } catch (e) {
      print('❌ Error disposing service: $e');
    } finally {
      _isDisposing = false;
    }
  }

  /// Gracefully end the conversation and free resources.
  Future<void> endConversation({String? notifyText}) async {
    if (_isDisposing) return;

    // 1) Optionally notify the agent (not required)
    try {
      if (_isConnected && notifyText != null && notifyText.isNotEmpty) {
        _channel?.sink.add(jsonEncode({'type': 'user_message', 'text': notifyText}));
      }
    } catch (_) {}

    // 2) Stop timers and audio first
    _stopPingTimer();
    try {
      await _audioPlayer?.stop();
    } catch (_) {}

    // 3) Close WS with normal-closure code (1000)
    try {
      await _channel?.sink.close(1000, 'user_left');
    } catch (_) {}

    // 4) Mark disconnected and close controllers
    _isConnected = false;
    try {
      await _transcriptController?.close();
    } catch (_) {}
    try {
      await _responseController?.close();
    } catch (_) {}
    try {
      await _audioController?.close();
    } catch (_) {}
    try {
      await _connectionController?.close();
    } catch (_) {}
    try {
      await _toolCallController?.close();
    } catch (_) {}

    _channel = null;
    _audioPlayer = null;
    _transcriptController = null;
    _responseController = null;
    _audioController = null;
    _connectionController = null;
    _toolCallController = null;
    _conversationId = null;
  }
}
