import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class UserRepository {
  // Method to update profile
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    String? filePath, // Optional profile image path
    String? token,
  }) async {
    Map<String, String> fields = {'userFirstName': firstName, 'userLastName': lastName, 'userEmail': email, 'userGender': gender};

    return await ApiService.putMultipart(
      '/user/auth/userEditProfile',
      fields: fields,
      fileKey: filePath == null ? null : 'image',
      filePath: filePath,
      token: token,
    );
  }

  Future<Map<String, dynamic>> supportFeedback(Map<String, dynamic> data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.support, data, token: requiredToken);
  }
}
