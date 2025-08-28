// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/CreateProfile/createProfile.dart';
import 'package:ollie/Auth/auth_repository.dart';
import 'package:ollie/Auth/interests/wellcome_sreen.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/Models/user_model.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/Auth/login/login_screen.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository = AuthRepository();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RxBool rememberMe = false.obs;
  RxBool isPasswordVisible = false.obs;
  var isAutoLoggingIn = false.obs;

  // Auto-login navigation flags
  var shouldNavigateToProfile = false.obs;
  var shouldNavigateToHome = false.obs;
  var autoLoginUserData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    print('🚀 LoginController onInit called');

    // Test GetX functionality
    testGetX();

    // Check token status
    checkTokenStatus();

    // Load saved credentials when controller initializes
    loadSavedCredentials();
    // Try to auto-login if user has a valid token
    attemptAutoLogin();
  }

  // Test method to verify GetX is working
  void testGetX() {
    print('🧪 Testing GetX functionality...');
    print(
      '  - Get.isRegistered<LoginController>: ${Get.isRegistered<LoginController>()}',
    );
    print(
      '  - Get.isRegistered<Login_Screen>: ${Get.isRegistered<Login_Screen>()}',
    );
    print('  - Current route: ${Get.currentRoute}');

    // Check user state
    try {
      final userController = Get.find<UserController>();
      print('  - UserController found: ${userController.user.value != null}');
      if (userController.user.value != null) {
        print('  - User logged in: ${userController.user.value!.firstName}');
      }
    } catch (e) {
      print('  - UserController not found: $e');
    }

    // Check if required screens are available
    checkRequiredScreens();
  }

  // Check if required screens are available
  void checkRequiredScreens() {
    print('🔍 Checking required screens...');
    try {
      // Try to create instances to see if they exist
      CreateProfileScreen();
      print('  ✅ CreateProfileScreen: Available');
    } catch (e) {
      print('  ❌ CreateProfileScreen: Not available - $e');
    }

    try {
      ConvexStyledBarScreen();
      print('  ✅ ConvexStyledBarScreen: Available');
    } catch (e) {
      print('  ❌ ConvexStyledBarScreen: Not available - $e');
    }

    try {
      Bottomcontroller();
      print('  ✅ Bottomcontroller: Available');
    } catch (e) {
      print('  ❌ Bottomcontroller: Not available - $e');
    }
  }

  // Check current navigation state
  void logNavigationState() {
    print('🔍 Navigation State Check:');
    print('  - Current route: ${Get.currentRoute}');
    print('  - Is auto-logging in: ${isAutoLoggingIn.value}');
    print('  - Can navigate: ${Get.isRegistered<Login_Screen>()}');
  }

  // Navigate to login screen (called from splash if auto-login fails)
  void navigateToLogin() {
    print('📱 navigateToLogin called');
    logNavigationState();

    try {
      // Use Get.offAll instead of Get.off to avoid navigation stack issues
      print('🔄 Attempting to navigate to Login_Screen...');
      Get.offAll(() => Login_Screen(), transition: Transition.fade);
      print('✅ Navigation successful');
    } catch (e) {
      // Fallback navigation if GetX is not ready
      print('❌ Navigation error: $e');
    }
  }

  // Attempt to auto-login user if they have a valid token
  Future<void> attemptAutoLogin() async {
    print('🔄 Attempting auto-login...');
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'userToken');

    if (token != null && token.isNotEmpty) {
      print('🔑 Token found, attempting API call...');
      isAutoLoggingIn.value = true;

      try {
        final result = await authRepository.getMe();
        print('📡 API response: ${result['success']}');

        if (result['success'] == true && result['data'] != null) {
          // User is still logged in, set user data
          print('✅ Auto-login successful, setting user data...');
          final userModel = UserModel.fromJson(result);

          // Ensure UserController is initialized
          UserController userController;
          try {
            userController = Get.find<UserController>();
          } catch (e) {
            print('🔄 UserController not found, creating new instance...');
            userController = Get.put(UserController());
          }

          if (userModel.data != null) {
            userController.setUser(userModel.data!);
            print(
              '👤 User data set: ${userModel.data!.firstName} ${userModel.data!.lastName}',
            );

            // Set navigation flags instead of navigating immediately
            autoLoginUserData.value = result["data"];
            if (result["data"]["isCreatedProfile"] == false) {
              print('📱 Setting flag to navigate to CreateProfileScreen...');
              shouldNavigateToProfile.value = true;
            } else {
              print('🏠 Setting flag to navigate to HomeScreen...');
              shouldNavigateToHome.value = true;
            }
          } else {
            print('❌ User data is null, clearing token...');
            await storage.delete(key: 'userToken');
          }
        } else {
          // Token is invalid, clear it
          print('❌ Token invalid, clearing...');
          await storage.delete(key: 'userToken');
        }
      } catch (e) {
        // Error occurred, clear token
        print('❌ Auto-login error: $e');
        await storage.delete(key: 'userToken');
      } finally {
        isAutoLoggingIn.value = false;
        print('🔄 Auto-login attempt completed');
      }
    } else {
      print('🔑 No token found, skipping auto-login');
    }
  }

  // Manual auto-login method (can be called from UI)
  Future<bool> manualAutoLogin() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'userToken');

    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final result = await authRepository.getMe();

      if (result['success'] == true && result['data'] != null) {
        // User is still logged in, set user data
        final userModel = UserModel.fromJson(result);
        final userController = Get.put(UserController());

        if (userModel.data != null) {
          userController.setUser(userModel.data!);
          return true;
        }
      } else {
        // Token is invalid, clear it
        await storage.delete(key: 'userToken');
      }
    } catch (e) {
      // Error occurred, clear token
      await storage.delete(key: 'userToken');
      print('Manual auto-login error: $e');
    }

    return false;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
    // Save the remember me preference
    saveRememberMePreference();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Save remember me preference
  Future<void> saveRememberMePreference() async {
    final storage = FlutterSecureStorage();
    await storage.write(key: 'rememberMe', value: rememberMe.value.toString());
  }

  // Load saved credentials if remember me was enabled
  Future<void> loadSavedCredentials() async {
    final storage = FlutterSecureStorage();
    final savedRememberMe = await storage.read(key: 'rememberMe');

    if (savedRememberMe == 'true') {
      rememberMe.value = true;

      // Load saved email and password
      final savedEmail = await storage.read(key: 'savedEmail');
      final savedPassword = await storage.read(key: 'savedPassword');

      if (savedEmail != null && savedPassword != null) {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
      }
    }
  }

  // Save credentials if remember me is enabled
  Future<void> saveCredentials() async {
    if (rememberMe.value) {
      final storage = FlutterSecureStorage();
      await storage.write(key: 'savedEmail', value: emailController.text);
      await storage.write(key: 'savedPassword', value: passwordController.text);
    } else {
      // Clear saved credentials if remember me is disabled
      await clearSavedCredentials();
    }
  }

  // Clear saved credentials
  Future<void> clearSavedCredentials() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'savedEmail');
    await storage.delete(key: 'savedPassword');
  }

  // Clear all saved data (for logout)
  Future<void> clearAllSavedData() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'savedEmail');
    await storage.delete(key: 'savedPassword');
    await storage.delete(key: 'rememberMe');
    await storage.delete(key: 'userToken');

    // Clear controllers
    emailController.clear();
    passwordController.clear();
    rememberMe.value = false;
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    try {
      final userController = Get.find<UserController>();
      return userController.user.value != null;
    } catch (e) {
      return false;
    }
  }

  // Check token status
  Future<void> checkTokenStatus() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'userToken');
    print('🔍 Token Status Check:');
    print('  - Token exists: ${token != null}');
    print('  - Token length: ${token?.length ?? 0}');
    print('  - User logged in: ${isUserLoggedIn()}');
    print('  - Auto-login status: ${isAutoLoggingIn.value}');
  }

  // Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    final storage = FlutterSecureStorage();
    final savedRememberMe = await storage.read(key: 'rememberMe');
    return savedRememberMe == 'true';
  }

  var loginStatus = RequestStatus.idle.obs;
  RxString receivedOTPFromAPI = "".obs;

  void userLogin(data) async {
    loginStatus.value = RequestStatus.loading;

    final result = await authRepository.login(data);

    if (result['success'] == true) {
      final userModel = UserModel.fromJson(result);
      final userController = Get.put(UserController());
      if (userModel.data != null) {
        userController.setUser(userModel.data!);
      }

      // Save credentials if remember me is enabled
      await saveCredentials();

      loginStatus.value = RequestStatus.success;
      if (result["data"]["isCreatedProfile"] == false) {
        final storage = FlutterSecureStorage();
        await storage.write(key: 'userToken', value: userModel.data?.userToken);
        Get.snackbar("Success", "Please Complete Your Profile");
        Get.to(() => CreateProfileScreen(), transition: Transition.fadeIn);
      } else {
        final storage = FlutterSecureStorage();
        await storage.write(key: 'userToken', value: userModel.data?.userToken);
        final bottomController = Get.put(Bottomcontroller());
        bottomController.updateIndex(0);
        Get.to(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);

        Get.snackbar("Success", result['message'] ?? "User registered");
      }
    } else {
      loginStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "Registration failed");
    }
  }
}
