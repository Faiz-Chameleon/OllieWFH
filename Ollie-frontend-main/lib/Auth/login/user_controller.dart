import 'package:get/get.dart';
import 'package:ollie/Auth/login/login_screen.dart';
import 'package:ollie/Models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/Auth/login/login_controller.dart';

class UserController extends GetxController {
  var user = Rxn<UserData>();

  void setUser(UserData userData) {
    user.value = userData;
  }

  void clearUser() {
    user.value = null;
  }

  // Logout method that clears all saved data
  Future logout() async {
    final loginController = Get.find<LoginController>();
    await loginController.clearAllSavedData();
    clearUser();
    // Navigate to login screen
    Get.offAll(() => Login_Screen()); // or use Get.offAll() with your login screen
  }
}
