import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/blogs/blog_details_screen.dart';
import 'package:ollie/blogs/filtered_blogs_screen.dart';
import 'package:ollie/blogs/topics_controller.dart';
import 'package:ollie/request_status.dart';
import 'blogs_controller.dart';

class LatestBlogsScreen extends StatefulWidget {
  final BlogsController controller;
  LatestBlogsScreen({super.key, required this.controller});

  @override
  State<LatestBlogsScreen> createState() => _LatestBlogsScreenState();
}

class _LatestBlogsScreenState extends State<LatestBlogsScreen> {
  // final BlogsController controller = Get.put(BlogsController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getLatestBlogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7E9),
        elevation: 0,
        title: const Text("Latest Blogs", style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
        actions: [
          // GestureDetector(
          //   onTap: () {
          //     _showSortBottomSheet(context, widget.controller);
          //   },
          //   child: Icon(Icons.tune, color: Colors.black),
          // ),
          SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (widget.controller.getLatestBlogsStatus.value == RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.controller.latestBlogsList.isEmpty) {
          return const Center(child: Text("No topics found."));
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Advertisement Box
              24.verticalSpace,

              // Blog List
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: widget.controller.latestBlogsList.length,
                    itemBuilder: (context, index) {
                      final blog = widget.controller.latestBlogsList[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => BlogDetailScreen(controller: widget.controller, blogId: blog.id));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(blog.image ?? "", width: 60, height: 60, fit: BoxFit.cover),
                              ),
                              12.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(blog.category?.name ?? "", style: const TextStyle(color: Colors.brown, fontSize: 12)),
                                    4.verticalSpace,
                                    Text(blog.title ?? "", style: const TextStyle(fontWeight: FontWeight.w600)),
                                    4.verticalSpace,
                                    Row(
                                      children: [
                                        Text(
                                          widget.controller.timeAgo(blog.createdAt.toString()),
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                        ),
                                        const SizedBox(width: 8),
                                        Text("6 min read", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),

                                        // if (blog["title"]!.contains(
                                        //       "Dumplings",
                                        //     ) ||
                                        //     blog["title"]!.contains(
                                        //       "Exercises",
                                        //     ) ||
                                        //     blog["title"]!.contains("Arthritis"))
                                        //   Container(
                                        //     margin: const EdgeInsets.only(
                                        //       left: 8,
                                        //     ),
                                        //     padding: const EdgeInsets.symmetric(
                                        //       horizontal: 8,
                                        //       vertical: 2,
                                        //     ),
                                        //     decoration: BoxDecoration(
                                        //       color: const Color(0xFFFFECA3),
                                        //       borderRadius: BorderRadius.circular(
                                        //         12,
                                        //       ),
                                        //     ),
                                        //     child: const Text(
                                        //       "Sponsored",
                                        //       style: TextStyle(
                                        //         fontSize: 11,
                                        //         fontWeight: FontWeight.w500,
                                        //       ),
                                        //     ),
                                        //   ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showSortBottomSheet(BuildContext context, BlogCategoryController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: BGcolor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sort By:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
              ],
            ),
            const Divider(),
            Obx(
              () => Column(
                children: [
                  _sortOption(controller, "Trending"),
                  _sortOption(controller, "Most Recent"),
                  _sortOption(controller, "Most Viewed"),
                  _sortOption(controller, "Least Viewed"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortOption(BlogCategoryController controller, String label) {
    return GestureDetector(
      onTap: () {
        controller.selectedSort.value = label;

        Get.back();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.selectedSort.value == label)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
              ),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(label),
            trailing: Radio<String>(
              value: label,
              groupValue: controller.selectedSort.value,
              onChanged: (val) {
                if (val != null) {
                  controller.selectedSort.value = val;
                  // applyFilter(val.toLowerCase());
                  Get.back(); // Close the bottom sheet
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // void applyFilter(String filter) {
  //   debugPrint("Applying filter: $filter for topicId: ${widget.topicId}");

  //   // Call the API with the appropriate parameters
  //   widget.controller.getBlogsByCategoryOnFilter(filter, widget.controller.blogsByTopicsList[0].categoryId ?? "").then((value) {
  //     Get.to(() => FilteredBlogsScreen(controller: widget.controller));
  //   });
  // }
}
