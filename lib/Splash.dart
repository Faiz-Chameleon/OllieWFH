// ignore_for_file: avoid_print, duplicate_ignore, camel_case_types, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/login/login_screen.dart';
import 'package:ollie/Auth/login/login_controller.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/Auth/CreateProfile/createProfile.dart';

// ignore: camel_case_types
class Splash_Screen extends StatefulWidget {
  final bool enableNavigation;

  const Splash_Screen({super.key, this.enableNavigation = true});

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableNavigation) {
      _handleNavigation();
    }
  }

  void _handleNavigation() async {
    print('🚀 Splash screen started, waiting 3 seconds...');
    // Wait for auto-login to complete
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    print('⏰ 3 seconds passed, checking auto-login status...');
    final loginController = Get.find<LoginController>();

    // Wait for auto-login to complete
    while (loginController.isAutoLoggingIn.value) {
      print('⏳ Auto-login still in progress, waiting...');
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }

    print('🔍 Auto-login completed, checking if user is logged in...');

    // Check if user is already logged in (auto-login succeeded)
    try {
      final userController = Get.find<UserController>();
      if (userController.user.value != null) {
        print('✅ User is already logged in, checking navigation flags...');

        // Check if auto-login set navigation flags
        if (loginController.shouldNavigateToProfile.value) {
          print('📱 Auto-login wants to navigate to CreateProfileScreen...');
          _hasNavigated = true;
          try {
            Get.offAll(() => CreateProfileScreen());
            return;
          } catch (e) {
            print('❌ Navigation to CreateProfileScreen failed: $e');
            // Fallback to login
          }
        } else if (loginController.shouldNavigateToHome.value) {
          print('🏠 Auto-login wants to navigate to HomeScreen...');
          _hasNavigated = true;
          try {
            final bottomController = Get.put(Bottomcontroller());
            bottomController.updateIndex(0);
            Get.offAll(() => ConvexStyledBarScreen());
            return;
          } catch (e) {
            print('❌ Navigation to HomeScreen failed: $e');
            // Fallback to login
          }
        } else {
          print('✅ User logged in without navigation flags, defaulting to HomeScreen...');
          _hasNavigated = true;
          try {
            final bottomController = Get.isRegistered<Bottomcontroller>() ? Get.find<Bottomcontroller>() : Get.put(Bottomcontroller());
            bottomController.updateIndex(0);
            Get.offAll(() => ConvexStyledBarScreen());
            return;
          } catch (e) {
            print('❌ Default navigation to HomeScreen failed: $e');
            _hasNavigated = false;
          }
        }
      }
    } catch (e) {
      print('⚠️ UserController not found: $e');
      // Continue to login screen if UserController is not available
    }

    // If we haven't navigated yet and user is not logged in, go to login
    if (!_hasNavigated) {
      print('📱 User not logged in, navigating to Login Screen...');
      _hasNavigated = true;
      loginController.navigateToLogin();
    } else {
      print('🚫 Navigation skipped - Already navigated: $_hasNavigated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/962.png"), fit: BoxFit.fill),
      ),
    );
  }
}
