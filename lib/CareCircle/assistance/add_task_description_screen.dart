import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/assistance/add_location_screen.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';

class AddTaskDescriptionScreen extends StatelessWidget {
  AddTaskDescriptionScreen({super.key}) {
    isNotEmpty.value = controller.descriptionController.text.trim().length >= 10;
  }
  final Assistance_Controller controller = Get.isRegistered<Assistance_Controller>()
      ? Get.find<Assistance_Controller>()
      : Get.put(Assistance_Controller());
  final UserController userController = Get.find<UserController>();

  final RxBool isNotEmpty = false.obs;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF3DD),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            Expanded(
                              child: Text(
                                "Add a description for your task.",
                                style: GoogleFonts.darkerGrotesque(fontSize: 22.sp, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
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
                            Text(
                              userController.user.value?.firstName ?? "",
                              style: GoogleFonts.darkerGrotesque(fontSize: 16.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description Field
                        TextFormField(
                          controller: controller.descriptionController,
                          maxLines: 6,
                          onChanged: (val) {
                            final trimmedLength = val.trim().length;
                            isNotEmpty.value = trimmedLength >= 10;
                          },
                          style: const TextStyle(fontSize: 16),
                          validator: (value) {
                            final trimmed = value?.trim() ?? "";
                            if (trimmed.isEmpty) {
                              return "Please describe the help you need.";
                            }
                            if (trimmed.length < 10) {
                              return "Description must be at least 10 characters long.";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF6EEDC),
                            hintText: "I need help with groceries, is anyone available?",
                            hintStyle: GoogleFonts.darkerGrotesque(color: Colors.black45),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color(0xFF3F362E)),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text("Share enough detail so volunteers know how to help best.", style: GoogleFonts.darkerGrotesque(color: Colors.black54)),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isNotEmpty.value
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                Get.to(() => AddLocationScreen(), transition: Transition.fadeIn);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F362E),
                        disabledBackgroundColor: const Color(0xFF3F362E).withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Next", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
