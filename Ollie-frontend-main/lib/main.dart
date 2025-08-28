import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/Splash.dart';
import 'package:ollie/Storage/SharedPreferencesService.dart';
import 'package:ollie/Volunteers/one_to_one_chat_controller.dart';
import 'package:ollie/Volunteers/socket_controller.dart';
import 'package:ollie/Auth/login/login_controller.dart';
import 'package:ollie/Auth/login/user_controller.dart';

SharedPreferencesService? sharedPrefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(Bottomcontroller());
  Get.put(SocketController());
  Get.put(OneToOneChatController());
  Get.put(OneToManyChatController());
  Get.put(LoginController());
  Get.put(UserController());

  // Load .env file if it exists, otherwise continue without it
  // myapikey  sk_58ab3f3d38d50d34638996d260ca17a88ebaab384b7eaf1f
  const apiKey = 'sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd'; // Replace with your key
  const testText = 'Hello, this is a test message.';

  print('🔑 Testing ElevenLabs API key...');

  try {
    // Test 1: Check API key validity with a simple request
    final response = await http.get(
      Uri.parse('https://api.elevenlabs.io/v1/user'),
      headers: {'xi-api-key': apiKey, 'Content-Type': 'application/json'},
    );

    print('📊 Response Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      print('✅ API Key is VALID!');
      print('👤 User: ${userData['first_name']} ${userData['last_name']}');
      print('📧 Email: ${userData['email']}');
      print('💼 Subscription: ${userData['subscription']['tier']}');
      print('🔢 Character Count: ${userData['subscription']['character_count']}');
      print('📈 Character Limit: ${userData['subscription']['character_limit']}');
    } else {
      print('❌ API Key is INVALID!');
      print('📄 Response: ${response.body}');
    }

    // Test 2: Try text-to-speech conversion
    print('\n🎵 Testing TTS conversion...');
    final ttsResponse = await http.post(
      Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM'),
      headers: {'xi-api-key': apiKey, 'Content-Type': 'application/json', 'Accept': 'audio/mpeg'},
      body: json.encode({
        'text': testText,
        'model_id': 'eleven_monolingual_v1',
        'voice_settings': {'stability': 0.5, 'similarity_boost': 0.5},
      }),
    );

    print('📊 TTS Status Code: ${ttsResponse.statusCode}');
    if (ttsResponse.statusCode == 200) {
      print('✅ TTS conversion successful!');
      print('🎧 Audio data received: ${ttsResponse.bodyBytes.length} bytes');
    } else {
      print('❌ TTS conversion failed');
      print('📄 Error: ${ttsResponse.body}');
    }
  } catch (e) {
    print('❌ Error testing API key: $e');
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _initUserPrefs() {}

  @override
  Widget build(BuildContext context) {
    _initUserPrefs();

    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.05)),
          child: GetMaterialApp(
            title: 'Ollie',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Darker Grotesque',
              textTheme: GoogleFonts.darkerGrotesqueTextTheme(),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellowAccent),
            ),
            home: _determineStartScreen(),
          ),
        );
      },
    );
  }

  Widget _determineStartScreen() {
    return Splash_Screen();
  }
}
//603//