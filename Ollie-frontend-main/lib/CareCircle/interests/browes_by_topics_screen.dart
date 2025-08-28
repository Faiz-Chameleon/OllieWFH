import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/interests/topics_post_screen.dart';
import 'package:ollie/request_status.dart';
import '../care_circle_controller.dart';

class BrowsebyTopicsScreen extends StatefulWidget {
  BrowsebyTopicsScreen({super.key});

  @override
  State<BrowsebyTopicsScreen> createState() => _BrowsebyTopicsScreenState();
}

class _BrowsebyTopicsScreenState extends State<BrowsebyTopicsScreen> {
  final CareCircleController controller = Get.put(CareCircleController());

  final List<String> favoriteTopics = ["Pets", "Fitness", "Food", "News"];

  final List<String> allTopics = ["Fitness", "Food", "Healthcare", "Hobbies", "Legal Aid", "Lifestyle", "News", "Pets"];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getInterestForPost().then((value) {
        controller.getYourInterestTopics();
      });
      _showInfoDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7E9),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Browse by Topic",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            // Advertisement Block

            // Favorite Topics
            const Text("Your Favourite Topics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.getYourInterestedTopicsStatus.value == RequestStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.getYourInterestedTopicsStatus.value == RequestStatus.empty) {
                return const Center(
                  child: Text(
                    "No favourite topics found.\nStart adding your favourites!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Obx(
                  () => Wrap(
                    spacing: 12, // horizontal space between items
                    runSpacing: 12, // vertical space between rows
                    children: controller.yourInterestedTopics.map((topic) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => TopicPostScreen(topic: topic['blogcategory']["name"] ?? "", topicId: topic['blogcategory']['id'] ?? ""));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFFFFE38E), borderRadius: BorderRadius.circular(16)),
                          child: Text(topic['blogcategory']['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // All Topics
            const Text("All Topics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.getBlogTopicsStatus.value == RequestStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                child: Obx(
                  () => Wrap(
                    spacing: 12, // horizontal space between items
                    runSpacing: 12, // vertical space between rows
                    children: controller.blogsTopicNames.map((topic) {
                      return GestureDetector(
                        onLongPress: () {
                          controller.markTopicAsFavourite(topic.id.toString());
                        },
                        onTap: () {
                          Get.to(() => TopicPostScreen(topic: topic.name ?? "", topicId: topic.id ?? ""));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFFFFE38E), borderRadius: BorderRadius.circular(16)),
                          child: Text(topic.name ?? "", style: const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChip(String topic) {
    return GestureDetector(
      onTap: () {
        Get.to(() => TopicPostScreen(topic: topic, topicId: ""));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFFFE38E), borderRadius: BorderRadius.circular(16)),
        child: Text(topic, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _showInfoDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text("Tip", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("By long-pressing on any topic, you can add it to your favorites.", style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // dismiss dialog
            child: const Text("Got it"),
          ),
        ],
      ),
      barrierDismissible: false, // user must tap "Got it"
    );
  }
}
