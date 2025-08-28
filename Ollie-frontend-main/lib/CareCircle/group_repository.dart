import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class GroupRepository {
  Future<Map<String, dynamic>> createGroups(data, file) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMultipart(ApiUrls.createGroups, data, file, token: requiredToken);
  }
}
