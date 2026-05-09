import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_form.dart';

class RepresentativeLoginPage extends GetView<AuthController> {
  const RepresentativeLoginPage({super.key});

  static const _roleColor = Color(0xFFFF7A00); // orange

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دخول المندوب')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.employeeFormKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 80, height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: _roleColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Text('🧾', style: TextStyle(fontSize: 36)),
                ).animate().fadeIn().scale(begin: const Offset(0.7, 0.7)),
                const SizedBox(height: 24),
                Text('أهلاً بك أيها المندوب', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text('سجّل دخولك لإدارة عملائك', style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary)).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                const AuthForm().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                Obx(() => CustomButton(text: 'تسجيل الدخول', isLoading: controller.isLoading.value, onPressed: controller.loginRepresentative)).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
