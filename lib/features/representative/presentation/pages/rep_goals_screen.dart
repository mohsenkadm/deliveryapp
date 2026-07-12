import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/rep_models.dart';
import '../controllers/representative_controllers.dart';

class RepGoalsScreen extends GetView<RepresentativeHomeController> {
  const RepGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLoadingGoals.value &&
          controller.currentGoal.value == null &&
          controller.goalsHistory.isEmpty) {
        controller.loadRepGoals();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('أهدافي', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadRepGoals,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingGoals.value &&
            controller.currentGoal.value == null) {
          return const LoadingIndicator();
        }

        return RefreshIndicator(
          onRefresh: controller.loadRepGoals,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _FiltersSection(controller: controller),
              const SizedBox(height: 20),
              _CurrentGoalSection(goal: controller.currentGoal.value)
                  .animate()
                  .fadeIn(duration: 500.ms),
              const SizedBox(height: 24),
              Text('سجل الأهداف',
                  style: GoogleFonts.cairo(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (controller.goalsHistory.isEmpty)
                const EmptyState(
                  icon: Icons.flag_outlined,
                  title: 'لا يوجد سجل',
                  subtitle: 'لم يُعثر على أهداف للفترة المحددة.',
                )
              else
                ...controller.goalsHistory.map((g) => _HistoryTile(goal: g)),
            ],
          ),
        );
      }),
    );
  }
}

class _FiltersSection extends StatelessWidget {
  final RepresentativeHomeController controller;
  const _FiltersSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: controller.selectedGoalYear.value,
                    decoration: InputDecoration(
                      labelText: 'السنة',
                      labelStyle: GoogleFonts.cairo(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: controller.goalYearOptions
                        .map((y) => DropdownMenuItem(
                              value: y,
                              child: Text('$y', style: GoogleFonts.cairo()),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) controller.setGoalYear(v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: controller.selectedGoalMonth.value,
                    decoration: InputDecoration(
                      labelText: 'الشهر',
                      labelStyle: GoogleFonts.cairo(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: List.generate(12, (i) {
                      final m = i + 1;
                      return DropdownMenuItem(
                        value: m,
                        child: Text(controller.monthLabel(m),
                            style: GoogleFonts.cairo()),
                      );
                    }),
                    onChanged: (v) {
                      if (v != null) controller.setGoalMonth(v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 1),
                  initialDateRange: controller.historyFrom.value != null &&
                          controller.historyTo.value != null
                      ? DateTimeRange(
                          start: controller.historyFrom.value!,
                          end: controller.historyTo.value!,
                        )
                      : null,
                );
                if (range != null) {
                  controller.setGoalsHistoryRange(range.start, range.end);
                }
              },
              icon: const Icon(Icons.date_range),
              label: Obx(() {
                final from = controller.historyFrom.value;
                final to = controller.historyTo.value;
                if (from == null || to == null) {
                  return Text('فلتر السجل بالتاريخ',
                      style: GoogleFonts.cairo());
                }
                return Text(
                  '${from.toIso8601String().split('T').first} — ${to.toIso8601String().split('T').first}',
                  style: GoogleFonts.cairo(fontSize: 12),
                );
              }),
            ),
            if (controller.historyFrom.value != null)
              TextButton(
                onPressed: () => controller.setGoalsHistoryRange(null, null),
                child: Text('إزالة فلتر التاريخ',
                    style: GoogleFonts.cairo(fontSize: 12)),
              ),
          ],
        ));
  }
}

class _CurrentGoalSection extends StatelessWidget {
  final RepGoalProgressDto? goal;
  const _CurrentGoalSection({required this.goal});

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return const EmptyState(
        icon: Icons.track_changes_outlined,
        title: 'لا يوجد هدف',
        subtitle: 'لم يُحدَّد هدف لهذا الشهر بعد.',
      );
    }

    final pct = goal!.progressPercent.clamp(0, 100) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هدف ${goal!.month}/${goal!.year}',
                style: GoogleFonts.cairo(
                    fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                '${goal!.progressPercent.toStringAsFixed(1)}%',
                style: GoogleFonts.cairo(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.24),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GoalStat(
                    label: 'المحقق',
                    value: Formatters.currency(goal!.achievedAmount),
                  ),
                  _GoalStat(
                    label: 'الهدف',
                    value: Formatters.currency(goal!.targetAmount),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (goal!.notes != null && goal!.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              goal!.notes!,
              style: GoogleFonts.cairo(fontSize: 13),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _GoalPieChart(goal: goal!),
      ],
    );
  }
}

class _GoalStat extends StatelessWidget {
  final String label;
  final String value;
  const _GoalStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.white60)),
        Text(value,
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ],
    );
  }
}

class _GoalPieChart extends StatefulWidget {
  final RepGoalProgressDto goal;
  const _GoalPieChart({required this.goal});

  @override
  State<_GoalPieChart> createState() => _GoalPieChartState();
}

class _GoalPieChartState extends State<_GoalPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final g = widget.goal;
    if (g.targetAmount <= 0) return const SizedBox.shrink();

    final achieved = g.achievedAmount.clamp(0, g.targetAmount);
    final remaining = g.remainingAmount;
    final sections = <PieChartSectionData>[];

    if (achieved > 0) {
      sections.add(PieChartSectionData(
        value: achieved,
        color: AppColors.successLight,
        title: '${(achieved / g.targetAmount * 100).toStringAsFixed(0)}%',
        radius: _touchedIndex == 0 ? 58 : 52,
        titleStyle: GoogleFonts.cairo(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    if (remaining > 0) {
      sections.add(PieChartSectionData(
        value: remaining,
        color: AppColors.primaryLight.withValues(alpha: 0.5),
        title: '',
        radius: _touchedIndex == 1 ? 58 : 52,
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('توزيع الإنجاز',
              style: GoogleFonts.cairo(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex =
                          response?.touchedSection?.touchedSectionIndex ?? -1;
                    });
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.successLight, label: 'محقق'),
              const SizedBox(width: 16),
              _LegendDot(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  label: 'متبقي'),
            ],
          ),
        ],
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.cairo(fontSize: 12)),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final RepGoalProgressDto goal;
  const _HistoryTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            '${goal.progressPercent.toStringAsFixed(0)}%',
            style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary),
          ),
        ),
        title: Text(
          '${goal.month}/${goal.year}',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${Formatters.currency(goal.achievedAmount)} / ${Formatters.currency(goal.targetAmount)}',
          style: GoogleFonts.cairo(fontSize: 12),
        ),
        trailing: goal.notes != null && goal.notes!.isNotEmpty
            ? const Icon(Icons.notes, size: 18)
            : null,
      ),
    );
  }
}
