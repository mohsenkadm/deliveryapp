import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  static const _roles = [
    _RoleData('👤', 'عميل', 'تصفح المنتجات واطلب ما تريد', Color(0xFF10B981), AppRoutes.customerLogin),
    _RoleData('🚚', 'سائق', 'إدارة التوصيلات والطلبات المسندة', Color(0xFF2E7DFF), AppRoutes.driverLogin),
    _RoleData('🧾', 'مندوب', 'إدارة العملاء والتحصيلات', Color(0xFFFF7A00), AppRoutes.representativeLogin),
    _RoleData('🔍', 'مشرف', 'متابعة المندوبين وموافقات العملاء', Color(0xFF06B6D4), AppRoutes.login),
    _RoleData('📊', 'مدير مبيعات', 'التقارير والموافقات الإدارية', Color(0xFF8B5CF6), AppRoutes.login),
    _RoleData('👑', 'مسؤول', 'لوحة التحكم والإدارة الكاملة', Color(0xFFEC4899), AppRoutes.adminLogin),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.6, 0.6)),
              const SizedBox(height: 20),
              Text(
                'تطبيق التوصيل',
                style: GoogleFonts.cairo(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'اختر نوع الحساب للمتابعة',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
              // Role cards grid — scrollable 2-column
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(_roles.length, (i) {
                  final r = _roles[i];
                  return _RoleCard(
                    emoji: r.emoji,
                    title: r.title,
                    subtitle: r.subtitle,
                    color: r.color,
                    onTap: () => Get.toNamed(r.route),
                  )
                      .animate()
                      .fadeIn(delay: (400 + i * 120).ms, duration: 400.ms)
                      .slideY(begin: 0.15);
                }),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final String route;
  const _RoleData(this.emoji, this.title, this.subtitle, this.color, this.route);
}

class _RoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withValues(alpha: 0.15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
