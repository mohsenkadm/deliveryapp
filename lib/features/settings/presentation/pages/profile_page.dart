import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/settings_controllers.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(auth),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── بطاقة المعلومات ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Obx(() {
                      final editing = controller.isEditing.value;
                      return Column(
                        children: [
                          CustomTextField(
                            controller: controller.nameController,
                            label: 'الاسم الكامل',
                            prefixIcon: Icons.person_outline,
                            readOnly: !editing,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: controller.phoneController,
                            label: 'رقم الهاتف',
                            prefixIcon: Icons.phone_outlined,
                            readOnly: !editing,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: controller.addressController,
                            label: 'العنوان',
                            prefixIcon: Icons.location_on_outlined,
                            readOnly: !editing,
                          ),
                        ],
                      );
                    }),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),

                  // ── أزرار التحكم ──
                  const SizedBox(height: 20),
                  Obx(() {
                    if (controller.isEditing.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomButton(
                            text: 'حفظ التغييرات',
                            isLoading: controller.isLoading.value,
                            onPressed: controller.updateProfile,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () =>
                                controller.isEditing.value = false,
                            child: Text(
                              'إلغاء',
                              style: GoogleFonts.cairo(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return OutlinedButton.icon(
                      onPressed: () => controller.isEditing.value = true,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(
                        'تعديل البيانات',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(AuthService auth) {
    final name = auth.userName;
    final initial = name.isNotEmpty ? name[0] : '؟';
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.cairo(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name.isNotEmpty ? name : 'الملف الشخصي',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
