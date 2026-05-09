// ربط متحكمات الإعدادات والملف الشخصي
import 'package:get/get.dart';
import '../controllers/settings_controllers.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
