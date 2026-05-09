import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

class RegistrationPendingPage extends StatelessWidget {
  const RegistrationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Waiting Lottie animation
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  AssetPaths.waitingAnimation,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.warningLight.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 60,
                      color: AppColors.warningLight,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                  ),
              const SizedBox(height: 32),
              Text(
                'في انتظار موافقة الإدارة',
                style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),
              Text(
                'تم استلام طلبك، سيتم إشعارك عند الموافقة.',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 48),
              CustomButton(
                text: 'العودة لتسجيل الدخول',
                onPressed: () => Get.offAllNamed(AppRoutes.login),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.15),
            ],
          ),
        ),
      ),
    );
  }
}
