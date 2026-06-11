import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ollie/home/notifications/notification_repository.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/services/firebase_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String image;
  final String createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.image,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? '').toString();
    final description = (json['description'] ?? '').toString();
    final message = (description.isNotEmpty ? description : title).toString();
    final image = (json['image'] ?? json['avatar'] ?? json['icon'] ?? '').toString();
    final createdAt = (json['createdAt'] ?? json['created_at'] ?? json['date'] ?? '').toString();
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final isRead = json['isRead'] == true;

    return NotificationItem(id: id, title: title, message: message, image: image, createdAt: createdAt, isRead: isRead);
  }
}

class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();

  var status = RequestStatus.idle.obs;
  var notifications = <NotificationItem>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    FirebaseService.instance.addMessageHandler(_handlePushMessage);
    fetchNotifications();
  }

  @override
  void onClose() {
    FirebaseService.instance.removeMessageHandler(_handlePushMessage);
    super.onClose();
  }

  Future<void> _handlePushMessage(RemoteMessage message) async {
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    status.value = RequestStatus.loading;
    errorMessage.value = '';

    try {
      final result = await _repository.getAllNotifications();

      if (result['success'] == true) {
        final rawData = result['data'];
        final items = _extractNotificationList(
          rawData,
        ).map((item) => NotificationItem.fromJson(item)).where((item) => item.message.trim().isNotEmpty).toList();

        notifications.assignAll(items);
        status.value = items.isEmpty ? RequestStatus.empty : RequestStatus.success;
      } else {
        notifications.clear();
        errorMessage.value = (result['message'] ?? 'Failed to load notifications').toString();
        status.value = RequestStatus.error;
      }
    } catch (e) {
      notifications.clear();
      errorMessage.value = e.toString();
      status.value = RequestStatus.error;
    }
  }

  List<Map<String, dynamic>> _extractNotificationList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }

    if (data is Map<String, dynamic>) {
      final candidates = [data['notifications'], data['data'], data['items'], data['rows']];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
        }
      }
    }

    return const [];
  }
}
