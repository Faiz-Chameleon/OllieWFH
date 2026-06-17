import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class SupplementRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _token() {
    return _storage.read(key: 'userToken');
  }

  Future<Map<String, dynamic>> getMySupplements() async {
    return ApiService.getMethod(
      ApiUrls.getMySupplements,
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> createMySupplement(
    Map<String, dynamic> data,
  ) async {
    return ApiService.postMethod(
      ApiUrls.createMySupplement,
      data,
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> updateMySupplement(
    String supplementId,
    Map<String, dynamic> data,
  ) async {
    return ApiService.putMethod(
      '${ApiUrls.updateMySupplement}/$supplementId',
      data: data,
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> deleteMySupplement(String supplementId) async {
    return ApiService.deleteMethod(
      '${ApiUrls.deleteMySupplement}/$supplementId',
      token: await _token(),
    );
  }
}
