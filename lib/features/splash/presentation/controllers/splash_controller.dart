import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    // Let the splash animations play for ~2.5s
    await Future.delayed(const Duration(milliseconds: 2500));

    final storageService = Get.find<StorageService>();
    final authService = Get.find<AuthService>();

    if (storageService.isFirstTime) {
      // First launch → Onboarding
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (authService.isLoggedIn) {
      // Has valid JWT → role-based home
      Get.offAllNamed(authService.getHomeRoute());
    } else {
      // Otherwise → Role Selection
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }
}
