import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/customer_entities.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({super.key, required this.category, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
        ),
        child: Text(
          category.name,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
