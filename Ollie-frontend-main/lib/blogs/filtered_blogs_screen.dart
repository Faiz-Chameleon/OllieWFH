import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/blogs/blog_details_screen.dart';
import 'package:ollie/blogs/blogs_controller.dart';
import 'package:ollie/request_status.dart';

class FilteredBlogsScreen extends StatefulWidget {
  final BlogsController controller;
  const FilteredBlogsScreen({super.key, required this.controller});

  @override
  State<FilteredBlogsScreen> createState() => _FilteredBlogsScreenState();
}

class _FilteredBlogsScreenState extends State<FilteredBlogsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: BGcolor,
        elevation: 0,
        leading: BackButton(color: Black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Text("ADVERTISEMENT", style: TextStyle(color: grey)),
              ),
            ),
            20.verticalSpace,
            Obx(() {
              if (widget.controller.blogsByTopicsListOnFilter.isEmpty) {
                return const Center(child: Text("No blogs available"));
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: widget.controller.blogsByTopicsListOnFilter.length,
                itemBuilder: (context, index) {
                  final blog = widget.controller.blogsByTopicsListOnFilter[index];
                  return ListTile(
                    onTap: () {
                      Get.to(() => BlogDetailScreen(controller: widget.controller, blogId: blog.id));
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(blog.image ?? "", width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(blog.title ?? "No title", style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(blog.category?.name ?? "", style: const TextStyle(fontSize: 13, color: Colors.brown)),
                        4.verticalSpace,
                        Row(
                          children: [
                            Text(widget.controller.timeAgo(blog.createdAt.toString()), style: TextStyle(fontSize: 12, color: Colors.grey)),
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
}
