import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class AssistanceRepository {
  Future<Map<String, dynamic>> userCreateAssistance(
    Map<String, dynamic> data,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      ApiUrls.createAssistance,
      data,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getEachAssistanceReasons() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(
      ApiUrls.getReasonsForAssistance,
      token: requiredToken,
    );
  }
}
