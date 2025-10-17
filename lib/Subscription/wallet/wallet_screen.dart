import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../credits/credits_sreen.dart';
import 'payment_method_screen.dart';
import 'wallet_controller.dart';
import 'walletmetod_screen.dart';

class WalletScreen extends StatelessWidget {
  final WalletController controller = Get.put(WalletController());

  WalletScreen({super.key});

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
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xffFFE1A4), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Image.asset("assets/icons/Frame 1686560309.png", width: 40, height: 40),
                      ),
                      SizedBox(width: 10),
                      Text("Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.help_outline),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("\$50.00", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => TopUpScreen(), transition: Transition.fadeIn);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFFC866),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        "Top Up",
                        style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTile(
              icon: Icons.credit_card,
              title: 'Payment Methods',
              onTap: () {
                Get.to(() => PaymentMethodsScreen(), transition: Transition.fadeIn);
              },
            ),
            const SizedBox(height: 12),
            _buildTile(
              icon: Icons.monetization_on,
              title: 'Top up Credits',
              onTap: () {
                Get.to(() => CreditsSubscriptionScreen(), transition: Transition.fadeIn);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(color: const Color(0xFFFDF1E3), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
