// تبويبات فلتر حالة الفاتورة
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/helpers.dart';

/// قائمة FilterChip أفقية لتصفية الفواتير حسب الحالة.
/// [selected] = '' يعني "الكل".
class InvoiceStatusFilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  /// الحالات المُضمَّنة افتراضياً — يمكن تمرير قائمة مخصصة.
  final List<String> statuses;

  const InvoiceStatusFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    this.statuses = const [
      '',
      'Pending',
      'Accepted',
      'WarehouseProcessing',
      'AwaitingDelivery',
      'Delivered',
      'Completed',
      'Rejected',
      'Deferred',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: statuses.map((status) {
          final isAll = status.isEmpty;
          final label =
              isAll ? 'الكل' : InvoiceStatusHelper.label(status);
          final color = isAll
              ? Theme.of(context).colorScheme.primary
              : InvoiceStatusHelper.color(status);
          final isSelected = selected == status;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : null,
                ),
              ),
              selected: isSelected,
              selectedColor: color.withValues(alpha: 0.12),
              checkmarkColor: color,
              side: BorderSide(
                color: isSelected
                    ? color.withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
              onSelected: (_) => onChanged(status),
            ),
          );
        }).toList(),
      ),
    );
  }
}
