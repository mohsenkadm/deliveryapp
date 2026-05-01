// قائمة المندوبين — مدير المبيعات
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
        title: const Text('المندوبون'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: ctrl.loadReps),
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
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.reps.length,
          itemBuilder: (ctx, i) {
            final rep = ctrl.reps[i];
            final totalSales =
                ((rep['totalSales'] as num?) ?? 0).toDouble();
            final collected =
                ((rep['totalCollected'] as num?) ?? 0).toDouble();
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Get.toNamed(
                    AppRoutes.salesManagerRepDetail,
                    arguments: rep),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text((rep['fullName'] ?? '?')[0],
                            style: TextStyle(color: AppColors.primary,
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rep['fullName'] ?? '',
                                style: AppTextStyles.titleSmall),
                            Text(rep['phone'] ?? '',
                                style: AppTextStyles.bodySmall),
                            Row(children: [
                              _Pill(
                                  label:
                                      '${rep['customerCount'] ?? 0} عميل',
                                  color: Colors.blue),
                              const SizedBox(width: 6),
                              _Pill(
                                  label:
                                      '${rep['invoiceCount'] ?? 0} فاتورة',
                                  color: Colors.orange),
                            ]),
                          ],
                        ),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(Formatters.formatCurrency(totalSales),
                              style: AppTextStyles.bodySmall),
                          Text(Formatters.formatCurrency(collected),
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.success)),
                        ]),
                    ],
                  ),
                ),
              ),
            );
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
