import 'package:get/get.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

// خدمة الإشعارات — جلب وتعليم كمقروء
class NotificationService extends GetxService {
  final DioClient _dioClient = Get.find<DioClient>();

  final notifications = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;

  /// جلب قائمة الإشعارات
  Future<void> fetchNotifications() async {
    try {
      final response = await _dioClient.get(ApiConstants.notifications);
      final List<dynamic> data = response.data['data'] ?? response.data;
      notifications.value = data.cast<Map<String, dynamic>>();
      unreadCount.value = notifications.where((n) => n['isRead'] == false).length;
    } catch (_) {}
  }

  /// تعليم إشعار كمقروء (PATCH)
  Future<void> markAsRead(String id) async {
    try {
      await _dioClient.patch(ApiConstants.markNotificationRead(id));
      final index = notifications.indexWhere((n) => n['id'].toString() == id);
      if (index != -1) {
        notifications[index]['isRead'] = true;
        notifications.refresh();
        unreadCount.value = notifications.where((n) => n['isRead'] == false).length;
      }
    } catch (_) {}
  }
}
