import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class NewUserRepository {
  Future<Map<String, dynamic>> deleteUser() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.deleteMethod(ApiUrls.deleteAccount, token: requiredToken);
  }
}
