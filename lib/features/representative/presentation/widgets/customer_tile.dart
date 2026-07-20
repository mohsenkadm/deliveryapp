import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/media_url.dart';

class CustomerTile extends StatelessWidget {
  final String name;
  final String phone;
  final String? email;
  final String? storeImagePath;
  final double? totalDebt;
  final VoidCallback? onTap;
  final VoidCallback? onCollectPayment;

  const CustomerTile({
    super.key,
    required this.name,
    required this.phone,
    this.email,
    this.storeImagePath,
    this.totalDebt,
    this.onTap,
    this.onCollectPayment,
  });

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(storeImagePath);
    final initial = name.isNotEmpty ? name[0] : '?';

    Widget avatarPlaceholder() => CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            initial,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

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
                  if (url != null)
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => avatarPlaceholder(),
                        errorWidget: (_, __, ___) => avatarPlaceholder(),
                      ),
                    )
                  else
                    avatarPlaceholder(),
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
