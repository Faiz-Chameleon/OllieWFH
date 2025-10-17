import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:ollie/CareCircle/interests/comments_screen_on_post.dart';
import 'package:ollie/CareCircle/interests/open_pdf.dart';
import 'package:ollie/CareCircle/interests/open_word_file.dart';
import 'package:ollie/CareCircle/interests/video_player_widget.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/blogs/blog_details_screen.dart';
import 'package:ollie/request_status.dart';
import '../care_circle_controller.dart';

class SavedPostsScreen extends StatelessWidget {
  SavedPostsScreen({super.key});
  final CareCircleController controller = Get.put(CareCircleController());

  final List<Map<String, dynamic>> savedPosts = [
    {
      "user": "Shelley",
      "time": "9:20 AM",
      "text": "Ever caught your pet doing something hilarious? Tell us the most mischievous thing your pet has ever done!",
      "image": "assets/images/Card (1).png",
    },
    {
      "user": "Shelley",
      "time": "9:20 AM",
      "text": "Calling all pet lovers! Drop a pic of your furry (or feathery) friend and tell us their funniest habit!",
      "image": "assets/images/Card (1).png",
    },
    {
      "user": "Shelley",
      "time": "9:20 AM",
      "text": "What's your pet’s favorite treat? Homemade or store-bought, share your top pet snack recommendations!",
      "image": null,
    },
    {"user": "Shelley", "time": "9:20 AM", "text": "Look at this adorable moment caught on camera!", "image": "assets/images/Card.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BGcolor,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Saved Posts",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (controller.getYourSavePostStatus.value == RequestStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.getYourSavePostStatus.value == RequestStatus.error) {
            return const Center(child: Text("Something went wrong"));
          } else if (controller.yourSavePostList.isEmpty) {
            return const Center(child: Text("No posts available"));
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: controller.yourSavePostList.length,

            itemBuilder: (context, index) {
              final post = controller.yourSavePostList[index];
              return Container(
                width: 1.sw,
                // height: 250.h,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
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
                            Text(controller.formatDate(post["createdAt"] ?? ""), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        PopupMenuButton(
                          shape: TooltipShapeBorder(),
                          itemBuilder: (context) => [const PopupMenuItem(value: 'report', child: Text("Report"))],
                          onSelected: (value) {
                            controller.postReport(post["id"] ?? "");
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

                    // Row(
                    //   children: [
                    //     // GestureDetector(
                    //     //   onTap: () {
                    //     //     var data = {"type": "user-posts", "postId": post.id.toString()};
                    //     //     controller.likeOrUnlikePost(data, index);
                    //     //   },
                    //     //   child: Icon(post["isLikePost"] == false ? Icons.thumb_up_alt_outlined : Icons.thumb_up, size: 18),
                    //     // ),
                    //     const SizedBox(width: 4),

                    //     // Text(post[""]),
                    //     const SizedBox(width: 16),
                    //     Row(
                    //       children: [
                    //         GestureDetector(
                    //           onTap: () {
                    //             Get.to(() => CommentsScreenOnPost(postId: post["id"].toString()));
                    //           },
                    //           child: Icon(Icons.comment_outlined, size: 18),
                    //         ),
                    //         SizedBox(width: 4),
                    //         // Text(post.cCount?.userpostcomments != null ? post.cCount!.userpostcomments.toString() : "0"),
                    //       ],
                    //     ),
                    //     const SizedBox(width: 16),
                    //     const Icon(Icons.remove_red_eye_outlined, size: 18),
                    //     const SizedBox(width: 4),
                    //     // Text(post.views.toString()),
                    //     // const Spacer(),
                    //     // Row(
                    //     //   children: [
                    //     //     // GestureDetector(
                    //     //     //   onTap: () {
                    //     //     //     controller.savePostToggle(post.id.toString(), index);
                    //     //     //   },
                    //     //     //   // child: Icon(post.isSavePost == false ? Icons.bookmark_border : Icons.bookmark_added, size: 18),
                    //     //     // ),
                    //     //     const SizedBox(width: 4),
                    //     //     const Text("Save"),
                    //     //   ],
                    //     // ),
                    //   ],
                    // ),
                  ],
                ),
              );
            },
          );
        }),
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
      return SizedBox(
        height: 200, // Slightly taller for video controls
        width: double.infinity,
        child: VideoPlayerWidget(
          videoUrl: url,
          autoPlay: false, // Don't autoplay by default
          looping: false,
        ),
      );
      // Later: integrate `video_player` package for playback
    } else if (extension == 'pdf') {
      // ✅ PDF
      return GestureDetector(
        onTap: () async {
          await openPdf(url);
        },
        child: Container(
          height: 150,
          width: double.infinity,
          color: Colors.red[100],
          child: const Center(child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 50)),
        ),
      );
    } else if (['doc', 'docx'].contains(extension)) {
      // ✅ Word document
      return GestureDetector(
        onTap: () async {
          await openDocFile(url);
        },
        child: Container(
          height: 150,
          width: double.infinity,
          color: Colors.blue[100],
          child: const Center(child: Icon(Icons.description, color: Colors.blue, size: 50)),
        ),
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
