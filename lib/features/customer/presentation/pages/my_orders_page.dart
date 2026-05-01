import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/customer_controllers.dart';

class MyOrdersPage extends GetView<OrdersController> {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: Column(
        children: [
          // ── فلاتر الحالة ──
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: OrdersController.statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = OrdersController.statusFilters[i];
                final val = f['value']!;
                return Obx(() {
                  final active = controller.selectedStatus.value == (val.isEmpty ? null : val);
                  return GestureDetector(
                    onTap: () => controller.loadOrders(status: val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          f['label']!,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          // ── قائمة الطلبات ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingIndicator();
              if (controller.orders.isEmpty) {
                return const EmptyState(title: 'لا توجد طلبات', icon: Icons.receipt_long_outlined);
              }
              return RefreshIndicator(
                onRefresh: controller.loadOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final order = controller.orders[i];
                    final statusColor = InvoiceStatusHelper.color(order.status);
                    return GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.orderDetails, arguments: {'orderId': order.id}),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('طلب #${order.orderNumber}',
                                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    InvoiceStatusHelper.label(order.status),
                                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // شريط تقدم الحالة
                            _StatusTimeline(status: order.status),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(Formatters.dateTime(order.createdAt),
                                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                                Text(Formatters.currency(order.totalAmount),
                                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;
  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = InvoiceStatusHelper.timeline;
    final idx = InvoiceStatusHelper.timelineIndex(status);
    if (steps.isEmpty) return const SizedBox.shrink();

    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final done = i <= idx;
        final color = done ? InvoiceStatusHelper.color(status) : Colors.grey.withValues(alpha: 0.3);
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (i < steps.length - 1)
                Expanded(child: Container(height: 2, color: color)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
