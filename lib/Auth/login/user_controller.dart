import 'package:get/get.dart';
import 'package:ollie/Auth/login/login_screen.dart';
import 'package:ollie/Auth/login/user_repository.dart';
import 'package:ollie/Models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/Auth/login/login_controller.dart';
import 'package:ollie/myprofile/profile_repository.dart';
import 'package:ollie/request_status.dart';

class UserController extends GetxController {
  final NewUserRepository userRepository = NewUserRepository();
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
    Get.offAll(() => Login_Screen());
  }

  var deleteAccountStatus = RequestStatus.idle.obs;
  Future<void> deleteAccount() async {
    deleteAccountStatus.value = RequestStatus.loading;

    final result = await userRepository.deleteUser();
    if (result['success'] == true) {
      logout();
      deleteAccountStatus.value = RequestStatus.success;
    } else {
      deleteAccountStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }
}
