import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/driver_controllers.dart';

class DriverHomePage extends GetView<DriverHomeController> {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
              child: Text('🚚', style: GoogleFonts.cairo(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً 👋', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                  Text(authService.userName, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Get.toNamed(AppRoutes.driverNotifications)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();

        final assigned = controller.assignedOrders.length;
        final inProgress = controller.assignedOrders.where((o) => o.status == 'AwaitingDelivery').length;
        final completedToday = controller.completedTodayCount.value;

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Stats Row ──
              Row(
                children: [
                  _DriverStat(icon: Icons.assignment_rounded, label: 'مسندة', value: '$assigned', color: AppColors.primaryLight),
                  const SizedBox(width: 10),
                  _DriverStat(icon: Icons.check_circle_rounded, label: 'مكتملة اليوم', value: '$completedToday', color: AppColors.successLight),
                  const SizedBox(width: 10),
                  _DriverStat(icon: Icons.local_shipping_rounded, label: 'قيد التوصيل', value: '$inProgress', color: AppColors.secondaryLight),
                ],
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 24),

              Text('الطلبات المسندة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              if (controller.assignedOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text('لا توجد طلبات مسندة حالياً', style: GoogleFonts.cairo(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                ...controller.assignedOrders.map((order) {
                  final statusColor = _getStatusColor(order.status);
                  final statusText = _getStatusText(order.status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
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
                        const SizedBox(height: 10),
                        _infoRow(Icons.person_outline, order.customerName, context),
                        const SizedBox(height: 4),
                        _infoRow(Icons.phone_outlined, order.customerPhone, context),
                        const SizedBox(height: 4),
                        _infoRow(Icons.location_on_outlined, order.customerAddress, context),
                        // No amount displayed per spec
                        if (order.status == 'AwaitingDelivery' || order.status == 'Accepted') ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: controller.isUpdating.value
                                  ? null
                                  : () {
                                      final nextStatus = order.status == 'AwaitingDelivery'
                                          ? 'Delivered'
                                          : 'AwaitingDelivery';
                                      controller.updateStatus(order.id, nextStatus);
                                    },
                              icon: Icon(
                                order.status == 'AwaitingDelivery' ? Icons.check_circle : Icons.local_shipping,
                                size: 18,
                              ),
                              label: Text(
                                order.status == 'AwaitingDelivery' ? 'تم التوصيل' : 'بدء التوصيل',
                                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: order.status == 'AwaitingDelivery' ? AppColors.successLight : AppColors.primaryLight,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: (200).ms).slideY(begin: 0.05);
                }),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return AppColors.pending;
      case 'AwaitingDelivery':
        return AppColors.inProgress;
      case 'Delivered':
        return AppColors.delivered;
      case 'Completed':
        return AppColors.approved;
      case 'Rejected':
        return AppColors.rejected;
      default:
        return AppColors.cancelled;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Accepted':
        return 'مقبول';
      case 'AwaitingDelivery':
        return 'قيد التوصيل';
      case 'Delivered':
        return 'تم التسليم';
      case 'Completed':
        return 'مكتمل';
      case 'Rejected':
        return 'مرفوض';
      default:
        return InvoiceStatusHelper.label(status);
    }
  }
}

class _DriverStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DriverStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
