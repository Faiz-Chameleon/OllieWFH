import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/request_status.dart';
import '../care_circle_controller.dart';

class CreatePostScreen extends StatelessWidget {
  final String topicId;

  const CreatePostScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context) {
    final CareCircleController controller = Get.put(CareCircleController());
    final TextEditingController postTitleController = TextEditingController();
    final TextEditingController postContentController = TextEditingController();
    final ImagePicker picker = ImagePicker();

    void pickImage(ImageSource source) async {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        controller.setImageFile(File(picked.path));
      }
    }

    void pickVideo(ImageSource source) async {
      final picked = await picker.pickVideo(source: source);
      if (picked != null) {
        controller.setVideoFile(File(picked.path));
      }
    }

    void pickDocument() async {
      final picked = await FilePicker.platform.pickFiles(type: FileType.any);
      if (picked != null && picked.files.single.path != null) {
        controller.setDocumentFile(File(picked.files.single.path!));
      }
    }

    void _createPost() async {
      final title = postTitleController.text.trim();
      final content = postContentController.text.trim();

      if (title.isEmpty || content.isEmpty) {
        Get.snackbar("Error", "Please fill in both title and content");
        return;
      }

      await controller.createUserPost(
        topicId,
        title,
        content,
        controller.imageFile.value,
        controller.videoFile.value,
      );

      if (controller.createPostStatus.value == RequestStatus.success) {
        Get.back();
      }
    }

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
                onPressed:
                    controller.createPostStatus.value == RequestStatus.loading
                    ? null
                    : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC766),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    controller.createPostStatus.value == RequestStatus.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text("Post", style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // User + Textfield
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    "assets/icons/Frame 1686560584.png",
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Julia Michael",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Post Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: postTitleController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Post Title",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: postContentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "What do you want to talk about?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Image Preview
          Obx(
            () => controller.imageFile.value != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            controller.imageFile.value!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => controller.clearImageFile(),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Video Preview
          Obx(
            () => controller.videoFile.value != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => controller.clearVideoFile(),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Document Preview
          Obx(
            () => controller.documentFile.value != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.documentFile.value!.path.split('/').last,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.clearDocumentFile(),
                          child: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const Spacer(),

          _buildBottomOptions(pickImage, pickVideo, pickDocument),
          80.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildBottomOptions(
    Function(ImageSource) pickImage,
    Function(ImageSource) pickVideo,
    Function() pickDocument,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () => pickImage(ImageSource.camera),
          ),
          IconButton(
            icon: const Icon(Icons.photo_outlined),
            onPressed: () => pickImage(ImageSource.gallery),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () => pickVideo(ImageSource.gallery),
          ),
          IconButton(
            icon: const Icon(Icons.insert_drive_file_outlined),
            onPressed: pickDocument,
          ),
        ],
      ),
    );
  }
}
