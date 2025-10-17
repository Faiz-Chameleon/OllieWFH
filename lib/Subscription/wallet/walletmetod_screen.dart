import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'payment_method_screen.dart';
import 'wallet_controller.dart';

class TopUpScreen extends StatelessWidget {
  TopUpScreen({super.key});

  final WalletController controller = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF2D9),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Wallet',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method Section
            GestureDetector(
              onTap: () {
                Get.to(() => PaymentMethodsScreen(), transition: Transition.fadeIn);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.white, child: Image.asset("assets/icons/Frame 1686560309 (2) 2.png")),
                    const SizedBox(width: 15, height: 20),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Tap to select", style: TextStyle(color: Colors.black54)),
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
              decoration: BoxDecoration(color: const Color(0xffFFE1A4), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Enter amount", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Obx(() => Text("\$${controller.amount}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFFC54D) : Color(0xffFFC866),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text("\$$amount", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ],
              ),
            ),
            350.verticalSpace,
            // Top Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C322D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Top Up Securely", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
