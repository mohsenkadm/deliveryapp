// صفحة ملخص أداء السائق
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/driver_controllers.dart';

class DriverSummaryPage extends StatelessWidget {
  const DriverSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverHomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملخص الأداء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ctrl.refreshSummary,
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) return const LoadingIndicator();
        final s = ctrl.summary.value;
        if (s == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('لا توجد بيانات أداء',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: ctrl.refreshSummary,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // نسبة الإنجاز
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('نسبة إتمام التوصيل',
                          style: AppTextStyles.titleMedium),
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: s.completionRate / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[200],
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${s.completionRate.toStringAsFixed(1)}%',
                            style: AppTextStyles.headlineMedium
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // إحصائيات
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(
                    label: 'إجمالي المُعيَّنة',
                    value: '${s.totalAssigned}',
                    color: Colors.blue,
                    icon: Icons.assignment,
                  ),
                  _StatCard(
                    label: 'مكتملة',
                    value: '${s.completed}',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                  _StatCard(
                    label: 'في انتظار التوصيل',
                    value: '${s.awaitingDelivery}',
                    color: Colors.orange,
                    icon: Icons.local_shipping,
                  ),
                  _StatCard(
                    label: 'مرفوضة',
                    value: '${s.rejected}',
                    color: Colors.red,
                    icon: Icons.cancel,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.headlineSmall
                    .copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
