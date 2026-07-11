import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// عدّاد كمية المنتج (+ / −) — يُستخدم في قوائم المنتجات وسلة الفاتورة.
class ProductQuantityStepper extends StatelessWidget {
  final int quantity;
  final bool enabled;
  final int? maxQuantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onAdd;

  const ProductQuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.enabled = true,
    this.maxQuantity,
    this.onAdd,
  });

  bool get _canIncrement =>
      enabled && (maxQuantity == null || quantity < maxQuantity!);

  @override
  Widget build(BuildContext context) {
    if (quantity <= 0) {
      return IconButton.filled(
        onPressed: enabled ? (onAdd ?? onIncrement) : null,
        icon: const Icon(Icons.add, size: 20),
        tooltip: 'إضافة',
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: EdgeInsets.zero,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dividerLight),
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onPressed: enabled ? onDecrement : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onPressed: _canIncrement ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
