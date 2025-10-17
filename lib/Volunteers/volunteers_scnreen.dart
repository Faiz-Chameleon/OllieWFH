// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/Volunteers/one_to_one_chat_controller.dart';
import 'package:ollie/request_status.dart';
import 'volunteers_chat_screen.dart';
import 'volunteers_contoller.dart';

class VolunteersScreen extends StatefulWidget {
  final CareCircleController controller;
  final String assistanceId;
  const VolunteersScreen({super.key, required this.controller, required this.assistanceId});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  final VolunteerController controller = Get.put(VolunteerController());
  final OneToOneChatController chatController = Get.find<OneToOneChatController>();

  final List<String> volunteers = ['Shelley', 'Margaret', 'Eleanor', 'Arthur', 'Gloria'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getVoluntersRequestOnEachAssistance(widget.assistanceId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF2D9),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Volunteers', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Obx(() {
              if (widget.controller.getVoluntersRequesttatus.value == RequestStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (widget.controller.voluntersRequestsList.isEmpty) {
                return const Center(child: Text("No Volunteers Request Found"));
              }
              return Container(
                height: 400,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: const Color(0xff1e18180d), borderRadius: BorderRadius.circular(16)),
                child: ListView.separated(
                  itemCount: widget.controller.voluntersRequestsList.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.transparent),
                  itemBuilder: (context, index) {
                    final name = volunteers[index];
                    return Obx(() {
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundImage: (widget.controller.voluntersRequestsList[index].volunteer?.image?.isNotEmpty ?? false)
                              ? NetworkImage(widget.controller.voluntersRequestsList[index].volunteer?.image ?? "")
                              : AssetImage('assets/icons/Group 1000000907 (1).png') as ImageProvider,
                        ),
                        title: Text(
                          " ${widget.controller.voluntersRequestsList[index].volunteer?.firstName} ${widget.controller.voluntersRequestsList[index].volunteer?.lastName} "
                          "",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(() {
                              return GestureDetector(
                                onTap: () async {
                                  var data = {
                                    "action": widget.controller.voluntersRequestsList[index].status == "VolunteerRequestSent" ? "accept" : "reject",
                                  };
                                  widget.controller.voluntersRequestLoadingStatus[index].value = true;
                                  await widget.controller.acceptrequestOnAssistance(
                                    widget.controller.voluntersRequestsList[index].id ?? "",
                                    data,
                                    index,
                                  );
                                  widget.controller.voluntersRequestLoadingStatus[index].value = false;
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: widget.controller.voluntersRequestsList[index].status == "VolunteerRequestSent"
                                        ? Colors.white
                                        : const Color(0xFFF4BD2A),
                                    border: Border.all(color: const Color(0xFFF4BD2A)),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Obx(() {
                                    if (widget.controller.voluntersRequestLoadingStatus[index].value) {
                                      return const CircularProgressIndicator();
                                    }
                                    return Text(
                                      widget.controller.voluntersRequestsList[index].status == "VolunteerRequestSent" ? "Select" : "Selected",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: widget.controller.voluntersRequestsList[index].status == "VolunteerRequestSent"
                                            ? const Color(0xFFF4BD2A)
                                            : Colors.white,
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                var data = {"userId": widget.controller.voluntersRequestsList[index].volunteerId.toString() ?? ""};
                                await chatController.createOneOnOneChat(data).then((value) {
                                  Get.to(
                                    () => ChatScreen(
                                      userName: widget.controller.voluntersRequestsList[index].volunteer?.firstName ?? "",
                                      userImage: widget.controller.voluntersRequestsList[index].volunteer?.image ?? "",
                                    ),
                                  );
                                });
                              },
                              child: const Icon(Icons.chat, color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
