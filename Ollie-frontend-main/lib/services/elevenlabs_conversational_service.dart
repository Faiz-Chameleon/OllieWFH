import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ElevenLabsConversationalService {
  static const String _baseUrl = 'wss://api.elevenlabs.io/v1/convai/conversation';
  static const String _apiKey = 'sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd';

  WebSocketChannel? _channel;
  AudioPlayer? _audioPlayer;
  StreamController<String>? _transcriptController;
  StreamController<String>? _responseController;
  StreamController<Uint8List>? _audioController;
  StreamController<bool>? _connectionController;
  bool _isConnected = false;
  String? _conversationId;
  Timer? _pingTimer;

  // Streams for UI updates
  Stream<String> get transcriptStream => _transcriptController?.stream ?? Stream.empty();
  Stream<String> get responseStream => _responseController?.stream ?? Stream.empty();
  Stream<Uint8List> get audioStream => _audioController?.stream ?? Stream.empty();
  Stream<bool> get connectionStream => _connectionController?.stream ?? Stream.empty();

  // Initialize the service
  Future<void> initialize({
    required String agentId,
    String? customPrompt,
    String? firstMessage,
    String voiceId = '21m00Tcm4TlvDq8ikWAM',
    String language = 'en',
  }) async {
    try {
      // Check if API key is configured
      if (_apiKey == 'YOUR_ELEVENLABS_API_KEY') {
        print('Warning: ElevenLabs API key not configured. Using mock response.');
        _isConnected = false;
        _connectionController?.add(false);
        return;
      }

      // Initialize controllers
      _transcriptController = StreamController<String>.broadcast();
      _responseController = StreamController<String>.broadcast();
      _audioController = StreamController<Uint8List>.broadcast();
      _connectionController = StreamController<bool>.broadcast();

      // Initialize audio player
      _audioPlayer = AudioPlayer();

      // Connect to WebSocket with proper URL and headers
      final uri = Uri.parse('$_baseUrl?agent_id=$agentId&xi-api-key=$_apiKey');

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(uri);

      // Send conversation initiation data
      final initData = {
        'type': 'conversation_initiation_client_data',
        'conversation_config_override': {
          'agent': {
            'prompt': {
              'prompt':
                  customPrompt ??
                  "You are Ollie, a friendly and helpful assistant who helps users stay organized and manage their tasks. Keep responses concise and friendly.",
            },
            'first_message': firstMessage ?? "Hi! I'm Ollie, your helpful companion. How can I assist you today?",
            'language': language,
          },
          'tts': {'voice_id': voiceId},
        },
        'custom_llm_extra_body': {'temperature': 0.7, 'max_tokens': 150},
        'dynamic_variables': {'user_name': 'User', 'account_type': 'standard'},
      };

      print('Sending conversation initiation data: ${jsonEncode(initData)}');
      _channel!.sink.add(jsonEncode(initData));

      // Listen for responses
      _channel!.stream.listen(
        (data) => _handleWebSocketMessage(data),
        onError: (error) {
          print('WebSocket Error: $error');
          _isConnected = false;
          _connectionController?.add(false);
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          _connectionController?.add(false);
          _stopPingTimer();
        },
      );

      // Don't set connected to true yet - wait for conversation_initiation_metadata
      _isConnected = false;
      _connectionController?.add(false);

      // Start ping timer to keep connection alive
      _startPingTimer();

      print('Conversational AI initialized successfully with WebSocket connection');
    } catch (e) {
      print('Error initializing Conversational AI: $e');
      _isConnected = false;
      _connectionController?.add(false);
      rethrow;
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
        print('Error sending ping: $e');
      }
    }
  }

  // Handle incoming WebSocket messages
  void _handleWebSocketMessage(dynamic data) {
    try {
      print('Received WebSocket message: $data');
      final message = jsonDecode(data);
      final type = message['type'];

      switch (type) {
        case 'conversation_initiation_metadata':
          _conversationId = message['conversation_initiation_metadata_event']['conversation_id'];
          print('Conversation started: $_conversationId');
          print('🔗 Setting connection status to TRUE');
          _isConnected = true;
          _connectionController?.add(true);
          print('✅ Connection status updated to TRUE');
          // Add a small delay to ensure UI updates
          Future.delayed(Duration(milliseconds: 100));
          break;

        case 'user_transcript':
          final transcript = message['user_transcription_event']['user_transcript'];
          print('User transcript received: $transcript');
          _transcriptController?.add(transcript);
          break;

        case 'agent_response':
          final response = message['agent_response_event']['agent_response'];
          print('Agent response received: $response');
          _responseController?.add(response);
          break;

        case 'internal_tentative_agent_response':
          final tentativeResponse = message['tentative_agent_response_internal_event']['tentative_agent_response'];
          print('Tentative agent response received: $tentativeResponse');
          // You can choose to show this or wait for the final response
          break;

        case 'audio':
          final audioBase64 = message['audio_event']['audio_base_64'];
          final audioData = base64Decode(audioBase64);
          print('Audio received, length: ${audioData.length} bytes');
          _audioController?.add(audioData);
          _playAudioChunk(audioData);
          break;

        case 'vad_score':
          final vadScore = message['vad_score_event']['vad_score'];
          print('VAD Score: $vadScore');
          break;

        case 'ping':
          // Respond to ping with pong
          final eventId = message['ping_event']['event_id'];
          _sendPong(eventId);
          break;

        case 'pong':
          print('Pong received: ${message['event_id']}');
          break;

        case 'client_tool_call':
          final toolCall = message['client_tool_call'];
          print('Client tool call received: ${toolCall['tool_name']}');
          break;

        case 'contextual_update':
          final context = message['contextual_update_event']['text'];
          print('Contextual update received: $context');
          break;

        default:
          print('Unknown message type: $type');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  // Send user audio chunk
  Future<void> sendUserAudio(Uint8List audioData) async {
    if (!_isConnected) {
      print('Not connected, cannot send audio');
      return;
    }

    try {
      final audioBase64 = base64Encode(audioData);
      final message = {'user_audio_chunk': audioBase64};
      print('Sending audio chunk, length: ${audioData.length} bytes');
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending user audio: $e');
    }
  }

  // Send text message
  Future<void> sendTextMessage(String text) async {
    if (!_isConnected) {
      print('Not connected, cannot send text message');
      return;
    }

    try {
      final message = {'type': 'user_message', 'text': text};
      print('Sending text message: $text');
      _channel!.sink.add(jsonEncode(message));

      // Set a timeout for response
      Timer(Duration(seconds: 10), () {
        if (_isConnected) {
          print('⚠️ No response received within 10 seconds');
          // You could add a fallback response here
        }
      });
    } catch (e) {
      print('Error sending text message: $e');
      _isConnected = false;
      _connectionController?.add(false);
    }
  }

  // Send contextual update
  Future<void> sendContextualUpdate(String context) async {
    if (!_isConnected) {
      print('Not connected, cannot send contextual update');
      return;
    }

    try {
      final message = {'type': 'contextual_update', 'text': context};
      print('Sending contextual update: $context');
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending contextual update: $e');
    }
  }

  // Send pong response
  void _sendPong(int eventId) {
    if (!_isConnected) return;

    try {
      final message = {'type': 'pong', 'event_id': eventId};
      print('Sending pong: $eventId');
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending pong: $e');
    }
  }

  // Play audio chunk
  Future<void> _playAudioChunk(Uint8List audioData) async {
    try {
      // Save audio chunk to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/audio_chunk_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(audioData);

      print('Playing audio chunk: ${tempFile.path}');
      // Play the audio
      await _audioPlayer?.play(DeviceFileSource(tempFile.path));
    } catch (e) {
      print('Error playing audio chunk: $e');
    }
  }

  // Stop audio playback
  Future<void> stopAudio() async {
    try {
      await _audioPlayer?.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  // Check if connected
  bool get isConnected => _isConnected;

  // Get conversation ID
  String? get conversationId => _conversationId;

  // Dispose resources
  void dispose() {
    try {
      _stopPingTimer();
      _channel?.sink.close();
      _audioPlayer?.dispose();
      _transcriptController?.close();
      _responseController?.close();
      _audioController?.close();
      _connectionController?.close();
      _isConnected = false;
    } catch (e) {
      print('Error disposing Conversational AI service: $e');
    }
  }
}
