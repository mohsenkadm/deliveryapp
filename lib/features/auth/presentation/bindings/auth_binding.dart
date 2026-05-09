// ربط متحكم المصادقة
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// AuthBinding — فعلياً تسجيل AuthController يتم في InitialBinding
/// بصفته permanent (لأنه يحتوي TextEditingControllers تحتاجها
/// كل صفحات تسجيل الدخول). وللحفاظ على التوافق مع
/// استخدام GetPage(binding: ...) نترك هذا الصف دون إنشاء
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }
}
