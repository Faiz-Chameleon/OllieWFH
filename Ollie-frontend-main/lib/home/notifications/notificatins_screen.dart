// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {"avatar": "assets/images/user1.png", "text": "Your daily check-in is ready. See what’s new in your community today!"},
      {"avatar": "assets/icons/octo.png", "text": "Forget something? Your saved reminders are just a tap away."},
      {"avatar": "assets/images/user2.png", "text": "Someone replied to your post! Tap to see what they said."},
      {"avatar": "assets/images/user3.png", "text": "Someone replied to your post! Tap to see what they said."},
      {"avatar": "assets/icons/octo.png", "text": "Your daily task list is ready! Let’s stay on top of things today."},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCF1DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF1DE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Container(
              height: 80.h,
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(color: const Color(0xFFF6ECDB), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  "ADVERTISEMENT",
                  style: TextStyle(color: Colors.grey.shade600, letterSpacing: 1.2, fontSize: 14.sp),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: 20.h),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(18.r)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: Colors.transparent,
                          backgroundImage: const AssetImage("assets/icons/Group 1000000907 (1).png"),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Text(
                            item["text"]!,
                            style: TextStyle(fontSize: 15.sp, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
