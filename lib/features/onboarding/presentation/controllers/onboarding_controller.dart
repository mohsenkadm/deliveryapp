import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final currentPage = 0.obs;

  final List<Map<String, dynamic>> slides = [
    {
      'title': 'تسوّق بسهولة',
      'description': 'تصفّح منتجات متنوعة واطلب ما تحتاج\nبكل سهولة ويسر من هاتفك',
      'lottie': AssetPaths.onboardingShopping,
      'icon': Icons.shopping_bag_rounded,
      'highlightIcons': <IconData>[
        Icons.storefront_rounded,
        Icons.shopping_cart_checkout_rounded,
        Icons.local_offer_rounded,
      ],
      'highlightLabels': <String>[
        'متاجر موثوقة',
        'طلب سريع',
        'عروض يومية',
      ],
      'color': const Color(0xFF2E7DFF),
      'gradientStart': const Color(0xFF2E7DFF),
      'gradientEnd': const Color(0xFF7BB8FF),
    },
    {
      'title': 'تتبع طلباتك',
      'description': 'تابع حالة طلبك ومدفوعاتك\nلحظة بلحظة حتى يصل إليك',
      'lottie': AssetPaths.onboardingTracking,
      'icon': Icons.local_shipping_rounded,
      'highlightIcons': <IconData>[
        Icons.route_rounded,
        Icons.gps_fixed_rounded,
        Icons.schedule_rounded,
      ],
      'highlightLabels': <String>[
        'مسار مباشر',
        'موقع لحظي',
        'وقت دقيق',
      ],
      'color': const Color(0xFF10B981),
      'gradientStart': const Color(0xFF10B981),
      'gradientEnd': const Color(0xFF6EE7C0),
    },
    {
      'title': 'إشعارات فورية',
      'description': 'احصل على إشعارات فورية بتحديثات\nطلباتك وعروضنا المميزة',
      'lottie': AssetPaths.onboardingNotification,
      'icon': Icons.notifications_active_rounded,
      'highlightIcons': <IconData>[
        Icons.notifications_rounded,
        Icons.security_rounded,
        Icons.star_rounded,
      ],
      'highlightLabels': <String>[
        'تنبيهات ذكية',
        'حساب آمن',
        'ميزات جديدة',
      ],
      'color': const Color(0xFFFF7A00),
      'gradientStart': const Color(0xFFFF7A00),
      'gradientEnd': const Color(0xFFFFB347),
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
    Get.offAllNamed(AppRoutes.login);
  }
}
