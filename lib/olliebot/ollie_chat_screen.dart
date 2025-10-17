import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/home/Dailytask/daily_task_screen.dart';
import 'ollie_chat_controller.dart';

class OllieChatScreen extends StatelessWidget {
  OllieChatScreen({super.key});
  final OllieChatController controller = Get.put(OllieChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BGcolor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Black),
              onPressed: () => Get.back(),
            ),
            CircleAvatar(backgroundColor: buttonColor, radius: 16, child: Image.asset("assets/icons/Frame 1686560557.png")),
            const SizedBox(width: 8),
            Text("Ollie", style: mediumTextStyle18),
            const SizedBox(width: 6),
            const CircleAvatar(backgroundColor: Colors.green, radius: 4),
          ],
        ),
        actions: [
          // TTS Toggle Button
          Obx(
            () => IconButton(
              icon: Icon(
                controller.enableTTS.value ? Icons.volume_up : Icons.volume_off,
                color: controller.enableTTS.value ? buttonColor : Colors.grey,
              ),
              onPressed: controller.toggleTTS,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Get.to(() => TodoListScreen(), transition: Transition.fadeIn);
              },
              child: Icon(Icons.menu, color: Black),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // TTS Status Indicator
          Obx(
            () => controller.isPlayingTTS.value
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: buttonColor.withOpacity(0.1),
                    child: Row(
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
                        const Spacer(),
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

          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isUser = msg.isUser;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser)
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(backgroundColor: buttonColor, radius: 16, child: Image.asset("assets/icons/Frame 1686560557.png")),
                          ),
                        Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: 0.65.sw),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser ? kprimaryColor : white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isUser ? 18 : 0),
                                  bottomRight: Radius.circular(isUser ? 0 : 18),
                                ),
                              ),
                              child: Text(msg.text, style: regularTextStyle16.copyWith(color: txtColor)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                Text("10:24 AM", style: lightTextStyle12.copyWith(color: Colors.grey)),
                                if (isUser) const SizedBox(width: 4),
                                if (isUser) const Icon(Icons.done_all, size: 16, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Input Area
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 30),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: cardbg, borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(
                            () => TextField(
                              controller: TextEditingController(text: controller.currentMessage.value)
                                ..selection = TextSelection.collapsed(offset: controller.currentMessage.value.length),
                              onChanged: (val) => controller.currentMessage.value = val,
                              onSubmitted: (_) => controller.sendMessage(),
                              style: regularTextStyle16,
                              decoration: InputDecoration(
                                hintText: "Enter your message",
                                hintStyle: lightTextStyle14.copyWith(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => GestureDetector(
                    onTap: controller.toggleMic,
                    child: CircleAvatar(
                      backgroundColor: buttonColor,
                      radius: 24,
                      child: Icon(controller.isListening.value ? Icons.mic_off : Icons.mic, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
