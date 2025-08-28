// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/Models/user_model.dart';
import 'package:ollie/myprofile/profile_repository.dart';

import '../Subscription/wallet/donate_now_screen.dart';

class ProfileController extends GetxController {
  final UserController userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    if (userController.user.value != null) {
      firstNameController.text = userController.user.value!.firstName ?? '';
      lastNameController.text = userController.user.value!.lastName ?? '';
      emailController.text = userController.user.value!.email ?? '';
      phoneController.text = userController.user.value!.phoneNumber ?? '';
      dateOfBirth.value = userController.user.value!.dateOfBirth ?? "";
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final UserRepository _userRepository = UserRepository();
  var walletBalance = 50.0.obs;

  // Editable fields
  var firstName = 'Julia'.obs;
  var lastName = 'Michael'.obs;
  var email = 'julia@hotmail.com'.obs;
  var phone = '+1 000 000 00'.obs;
  var selectedDate = ''.obs;
  var showCalendar = false.obs;

  var gender = ''.obs;
  var showGenderDropdown = false.obs;

  var profileImage = Rx<File?>(null);

  void toggleCalendar() => showCalendar.toggle();

  void selectDate(DateTime date) {
    selectedDate.value = "${date.day}/${date.month}/${date.year}";
    showCalendar.value = false;
  }

  void toggleGenderDropdown() => showGenderDropdown.toggle();

  void selectGender(String value) {
    gender.value = value;
    showGenderDropdown.value = false;
  }

  // void saveProfile() {
  //   print("Saved profile:");
  //   print("Name: ${firstName.value} ${lastName.value}");
  //   print("Email: ${email.value}");
  //   print("Phone: ${phone.value}");
  //   print("DOB: ${selectedDate.value}");
  //   print("Gender: ${gender.value}");
  // }

  void donate() {
    Get.to(() => DonateNowScreen(), transition: Transition.fadeIn);
  }

  void subscribe() {
    print("Subscribe Now tapped.");
  }

  Future<void> pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = File(picked.path);
    }
  }

  Future<void> captureImageWithCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      profileImage.value = File(picked.path);
    }
  }

  var dateOfBirth = ''.obs; // Observable for Date of Birth

  // Method to select the Date of Birth
  Future<void> selectDateNew(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(context: context, initialDate: initialDate, firstDate: firstDate, lastDate: lastDate);

    if (pickedDate != null) {
      // Format the date as per your requirement
      dateOfBirth.value = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
    }
  }

  var isLoading = false.obs;
  Future<void> saveProfile() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    // Validate the fields before calling the update
    if (firstName.value.isEmpty || lastName.value.isEmpty || email.value.isEmpty || gender.value.isEmpty) {
      // Show validation error if any field is empty
      Get.snackbar("Error", "Please fill all the fields.");
      return;
    }
    isLoading.value = true;

    // Call the repository's method to update the profile
    final response = await _userRepository.updateProfile(
      firstName: firstNameController.value.text,
      lastName: lastNameController.value.text,
      email: emailController.value.text,
      gender: gender.value,
      filePath: profileImage.value!.path,
      token: requiredToken,
    );
    isLoading.value = false;

    // Check the response and show success or error
    if (response['success']) {
      final userModel = UserModel.fromJson(response);
      final userController = Get.put(UserController());

      if (userModel.data != null) {
        userController.setUser(userModel.data!);
      }
      Get.close(1);
      // Profile updated successfully
      Get.snackbar("Success", "Profile updated successfully!");
    } else {
      // Handle error
      Get.snackbar("Error", response['message']);
    }
  }
}
