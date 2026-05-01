// جذر التطبيق — GetMaterialApp مع الثيمات والمسارات والترجمة
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/bindings/initial_binding.dart';
import 'core/localization/translation_service.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (tc) => GetMaterialApp(
        title: 'تطبيق التوصيل',
        debugShowCheckedModeBanner: false,
        textDirection: TextDirection.rtl,
        locale: const Locale('ar'),
        fallbackLocale: const Locale('ar'),
        translations: TranslationService(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: tc.themeMode,
        initialBinding: InitialBinding(),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
