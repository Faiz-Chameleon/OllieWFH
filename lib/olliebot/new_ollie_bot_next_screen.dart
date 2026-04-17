import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/olliebot/conversational_chat_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ollie/common/common.dart';

class NextOllieBotScreen extends StatefulWidget {
  const NextOllieBotScreen({super.key});

  @override
  State<NextOllieBotScreen> createState() => _NextOllieBotScreenState();
}

class _NextOllieBotScreenState extends State<NextOllieBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }

    final bottomController = Get.isRegistered<Bottomcontroller>() ? Get.find<Bottomcontroller>() : Get.put(Bottomcontroller());
    bottomController.updateIndex(0);
    Get.offAll(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);
  }

  void _openConversation(String message) {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) return;

    _messageController.text = trimmedMessage;
    Get.to(() => ConversationalChatScreen(initialMessage: trimmedMessage), transition: Transition.fadeIn);
  }

  Future<void> _toggleMic() async {
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      appSnackbar('Voice Not Available', 'Speech recognition is not available on this device.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() {
      _isListening = true;
      _spokenText = '';
    });

    await _speech.listen(
      localeId: 'en_US',
      listenOptions: stt.SpeechListenOptions(listenMode: stt.ListenMode.confirmation),
      onResult: (result) async {
        if (!mounted) return;

        setState(() {
          _spokenText = result.recognizedWords;
          _messageController.text = result.recognizedWords;
        });

        if (result.finalResult) {
          await _speech.stop();
          if (!mounted) return;
          setState(() {
            _isListening = false;
          });
          _openConversation(result.recognizedWords);
        }
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF2D6),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: const Color(0xFFFFF2D6),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Black),
            onPressed: _handleBack,
          ),
          title: const Text(
            "Ollie",
            style: TextStyle(color: Black, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          actions: [
            // TTS Settings Button
            // IconButton(
            //   icon: Icon(Icons.settings, color: Black),
            //   onPressed: () {
            //     Get.to(() => TTSSettingsScreen());
            //   },
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Get.to(() => TodoListScreen(), transition: Transition.fadeIn);
            //   },
            //   child: Padding(
            //     padding: EdgeInsets.only(right: 16),
            //     child: Icon(Icons.menu, color: Black),
            //   ),
            // ),
          ],
        ),
        body: Center(
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const Text(
                "What can I\ndo for you?",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {},
                child: Image.asset("assets/images/Group 1000000914.png", height: 0.3.sh),
              ),

              const SizedBox(height: 20),

              Text(
                "I'm Ollie, your companion.\nI'm here to help you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26.sp, color: Black, fontWeight: FontWeight.bold),
              ),

              // TTS Status Indicator
              // Container(
              //   margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              //   decoration: BoxDecoration(color: buttonColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       const SizedBox(
              //         width: 16,
              //         height: 16,
              //         child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(buttonColor)),
              //       ),
              //       const SizedBox(width: 8),
              //       Text(
              //         "Ollie is speaking...",
              //         style: TextStyle(color: buttonColor, fontWeight: FontWeight.w500),
              //       ),
              //       const SizedBox(width: 8),
              //       IconButton(
              //         icon: const Icon(Icons.stop, color: buttonColor),
              //         onPressed: () {},
              //         // controller.stopTTS,
              //         iconSize: 20,
              //       ),
              //     ],
              //   ),
              // ),
              Column(
                children: [
                  const SizedBox(height: 16),

                  Column(
                    children: [
                      GestureDetector(
                        onTap: _toggleMic,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: _isListening ? Colors.red : buttonColor,
                          child: Icon(_isListening ? Icons.mic_off : Icons.mic, size: 28, color: white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_spokenText.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _spokenText,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp, color: Colors.black54, fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // GestureDetector(
                      //   onTap: () {
                      //     Get.to(() => ConversationalChatScreen(), transition: Transition.fadeIn); // Navigates to conversational AI
                      //   },
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //     decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(20)),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Icon(Icons.psychology, color: white, size: 20),
                      //         const SizedBox(width: 8),
                      //         Text(
                      //           "AI Chat",
                      //           style: TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w600),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),

                  // 25.verticalSpace,
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
                              controller: _messageController,
                              onSubmitted: (value) {
                                _openConversation(value);
                              },
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

              // const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
