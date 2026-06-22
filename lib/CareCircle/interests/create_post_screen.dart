import 'dart:io';
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
  late final TextEditingController pollQuestionController;
  final List<TextEditingController> pollOptionControllers = [TextEditingController(), TextEditingController()];
  final ImagePicker picker = ImagePicker();
  String postType = 'TEXT';

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CareCircleController>() ? Get.find<CareCircleController>() : Get.put(CareCircleController());
    postTitleController = TextEditingController();
    postContentController = TextEditingController();
    pollQuestionController = TextEditingController();
  }

  @override
  void dispose() {
    postTitleController.dispose();
    postContentController.dispose();
    pollQuestionController.dispose();
    for (final optionController in pollOptionControllers) {
      optionController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_hasPollInput()) {
      appSnackbar("Error", "Remove poll details before adding images");
      return;
    }
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      controller.setImageFile(File(picked.path));
      controller.postImages.assignAll([XFile(picked.path)]);
      setState(() => postType = 'IMAGE');
    }
  }

  Future<void> _pickImages() async {
    if (_hasPollInput()) {
      appSnackbar("Error", "Remove poll details before adding images");
      return;
    }
    final picked = await picker.pickMultiImage(limit: 5);
    if (picked.isEmpty) return;
    controller.postImages.assignAll(picked.take(5));
    controller.imageFile.value = File(picked.first.path);
    setState(() => postType = 'IMAGE');
  }

  Future<void> _pickVideo(ImageSource source) async {
    if (_hasPollInput()) {
      appSnackbar("Error", "Remove poll details before adding video");
      return;
    }
    final picked = await picker.pickVideo(source: source);
    if (picked != null) {
      controller.setVideoFile(XFile(picked.path));
      setState(() => postType = 'VIDEO');
    }
  }

  void _setPostType(String type) {
    if (type == 'POLL' && _hasMediaAttachment()) {
      appSnackbar("Error", "Remove images or video before adding a poll");
      return;
    }
    setState(() => postType = type);
  }

  void _addPollOption() {
    if (pollOptionControllers.length >= 10) return;
    setState(() => pollOptionControllers.add(TextEditingController()));
  }

  void _removePollOption(int index) {
    if (pollOptionControllers.length <= 2) return;
    final removed = pollOptionControllers.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _createPost() async {
    FocusScope.of(context).unfocus();
    final title = postTitleController.text.trim();
    final content = postContentController.text.trim();
    final pollQuestion = pollQuestionController.text.trim();
    final pollOptions = pollOptionControllers.map((controller) => controller.text.trim()).where((option) => option.isNotEmpty).toList();
    final hasPollInput = pollQuestion.isNotEmpty || pollOptions.isNotEmpty;

    if (title.isEmpty) {
      appSnackbar("Error", "Please enter post title");
      return;
    }
    if (hasPollInput && _hasMediaAttachment()) {
      appSnackbar("Error", "Poll cannot be added with images or video");
      return;
    }
    if (postType == 'POLL' && pollQuestion.isEmpty) {
      appSnackbar("Error", "Please enter poll question");
      return;
    }
    if (hasPollInput && pollQuestion.isEmpty) {
      appSnackbar("Error", "Please enter poll question");
      return;
    }
    if (hasPollInput && pollOptions.length < 2) {
      appSnackbar("Error", "Poll needs at least 2 options");
      return;
    }

    await controller.createUserPost(
      widget.topicId,
      title,
      content,
      _effectivePostType(hasPollInput),
      controller.postImages.toList(),
      controller.videoFile.value,
      pollQuestion,
      pollOptions,
      null,
    );

    if (controller.createPostStatus.value == RequestStatus.success) {
      postTitleController.clear();
      postContentController.clear();
      pollQuestionController.clear();
      for (final optionController in pollOptionControllers) {
        optionController.clear();
      }
      controller.imageFile.value = null;
      controller.postImages.clear();
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
                        child: Wrap(
                          spacing: 8,
                          children: [
                            _postTypeChip('TEXT', Icons.notes_rounded),
                            _postTypeChip('IMAGE', Icons.photo_rounded),
                            _postTypeChip('VIDEO', Icons.videocam_rounded),
                            _postTypeChip('POLL', Icons.poll_rounded),
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
                        () => controller.postImages.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.postImages.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemBuilder: (context, index) {
                                    final image = controller.postImages[index];
                                    return Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(File(image.path), fit: BoxFit.cover),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () {
                                              controller.postImages.removeAt(index);
                                              controller.imageFile.value = controller.postImages.isEmpty
                                                  ? null
                                                  : File(controller.postImages.first.path);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
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
                      if (postType == 'POLL' || hasPollDraft) _buildPollFields(),
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

  bool get hasPollDraft {
    return _hasPollInput();
  }

  bool _hasPollInput() {
    return pollQuestionController.text.trim().isNotEmpty || pollOptionControllers.any((controller) => controller.text.trim().isNotEmpty);
  }

  bool _hasMediaAttachment() {
    return controller.postImages.isNotEmpty || controller.videoFile.value != null;
  }

  String _effectivePostType(bool hasPollInput) {
    if (controller.videoFile.value != null) return 'VIDEO';
    if (controller.postImages.isNotEmpty) return 'IMAGE';
    if (hasPollInput) return 'POLL';
    return 'TEXT';
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
          IconButton(icon: const Icon(Icons.photo_outlined), onPressed: _pickImages),
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () => _pickVideo(ImageSource.gallery)),
        ],
      ),
    );
  }

  Widget _postTypeChip(String type, IconData icon) {
    final selected = postType == type;
    return ChoiceChip(
      selected: selected,
      avatar: Icon(icon, size: 18, color: selected ? Colors.black : Colors.grey.shade700),
      label: Text(type),
      onSelected: (_) => _setPostType(type),
      selectedColor: const Color(0xFFFFC766),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildPollFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: pollQuestionController,
            decoration: InputDecoration(
              hintText: "Poll question",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(pollOptionControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pollOptionControllers[index],
                      decoration: InputDecoration(
                        hintText: "Option ${index + 1}",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  if (pollOptionControllers.length > 2)
                    IconButton(
                      onPressed: () => _removePollOption(index),
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                ],
              ),
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: pollOptionControllers.length >= 10 ? null : _addPollOption,
              icon: const Icon(Icons.add),
              label: const Text('Add option'),
            ),
          ),
        ],
      ),
    );
  }
}
