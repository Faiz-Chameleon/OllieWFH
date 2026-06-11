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
}
