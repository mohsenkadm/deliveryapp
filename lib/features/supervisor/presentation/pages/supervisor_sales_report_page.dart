// تقرير المبيعات — المشرف (جدول + مخطط شريطي)
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
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
    extends State<SupervisorSalesReportPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.find<SupervisorController>().loadSalesReport());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupervisorController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('تقرير المبيعات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'فلتر التاريخ',
            onPressed: () => _pickDateRange(context, ctrl),
          ),
          if (_from != null || _to != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'إلغاء الفلتر',
              onPressed: () {
                setState(() {
                  _from = null;
                  _to = null;
                });
                ctrl.loadSalesReport();
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'مخطط'),
            Tab(icon: Icon(Icons.table_rows_outlined), text: 'جدول'),
          ],
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.salesReport.isEmpty) {
          return const LoadingIndicator();
        }

        return Column(
          children: [
            // ── شريط التاريخ ──
            if (_from != null || _to != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: AppColors.primaryLight),
                    const SizedBox(width: 6),
                    Text(
                      '${_from != null ? Formatters.date(_from!) : '---'}  →  ${_to != null ? Formatters.date(_to!) : '---'}',
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: AppColors.primaryLight),
                    ),
                  ],
                ),
              ),

            // ── ملخص الإجماليات ──
            if (ctrl.salesReport.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSummaryRow(ctrl),
            ],

            // ── المحتوى ──
            Expanded(
              child: ctrl.salesReport.isEmpty
                  ? const EmptyState(
                      icon: Icons.bar_chart_outlined,
                      title: 'لا توجد بيانات',
                      subtitle: 'حاول تغيير نطاق التاريخ',
                    )
                  : TabBarView(
                      controller: _tabs,
                      children: [
                        _BarChartTab(data: ctrl.salesReport),
                        _TableTab(data: ctrl.salesReport),
                      ],
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryRow(SupervisorController ctrl) {
    final totals = _computeTotals(ctrl.salesReport);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SummaryCard(
            label: 'إجمالي المبيعات',
            value: Formatters.currency(totals['sales']!),
            color: AppColors.primaryLight,
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(width: 10),
          _SummaryCard(
            label: 'إجمالي التحصيل',
            value: Formatters.currency(totals['collected']!),
            color: AppColors.successLight,
            icon: Icons.payments_rounded,
          ),
        ],
      ),
    );
  }

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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryLight),
        ),
        child: child!,
      ),
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

// ─────────────────────────────────────────────
// تبويب المخطط الشريطي
// ─────────────────────────────────────────────
class _BarChartTab extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  const _BarChartTab({required this.data});

  @override
  State<_BarChartTab> createState() => _BarChartTabState();
}

class _BarChartTabState extends State<_BarChartTab> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final items = widget.data.take(8).toList(); // max 8 bars for readability
    if (items.isEmpty) return const SizedBox();

    final maxSales = items.fold<double>(
        0, (m, r) => ((r['totalSales'] as num?) ?? 0).toDouble() > m
            ? ((r['totalSales'] as num?) ?? 0).toDouble()
            : m);
    final maxY = (maxSales * 1.2).clamp(1.0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.primaryLight, label: 'المبيعات'),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.successLight, label: 'التحصيل'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final rep = items[group.x];
                      final repName = (rep['repName'] ?? rep['name'] ?? '')
                          .toString();
                      final shortened = repName.length > 8
                          ? '${repName.substring(0, 8)}...'
                          : repName;
                      return BarTooltipItem(
                        '$shortened\n${Formatters.currency(rod.toY)}',
                        GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex =
                          response?.spot?.touchedBarGroupIndex ?? -1;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= items.length) return const SizedBox();
                        final name =
                            (items[i]['repName'] ?? items[i]['name'] ?? '')
                                .toString();
                        final short = name.length > 5
                            ? name.substring(0, 5)
                            : name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(short,
                              style: GoogleFonts.cairo(
                                  fontSize: 9,
                                  color: AppColors.textSecondary)),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) => Text(
                        _shortCurrency(value),
                        style: GoogleFonts.cairo(
                            fontSize: 9, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.dividerLight.withValues(alpha: 0.5),
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(items.length, (i) {
                  final rep = items[i];
                  final sales =
                      ((rep['totalSales'] as num?) ?? 0).toDouble();
                  final collected =
                      ((rep['totalCollected'] as num?) ?? 0).toDouble();
                  final isTouched = _touchedIndex == i;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: sales,
                        color: AppColors.primaryLight
                            .withValues(alpha: isTouched ? 1.0 : 0.8),
                        width: isTouched ? 14 : 11,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5)),
                      ),
                      BarChartRodData(
                        toY: collected,
                        color: AppColors.successLight
                            .withValues(alpha: isTouched ? 1.0 : 0.8),
                        width: isTouched ? 14 : 11,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5)),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
            ),
          ),
          if (items.length < widget.data.length) ...[
            const SizedBox(height: 8),
            Text(
              '* يُعرض أول ${items.length} مندوبين فقط في المخطط',
              style: GoogleFonts.cairo(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  String _shortCurrency(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}م';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}ك';
    return v.toInt().toString();
  }
}

// ─────────────────────────────────────────────
// تبويب الجدول
// ─────────────────────────────────────────────
class _TableTab extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _TableTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: data.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemBuilder: (_, i) {
        if (i == 0) {
          // رأس الجدول
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('المندوب',
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight))),
                Expanded(
                    flex: 2,
                    child: Text('المبيعات',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight))),
                Expanded(
                    flex: 2,
                    child: Text('التحصيل',
                        textAlign: TextAlign.end,
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successLight))),
              ],
            ),
          );
        }

        final item = data[i - 1];
        final sales =
            ((item['totalSales'] as num?) ?? 0).toDouble();
        final collected =
            ((item['totalCollected'] as num?) ?? 0).toDouble();
        final repName =
            item['repName'] ?? item['name'] ?? '—';
        final isEven = i.isEven;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          color: isEven
              ? AppColors.primaryLight.withValues(alpha: 0.03)
              : null,
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(repName.toString(),
                      style: GoogleFonts.cairo(fontSize: 13))),
              Expanded(
                flex: 2,
                child: Text(
                  Formatters.currency(sales),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  Formatters.currency(collected),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successLight),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Widgets مساعدة
// ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(label,
                      style: GoogleFonts.cairo(
                          fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

