// مساعد الرسائل المنبثقة — رسائل نجاح/خطأ/تنبيه/معلومة
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../network/api_exception.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      'نجاح',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void showError(String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  static void showWarning(String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      'تنبيه',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFF59E0B),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  static void showInfo(String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      'معلومة',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  /// يستخرج رسالة الخطأ العربية من [ApiException] إن وُجدت،
  /// وإلا يعرض [fallback]. يُستخدم في جميع catch blocks.
  static void handleApiError(Object e, String fallback) {
    final msg = e is ApiException ? e.message : fallback;
    showError(msg);
  }
}
