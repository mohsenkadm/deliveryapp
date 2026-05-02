// خدمة OneSignal — الإشعارات الفورية وربط المستخدم
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../constants/api_constants.dart';
import '../routes/app_routes.dart';

class OneSignalService extends GetxService {
  /// تهيئة OneSignal وطلب إذن الإشعارات
  Future<OneSignalService> init() async {
    OneSignal.initialize(ApiConstants.oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null) {
        _handleNotificationClick(data);
      }
    });

    return this;
  }

  void setExternalUserId(String userId) {
    OneSignal.login(userId);
  }

  void removeExternalUserId() {
    OneSignal.logout();
  }

  void addTag(String key, String value) {
    OneSignal.User.addTagWithKey(key, value);
  }

  void removeTag(String key) {
    OneSignal.User.removeTag(key);
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'order':
        Get.toNamed(AppRoutes.orderDetailsAlias, arguments: {'id': id});
        break;
      case 'invoice':
        Get.toNamed(AppRoutes.invoiceDetailsAlias, arguments: {'id': id});
        break;
      default:
        Get.toNamed(AppRoutes.notificationsAlias);
    }
  }
}
