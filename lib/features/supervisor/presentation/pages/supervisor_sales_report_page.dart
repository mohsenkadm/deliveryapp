// تقرير المبيعات — المشرف
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/supervisor_controller.dart';

class SupervisorSalesReportPage extends StatefulWidget {
  const SupervisorSalesReportPage({super.key});

  @override
  State<SupervisorSalesReportPage> createState() =>
      _SupervisorSalesReportPageState();
}

class _SupervisorSalesReportPageState
    extends State<SupervisorSalesReportPage> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<SupervisorController>();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ctrl.loadSalesReport());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupervisorController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المبيعات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _pickDateRange(context, ctrl),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.salesReport.isEmpty) {
          return const LoadingIndicator();
        }

        if (_from != null || _to != null) {
          _buildDateHeader(context);
        }

        if (ctrl.salesReport.isEmpty) {
          return const EmptyState(
            icon: Icons.bar_chart_outlined,
            title: 'لا توجد بيانات',
            subtitle: 'حاول تغيير نطاق التاريخ',
          );
        }

        final totals = _computeTotals(ctrl.salesReport);

        return Column(
          children: [
            if (_from != null || _to != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${_from != null ? Formatters.formatDate(_from!) : '---'} ← ${_to != null ? Formatters.formatDate(_to!) : '---'}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            // ملخص الإجماليات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _SummaryCard(
                      label: 'إجمالي المبيعات',
                      value: Formatters.formatCurrency(totals['sales']!),
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  _SummaryCard(
                      label: 'إجمالي التحصيل',
                      value: Formatters.formatCurrency(totals['collected']!),
                      color: AppColors.success),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.salesReport.length,
                itemBuilder: (ctx, i) {
                  final item = ctrl.salesReport[i];
                  final sales =
                      ((item['totalSales'] as num?) ?? 0).toDouble();
                  final collected =
                      ((item['totalCollected'] as num?) ?? 0).toDouble();
                  return Card(
                    child: ListTile(
                      title: Text(item['repName'] ?? item['name'] ?? '',
                          style: AppTextStyles.titleSmall),
                      subtitle: Text(
                          'مبيعات: ${Formatters.formatCurrency(sales)}'),
                      trailing: Text(
                        Formatters.formatCurrency(collected),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.success),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDateHeader(BuildContext context) => const SizedBox();

  Map<String, double> _computeTotals(List<Map<String, dynamic>> data) {
    double sales = 0, collected = 0;
    for (final item in data) {
      sales += ((item['totalSales'] as num?) ?? 0).toDouble();
      collected += ((item['totalCollected'] as num?) ?? 0).toDouble();
    }
    return {'sales': sales, 'collected': collected};
  }

  Future<void> _pickDateRange(
      BuildContext ctx, SupervisorController ctrl) async {
    final range = await showDateRangePicker(
      context: ctx,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _from != null && _to != null
          ? DateTimeRange(start: _from!, end: _to!)
          : null,
    );
    if (range != null) {
      setState(() {
        _from = range.start;
        _to = range.end;
      });
      ctrl.loadSalesReport(
        from: Formatters.toApiDate(_from!),
        to: Formatters.toApiDate(_to!),
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
