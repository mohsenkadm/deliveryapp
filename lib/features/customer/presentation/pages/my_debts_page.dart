import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/customer_controllers.dart';

class MyDebtsPage extends GetView<DebtsController> {
  const MyDebtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مديونياتي'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.loadDebts),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();

        final summary = controller.summary.value;

        if (summary == null || (summary.totalDebt == 0 && summary.invoices.isEmpty)) {
          return const EmptyState(
            title: 'لا توجد مديونيات',
            subtitle: 'ليس لديك أي مستحقات مالية حالياً',
            icon: Icons.account_balance_wallet_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadDebts,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── بطاقة الملخص ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Text('إجمالي المديونيات',
                        style: GoogleFonts.cairo(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(Formatters.currency(summary.totalDebt),
                        style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _SummaryPill(label: 'إجمالي الفواتير', value: '${summary.totalInvoices}', icon: Icons.receipt_long),
                        const SizedBox(width: 10),
                        _SummaryPill(label: 'غير مسددة', value: '${summary.unpaidInvoices}', icon: Icons.error_outline, highlight: true),
                        const SizedBox(width: 10),
                        _SummaryPill(label: 'المدفوع', value: Formatters.currency(summary.totalPaid), icon: Icons.check_circle_outline),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (summary.invoices.isNotEmpty) ...[
                Text('تفصيل الفواتير',
                    style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...summary.invoices.map((debt) {
                  final pctPaid = debt.amount > 0 ? (debt.paidAmount / debt.amount).clamp(0.0, 1.0) : 0.0;
                  final isOverdue = debt.dueDate.isBefore(DateTime.now()) && debt.remainingAmount > 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOverdue
                            ? AppColors.error.withValues(alpha: 0.4)
                            : AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Icon(
                                isOverdue ? Icons.warning_amber_rounded : Icons.receipt_outlined,
                                size: 16,
                                color: isOverdue ? AppColors.error : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text('فاتورة #${debt.invoiceNumber}',
                                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
                            ]),
                            Text(
                              Formatters.currency(debt.remainingAmount),
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: debt.remainingAmount > 0 ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pctPaid,
                            backgroundColor: Colors.grey.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation(
                              pctPaid >= 1 ? AppColors.success : AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('المدفوع: ${Formatters.currency(debt.paidAmount)}',
                                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                            Text(
                              'الاستحقاق: ${Formatters.date(debt.dueDate)}',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: isOverdue ? AppColors.error : Colors.grey,
                                fontWeight: isOverdue ? FontWeight.w700 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        if (isOverdue) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('متأخر السداد',
                                style: GoogleFonts.cairo(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _SummaryPill({required this.label, required this.value, required this.icon, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: highlight ? Colors.red.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                textAlign: TextAlign.center),
            Text(label,
                style: GoogleFonts.cairo(fontSize: 9, color: Colors.white70),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

