// صفحة ملخص أداء السائق — مع رسم بياني دائري fl_chart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/driver_controllers.dart';

class DriverSummaryPage extends GetView<DriverHomeController> {
  const DriverSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملخص الأداء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshSummary,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) {
          return const LoadingIndicator();
        }
        final s = controller.summary.value;
        if (s == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('لا توجد بيانات أداء',
                    style: GoogleFonts.cairo(
                        fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: controller.refreshSummary,
                  child: Text('إعادة المحاولة',
                      style: GoogleFonts.cairo()),
                ),
              ],
            ),
          );
        }

        final total = s.totalAssigned == 0 ? 1.0 : s.totalAssigned.toDouble();
        final completedPct = (s.completed / total * 100).toStringAsFixed(1);

        return RefreshIndicator(
          onRefresh: controller.refreshSummary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── رسم بياني دائري ──
                _PieSection(s: s)
                    .animate()
                    .fadeIn(duration: 600.ms),

                const SizedBox(height: 24),

                // ── بطاقة نسبة الإنجاز ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('نسبة الإنجاز الكلية',
                          style: GoogleFonts.cairo(
                              fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text('$completedPct%',
                          style: GoogleFonts.cairo(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('${s.completed} من ${s.totalAssigned} طلب',
                          style: GoogleFonts.cairo(
                              fontSize: 13, color: Colors.white60)),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),

                // ── شبكة الإحصائيات ──
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                      label: 'إجمالي المُعيَّنة',
                      value: '${s.totalAssigned}',
                      color: AppColors.primaryLight,
                      icon: Icons.assignment_rounded,
                    ),
                    _StatCard(
                      label: 'مكتملة',
                      value: '${s.completed}',
                      color: AppColors.successLight,
                      icon: Icons.check_circle_rounded,
                    ),
                    _StatCard(
                      label: 'في انتظار التوصيل',
                      value: '${s.awaitingDelivery}',
                      color: const Color(0xFFF59E0B),
                      icon: Icons.local_shipping_rounded,
                    ),
                    _StatCard(
                      label: 'مرفوضة',
                      value: '${s.rejected}',
                      color: AppColors.errorLight,
                      icon: Icons.cancel_rounded,
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// الرسم البياني الدائري
// ─────────────────────────────────────────────
class _PieSection extends StatefulWidget {
  final dynamic s;
  const _PieSection({required this.s});

  @override
  State<_PieSection> createState() => _PieSectionState();
}

class _PieSectionState extends State<_PieSection> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final total = (s.totalAssigned as int).toDouble();
    if (total == 0) return const SizedBox.shrink();

    final sections = [
      _PieEntry('مكتملة', s.completed.toDouble(), AppColors.successLight),
      _PieEntry('في التوصيل', s.awaitingDelivery.toDouble(), const Color(0xFFF59E0B)),
      _PieEntry('مرفوضة', s.rejected.toDouble(), AppColors.errorLight),
    ].where((e) => e.value > 0).toList();

    if (sections.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('توزيع الطلبات',
              style: GoogleFonts.cairo(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie chart
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            _touchedIndex = response
                                        ?.touchedSection
                                        ?.touchedSectionIndex ??
                                    -1;
                          });
                        },
                      ),
                      sections: sections.asMap().entries.map((entry) {
                        final i = entry.key;
                        final e = entry.value;
                        final isTouched = i == _touchedIndex;
                        final pct = (e.value / total * 100)
                            .toStringAsFixed(0);
                        return PieChartSectionData(
                          value: e.value,
                          color: e.color,
                          radius: isTouched ? 65 : 56,
                          title: '$pct%',
                          titleStyle: GoogleFonts.cairo(
                            fontSize: isTouched ? 14 : 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 32,
                      sectionsSpace: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Legend
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: e.color,
                                    borderRadius:
                                        BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(e.label,
                                      style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color:
                                              AppColors.textSecondary)),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieEntry {
  final String label;
  final double value;
  final Color color;
  const _PieEntry(this.label, this.value, this.color);
}

// ─────────────────────────────────────────────
// بطاقة إحصاء
// ─────────────────────────────────────────────
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color)),
                Text(label,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
