import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletController extends GetxController {
  // Top-up logic
  final RxInt selectedAmount = 0.obs;
  final List<int> presetAmounts = [55, 60, 65];

  void setAmount(int amount) {
    selectedAmount.value = amount;
  }

  int get amount => selectedAmount.value;

  // Payment method logic
  final RxInt selectedPaymentIndex = 0.obs;

  final RxList<Map<String, String>> paymentMethods = <Map<String, String>>[
    {"name": "Julia", "card": "xxxx - xxxx - xxxx - xxxx"},
    {"name": "Julia", "card": "xxxx - xxxx - xxxx - xxxx"},
  ].obs;

  void selectPaymentMethod(int index) {
    selectedPaymentIndex.value = index;
  }

  int get selectedPayment => selectedPaymentIndex.value;

  void addPaymentMethod({required String name, required String card}) {
    paymentMethods.add({"name": name, "card": card});
  }

  // Add Payment Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cardController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipController = TextEditingController();

  void clearPaymentForm() {
    nameController.clear();
    cardController.clear();
    expiryController.clear();
    cvvController.clear();
    address1Controller.clear();
    address2Controller.clear();
    stateController.clear();
    cityController.clear();
    zipController.clear();
  }
}
