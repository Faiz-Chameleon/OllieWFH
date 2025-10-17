import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'wallet_controller.dart';

class AddPaymentMethodScreen extends StatelessWidget {
  AddPaymentMethodScreen({super.key});

  final WalletController controller = Get.put(WalletController());

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
          "Add Payment Method",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, size: 25, color: Colors.black),
                SizedBox(width: 6),
                Expanded(
                  child: Text("All payment information is stored securely.", style: TextStyle(fontSize: 14, color: Colors.black54)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildField("Card Holder’s Name", controller.nameController),
            _buildField("Card Number", controller.cardController),

            Row(
              children: [
                Expanded(child: _buildField("Expiry Date", controller.expiryController)),
                const SizedBox(width: 12),
                Expanded(child: _buildField("CVV", controller.cvvController)),
              ],
            ),
            _buildField("Address Line 1", controller.address1Controller),
            _buildField("Address Line 2", controller.address2Controller),
            Row(
              children: [
                Expanded(child: _buildField("State", controller.stateController)),
                const SizedBox(width: 12),
                Expanded(child: _buildField("City", controller.cityController)),
              ],
            ),
            _buildField("Zip Code", controller.zipController),

            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = controller.nameController.text.trim();
                  final card = controller.cardController.text.trim();

                  if (name.isNotEmpty && card.isNotEmpty) {
                    controller.addPaymentMethod(name: name, card: card);
                    controller.clearPaymentForm();
                    Get.back();
                  } else {
                    Get.snackbar(
                      "Error",
                      "Please fill in required fields (Name & Card Number).",
                      backgroundColor: Colors.red.shade100,
                      colorText: Colors.black,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C322D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "...",
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: const Color(0xFFFFF7E5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
