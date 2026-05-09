import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';

class ThemeSettingsPage extends GetView<ThemeController> {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'المظهر والألوان',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildPreviewCard(context)
                .animate()
                .fadeIn(duration: 450.ms)
                .slideY(begin: -0.05),
            const SizedBox(height: 18),
            Text(
              'وضع العرض',
              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ThemeModeCard(
                    icon: Icons.light_mode_rounded,
                    label: 'فاتح',
                    subtitle: 'مظهر واضح نهاري',
                    isSelected: !controller.isDarkMode.value,
                    onTap: () => controller.setDarkMode(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ThemeModeCard(
                    icon: Icons.dark_mode_rounded,
                    label: 'داكن',
                    subtitle: 'مظهر مريح ليلي',
                    isSelected: controller.isDarkMode.value,
                    onTap: () => controller.setDarkMode(true),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 120.ms),
            const SizedBox(height: 24),
            Text(
              'ألوان التمييز',
              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              'اختر اللون الذي يظهر في الأزرار والعناصر التفاعلية',
              style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _accentOptions.map((item) {
                final isSelected = controller.accentColor.value == item.value.toARGB32();
                return GestureDetector(
                  onTap: () => controller.setAccentColor(item.value.toARGB32()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 98,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? item.value : AppColors.dividerLight,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: item.value.withValues(alpha: 0.24),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.value,
                            shape: BoxShape.circle,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.name,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? item.value : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 220.ms),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () {
                controller.setDarkMode(false);
                controller.setAccentColor(const Color(0xFF2E7DFF).toARGB32());
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'استعادة المظهر الافتراضي',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final isDark = controller.isDarkMode.value;
    final selected = Color(controller.accentColor.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF141B2A), const Color(0xFF1F2937)]
              : [const Color(0xFFE8F1FF), const Color(0xFFFDF6EC)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_rounded, color: selected),
              const SizedBox(width: 8),
              Text(
                'معاينة مباشرة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'زر الإجراء الأساسي',
                    style: GoogleFonts.cairo(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(
                    'تجربة',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _accentOptions = <_AccentOption>[
    _AccentOption('أزرق', Color(0xFF2E7DFF)),
    _AccentOption('أخضر', Color(0xFF10B981)),
    _AccentOption('برتقالي', Color(0xFFFF7A00)),
    _AccentOption('بنفسجي', Color(0xFF8B5CF6)),
    _AccentOption('أحمر', Color(0xFFEF4444)),
    _AccentOption('وردي', Color(0xFFEC4899)),
    _AccentOption('سماوي', Color(0xFF06B6D4)),
    _AccentOption('عنبر', Color(0xFFF59E0B)),
  ];
}

class _ThemeModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).cardTheme.color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.dividerLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentOption {
  final String name;
  final Color value;

  const _AccentOption(this.name, this.value);
}
