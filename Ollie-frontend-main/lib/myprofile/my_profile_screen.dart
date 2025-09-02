// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/myprofile/delete_account_dialouge.dart';
import '../Subscription/credits/credits_sreen.dart';
import '../Subscription/wallet/wallet_screen.dart';
import 'edit_profile_screen.dart';
import 'my_profile_controller.dart';

class MyProfileScreen extends StatelessWidget {
  MyProfileScreen({super.key});
  final ProfileController controller = Get.put(ProfileController());
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFFFF2D9),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: userController.user.value?.image != null && userController.user.value?.image!.isNotEmpty == true
                    ? NetworkImage(userController.user.value!.image!)
                    : const AssetImage("assets/icons/Frame 1686560584.png") as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),

            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => CreditsSubscriptionScreen(), transition: Transition.fadeIn);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xff463C33), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Unlock Full Access. Get Premium Now!",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: controller.subscribe,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ksecondaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: const Text(
                                    "Subscribe Now",
                                    style: TextStyle(color: Black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 50), // Space for image positioning
                      ],
                    ),
                  ),
                ),

                // Positioned image
                const Positioned(
                  right: 30,
                  bottom: -45,
                  child: Image(image: AssetImage("assets/icons/Group 1000000907 (1).png"), height: 100, width: 95, fit: BoxFit.cover),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Obx(
              () => GestureDetector(
                onTap: () {
                  Get.to(() => WalletScreen(), transition: Transition.fadeIn);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xffFFE1A4), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Image(image: AssetImage("assets/icons/Frame 1686560309.png"), height: 60, width: 60, fit: BoxFit.cover),
                      const SizedBox(width: 12),
                      const Text("Wallet", style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      Text("\$${controller.walletBalance.value.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: controller.donate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xffFFE1A4), borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Image(image: AssetImage("assets/icons/Frame 1686560309.png"), height: 60, width: 60, fit: BoxFit.cover),
                    SizedBox(width: 12),
                    Text("Donate Now!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text("General", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTile(
              "Edit",
              "Adjust your preferences and personal details.",
              () => Get.to(() => EditProfileScreen(), transition: Transition.fadeIn),
            ),

            _buildTile("Privacy", "Manage what you share and how we protect it.", () => print("Privacy")),
            _buildTile("Account", "Manage your profile and preferences.", () => print("Account")),

            const SizedBox(height: 24),
            const Text("Help", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTile("FAQs", "Find answers to your most common questions.", () => print("FAQs")),
            _buildTile("Support", "Reach out for assistance anytime.", () => print("Support")),
            _buildTile("Privacy Policy", "Learn how we protect your information.", () => print("Privacy Policy")),
            _buildTile("Terms and Conditions", "Understand the terms of using Ollie.", () => print("Terms")),

            const SizedBox(height: 24),
            const Text("Delete Account", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              onTap: () {
                showDeleteAccountDialog(context);
              },
              title: Text("Delete Account"),
              // subtitle: Text(""),
              // trailing: const Icon(Icons.chevron_right),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            const SizedBox(height: 45),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String title, String subtitle, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
