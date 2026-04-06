// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/request_status.dart';

import 'notification_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

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
            // Container(
            //   height: 80.h,
            //   width: double.infinity,
            //   margin: EdgeInsets.symmetric(vertical: 12.h),
            //   decoration: BoxDecoration(color: const Color(0xFFF6ECDB), borderRadius: BorderRadius.circular(12)),
            //   child: Center(
            //     child: Text(
            //       "ADVERTISEMENT",
            //       style: TextStyle(color: Colors.grey.shade600, letterSpacing: 1.2, fontSize: 14.sp),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Obx(() {
                if (controller.status.value == RequestStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.status.value == RequestStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.errorMessage.value.isEmpty ? "Failed to load notifications" : controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                        ),
                        SizedBox(height: 12.h),
                        ElevatedButton(onPressed: controller.fetchNotifications, child: const Text("Retry")),
                      ],
                    ),
                  );
                }

                if (controller.status.value == RequestStatus.empty) {
                  return Center(
                    child: Text(
                      "No notifications found",
                      style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchNotifications,
                  child: ListView.separated(
                    padding: EdgeInsets.only(bottom: 20.h),
                    itemCount: controller.notifications.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final item = controller.notifications[index];
                      return Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(18.r)),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: Colors.transparent,
                              backgroundImage: (item.image.isNotEmpty && item.image.startsWith('http'))
                                  ? NetworkImage(item.image)
                                  : const AssetImage("assets/icons/Group 1000000907 (1).png") as ImageProvider,
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Text(
                                item.message,
                                style: TextStyle(fontSize: 15.sp, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
