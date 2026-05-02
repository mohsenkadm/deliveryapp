// قائمة المندوبين — مدير المبيعات
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/sales_manager_controller.dart';

class SalesManagerRepsPage extends StatelessWidget {
  const SalesManagerRepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesManagerController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('المندوبون',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: ctrl.loadReps),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.reps.isEmpty) {
          return const LoadingIndicator();
        }
        if (ctrl.reps.isEmpty) {
          return const EmptyState(
              icon: Icons.people_outline, title: 'لا يوجد مندوبون');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.reps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final rep = ctrl.reps[i];
            final totalSales =
                ((rep['totalSales'] as num?) ?? 0).toDouble();
            final collected =
                ((rep['totalCollected'] as num?) ?? 0).toDouble();
            final name = rep['fullName'] ?? '?';
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.dividerLight),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Get.toNamed(
                    AppRoutes.salesManagerRepDetail,
                    arguments: rep),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            AppColors.primaryLight.withValues(alpha: 0.12),
                        child: Text(
                          name[0],
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            Text(rep['phone'] ?? '',
                                style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Row(children: [
                              _Pill(
                                  label:
                                      '${rep['customerCount'] ?? 0} عميل',
                                  color: AppColors.primaryLight),
                              const SizedBox(width: 6),
                              _Pill(
                                  label:
                                      '${rep['invoiceCount'] ?? 0} فاتورة',
                                  color: AppColors.warningLight),
                            ]),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(totalSales),
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLight),
                          ),
                          Text(
                            Formatters.currency(collected),
                            style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.successLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (40 + i * 40).ms).slideY(begin: 0.05, end: 0);
          },
        );
      }),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.cairo(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
