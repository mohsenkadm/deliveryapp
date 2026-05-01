import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme/theme_controller.dart';

import '../services/signalr_service.dart';

/// الربط الأولي — تسجيل الخدمات والمتحكمات عند بدء التطبيق
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // الشبكة — StorageService مسجّل في main.dart
    Get.put(
      DioClient(const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      )),
      permanent: true,
    );
    Get.put(NetworkInfo(Connectivity()), permanent: true);

    // الخدمات — OneSignalService مسجّل في main.dart
    Get.put(AuthService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(SignalRService(), permanent: true);

    // Controllers
    Get.put(ThemeController(), permanent: true);
  }
}
