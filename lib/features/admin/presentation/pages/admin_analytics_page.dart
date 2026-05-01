import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/admin_controllers.dart';

class AdminAnalyticsPage extends GetView<AdminDashboardController> {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('التحليلات والإحصائيات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadDashboard,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();
        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('ملخص الأداء'),
                const SizedBox(height: 12),
                _buildKpiGrid(),
                const SizedBox(height: 24),
                _SectionTitle('المبيعات الأسبوعية'),
                const SizedBox(height: 12),
                _WeeklySalesChart(data: controller.weeklySales),
                const SizedBox(height: 24),
                _SectionTitle('توزيع الفواتير'),
                const SizedBox(height: 12),
                _buildStatusDistribution(),
                const SizedBox(height: 24),
                _SectionTitle('أبرز المؤشرات'),
                const SizedBox(height: 12),
                _buildHighlights(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKpiGrid() {
    final stats = controller.stats;
    final kpis = [
      _KpiData(
        icon: Icons.receipt_long_rounded,
        label: 'إجمالي الفواتير',
        value: '${stats['totalInvoices'] ?? 0}',
        color: AppColors.primaryLight,
      ),
      _KpiData(
        icon: Icons.monetization_on_rounded,
        label: 'المبيعات',
        value: Formatters.currency((stats['totalSales'] ?? 0).toDouble()),
        color: AppColors.successLight,
      ),
      _KpiData(
        icon: Icons.people_rounded,
        label: 'العملاء',
        value: '${stats['totalCustomers'] ?? 0}',
        color: AppColors.secondaryLight,
      ),
      _KpiData(
        icon: Icons.money_off_rounded,
        label: 'الديون',
        value: Formatters.currency((stats['totalDebts'] ?? 0).toDouble()),
        color: AppColors.errorLight,
      ),
      _KpiData(
        icon: Icons.pending_actions_rounded,
        label: 'معلقة',
        value: '${stats['pendingInvoices'] ?? 0}',
        color: AppColors.warningLight,
      ),
      _KpiData(
        icon: Icons.check_circle_rounded,
        label: 'مكتملة',
        value: '${stats['completedInvoices'] ?? 0}',
        color: AppColors.accentLight,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: kpis.length,
      itemBuilder: (_, i) => _KpiCard(data: kpis[i]),
    );
  }

  Widget _buildStatusDistribution() {
    final stats = controller.stats;
    final statuses = [
      _StatusItem('معلق', stats['pendingInvoices'] ?? 0, AppColors.warningLight),
      _StatusItem('مقبول', stats['acceptedInvoices'] ?? 0, AppColors.primaryLight),
      _StatusItem('في المستودع', stats['warehouseInvoices'] ?? 0, Colors.purple),
      _StatusItem('مكتمل', stats['completedInvoices'] ?? 0, AppColors.successLight),
      _StatusItem('مرفوض', stats['rejectedInvoices'] ?? 0, AppColors.errorLight),
    ];
    final total = statuses.fold(0, (sum, s) => sum + (s.count as int));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: statuses.map((s) {
          final percent = total > 0 ? (s.count / total) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.label, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('${s.count} (${(percent * 100).toStringAsFixed(0)}%)',
                        style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent.toDouble(),
                    minHeight: 8,
                    backgroundColor: AppColors.dividerLight,
                    valueColor: AlwaysStoppedAnimation<Color>(s.color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHighlights() {
    final stats = controller.stats;
    final items = [
      _HighlightItem(Icons.trending_up_rounded, 'أعلى مبيعات', '${stats['topRepresentative'] ?? 'غير متوفر'}', AppColors.successLight),
      _HighlightItem(Icons.star_rounded, 'أكثر عميل شراءً', '${stats['topCustomer'] ?? 'غير متوفر'}', AppColors.warningLight),
      _HighlightItem(Icons.local_shipping_rounded, 'أفضل سائق', '${stats['topDriver'] ?? 'غير متوفر'}', AppColors.primaryLight),
      _HighlightItem(Icons.inventory_2_rounded, 'الأكثر مبيعاً', '${stats['topProduct'] ?? 'غير متوفر'}', AppColors.secondaryLight),
    ];
    return Column(
      children: items.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.label, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)),
              Text(item.value, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14)),
            ]),
          ],
        ),
      )).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16));
  }
}

class _KpiData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _KpiData({required this.icon, required this.label, required this.value, required this.color});
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Icon(data.icon, color: data.color, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(data.label, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Text(data.value, style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 18, color: data.color)),
        ],
      ),
    );
  }
}

class _StatusItem {
  final String label;
  final num count;
  final Color color;
  const _StatusItem(this.label, this.count, this.color);
}

class _HighlightItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _HighlightItem(this.icon, this.label, this.value, this.color);
}

class _WeeklySalesChart extends StatelessWidget {
  final List<double> data;
  const _WeeklySalesChart({required this.data});

  static const _days = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

  @override
  Widget build(BuildContext context) {
    final values = data.isEmpty ? List.filled(7, 0.0) : data;
    final maxVal = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(values.length > 7 ? 7 : values.length, (i) {
                final val = values[i];
                final heightPercent = maxVal > 0 ? val / maxVal : 0.0;
                return Tooltip(
                  message: Formatters.currency(val),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 28,
                        height: (heightPercent * 100).clamp(4.0, 100.0),
                        decoration: BoxDecoration(
                          color: i == values.length - 1 ? AppColors.primary : AppColors.primaryLight.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              values.length > 7 ? 7 : values.length,
              (i) => SizedBox(
                width: 32,
                child: Text(_days[i % 7],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 9, color: AppColors.textSecondary)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
