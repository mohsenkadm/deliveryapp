// شارة نوع العميل — مفرد/جملة
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientTypeBadge extends StatelessWidget {
  /// قيمة من الباك‑إند: "Retail" / "Wholesale" (case-insensitive) أو نص عربي
  final String? type;
  final bool dense;
  const ClientTypeBadge({super.key, required this.type, this.dense = false});

  bool get _isWholesale {
    final t = (type ?? '').toLowerCase();
    return t == 'wholesale' || t.contains('جملة');
  }

  @override
  Widget build(BuildContext context) {
    if (type == null || type!.isEmpty) return const SizedBox.shrink();
    final color = _isWholesale ? const Color(0xFF6A1B9A) : const Color(0xFF00838F);
    final label = _isWholesale ? 'جملة' : 'مفرد';
    final icon = _isWholesale ? Icons.storefront_outlined : Icons.person_outline;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 6 : 9, vertical: dense ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dense ? 11 : 13, color: color),
          SizedBox(width: dense ? 3 : 5),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: dense ? 10 : 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}
