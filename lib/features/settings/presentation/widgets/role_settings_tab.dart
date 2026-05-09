import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/branding_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Shared settings tab used in every role's main page.
/// Mirrors the unified admin settings design (gradient profile card,
/// grouped sections, themed tiles, logout confirmation).
class RoleSettingsTab extends StatelessWidget {
  /// Optional role-specific notifications route. When null, the
  /// notifications tile is hidden.
  final String? notificationsRoute;

  /// Optional avatar icon (defaults based on user kind).
  final IconData? avatarIcon;

  const RoleSettingsTab({
    super.key,
    this.notificationsRoute,
    this.avatarIcon,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الإعدادات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── Profile Card ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: Icon(
                    avatarIcon ?? _iconForKind(auth.userKind),
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName.isNotEmpty
                            ? auth.userName
                            : 'مرحباً بك',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _kindLabel(auth.userKind, auth.activeRole),
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => Get.toNamed(AppRoutes.profile),
                  tooltip: 'تعديل الملف',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Account ──
          _section('الحساب'),
          _card([
            _tile(Icons.person_outline, 'الملف الشخصي',
                () => Get.toNamed(AppRoutes.profile)),
            _divider(),
            _tile(Icons.lock_outline, 'تغيير كلمة المرور',
                () => Get.toNamed(AppRoutes.changePassword)),
            if (auth.isMultiRole) _divider(),
            if (auth.isMultiRole)
              _tile(
                Icons.swap_horiz_rounded,
                'تبديل الدور (${_roleLabelAr(auth.activeRole)})',
                () => _showRoleSwitcher(auth),
              ),
          ]),
          const SizedBox(height: 16),

          // ── Preferences ──
          _section('التفضيلات'),
          _card([
            _tile(Icons.dark_mode_outlined, 'المظهر',
                () => Get.toNamed(AppRoutes.themeSettings)),
            if (notificationsRoute != null) _divider(),
            if (notificationsRoute != null)
              _tile(Icons.notifications_outlined, 'الإشعارات',
                  () => Get.toNamed(notificationsRoute!)),
            if (auth.userKind == UserKind.admin) _divider(),
            if (auth.userKind == UserKind.admin)
              _tile(Icons.palette_outlined, 'الهوية البصرية للنظام',
                  () => Get.toNamed(AppRoutes.brandingSettings)),
          ]),
          const SizedBox(height: 16),

          // ── About ──
          _section('حول التطبيق'),
          _card([
            _tile(Icons.info_outline, 'حول التطبيق',
                () => Get.toNamed(AppRoutes.aboutApp)),
            _divider(),
            _tile(Icons.privacy_tip_outlined, 'سياسة الخصوصية',
                () => Get.toNamed(AppRoutes.privacyPolicy)),
            _divider(),
            _tile(Icons.support_agent_outlined, 'الدعم الفني',
                () => Get.toNamed(AppRoutes.technicalSupport)),
          ]),
          const SizedBox(height: 24),

          // ── Logout ──
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(
                    color: Colors.red, fontWeight: FontWeight.w700),
              ),
              trailing: const Icon(Icons.chevron_left, color: Colors.red),
              onTap: _confirmLogout,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Obx(() {
              final brand = Get.find<BrandingService>();
              return Text(
                '${brand.appName.value} • الإصدار 1.0.0',
                style: GoogleFonts.cairo(
                    fontSize: 11, color: AppColors.textSecondary),
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _iconForKind(UserKind k) {
    switch (k) {
      case UserKind.admin:
        return Icons.admin_panel_settings;
      case UserKind.customer:
        return Icons.person;
      case UserKind.employee:
        return Icons.badge_outlined;
      default:
        return Icons.person_outline;
    }
  }

  String _kindLabel(UserKind k, String role) {
    switch (k) {
      case UserKind.admin:
        return 'مدير النظام';
      case UserKind.customer:
        return 'عميل';
      case UserKind.employee:
        return _roleLabelAr(role);
      default:
        return '';
    }
  }

  String _roleLabelAr(String role) {
    switch (role) {
      case 'Driver':
        return 'سائق توصيل';
      case 'SalesRepresentative':
      case 'Representative':
        return 'مندوب مبيعات';
      case 'SalesManager':
        return 'مدير مبيعات';
      case 'Supervisor':
        return 'مشرف';
      case 'Manager':
        return 'مدير';
      case 'WarehouseManager':
        return 'أمين مستودع';
      case 'Accountant':
        return 'محاسب';
      default:
        return 'موظف';
    }
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 8, top: 4),
        child: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Column(children: children),
      );

  Widget _divider() => Divider(
        height: 1,
        thickness: 1,
        color: AppColors.dividerLight.withValues(alpha: 0.6),
        indent: 56,
      );

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_left, size: 20),
      onTap: onTap,
    );
  }

  void _showRoleSwitcher(AuthService auth) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'اختر الدور',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...auth.userRoles.map((role) {
                final isActive = role == auth.activeRole;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_iconForRole(role),
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text(
                    _roleLabelAr(role),
                    style: GoogleFonts.cairo(
                      fontWeight:
                          isActive ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  trailing: isActive
                      ? Icon(Icons.check_circle,
                          color: AppColors.primary, size: 20)
                      : null,
                  onTap: () async {
                    Get.back();
                    if (isActive) return;
                    await auth.switchActiveRole(role);
                    Get.offAllNamed(AuthService.routeForRole(role));
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForRole(String role) {
    switch (role) {
      case 'Driver':
        return Icons.delivery_dining_rounded;
      case 'SalesRepresentative':
      case 'Representative':
        return Icons.support_agent_rounded;
      case 'SalesManager':
        return Icons.trending_up_rounded;
      case 'Supervisor':
        return Icons.supervisor_account_rounded;
      case 'Manager':
        return Icons.manage_accounts_rounded;
      case 'WarehouseManager':
      case 'WarehouseKeeper':
        return Icons.warehouse_rounded;
      case 'Accountant':
      case 'Cashier':
        return Icons.point_of_sale_rounded;
      case 'Admin':
      case 'SystemManager':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.badge_outlined;
    }
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: Text('تأكيد الخروج',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text('هل أنت متأكد من تسجيل الخروج؟',
            style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
            child: Text('خروج',
                style: GoogleFonts.cairo(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
