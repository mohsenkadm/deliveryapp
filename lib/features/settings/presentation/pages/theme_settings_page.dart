import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';

class ThemeSettingsPage extends GetView<ThemeController> {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('المظهر والألوان', style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Dark / Light Toggle ──
              Text('وضع العرض', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ThemeModeCard(
                      icon: Icons.light_mode_rounded,
                      label: 'فاتح',
                      isSelected: !controller.isDarkMode.value,
                      onTap: () => controller.setDarkMode(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ThemeModeCard(
                      icon: Icons.dark_mode_rounded,
                      label: 'داكن',
                      isSelected: controller.isDarkMode.value,
                      onTap: () => controller.setDarkMode(true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Accent Color Picker ──
              Text('لون التطبيق', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('اختر اللون المفضل للتطبيق', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _accentColors.map((color) {
                  final isSelected = controller.accentColor.value == color.toARGB32();
                  return GestureDetector(
                    onTap: () => controller.setAccentColor(color.toARGB32()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.textPrimary : Colors.transparent,
                          width: isSelected ? 3 : 0,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 22) : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          )),
    );
  }

  static const _accentColors = <Color>[
    Color(0xFF2E7DFF), // Blue (default)
    Color(0xFF10B981), // Green
    Color(0xFFFF7A00), // Orange
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEF4444), // Red
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF59E0B), // Amber
  ];
}

class _ThemeModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeCard({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Theme.of(context).cardTheme.color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.dividerLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.cairo(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            )),
          ],
        ),
      ),
    );
  }
}
