import 'package:get/get.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final currentPage = 0.obs;

  final List<Map<String, String>> slides = [
    {
      'title': 'تسوّق بسهولة',
      'description': 'تصفّح منتجات متنوعة واطلب ما تحتاج\nبكل سهولة ويسر من هاتفك',
      'lottie': AssetPaths.onboardingShopping,
    },
    {
      'title': 'تتبع طلباتك',
      'description': 'تابع حالة طلبك ومدفوعاتك\nلحظة بلحظة حتى يصل إليك',
      'lottie': AssetPaths.onboardingTracking,
    },
    {
      'title': 'إشعارات فورية',
      'description': 'احصل على إشعارات فورية بتحديثات\nطلباتك وعروضنا المميزة',
      'lottie': AssetPaths.onboardingNotification,
    },
  ];

  bool get isLastPage => currentPage.value == slides.length - 1;

  void nextPage() {
    if (!isLastPage) {
      currentPage.value++;
    } else {
      completeOnboarding();
    }
  }

  void completeOnboarding() {
    _storageService.setFirstTimeDone();
    Get.offAllNamed(AppRoutes.roleSelection);
  }
}
