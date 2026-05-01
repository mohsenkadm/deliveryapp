import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationDialog {
  static Future<bool> show({
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color? confirmColor,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText,
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Get.theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              confirmText,
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}
