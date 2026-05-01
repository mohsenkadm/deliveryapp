import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class CustomerRegisterPage extends GetView<AuthController> {
  const CustomerRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب عميل')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              children: [
                // Full Name
                CustomTextField(
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  controller: controller.fullNameController,
                  validator: Validators.required,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),

                // Phone
                CustomTextField(
                  label: 'رقم الهاتف',
                  hint: 'أدخل رقم هاتفك',
                  controller: controller.phoneController,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),

                // Address
                CustomTextField(
                  label: 'العنوان',
                  hint: 'أدخل عنوانك',
                  controller: controller.addressController,
                  validator: Validators.required,
                  prefixIcon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),

                // Username
                CustomTextField(
                  label: 'اسم المستخدم',
                  hint: 'أدخل اسم المستخدم',
                  controller: controller.usernameController,
                  validator: Validators.required,
                  prefixIcon: Icons.alternate_email,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),

                // Password
                Obx(() => CustomTextField(
                      label: 'كلمة المرور',
                      hint: 'أدخل كلمة المرور',
                      controller: controller.passwordController,
                      validator: Validators.password,
                      obscureText: controller.obscurePassword.value,
                      prefixIcon: Icons.lock_outlined,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        icon: Icon(controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => controller.obscurePassword.toggle(),
                      ),
                    )).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),

                // Confirm Password
                Obx(() => CustomTextField(
                      label: 'تأكيد كلمة المرور',
                      hint: 'أعد إدخال كلمة المرور',
                      controller: controller.confirmPasswordController,
                      validator: Validators.confirmPassword(controller.passwordController.text),
                      obscureText: controller.obscureConfirmPassword.value,
                      prefixIcon: Icons.lock_outlined,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(controller.obscureConfirmPassword.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => controller.obscureConfirmPassword.toggle(),
                      ),
                    )).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),

                // Submit
                Obx(() => CustomButton(
                      text: 'إنشاء الحساب',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.registerCustomer,
                    )).animate().fadeIn(delay: 700.ms),
                const SizedBox(height: 20),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('لديك حساب بالفعل؟', style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('تسجيل الدخول', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
