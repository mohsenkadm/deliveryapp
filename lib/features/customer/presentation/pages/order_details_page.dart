import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/customer_controllers.dart';
import '../../domain/entities/customer_entities.dart';

class OrderDetailsPage extends GetView<OrdersController> {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final orderId = args['orderId'] as String;

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: FutureBuilder(
        future: () async {
          final repo = controller.repository;
          return repo.getOrderDetails(orderId);
        }(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingIndicator();
          return snapshot.data!.fold(
            (f) => Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(f.message, style: GoogleFonts.cairo(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => Get.back(), child: const Text('رجوع')),
              ]),
            ),
            (order) => _OrderBody(order: order, controller: controller),
          );
        },
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  final Order order;
  final OrdersController controller;

  const _OrderBody({required this.order, required this.controller});

  bool get _canCancel =>
      order.status == 'Pending' || order.status == 'Accepted';

  bool get _hasInvoice =>
      order.status == 'Delivered' ||
      order.status == 'Completed' ||
      order.status == 'AwaitingDelivery';

  @override
  Widget build(BuildContext context) {
    final statusColor = InvoiceStatusHelper.color(order.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس الطلب ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('طلب #${order.orderNumber}',
                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(InvoiceStatusHelper.label(order.status),
                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(Formatters.dateTime(order.createdAt),
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                if (order.driverName != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('السائق: ${order.driverName}',
                        style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                  ]),
                ],
              ],
            ),
          ),

          // ── تسلسل الحالات ──
          const SizedBox(height: 20),
          Text('مراحل الطلب', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildTimeline(context, statusColor),

          // ── المنتجات ──
          const SizedBox(height: 24),
          Text('المنتجات', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...order.items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(item.productName,
                            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600))),
                    Text('× ${item.quantity}',
                        style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                    const SizedBox(width: 16),
                    Text(Formatters.currency(item.total),
                        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              )),

          // ── الإجمالي ──
          const Divider(height: 24),
          if (order.deliveryFee != null)
            _row('رسوم التوصيل', Formatters.currency(order.deliveryFee!)),
          _row('الإجمالي', Formatters.currency(order.totalAmount), isBold: true),

          // ── ملاحظات ──
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('ملاحظات', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(order.notes!, style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600])),
          ],

          // ── أزرار الإجراءات ──
          const SizedBox(height: 24),
          if (_hasInvoice)
            CustomButton(
              text: 'عرض الفاتورة',
              icon: Icons.receipt_long_outlined,
              onPressed: () => Get.toNamed(AppRoutes.invoiceViewer, arguments: order.id),
            ),
          if (_canCancel) ...[
            const SizedBox(height: 10),
            Obx(() => CustomButton(
                  text: 'إلغاء الطلب',
                  isLoading: controller.isCancelling.value,
                  backgroundColor: AppColors.error,
                  onPressed: () => _confirmCancel(context),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, Color activeColor) {
    final steps = InvoiceStatusHelper.timeline;
    final currentIdx = InvoiceStatusHelper.timelineIndex(order.status);
    if (steps.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        itemBuilder: (_, i) {
          final done = i <= currentIdx;
          final isCurrent = i == currentIdx;
          final color = done ? activeColor : Colors.grey.withValues(alpha: 0.35);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isCurrent ? 32 : 22,
                    height: isCurrent ? 32 : 22,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isCurrent ? Border.all(color: color.withValues(alpha: 0.3), width: 4) : null,
                    ),
                    child: done
                        ? Icon(Icons.check, size: isCurrent ? 16 : 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    InvoiceStatusHelper.label(steps[i]),
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                      color: done ? activeColor : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (i < steps.length - 1)
                Container(
                  width: 28,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: i < currentIdx ? activeColor : Colors.grey.withValues(alpha: 0.3),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.normal)),
          Text(value, style: GoogleFonts.cairo(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('تراجع')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إلغاء الطلب'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.cancelOrder(order.id);
      Get.back();
    }
  }
}
