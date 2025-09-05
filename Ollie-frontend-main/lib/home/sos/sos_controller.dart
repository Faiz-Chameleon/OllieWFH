import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSController extends GetxController {
  void showSOSBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDF3DD),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) {
        return SizedBox(
          width: double.infinity,
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "SOS",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFE2645A)),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 300.w,
                child: ElevatedButton(
                  onPressed: () {
                    _launchDialer("119");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2645A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Call 119", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchDialer(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar("Error", "Could not open dialer", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void showEmergencyContactSheet(BuildContext context, String contactNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDF3DD),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) {
        return SizedBox(
          width: double.infinity,
          height: 240,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Emergency Contact",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFE2645A)),
              ),
              const SizedBox(height: 20),

              // Call Button
              SizedBox(
                width: 390.w,
                child: ElevatedButton(
                  onPressed: () {
                    _launchDialer(contactNumber);
                    // Simulate call
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2645A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Call", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 10),

              // Message Button
              // SizedBox(
              //   width: 390.w,
              //   child: OutlinedButton(
              //     onPressed: () {
              //       // Simulate message
              //     },
              //     style: OutlinedButton.styleFrom(
              //       side: const BorderSide(color: Color(0xFFE2645A), width: 2),
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //     ),
              //     child: const Text("Message", style: TextStyle(fontSize: 16, color: Color(0xFFE2645A))),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
