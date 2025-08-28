import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sos_controller.dart';

class SOSScreen extends StatelessWidget {
  SOSScreen({super.key});

  final SOSController controller = Get.put(SOSController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF3DD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "sos",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.info_outline, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("In an emergency? Alert your contacts or call for help instantly.", style: TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 20),

            // SOS button
            GestureDetector(
              onTap: () => controller.showSOSBottomSheet(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFE2645A), borderRadius: BorderRadius.circular(20)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tap to\nsend SOS",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text("Tap to call emergency services.", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Emergency contacts
            GestureDetector(
              onTap: () => controller.showEmergencyContactSheet(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF3DD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2645A), width: 2),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Emergency\nContacts",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE2645A)),
                    ),
                    SizedBox(height: 10),
                    Text("Tap to notify your loved ones.", style: TextStyle(color: Color(0xFFE2645A))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Advertisement Placeholder
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(color: const Color(0xFFF6ECDB), borderRadius: BorderRadius.circular(10)),
              child: const Center(
                child: Text("ADVERTISEMENT", style: TextStyle(letterSpacing: 2, color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
