import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/snackbar_helper.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _isLoading = false.obs;
  final _showCurrent = false.obs;
  final _showNew = false.obs;
  final _showConfirm = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تغيير كلمة المرور',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Security header ──
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFB68BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.38),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.lock_rounded,
                          size: 40, color: Colors.white),
                    )
                        .animate()
                        .fadeIn()
                        .scale(begin: const Offset(0.7, 0.7)),
                    const SizedBox(height: 12),
                    Text('أمان حسابك يهمنا',
                        style: GoogleFonts.cairo(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500))
                        .animate()
                        .fadeIn(delay: 100.ms),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Fields card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Obx(() => CustomTextField(
                          controller: _currentCtrl,
                          label: 'كلمة المرور الحالية',
                          hint: 'أدخل كلمة المرور الحالية',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: !_showCurrent.value,
                          validator: Validators.required,
                          suffixIcon: IconButton(
                            icon: Icon(_showCurrent.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => _showCurrent.toggle(),
                          ),
                        )).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 16),
                    Obx(() => CustomTextField(
                          controller: _newCtrl,
                          label: 'كلمة المرور الجديدة',
                          hint: 'أدخل كلمة المرور الجديدة',
                          prefixIcon: Icons.lock_rounded,
                          obscureText: !_showNew.value,
                          validator: Validators.password,
                          suffixIcon: IconButton(
                            icon: Icon(_showNew.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => _showNew.toggle(),
                          ),
                        )).animate().fadeIn(delay: 230.ms),
                    const SizedBox(height: 16),
                    Obx(() => CustomTextField(
                          controller: _confirmCtrl,
                          label: 'تأكيد كلمة المرور',
                          hint: 'أعد إدخال كلمة المرور الجديدة',
                          prefixIcon: Icons.lock_reset_rounded,
                          obscureText: !_showConfirm.value,
                          validator: (v) => v != _newCtrl.text
                              ? 'كلمة المرور غير متطابقة'
                              : null,
                          suffixIcon: IconButton(
                            icon: Icon(_showConfirm.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => _showConfirm.toggle(),
                          ),
                        )).animate().fadeIn(delay: 310.ms),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Hint box ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'كلمة المرور يجب أن تكون ٦ أحرف أو أكثر',
                        style: GoogleFonts.cairo(
                            fontSize: 12, color: const Color(0xFF8B5CF6)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 390.ms),
              const SizedBox(height: 28),

              Obx(() => CustomButton(
                    text: 'تغيير كلمة المرور',
                    isLoading: _isLoading.value,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        SnackbarHelper.showSuccess(
                            'تم تغيير كلمة المرور بنجاح');
                        Get.back();
                      }
                    },
                  )).animate().fadeIn(delay: 460.ms),
            ],
          ),
        ),
      ),
    );
  }
}
