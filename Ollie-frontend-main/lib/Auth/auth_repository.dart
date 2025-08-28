import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/app_urls.dart';

import '../api_service.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) {
    return ApiService.postMethod(ApiUrls.loginUser, data);
  }

  Future<Map<String, dynamic>> signUp(Map<String, dynamic> data) {
    return ApiService.postMethod(ApiUrls.registerApi, data);
  }

  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      ApiUrls.createProfile,
      data,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> data) {
    return ApiService.postMethod(ApiUrls.verifyOTPApi, data);
  }

  Future<Map<String, dynamic>> getInterest() {
    return ApiService.get(ApiUrls.getInterest);
  }

  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> data) {
    return ApiService.postMethod(ApiUrls.forgotPassword, data);
  }

  Future<Map<String, dynamic>> resendOtpMethod(Map<String, dynamic> data) {
    return ApiService.postMethod(ApiUrls.resendOTP, data);
  }

  Future<Map<String, dynamic>> resetPasswordMethod(
    Map<String, dynamic> data,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.putMethod(
      ApiUrls.resetPassword,
      data: data,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getMe() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(ApiUrls.getMe, token: requiredToken);
  }
}
