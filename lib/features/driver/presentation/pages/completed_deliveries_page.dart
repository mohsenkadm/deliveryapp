// صفحة التوصيلات المكتملة — السائق
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/driver_entities.dart';
import '../controllers/driver_controllers.dart';

class CompletedDeliveriesPage extends GetView<DriverHomeController> {
  const CompletedDeliveriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التوصيلات المكتملة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadCompletedDeliveries,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.completedOrders.isEmpty) {
          return const LoadingIndicator();
        }
        if (controller.completedOrders.isEmpty) {
          return const EmptyState(
            title: 'لا توجد توصيلات مكتملة',
            subtitle: 'ستظهر هنا الطلبات التي تم تسليمها',
            icon: Icons.check_circle_outline,
          );
        }

        // حساب الإجماليات
        final total = controller.completedOrders
            .fold<double>(0, (sum, o) => sum + o.totalAmount);

        return RefreshIndicator(
          onRefresh: controller.loadCompletedDeliveries,
          child: CustomScrollView(
            slivers: [
              // ── بطاقة الملخص ──
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.successLight,
                        AppColors.successLight.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.successLight.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('عدد التوصيلات',
                              style: GoogleFonts.cairo(
                                  fontSize: 12, color: Colors.white70)),
                          Text('${controller.completedOrders.length}',
                              style: GoogleFonts.cairo(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('إجمالي المبالغ',
                              style: GoogleFonts.cairo(
                                  fontSize: 12, color: Colors.white70)),
                          Text(Formatters.currency(total),
                              style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),

              // ── قائمة الطلبات ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _CompletedOrderCard(
                            order: controller.completedOrders[i])
                        .animate()
                        .fadeIn(delay: (50 + i * 40).ms)
                        .slideY(begin: 0.05),
                    childCount: controller.completedOrders.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CompletedOrderCard extends StatelessWidget {
  final DeliveryOrder order;
  const _CompletedOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.successLight.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('طلب #${order.orderNumber}',
                  style: GoogleFonts.cairo(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: AppColors.successLight),
                    const SizedBox(width: 4),
                    Text('مكتمل',
                        style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.successLight)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // معلومات العميل
          Row(
            children: [
              Icon(Icons.storefront_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.storeName ?? order.customerName,
                  style: GoogleFonts.cairo(
                      fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.customerAddress,
                  style: GoogleFonts.cairo(
                      fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // السطر السفلي: المبلغ والتاريخ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Formatters.currency(order.totalAmount),
                  style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              Text(Formatters.date(order.createdAt),
                  style: GoogleFonts.cairo(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
