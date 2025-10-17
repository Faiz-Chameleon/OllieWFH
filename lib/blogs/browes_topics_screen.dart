// ignore_for_file: deprecated_member_use, use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/blogs/Blog_category_topics_screen.dart';
import 'package:ollie/blogs/blogs_controller.dart';
import 'package:ollie/request_status.dart';

class BrowseTopicsScreen extends StatefulWidget {
  final BlogsController controller;
  BrowseTopicsScreen({super.key, required this.controller});

  @override
  State<BrowseTopicsScreen> createState() => _BrowseTopicsScreenState();
}

class _BrowseTopicsScreenState extends State<BrowseTopicsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getBlogsTopics();
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
          "Browse Topics",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Text("ADVERTISEMENT", style: TextStyle(color: Colors.brown)),
              ),
            ),
            24.verticalSpace,
            Text(
              "All Topics",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
            ),
            16.verticalSpace,
            Expanded(
              child: Obx(() {
                if (widget.controller.getBlogTopicsStatus.value == RequestStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (widget.controller.blogsTopicNames.isEmpty) {
                  return const Center(child: Text("No topics found."));
                }
                return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.6,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: widget.controller.blogsTopicNames.map((topic) {
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => BlogCategoryScreen(category: topic.name ?? "", controller: widget.controller, topicId: topic.id.toString())),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFFFE08A), borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(topic.name ?? "", style: const TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
                              child: Text(" articles", style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
