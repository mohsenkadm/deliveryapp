// ألوان التطبيق — الوضع الفاتح والداكن
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  AppColors._();

  // ── Convenience getters (theme-aware) ──
  static Color get primary => Get.isDarkMode ? primaryDark : primaryLight;
  static Color get secondary => Get.isDarkMode ? secondaryDark : secondaryLight;
  static Color get accent => Get.isDarkMode ? accentDark : accentLight;
  static Color get background => Get.isDarkMode ? backgroundDark : backgroundLight;
  static Color get surface => Get.isDarkMode ? surfaceDark : surfaceLight;
  static Color get textPrimary => Get.isDarkMode ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary => Get.isDarkMode ? textSecondaryDark : textSecondaryLight;
  static Color get error => Get.isDarkMode ? errorDark : errorLight;
  static Color get success => Get.isDarkMode ? successDark : successLight;
  static Color get warning => Get.isDarkMode ? warningDark : warningLight;

  // ── Light Mode Colors ──
  static const Color primaryLight = Color(0xFF2E7DFF);
  static const Color secondaryLight = Color(0xFFFF7A00);
  static const Color accentLight = Color(0xFF00C896);
  static const Color backgroundLight = Color(0xFFF7F9FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1D2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color successLight = Color(0xFF10B981);
  static const Color warningLight = Color(0xFFF59E0B);

  // ── Dark Mode Colors ──
  static const Color primaryDark = Color(0xFF4D9FFF);
  static const Color secondaryDark = Color(0xFFFF9333);
  static const Color accentDark = Color(0xFF26E0AC);
  static const Color backgroundDark = Color(0xFF0F1420);
  static const Color surfaceDark = Color(0xFF1A2030);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color dividerDark = Color(0xFF374151);
  static const Color errorDark = Color(0xFFEF4444);
  static const Color successDark = Color(0xFF10B981);
  static const Color warningDark = Color(0xFFF59E0B);

  // ── Status Colors (Shared) ──
  static const Color pending = Color(0xFFF59E0B);
  static const Color approved = Color(0xFF10B981);
  static const Color rejected = Color(0xFFEF4444);
  static const Color inProgress = Color(0xFF2E7DFF);
  static const Color delivered = Color(0xFF00C896);
  static const Color cancelled = Color(0xFF9CA3AF);
}
