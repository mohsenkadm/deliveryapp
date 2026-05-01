import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_form.dart';

class CustomerLoginPage extends GetView<AuthController> {
  const CustomerLoginPage({super.key});

  static const _roleColor = Color(0xFF10B981); // green

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دخول العميل')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 80, height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _roleColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('👤', style: TextStyle(fontSize: 36)),
                ).animate().fadeIn().scale(begin: const Offset(0.7, 0.7)),
                const SizedBox(height: 24),
                Text('مرحباً بك', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700))
                    .animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  'سجّل دخولك للمتابعة',
                  style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                const AuthForm().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                Obx(() => CustomButton(
                      text: 'تسجيل الدخول',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.loginCustomer,
                    )).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ليس لديك حساب؟', style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.customerRegister),
                      child: Text('إنشاء حساب جديد', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
