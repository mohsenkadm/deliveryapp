// شارة الحالة — ملوّنة بحسب حالة الفاتورة أو الطلب
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/helpers.dart';

/// شارة صغيرة ملونة تعرض حالة الفاتورة بالعربية
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    final color = InvoiceStatusHelper.color(status);
    final label = InvoiceStatusHelper.label(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
