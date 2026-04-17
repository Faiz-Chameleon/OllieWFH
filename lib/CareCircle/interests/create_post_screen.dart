import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/request_status.dart';
import '../care_circle_controller.dart';
import 'package:ollie/common/common.dart';

class CreatePostScreen extends StatefulWidget {
  final String topicId;

  const CreatePostScreen({super.key, required this.topicId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final CareCircleController controller;
  late final TextEditingController postTitleController;
  late final TextEditingController postContentController;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CareCircleController>() ? Get.find<CareCircleController>() : Get.put(CareCircleController());
    postTitleController = TextEditingController();
    postContentController = TextEditingController();
  }

  @override
  void dispose() {
    postTitleController.dispose();
    postContentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      controller.setImageFile(File(picked.path));
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picked = await picker.pickVideo(source: source);
    if (picked != null) {
      controller.setVideoFile(XFile(picked.path));
    }
  }

  Future<void> _pickDocument() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.any);
    if (picked != null && picked.files.single.path != null) {
      controller.setDocumentFile(XFile(picked.files.single.path!));
    }
  }

  Future<void> _createPost() async {
    FocusScope.of(context).unfocus();
    final title = postTitleController.text.trim();
    final content = postContentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      appSnackbar("Error", "Please fill in both title and content");
      return;
    }

    await controller.createUserPost(
      widget.topicId,
      title,
      content,
      controller.imageFile.value,
      controller.videoFile.value,
      controller.documentFile.value,
    );

    if (controller.createPostStatus.value == RequestStatus.success) {
      postTitleController.clear();
      postContentController.clear();
      controller.imageFile.value = null;
      controller.videoFile.value = null;
      controller.documentFile.value = null;

      Get.close(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Create Post",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.createPostStatus.value == RequestStatus.loading ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC766),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: controller.createPostStatus.value == RequestStatus.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text("Post", style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(bottom: 24 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 20, backgroundImage: AssetImage("assets/icons/Frame 1686560584.png")),
                            const SizedBox(width: 10),
                            const Text("Julia Michael", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: postTitleController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: "Post Title",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: postContentController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: "What do you want to talk about?",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      Obx(
                        () => controller.imageFile.value != null
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(controller.imageFile.value!, height: 160, width: double.infinity, fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => controller.clearImageFile(),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      Obx(
                        () => controller.videoFile.value != null
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 160,
                                      width: double.infinity,
                                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                                      child: const Center(child: Icon(Icons.videocam, color: Colors.white, size: 48)),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => controller.clearVideoFile(),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      Obx(
                        () => controller.documentFile.value != null
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file, color: Colors.black),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(controller.documentFile.value!.path.split('/').last)),
                                    GestureDetector(
                                      onTap: () => controller.clearDocumentFile(),
                                      child: const Icon(Icons.close, color: Colors.red),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.camera_alt_outlined), onPressed: () => _pickImage(ImageSource.camera)),
          IconButton(icon: const Icon(Icons.photo_outlined), onPressed: () => _pickImage(ImageSource.gallery)),
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () => _pickVideo(ImageSource.gallery)),
          IconButton(icon: const Icon(Icons.insert_drive_file_outlined), onPressed: _pickDocument),
        ],
      ),
    );
  }
}
