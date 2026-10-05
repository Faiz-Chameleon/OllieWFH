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
    final requestBody =
        await DeviceTimeZoneService.requestBodyWithDeviceTimeZone(data);
    return ApiService.putMethod(
      '${ApiUrls.rescheduleTask}/$taskId',
      data: requestBody,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getUserTasksByDate(date) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(
      '${ApiUrls.getByDateTask}?date=$date&limit=100',
      token: requiredToken,
    );
  }

  /// Per-day `{total, completed}` between two YYYY-MM-DD dates (max 62 days).
  Future<Map<String, dynamic>> getTaskSummary(String from, String to) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(
      '${ApiUrls.getTaskSummary}?from=$from&to=$to',
      token: requiredToken,
    );
  }

  /// [date] picks the occurrence of a recurring task (YYYY-MM-DD).
  Future<Map<String, dynamic>> markTaskCompleted(
    String taskId, {
    bool completed = true,
    String? date,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.putMethod(
      '${ApiUrls.markTaskAsComplete}/$taskId',
      data: {'completed': completed, if (date != null) 'date': date},
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> toggleChecklistItem(
    String taskId, {
    required String itemId,
    required bool done,
    String? date,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.putMethod(
      '${ApiUrls.toggleTaskChecklistItem}/$taskId',
      data: {'itemId': itemId, 'done': done, if (date != null) 'date': date},
      token: requiredToken,
    );
  }

  /// With [onlyDate], removes that one day of a recurring task instead of
  /// deleting the whole task.
  Future<Map<String, dynamic>> deleteTask(
    String taskId, {
    String? onlyDate,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final query = onlyDate == null ? '' : '?scope=occurrence&date=$onlyDate';

    return ApiService.deleteMethod(
      '${ApiUrls.deleteUserTask}/$taskId$query',
      token: requiredToken,
    );
  }
}
