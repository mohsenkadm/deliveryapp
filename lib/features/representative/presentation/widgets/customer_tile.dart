import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomerTile extends StatelessWidget {
  final String name;
  final String phone;
  final String? email;
  final double? totalDebt;
  final VoidCallback? onTap;
  final VoidCallback? onCollectPayment;

  const CustomerTile({
    super.key,
    required this.name,
    required this.phone,
    this.email,
    this.totalDebt,
    this.onTap,
    this.onCollectPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(phone, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (totalDebt != null && totalDebt! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${totalDebt!.toStringAsFixed(0)} د.ع',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              if (onCollectPayment != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onCollectPayment,
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('تحصيل دفعة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
