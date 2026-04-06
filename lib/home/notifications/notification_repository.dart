import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class NotificationRepository {
  Future<Map<String, dynamic>> getAllNotifications() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'userToken');
    return ApiService.getMethod(ApiUrls.showAllNotification, token: token);
  }
}
