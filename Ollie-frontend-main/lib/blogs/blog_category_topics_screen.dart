// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/Constants.dart';
import 'package:ollie/blogs/blog_details_screen.dart';
import 'package:ollie/blogs/blogs_controller.dart';
import 'package:ollie/blogs/topics_controller.dart';
import 'package:ollie/request_status.dart';

class BlogCategoryScreen extends StatefulWidget {
  final BlogsController controller;
  final String category;
  final String topicId;
  BlogCategoryScreen({
    super.key,
    required this.category,
    required this.controller,
    required this.topicId,
  });

  @override
  State<BlogCategoryScreen> createState() => _BlogCategoryScreenState();
}

class _BlogCategoryScreenState extends State<BlogCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getBlogsByCategory(widget.topicId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final BlogCategoryController controller = Get.put(
      BlogCategoryController(widget.category),
    );

    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: BGcolor,
        elevation: 0,
        leading: BackButton(color: Black),
        title: Text(
          widget.category,
          style: const TextStyle(color: Black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Black),
            onPressed: () => _showSortBottomSheet(context, controller),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xff1e18180d),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("ADVERTISEMENT", style: TextStyle(color: grey)),
              ),
            ),
            20.verticalSpace,
            Obx(() {
              if (widget.controller.getBlogsByTopicsStatus.value ==
                  RequestStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: widget.controller.blogsByTopicsList.length,
                itemBuilder: (context, index) {
                  final blog = widget.controller.blogsByTopicsList[index];
                  return ListTile(
                    onTap: () {
                      Get.to(
                        () => BlogDetailScreen(
                          controller: widget.controller,
                          blogId: blog.id,
                        ),
                      );
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        blog.image ?? "",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      blog.title ?? "No title",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.brown,
                          ),
                        ),
                        4.verticalSpace,
                        Row(
                          children: [
                            Text(
                              widget.controller.timeAgo(
                                blog.createdAt.toString(),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // const Text(
                            //   "6 min read.",
                            //   style: TextStyle(
                            //     fontSize: 12,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                            // if (blog['sponsored'] == true)
                            //   Container(
                            //     margin: const EdgeInsets.only(left: 8),
                            //     padding: const EdgeInsets.symmetric(
                            //       horizontal: 8,
                            //       vertical: 2,
                            //     ),
                            //     decoration: BoxDecoration(
                            //       color: const Color(0xFFFFE08A),
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //     child: const Text(
                            //       "Sponsored",
                            //       style: TextStyle(fontSize: 10),
                            //     ),
                            //   ),
                          ],
                        ),
                      ],
                    ),
                  );
                  // ListTile(
                  //   leading: Image.network(blog.image ?? ""),
                  //   title: Text(blog.title ?? "No title"),
                  //   subtitle: Text(blog.category?.name ?? ""),
                  // );
                },
              );
              // return Column(
              //   children: controller.blogs.map((blog) {
              //     return
              //     Column(
              //       children: [
              //         ListTile(
              //           leading: ClipRRect(
              //             borderRadius: BorderRadius.circular(8),
              //             child: Image.asset(
              //               blog['image']!,
              //               width: 50,
              //               height: 50,
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //           title: Text(
              //             blog['title']!,
              //             style: const TextStyle(fontWeight: FontWeight.w600),
              //           ),
              //           subtitle: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 widget.category,
              //                 style: const TextStyle(
              //                   fontSize: 13,
              //                   color: Colors.brown,
              //                 ),
              //               ),
              //               4.verticalSpace,
              //               Row(
              //                 children: [
              //                   const Text(
              //                     "1 day ago",
              //                     style: TextStyle(
              //                       fontSize: 12,
              //                       color: Colors.grey,
              //                     ),
              //                   ),
              //                   const SizedBox(width: 10),
              //                   const Text(
              //                     "6 min read.",
              //                     style: TextStyle(
              //                       fontSize: 12,
              //                       color: Colors.grey,
              //                     ),
              //                   ),
              //                   if (blog['sponsored'] == true)
              //                     Container(
              //                       margin: const EdgeInsets.only(left: 8),
              //                       padding: const EdgeInsets.symmetric(
              //                         horizontal: 8,
              //                         vertical: 2,
              //                       ),
              //                       decoration: BoxDecoration(
              //                         color: const Color(0xFFFFE08A),
              //                         borderRadius: BorderRadius.circular(10),
              //                       ),
              //                       child: const Text(
              //                         "Sponsored",
              //                         style: TextStyle(fontSize: 10),
              //                       ),
              //                     ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),

              //         const Divider(),
              //       ],
              //     );

              //   }).toList(),
              // );
            }),
            100.verticalSpace,
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(
    BuildContext context,
    BlogCategoryController controller,
  ) {
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
                const Text(
                  "Sort By:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Get.back(),
                ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.selectedSort.value == label)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          trailing: Radio<String>(
            value: label,
            groupValue: controller.selectedSort.value,
            onChanged: (val) => controller.selectedSort.value = val!,
          ),
          onTap: () => controller.selectedSort.value = label,
        ),
      ],
    );
  }
}
