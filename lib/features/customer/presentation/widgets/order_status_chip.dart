import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/helpers.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;

  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = Helpers.getStatusColor(status);
    final text = Helpers.getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
