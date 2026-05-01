// صفحة البداية — شاشة التحميل الأولية مع رسوم متحركة
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryLight,
              AppColors.primaryLight.withValues(alpha: 0.85),
              AppColors.accentLight.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            SizedBox(
              width: 180,
              height: 180,
              child: Lottie.asset(
                AssetPaths.splashAnimation,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    size: 60,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
            const SizedBox(height: 32),
            Text(
              'تطبيق التوصيل',
              style: GoogleFonts.cairo(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              'أسرع توصيل لطلباتك',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.white70,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
            const SizedBox(height: 60),
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
