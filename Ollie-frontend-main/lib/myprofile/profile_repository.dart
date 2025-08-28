import 'package:get/get.dart';
import 'package:ollie/api_service.dart';

class UserRepository {
  // Method to update profile
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String filePath, // This would be the profile image path
    String? token,
  }) async {
    Map<String, String> fields = {'userFirstName': firstName, 'userLastName': lastName, 'userEmail': email, 'userGender': gender};

    // Call the ApiService to update the profile with the given parameters
    return await ApiService.putMultipart(
      '/user/auth/userEditProfile', // Your endpoint
      fields: fields, // Text fields
      fileKey: 'image', // File field name in the API (usually "image")
      filePath: filePath, // Path to the image
      token: token, // User's access token
    );
  }
}
