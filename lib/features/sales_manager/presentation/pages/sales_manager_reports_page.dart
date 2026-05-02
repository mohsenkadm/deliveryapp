// تقارير الديون والمدفوعات — مدير المبيعات
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/sales_manager_controller.dart';

class SalesManagerReportsPage extends StatefulWidget {
  const SalesManagerReportsPage({super.key});

  @override
  State<SalesManagerReportsPage> createState() =>
      _SalesManagerReportsPageState();
}

class _SalesManagerReportsPageState extends State<SalesManagerReportsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool? _verifiedFilter;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final ctrl = Get.find<SalesManagerController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadDebtsReport();
      ctrl.loadPaymentsReport();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesManagerController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('التقارير',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'الديون'),
            Tab(icon: Icon(Icons.payments_outlined), text: 'المدفوعات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── تبويب الديون ──
          Obx(() {
            if (ctrl.isLoading.value && ctrl.debtsReport.isEmpty) {
              return const LoadingIndicator();
            }
            if (ctrl.debtsReport.isEmpty) {
              return const EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'لا توجد ديون');
            }
            final sorted = [...ctrl.debtsReport]
              ..sort((a, b) =>
                  ((b['totalDebt'] as num?) ?? 0)
                      .compareTo((a['totalDebt'] as num?) ?? 0));
            final total = sorted.fold<double>(
                0,
                (s, d) =>
                    s + ((d['totalDebt'] as num?) ?? 0).toDouble());
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.errorLight.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded,
                          color: AppColors.errorLight, size: 22),
                      const SizedBox(width: 8),
                      Text('إجمالي الديون: ',
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.errorLight)),
                      Text(Formatters.currency(total),
                          style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.errorLight)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final d = sorted[i];
                      final debt =
                          ((d['totalDebt'] as num?) ?? 0).toDouble();
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  AppColors.errorLight.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.errorLight
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('${i + 1}',
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.errorLight)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d['customerName'] ?? '—',
                                      style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                    '${d['invoiceCount'] ?? 0} فاتورة غير مسددة',
                                    style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: AppColors.textSecondary),
                                  ),
                                  if ((d['repName'] as String?)
                                          ?.isNotEmpty ==
                                      true)
                                    Text(d['repName']!,
                                        style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            color: AppColors.primaryLight)),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.currency(debt),
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.errorLight),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (40 + i * 35).ms);
                    },
                  ),
                ),
              ],
            );
          }),

          // ── تبويب المدفوعات ──
          Column(
            children: [
              // فلتر التحقق
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: StatefulBuilder(
                  builder: (ctx, setS) => Row(
                    children: [
                      Text('الفلتر:',
                          style: GoogleFonts.cairo(
                              fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      for (final entry in [
                        (null, 'الكل'),
                        (true, 'مُسوّى'),
                        (false, 'غير مُسوّى'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: FilterChip(
                            label: Text(entry.$2,
                                style: GoogleFonts.cairo(fontSize: 12)),
                            selected: _verifiedFilter == entry.$1,
                            onSelected: (v) {
                              setState(() => _verifiedFilter = entry.$1);
                              ctrl.loadPaymentsReport(
                                  verified: entry.$1);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  if (ctrl.isLoading.value && ctrl.paymentsReport.isEmpty) {
                    return const LoadingIndicator();
                  }
                  if (ctrl.paymentsReport.isEmpty) {
                    return const EmptyState(
                        icon: Icons.payments_outlined,
                        title: 'لا توجد مدفوعات');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.paymentsReport.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final p = ctrl.paymentsReport[i];
                      final amount =
                          ((p['amount'] as num?) ?? 0).toDouble();
                      final isVerified = p['isVerified'] == true;
                      final date = p['createdAt'] != null
                          ? Formatters.date(DateTime.tryParse(
                                  p['createdAt'].toString()) ??
                              DateTime.now())
                          : '—';
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isVerified
                                ? AppColors.successLight.withValues(alpha: 0.2)
                                : AppColors.warningLight.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (isVerified
                                        ? AppColors.successLight
                                        : AppColors.warningLight)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isVerified
                                    ? Icons.verified_rounded
                                    : Icons.pending_rounded,
                                color: isVerified
                                    ? AppColors.successLight
                                    : AppColors.warningLight,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Formatters.currency(amount),
                                      style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isVerified
                                              ? AppColors.successLight
                                              : AppColors.warningLight)),
                                  if ((p['repName'] as String?)
                                          ?.isNotEmpty ==
                                      true)
                                    Text(p['repName']!,
                                        style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: AppColors.primaryLight)),
                                  if ((p['customerName'] as String?)
                                          ?.isNotEmpty ==
                                      true)
                                    Text(p['customerName']!,
                                        style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            color: AppColors.textSecondary)),
                                  Text(date,
                                      style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isVerified
                                        ? AppColors.successLight
                                        : AppColors.warningLight)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isVerified ? 'مُسوّى' : 'معلق',
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isVerified
                                        ? AppColors.successLight
                                        : AppColors.warningLight),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (40 + i * 35).ms);
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
