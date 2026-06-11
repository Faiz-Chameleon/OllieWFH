// // test_api_key.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// void main() async {
//   const apiKey = 'your_actual_api_key_here'; // Replace with your key
//   const testText = 'Hello, this is a test message.';

//   debugPrint('🔑 Testing ElevenLabs API key...');

//   try {
//     // Test 1: Check API key validity with a simple request
//     final response = await http.get(
//       Uri.parse('https://api.elevenlabs.io/v1/user'),
//       headers: {'xi-api-key': apiKey, 'Content-Type': 'application/json'},
//     );

//     debugPrint('📊 Response Status Code: ${response.statusCode}');

//     if (response.statusCode == 200) {
//       final userData = json.decode(response.body);
//       debugPrint('✅ API Key is VALID!');
//       debugPrint('👤 User: ${userData['first_name']} ${userData['last_name']}');
//       debugPrint('📧 Email: ${userData['email']}');
//       debugPrint('💼 Subscription: ${userData['subscription']['tier']}');
//       debugPrint('🔢 Character Count: ${userData['subscription']['character_count']}');
//       debugPrint('📈 Character Limit: ${userData['subscription']['character_limit']}');
//     } else {
//       debugPrint('❌ API Key is INVALID!');
//       debugPrint('📄 Response: ${response.body}');
//     }

//     // Test 2: Try text-to-speech conversion
//     debugPrint('\n🎵 Testing TTS conversion...');
//     final ttsResponse = await http.post(
//       Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM'),
//       headers: {'xi-api-key': apiKey, 'Content-Type': 'application/json', 'Accept': 'audio/mpeg'},
//       body: json.encode({
//         'text': testText,
//         'model_id': 'eleven_monolingual_v1',
//         'voice_settings': {'stability': 0.5, 'similarity_boost': 0.5},
//       }),
//     );

//     debugPrint('📊 TTS Status Code: ${ttsResponse.statusCode}');
//     if (ttsResponse.statusCode == 200) {
//       debugPrint('✅ TTS conversion successful!');
//       debugPrint('🎧 Audio data received: ${ttsResponse.bodyBytes.length} bytes');
//     } else {
//       debugPrint('❌ TTS conversion failed');
//       debugPrint('📄 Error: ${ttsResponse.body}');
//     }
//   } catch (e) {
//     debugPrint('❌ Error testing API key: $e');
//   }
// }
