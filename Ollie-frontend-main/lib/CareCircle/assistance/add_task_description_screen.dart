import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/assistance/add_location_screen.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';

class AddTaskDescriptionScreen extends StatelessWidget {
  AddTaskDescriptionScreen({super.key});
  final Assistance_Controller controller = Get.put(Assistance_Controller());
  final UserController userController = Get.find<UserController>();
  // final TextEditingController descriptionController = TextEditingController();

  final RxBool isNotEmpty = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3DD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              50.verticalSpace,
              // Back + Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Add a description for your task.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Profile Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: userController.user.value?.image != null && userController.user.value?.image!.isNotEmpty == true
                        ? NetworkImage(userController.user.value!.image!)
                        : const AssetImage("assets/icons/Frame 1686560584.png") as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Text(userController.user.value?.firstName ?? "", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 20),

              // Description Field
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF6EEDC), borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  controller: controller.descriptionController,
                  maxLines: 5,
                  onChanged: (val) => isNotEmpty.value = val.trim().isNotEmpty,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration.collapsed(
                    hintText: "I need help with groceries, is anyone available?",
                    hintStyle: TextStyle(color: Colors.black45),
                  ),
                ),
              ),

              const Spacer(),

              // Next Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isNotEmpty.value
                        ? () {
                            Get.to(() => AddLocationScreen(), transition: Transition.fadeIn); // ✅ Navigate to next screen
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNotEmpty.value ? const Color(0xFF3F362E) : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Next", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),

              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
