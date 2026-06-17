import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class AssistanceRepository {
  Future<Map<String, dynamic>> userCreateAssistance(
    Map<String, dynamic> data,
    List<XFile> attachments,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    if (attachments.isEmpty) {
      return ApiService.postMethod(
        ApiUrls.createAssistance,
        data,
        token: requiredToken,
      );
    }

    return ApiService.postMultipartWithAttachments(
      ApiUrls.createAssistance,
      data,
      attachments,
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

  Future<Map<String, dynamic>> getCategoryFeed({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int limit = 20,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final queryParameters = <String, String>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'limit': limit.toString(),
      if (radiusKm != null) 'radiusKm': radiusKm.toString(),
    };
    final endpoint =
        '${ApiUrls.assistanceCategoryFeed}?${Uri(queryParameters: queryParameters).query}';
    return ApiService.getMethod(endpoint, token: requiredToken);
  }

  Future<Map<String, dynamic>> searchLocation(
    String query, {
    int limit = 20,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final endpoint =
        '${ApiUrls.searchLocation}?${Uri(queryParameters: {'q': query, 'limit': limit.toString()}).query}';
    return ApiService.getMethod(endpoint, token: requiredToken);
  }

  Future<Map<String, dynamic>> searchAssistanceReasons(
    String query, {
    int limit = 20,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final endpoint =
        '${ApiUrls.getReasonsForAssistance}?${Uri(queryParameters: {'q': query, 'limit': limit.toString()}).query}';
    return ApiService.getMethod(endpoint, token: requiredToken);
  }
}
