// // test_api_key.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// void main() async {
//   const apiKey = 'your_actual_api_key_here'; // Replace with your key
//   const testText = 'Hello, this is a test message.';

//   print('🔑 Testing ElevenLabs API key...');

//   try {
//     // Test 1: Check API key validity with a simple request
//     final response = await http.get(
//       Uri.parse('https://api.elevenlabs.io/v1/user'),
//       headers: {'xi-api-key': apiKey, 'Content-Type': 'application/json'},
//     );

//     print('📊 Response Status Code: ${response.statusCode}');

//     if (response.statusCode == 200) {
//       final userData = json.decode(response.body);
//       print('✅ API Key is VALID!');
//       print('👤 User: ${userData['first_name']} ${userData['last_name']}');
//       print('📧 Email: ${userData['email']}');
//       print('💼 Subscription: ${userData['subscription']['tier']}');
//       print('🔢 Character Count: ${userData['subscription']['character_count']}');
//       print('📈 Character Limit: ${userData['subscription']['character_limit']}');
//     } else {
//       print('❌ API Key is INVALID!');
//       print('📄 Response: ${response.body}');
//     }

//     // Test 2: Try text-to-speech conversion
//     print('\n🎵 Testing TTS conversion...');
//     final ttsResponse = await http.post(
//       Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM'),
//       headers: {'xi-api-key': apiKey, 'Content-Type': 'application/json', 'Accept': 'audio/mpeg'},
//       body: json.encode({
//         'text': testText,
//         'model_id': 'eleven_monolingual_v1',
//         'voice_settings': {'stability': 0.5, 'similarity_boost': 0.5},
//       }),
//     );

//     print('📊 TTS Status Code: ${ttsResponse.statusCode}');
//     if (ttsResponse.statusCode == 200) {
//       print('✅ TTS conversion successful!');
//       print('🎧 Audio data received: ${ttsResponse.bodyBytes.length} bytes');
//     } else {
//       print('❌ TTS conversion failed');
//       print('📄 Error: ${ttsResponse.body}');
//     }
//   } catch (e) {
//     print('❌ Error testing API key: $e');
//   }
// }
