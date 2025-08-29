// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
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

          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     children: ["Pets", "Fitness", "Food", "Healthcare"]
          //         .map(
          //           (topic) => GestureDetector(
          //             onTap: () {
          //               Get.to(() => TopicPostScreen(topic: topic));
          //             },
          //             child: Container(
          //               margin: const EdgeInsets.only(right: 10),
          //               padding: const EdgeInsets.symmetric(
          //                 horizontal: 16,
          //                 vertical: 15,
          //               ),
          //               decoration: BoxDecoration(
          //                 color: const Color(0xFFFFE38E),
          //                 borderRadius: BorderRadius.circular(15),
          //               ),
          //               child: Text(
          //                 topic,
          //                 style: const TextStyle(fontWeight: FontWeight.w500),
          //               ),
          //             ),
          //           ),
          //         )
          //         .toList(),
          //   ),
          // ),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardbg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(radius: 25, backgroundImage: AssetImage("assets/icons/Frame 1686560584.png")),
                    10.horizontalSpace,
                    Text("Shelley", style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    Icon(Icons.more_horiz),
                  ],
                ),
                10.verticalSpace,
                const Text(
                  "Ever caught your pet doing something hilarious? Tell us the most mischievous thing your pet has ever done!",
                  style: TextStyle(fontSize: 14),
                ),
                10.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, size: 18),
                    5.horizontalSpace,
                    Text("634"),
                    15.horizontalSpace,
                    Icon(Icons.chat_bubble_outline, size: 18),
                    5.horizontalSpace,
                    Text("634"),
                    15.horizontalSpace,
                    Icon(Icons.remove_red_eye_outlined, size: 18),
                    5.horizontalSpace,
                    Text("634"),
                    15.horizontalSpace,
                    Spacer(),
                    Icon(Icons.bookmark, size: 18),
                    Text("Saved"),
                  ],
                ),
              ],
            ),
          ),

          200.verticalSpace,
        ],
      ),
    );
  }
}
