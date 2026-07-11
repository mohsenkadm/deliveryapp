// خدمة OneSignal — الإشعارات الفورية وربط المستخدم
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../routes/app_routes.dart';
import 'storage_service.dart';

class OneSignalService extends GetxService {
  /// تهيئة OneSignal وطلب إذن الإشعارات
  Future<OneSignalService> init() async {
    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }

    OneSignal.initialize(ApiConstants.oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null) {
        _handleNotificationClick(data);
      }
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
    });

    OneSignal.User.pushSubscription.addObserver((state) {
      final playerId = state.current.id;
      if (playerId != null && playerId.isNotEmpty) {
        Get.find<StorageService>().write(StorageKeys.oneSignalPlayerId, playerId);
      }
    });

    return this;
  }

  void setExternalUserId(String userId, {String? role}) {
    OneSignal.login(userId);
    if (role != null && role.isNotEmpty) {
      OneSignal.User.addTagWithKey('role', role);
    }
  }

  void removeExternalUserId() {
    OneSignal.User.removeTag('role');
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
