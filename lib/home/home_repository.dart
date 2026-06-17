import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';
import 'package:ollie/home/Dailytask/device_time_zone_service.dart';

class HomeRepository {
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final requestBody =
        await DeviceTimeZoneService.requestBodyWithDeviceTimeZone(data);
    return ApiService.postMethod(
      ApiUrls.createTask,
      requestBody,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> rescheduleTask(
    String taskId,
    Map<String, dynamic> data,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.putMethod(
      '${ApiUrls.rescheduleTask}/$taskId',
      data: data,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getUserTasksByDate(date) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(
      '${ApiUrls.getByDateTask}?date=$date',
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> markTaskCompleted(taskId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.putMethod(
      '${ApiUrls.markTaskAsComplete}/$taskId',
      data: {},
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.deleteMethod(
      '${ApiUrls.deleteUserTask}/$taskId',
      token: requiredToken,
    );
  }
}
