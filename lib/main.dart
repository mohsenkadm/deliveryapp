// نقطة بداية التطبيق — تهيئة الخدمات وتشغيل التطبيق
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'core/services/onesignal_service.dart';
import 'core/services/storage_service.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // تهيئة التخزين المحلي
  final storageService = StorageService();
  await storageService.init();
  Get.put(storageService, permanent: true);

  // تهيئة OneSignal
  final oneSignalService = OneSignalService();
  await oneSignalService.init();
  Get.put(oneSignalService, permanent: true);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const DeliveryApp());
}
