import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ollie/Constants/constants.dart';
import 'package:ollie/home/Dailytask/daily_task_screen.dart';
import 'package:ollie/olliebot/ollie_chat_screen.dart';
import 'package:ollie/olliebot/conversational_chat_screen.dart';
import 'package:ollie/olliebot/tts_settings_screen.dart';
import 'ollie_controller.dart';

class OllieScreen extends StatefulWidget {
  OllieScreen({super.key});

  @override
  State<OllieScreen> createState() => _OllieScreenState();
}

class _OllieScreenState extends State<OllieScreen> {
  final OllieController controller = Get.put(OllieController());

  @override
  void initState() {
    super.initState();
    // Play welcome message after a short delay
    Future.delayed(Duration(seconds: 1), () {
      controller.speakWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D6),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFFFF2D6),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Ollie",
          style: TextStyle(color: Black, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // TTS Settings Button
          IconButton(
            icon: Icon(Icons.settings, color: Black),
            onPressed: () {
              Get.to(() => TTSSettingsScreen());
            },
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => TodoListScreen(), transition: Transition.fadeIn);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.menu, color: Black),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "What can I\ndo for you?",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Image.asset("assets/images/Group 1000000914.png", height: 0.35.sh),

              const SizedBox(height: 30),

              Text(
                "I'm Ollie, your companion.\nI'm here to help you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26.sp, color: Black, fontWeight: FontWeight.bold),
              ),

              // TTS Status Indicator
              Obx(
                () => controller.isPlayingTTS.value
                    ? Container(
                        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(color: buttonColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(buttonColor)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Ollie is speaking...",
                              style: TextStyle(color: buttonColor, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.stop, color: buttonColor),
                              onPressed: controller.stopTTS,
                              iconSize: 20,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => Column(
                  children: [
                    const SizedBox(height: 16),

                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => OllieChatScreen(), transition: Transition.fadeIn); // Navigates to chat screen
                          },
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: buttonColor,
                            child: Icon(Icons.mic, size: 28, color: white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Basic Chat",
                          style: TextStyle(fontSize: 12, color: Black, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => ConversationalChatScreen(), transition: Transition.fadeIn); // Navigates to conversational AI
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.psychology, color: white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "AI Chat",
                                  style: TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    25.verticalSpace,
                    if (controller.isChatVisible.value)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attachment_rounded, size: 20, color: txtColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) => controller.chatText.value = value,
                                  style: regularTextStyle16,
                                  decoration: InputDecoration(hintText: "Ask Ollie", hintStyle: lightTextStyle14, border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
