import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/home/Dailytask/daily_task_screen.dart';
import 'conversational_chat_controller.dart';

class ConversationalChatScreen extends StatelessWidget {
  ConversationalChatScreen({super.key});
  final ConversationalChatController controller = Get.put(ConversationalChatController());

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
            Text("Ollie AI", style: mediumTextStyle18),
            const SizedBox(width: 6),
            Obx(() => CircleAvatar(backgroundColor: controller.isConnected.value ? Colors.green : Colors.red, radius: 4)),
          ],
        ),
        actions: [
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
          // Connection Status
          Obx(
            () => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: controller.isConnected.value ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    controller.isConnected.value ? Icons.wifi : Icons.wifi_off,
                    color: controller.isConnected.value ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.connectionStatus.value,
                      style: TextStyle(color: controller.isConnected.value ? Colors.green : Colors.red, fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transcript Display
          Obx(
            () => controller.currentTranscript.value.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.blue.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(Icons.mic, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "You said: ${controller.currentTranscript.value}",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Listening Indicator
          Obx(
            () => controller.isListening.value
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.orange.withOpacity(0.1),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Listening... Speak now",
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500, fontSize: 12),
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
                  final isStreaming = msg.isStreaming;

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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isStreaming)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(txtColor)),
                                    ),
                                  if (isStreaming) const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(msg.text, style: regularTextStyle16.copyWith(color: txtColor)),
                                  ),
                                ],
                              ),
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
                          child: TextField(
                            onChanged: (val) {
                              controller.currentMessage.value = val;
                              print('Text input changed: $val');
                            },
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                controller.currentMessage.value = val;
                                controller.sendMessage();
                              }
                            },
                            style: regularTextStyle16,
                            decoration: InputDecoration(
                              hintText: "Type your message...",
                              hintStyle: lightTextStyle14.copyWith(color: Colors.grey),
                              border: InputBorder.none,
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
                      backgroundColor: controller.isListening.value ? Colors.red : buttonColor,
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
