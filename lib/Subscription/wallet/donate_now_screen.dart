import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/Constants.dart';
import 'payment_method_screen.dart';
import 'wallet_controller.dart';

class DonateNowScreen extends StatelessWidget {
  DonateNowScreen({super.key});

  final WalletController controller = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        backgroundColor: BGcolor,
        elevation: 0,
        leading: const BackButton(color: Black),
        title: const Text(
          "Donate Now!",
          style: TextStyle(color: Black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method Card
            GestureDetector(
              onTap: () {
                Get.to(
                  () => PaymentMethodsScreen(),
                  transition: Transition.fadeIn,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        "assets/icons/Frame 1686560309 (2) 2.png",
                      ),
                    ),
                    const SizedBox(width: 15, height: 20),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Method",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tap to select",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Enter Amount Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffFFE1A4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter amount",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Text(
                      "\$${controller.amount}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.black26),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: controller.presetAmounts.map((amount) {
                      return Obx(() {
                        final isSelected = controller.amount == amount;
                        return GestureDetector(
                          onTap: () => controller.setAmount(amount),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFC54D)
                                  : const Color(0xffFFC866),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "\$$amount",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text("Note:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              "All donations are used to support wellness programs, events, and essential features that enhance the lives of our users. "
              "This includes health challenges, social engagement activities, and access to resources within the app.\n\n"
              "Your donation is processed through secure, encrypted payment gateways. "
              "We do not store any financial information, and your privacy is fully protected.",
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            170.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.amount == 0) {
                    Get.snackbar(
                      "Oops!",
                      "Please select an amount to donate.",
                      backgroundColor: Colors.red.shade100,
                      colorText: Colors.black,
                    );
                  } else {
                    // Trigger donation logic here
                    Get.snackbar(
                      "Thank You!",
                      "Your donation of \$${controller.amount} has been received.",
                      backgroundColor: Colors.green.shade100,
                      colorText: Colors.black,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C322D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Donate Now",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
