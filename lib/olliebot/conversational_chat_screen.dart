// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/home/Dailytask/daily_task_screen.dart';

import 'conversational_chat_controller.dart';

class ConversationalChatScreen extends StatelessWidget {
  ConversationalChatScreen({super.key, this.initialMessage});

  final String? initialMessage;

  final ConversationalChatController controller = Get.isRegistered<ConversationalChatController>()
      ? Get.find<ConversationalChatController>()
      : Get.put(ConversationalChatController());

  void _closeScreen() {
    if (Get.isOverlaysOpen) {
      Get.back();
      return;
    }

    Get.back();
    if (Get.isRegistered<ConversationalChatController>()) {
      Future.microtask(() => Get.delete<ConversationalChatController>());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (initialMessage != null && initialMessage!.trim().isNotEmpty) {
      controller.sendInitialMessage(initialMessage!);
    }
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        _closeScreen();
      },
      child: Scaffold(
        backgroundColor: BGcolor,
        resizeToAvoidBottomInset: false,
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
                onPressed: _closeScreen,
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
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => TodoListScreen(), transition: Transition.fadeIn);
                },
                child: const Icon(Icons.menu, color: Black),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
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
                          style: TextStyle(
                            color: controller.isConnected.value ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => controller.currentTranscript.value.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.blue.withOpacity(0.1),
                        child: Row(
                          children: [
                            const Icon(Icons.mic, color: Colors.blue, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "You said: ${controller.currentTranscript.value}",
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => controller.isListening.value
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.orange.withOpacity(0.1),
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
                            ),
                            SizedBox(width: 8),
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
                                padding: const EdgeInsets.only(right: 8),
                                child: CircleAvatar(
                                  backgroundColor: buttonColor,
                                  radius: 16,
                                  child: Image.asset("assets/icons/Frame 1686560557.png"),
                                ),
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
                                        const SizedBox(
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
              AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.fromLTRB(12, 4, 12, math.max(bottomInset, safeBottom) + 8),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: cardbg, borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: controller.messageController,
                                textInputAction: TextInputAction.send,
                                onChanged: (val) {
                                  controller.currentMessage.value = val;
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
                    Obx(() {
                      final isListening = controller.isListening.value;
                      final hasTypedMessage = controller.currentMessage.value.trim().isNotEmpty;

                      if (isListening) {
                        return GestureDetector(
                          onTap: controller.toggleMic,
                          child: const CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 24,
                            child: Icon(Icons.mic_off, color: Colors.white, size: 20),
                          ),
                        );
                      }

                      if (hasTypedMessage) {
                        return GestureDetector(
                          onTap: controller.sendMessage,
                          child: const CircleAvatar(
                            backgroundColor: buttonColor,
                            radius: 24,
                            child: Icon(Icons.send, color: Colors.white, size: 20),
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: controller.toggleMic,
                        child: const CircleAvatar(
                          backgroundColor: buttonColor,
                          radius: 24,
                          child: Icon(Icons.mic, color: Colors.white, size: 20),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
