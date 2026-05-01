import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── User Info Header ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    authService.userName.isNotEmpty ? authService.userName[0] : '👤',
                    style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authService.userName, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(authService.userRole, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => Get.toNamed(AppRoutes.profile),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 8),

          // Account
          const _SectionHeader(title: 'الحساب'),
          _SettingsTile(icon: Icons.person_outline, title: 'الملف الشخصي', subtitle: 'عرض وتعديل بياناتك', onTap: () => Get.toNamed(AppRoutes.profile)),
          _SettingsTile(icon: Icons.lock_outline, title: 'تغيير كلمة المرور', subtitle: 'تحديث كلمة المرور', onTap: () => Get.toNamed(AppRoutes.changePassword)),
          const SizedBox(height: 8),

          // Appearance
          const _SectionHeader(title: 'المظهر'),
          _SettingsTile(icon: Icons.palette_outlined, title: 'المظهر والألوان', subtitle: 'الوضع الداكن / الفاتح ولون التطبيق', onTap: () => Get.toNamed(AppRoutes.themeSettings)),
          const SizedBox(height: 8),

          // Info
          const _SectionHeader(title: 'معلومات'),
          _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'سياسة الخصوصية', onTap: () => Get.toNamed(AppRoutes.privacyPolicy)),
          _SettingsTile(icon: Icons.info_outline, title: 'حول التطبيق', onTap: () => Get.toNamed(AppRoutes.aboutApp)),
          const SizedBox(height: 8),

          // Support
          const _SectionHeader(title: 'الدعم'),
          _SettingsTile(icon: Icons.support_agent_outlined, title: 'الدعم الفني', subtitle: 'واتساب / بريد / هاتف', onTap: () => Get.toNamed(AppRoutes.technicalSupport)),
          const SizedBox(height: 16),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, authService),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text('تسجيل الخروج', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تسجيل الخروج', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text('هل أنت متأكد من تسجيل الخروج؟', style: GoogleFonts.cairo()),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authService.logout();
              Get.offAllNamed(AppRoutes.roleSelection);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('خروج', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(title, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)) : null,
      trailing: const Icon(Icons.chevron_left, size: 20),
      onTap: onTap,
    );
  }
}
