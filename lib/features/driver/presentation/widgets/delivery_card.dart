import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/driver_entities.dart';

class DeliveryCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback? onTap;
  final VoidCallback? onStartDelivery;
  final VoidCallback? onMarkDelivered;

  const DeliveryCard({super.key, required this.order, this.onTap, this.onStartDelivery, this.onMarkDelivered});

  @override
  Widget build(BuildContext context) {
    final statusColor = Helpers.getStatusColor(order.status);
    final statusText = Helpers.getStatusText(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طلب #${order.orderNumber}', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(statusText, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.person, order.customerName, context),
            const SizedBox(height: 6),
            _infoRow(Icons.phone, order.customerPhone, context),
            const SizedBox(height: 6),
            _infoRow(Icons.location_on, order.customerAddress, context),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Formatters.currency(order.totalAmount), style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                Text(Formatters.timeAgo(order.createdAt), style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
              ],
            ),
            if (onStartDelivery != null || onMarkDelivered != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onStartDelivery != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onStartDelivery,
                        icon: const Icon(Icons.local_shipping, size: 18),
                        label: Text('بدء التوصيل', style: GoogleFonts.cairo(fontSize: 13)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                      ),
                    ),
                  if (onStartDelivery != null && onMarkDelivered != null) const SizedBox(width: 8),
                  if (onMarkDelivered != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMarkDelivered,
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: Text('تم التوصيل', style: GoogleFonts.cairo(fontSize: 13)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
