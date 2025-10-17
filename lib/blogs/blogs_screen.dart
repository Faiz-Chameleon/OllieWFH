import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Subscription/credits/credits_sreen.dart';
import 'package:ollie/blogs/popular_blogs_screen.dart';
import 'package:ollie/home/notifications/notificatins_screen.dart';
import 'blogs_controller.dart';

class BlogsScreen extends StatelessWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BlogsController controller = Get.put(BlogsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7E9),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: BGcolor,
          elevation: 0,
          title: const Text(
            "Blogs",
            style: TextStyle(
              color: Black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Image.asset("assets/icons/MagnifyingGlass.png", scale: 4),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => NotificationsScreen(),
                        transition: Transition.fadeIn,
                      );
                    },
                    child: Image.asset("assets/icons/Vector (2).png", scale: 4),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => CreditsSubscriptionScreen(),
                        transition: Transition.fadeIn,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: kprimaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Image.asset("assets/icons/Vector (1).png", scale: 4),
                          const SizedBox(width: 5),
                          const Text(
                            "0",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: false,
            labelColor: Black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kprimaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            onTap: (index) {
              // Handle tab changes here
              final blogTypes = ["popular", "trending", "recent"];
              controller.currentTab.value = blogTypes[index];
              controller.loadBlogForTab(blogTypes[index]);
            },
            tabs: const [
              Tab(text: "Popular"),
              Tab(text: "Trending"),
              Tab(text: "Recent"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Single instance that handles all tabs
            popular_screen(controller: controller),
            popular_screen(controller: controller),
            popular_screen(controller: controller),
          ],
        ),
      ),
    );
  }
}
