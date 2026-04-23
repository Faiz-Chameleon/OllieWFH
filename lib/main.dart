import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:ollie/services/firebase_service.dart';

SharedPreferencesService? sharedPrefs;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.initialize();
  await FirebaseService.instance.showIncomingNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseService.instance.initialize();
  Get.put(Bottomcontroller());
  Get.put(SocketController());
  Get.put(OneToOneChatController());
  Get.put(OneToManyChatController());
  Get.put(LoginController());
  Get.put(UserController());

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
