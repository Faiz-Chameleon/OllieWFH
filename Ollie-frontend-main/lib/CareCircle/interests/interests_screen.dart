// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/interests/comments_screen_on_post.dart';
import 'package:ollie/CareCircle/interests/topics_post_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/request_status.dart';

import 'browes_by_topics_screen.dart';
import 'save_post_screen.dart';

class InterestsScreen extends StatelessWidget {
  InterestsScreen({super.key});
  final CareCircleController controller = Get.put(CareCircleController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.verticalSpace,

          // Carousel Card
          SizedBox(
            height: 260.h,
            child: Obx(() {
              if (controller.getYourPostAsInteresStatus.value == RequestStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.getYourPostAsInteresStatus.value == RequestStatus.error) {
                return const Center(child: Text("Something went wrong"));
              } else if (controller.postAccordingToMyInterest.isEmpty) {
                return const Center(child: Text("No posts available"));
              }
              return Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: controller.postAccordingToMyInterest.length,
                      controller: PageController(viewportFraction: 0.9),
                      onPageChanged: (index) => controller.currentPage.value = index,
                      itemBuilder: (context, index) {
                        final post = controller.postAccordingToMyInterest[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => TopicPostScreen(topic: post.category?.name ?? "", topicId: post.categoryId ?? ""));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(color: cardbg, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  fit: BoxFit.fill,
                                  post.image ?? "",
                                  height: 110,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 110,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    );
                                  },
                                ),
                                20.verticalSpace,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(post.category?.name ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        // CircleAvatar(radius: 8, backgroundColor: Color(0xFFD6CCBC)),
                                        // CircleAvatar(radius: 8, backgroundColor: Color(0xFFD6CCBC)),
                                        CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Color(0xFF3C3129),
                                          child: Text(post.views.toString(), style: TextStyle(fontSize: 8, color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  8.verticalSpace,
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(controller.postAccordingToMyInterest.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.currentPage.value == index ? Colors.black : Colors.grey,
                          ),
                        );
                      }),
                    );
                  }),
                ],
              );
            }),
          ),

          20.verticalSpace,

          // Advertisement
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(color: Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Text("ADVERTISEMENT", style: TextStyle(color: Colors.black54)),
            ),
          ),

          20.verticalSpace,

          // Browse by Topics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Browse by Topics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: () => Get.to(() => BrowsebyTopicsScreen(), transition: Transition.fadeIn), // Navigate to full screen
                child: const Text("See All", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),

          10.verticalSpace,
          Obx(() {
            if (controller.getBlogTopicsStatus.value == RequestStatus.loading) {
              return Center(child: const CircularProgressIndicator());
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: controller.blogsTopicNames.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        // onTap: () =>
                        //     Get.to(() => BlogCategoryScreen(category: topic.name ?? "", controller: controller, topicId: topic.id.toString())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFFFFE08A), borderRadius: BorderRadius.circular(18)),
                          child: Text(topic.name ?? "", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),

          20.verticalSpace,

          // Saved Posts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Saved Posts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: () {
                  Get.to(() => SavedPostsScreen(), transition: Transition.fadeIn);
                },

                child: Text("See All", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          10.verticalSpace,

          Obx(() {
            if (controller.getYourSavePostStatus.value == RequestStatus.loading) {
              return Center(child: CircularProgressIndicator());
            } else if (controller.yourSavePostList.isEmpty) {
              return Center(
                child: Text("No saved posts found", style: TextStyle(color: Colors.grey)),
              );
            } else {
              var post = controller.yourSavePostList[0];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(post["user"]["image"] ?? ""),
                          child: post["user"]["image"] == null || post["user"]["image"] == ""
                              ? Icon(Icons.person, size: 20) // Default icon when there is no image
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post["user"]["firstName"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                            // Text(controller.formatDate(post.createdAt ?? ""), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        PopupMenuButton(
                          shape: TooltipShapeBorder(),
                          itemBuilder: (context) => [const PopupMenuItem(value: 'report', child: Text("Report"))],
                          onSelected: (value) {
                            controller.postReport(post.id ?? "");
                          },
                          icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("Title: ${post["userPost"]["title"]}", style: const TextStyle(fontSize: 14)),
                    Text('Description: ${post["userPost"]["content"]}' ?? "", style: const TextStyle(fontSize: 14)),

                    if (post["userPost"]["image"] != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildMediaWidget(post["userPost"]["image"].toString())),
                    ] else ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset("assets/images/Card.png", height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],

                    // if (post.document != null) ...[
                    //   const SizedBox(height: 10),
                    //   Row(
                    //     children: [
                    //       const Icon(
                    //         Icons.insert_drive_file,
                    //         color: Colors.black,
                    //       ),
                    //       const SizedBox(width: 8),
                    //       Expanded(
                    //         child: Text(post.document!.path.split('/').last),
                    //       ),
                    //     ],
                    //   ),
                    // ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            var data = {"type": "user-posts", "postId": post["id"].toString()};
                            controller.likeOrUnlikePost(data, 0);
                          },
                          // child: Icon(post.isLikePost == false ? Icons.thumb_up_alt_outlined : Icons.thumb_up, size: 18),
                        ),
                        const SizedBox(width: 4),
                        Text(post["userPost"]["views"].toString() ?? "0"),

                        const SizedBox(width: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => CommentsScreenOnPost(postId: post.id.toString()));
                              },
                              child: Icon(Icons.comment_outlined, size: 18),
                            ),
                            SizedBox(width: 4),
                            // Text(post.cCount?.userpostcomments != null ? post.cCount!.userpostcomments.toString() : "0"),
                          ],
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.remove_red_eye_outlined, size: 18),
                        const SizedBox(width: 4),
                        // Text(post.views.toString()),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            controller.savePostToggle(post.id.toString(), 0);
                          },
                          // child: Icon(post.isSavePost == false ? Icons.bookmark_border : Icons.bookmark_added, size: 18),
                        ),
                        const SizedBox(width: 4),
                        const Text("Save"),
                      ],
                    ),
                  ],
                ),
              );
            }
          }),
          200.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildMediaWidget(String url) {
    final extension = url.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      // ✅ Image
      return Image.network(
        url,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },
      );
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      // ✅ Video
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.black,
        child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)),
      );
      // Later: integrate `video_player` package for playback
    } else if (extension == 'pdf') {
      // ✅ PDF
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.red[100],
        child: const Center(child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 50)),
      );
    } else if (['doc', 'docx'].contains(extension)) {
      // ✅ Word document
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.blue[100],
        child: const Center(child: Icon(Icons.description, color: Colors.blue, size: 50)),
      );
    } else {
      // ❌ Unknown file type
      return _placeholder();
    }
  }

  Widget _placeholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.insert_drive_file, color: Colors.grey),
    );
  }
}
