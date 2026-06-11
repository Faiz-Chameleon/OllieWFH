// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/assistance/add_location_screen.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';

class AddTaskDescriptionScreen extends StatelessWidget {
  AddTaskDescriptionScreen({super.key}) {
    isNotEmpty.value =
        controller.descriptionController.text.trim().length >= 10;
  }
  final Assistance_Controller controller =
      Get.isRegistered<Assistance_Controller>()
      ? Get.find<Assistance_Controller>()
      : Get.put(Assistance_Controller());
  final UserController userController = Get.find<UserController>();
  final ImagePicker _picker = ImagePicker();

  final RxBool isNotEmpty = false.obs;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      controller.addAttachments([picked]);
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      controller.addAttachments([picked]);
    }
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    final files =
        result?.files
            .where((file) => file.path != null)
            .map((file) => XFile(file.path!))
            .toList() ??
        [];
    controller.addAttachments(files);
  }

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.webm');
  }

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                              child: const Icon(
                                Icons.arrow_back,
                                size: 24,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Add a description for your task.",
                                style: GoogleFonts.darkerGrotesque(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
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
                              backgroundImage:
                                  userController.user.value?.image != null &&
                                      userController
                                              .user
                                              .value
                                              ?.image!
                                              .isNotEmpty ==
                                          true
                                  ? NetworkImage(
                                      userController.user.value!.image!,
                                    )
                                  : const AssetImage(
                                          "assets/icons/Frame 1686560584.png",
                                        )
                                        as ImageProvider,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              userController.user.value?.firstName ?? "",
                              style: GoogleFonts.darkerGrotesque(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
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
                            hintText:
                                "I need help with groceries, is anyone available?",
                            hintStyle: GoogleFonts.darkerGrotesque(
                              color: Colors.black45,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF3F362E),
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Share enough detail so volunteers know how to help best.",
                          style: GoogleFonts.darkerGrotesque(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Obx(
                          () => Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _AttachmentAction(
                                icon: Icons.camera_alt_outlined,
                                label: "Camera",
                                onTap: controller.canAddMoreAttachments
                                    ? () => _pickImage(ImageSource.camera)
                                    : null,
                              ),
                              _AttachmentAction(
                                icon: Icons.photo_outlined,
                                label: "Photo",
                                onTap: controller.canAddMoreAttachments
                                    ? () => _pickImage(ImageSource.gallery)
                                    : null,
                              ),
                              _AttachmentAction(
                                icon: Icons.videocam_outlined,
                                label: "Video",
                                onTap: controller.canAddMoreAttachments
                                    ? _pickVideo
                                    : null,
                              ),
                              _AttachmentAction(
                                icon: Icons.attach_file,
                                label: "File",
                                onTap: controller.canAddMoreAttachments
                                    ? _pickDocuments
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Obx(
                          () => controller.attachments.isEmpty
                              ? const SizedBox.shrink()
                              : Column(
                                  children: List.generate(
                                    controller.attachments.length,
                                    (index) {
                                      final file =
                                          controller.attachments[index];
                                      final path = file.path;
                                      final name = path.split('/').last;
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: SizedBox(
                                                width: 46,
                                                height: 46,
                                                child: _isImage(path)
                                                    ? Image.file(
                                                        File(path),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        color: const Color(
                                                          0xFFF6EEDC,
                                                        ),
                                                        child: Icon(
                                                          _isVideo(path)
                                                              ? Icons.videocam
                                                              : Icons
                                                                    .insert_drive_file,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.darkerGrotesque(
                                                      fontSize: 17.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => controller
                                                  .removeAttachmentAt(index),
                                              icon: const Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isNotEmpty.value
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                Get.to(
                                  () => AddLocationScreen(),
                                  transition: Transition.fadeIn,
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F362E),
                        disabledBackgroundColor: const Color(
                          0xFF3F362E,
                        ).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(color: Colors.white),
                      ),
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

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: enabled ? Colors.black : Colors.black38,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.darkerGrotesque(
                color: enabled ? Colors.black : Colors.black38,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
