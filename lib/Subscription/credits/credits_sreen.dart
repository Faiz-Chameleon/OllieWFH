import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'credits_controller.dart';

class CreditsSubscriptionScreen extends StatelessWidget {
  CreditsSubscriptionScreen({super.key});
  final controller = Get.put(SubscriptionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/images/2092.png"), fit: BoxFit.cover),
            ),
          ),

          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const BackButton(color: Colors.black),
                title: Row(
                  children: [
                    const Text(
                      "Ollie",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 35),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFEFE6D4), borderRadius: BorderRadius.circular(16)),
                      child: const Text("Pro", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 180),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                              child: Text(
                                "Experience Ollie with unlimited access to all features!",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                            ),
                            Obx(
                              () => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(color: const Color(0xFF4B4036), borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  children: [
                                    buildOptionTile(PlanType.free, "Free", "\$0.00 / per year"),
                                    buildOptionTile(PlanType.basic, "Basic", "\$150.00 / per year"),
                                    buildOptionTile(PlanType.advanced, "Advanced", "\$250.00 / per year"),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text("What’s included?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: controller.planBenefits
                                      .map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              const Text("• ", style: TextStyle(fontSize: 16)),
                                              Expanded(
                                                child: Text(
                                                  e,
                                                  style: const TextStyle(fontSize: 18, color: Black, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("Google Play", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Starting today"),
                                  Text("3-day free trial", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Text("Starting 18 Nov 2024\nRs 3,650.00/year + tax"),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Text(
                                "\u2022 Cancel at any time in Subscriptions on Google Play\n"
                                "\u2022 You won’t be charged if you cancel before 18 Nov 2024.\n"
                                "\u2022 We’ll send you a reminder 2 days before your trial ends",
                                style: TextStyle(height: 1.5),
                              ),
                            ),
                            const Divider(),
                            const ListTile(leading: Icon(Icons.credit_card), title: Text("Mastercard-0745"), trailing: Icon(Icons.chevron_right)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text.rich(
                                TextSpan(
                                  text:
                                      "By tapping 'Subscribe', you agree that your subscription automatically renews until cancelled. We'll notify you if your price changes, as described in the ",
                                  children: [
                                    TextSpan(
                                      text: "Google Play Terms of Service.",
                                      style: TextStyle(decoration: TextDecoration.underline),
                                    ),
                                  ],
                                ),
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900],
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Subscribe", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3C3226),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Continue", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOptionTile(PlanType type, String title, String subtitle) {
    final controller = Get.find<SubscriptionController>();
    final isSelected = controller.selectedPlan.value == type;
    return ListTile(
      onTap: () => controller.selectPlan(type),
      leading: Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFFFFC857) : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 20),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: isSelected ? const Color(0xFFFFC857) : Colors.white70)),
    );
  }
}
