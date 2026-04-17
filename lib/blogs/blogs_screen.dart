import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
          title: Text(
            "Blogs",
            style: GoogleFonts.darkerGrotesque(color: Black, fontSize: 24.sp, fontWeight: FontWeight.w700, height: 1.1),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                children: [
                  Image.asset("assets/icons/MagnifyingGlass.png", scale: 3.4),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => NotificationsScreen(), transition: Transition.fadeIn);
                    },
                    child: Image.asset("assets/icons/Vector (2).png", scale: 3.4),
                  ),
                  SizedBox(width: 12.w),
                  // GestureDetector(
                  //   onTap: () {
                  //     Get.to(() => CreditsSubscriptionScreen(), transition: Transition.fadeIn);
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  //     decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(20)),
                  //     child: Row(
                  //       children: [
                  //         Image.asset("assets/icons/Vector (1).png", scale: 4),
                  //         const SizedBox(width: 5),
                  //         Text("0", style: GoogleFonts.darkerGrotesque(fontWeight: FontWeight.bold)),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: false,
            labelColor: Black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: kprimaryColor,
            indicatorWeight: 3.5,
            labelStyle: GoogleFonts.darkerGrotesque(fontWeight: FontWeight.w700, fontSize: 21.sp, height: 1.1),
            unselectedLabelStyle: GoogleFonts.darkerGrotesque(fontWeight: FontWeight.w600, fontSize: 20.sp, height: 1.1),
            onTap: (index) {
              // Handle tab changes here
              final blogTypes = ["popular", "trending", "recent"];
              controller.currentTab.value = blogTypes[index];
              controller.loadBlogForTab(blogTypes[index]);
            },
            tabs: [
              Tab(
                child: Text(
                  "Popular",
                  style: GoogleFonts.darkerGrotesque(fontSize: 20.sp, fontWeight: FontWeight.w700),
                ),
              ),
              Tab(
                child: Text(
                  "Trending",
                  style: GoogleFonts.darkerGrotesque(fontSize: 20.sp, fontWeight: FontWeight.w700),
                ),
              ),
              Tab(
                child: Text(
                  "Recent",
                  style: GoogleFonts.darkerGrotesque(fontSize: 20.sp, fontWeight: FontWeight.w700),
                ),
              ),
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
