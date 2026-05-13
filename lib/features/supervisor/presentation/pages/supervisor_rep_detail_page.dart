// تفاصيل المندوب — المشرف (فواتير + مدفوعات + عملاء)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/supervisor_controller.dart';

class SupervisorRepDetailPage extends StatefulWidget {
  const SupervisorRepDetailPage({super.key});

  @override
  State<SupervisorRepDetailPage> createState() =>
      _SupervisorRepDetailPageState();
}

class _SupervisorRepDetailPageState extends State<SupervisorRepDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final Map<String, dynamic> _rep;
  late final SupervisorController _ctrl;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _rep = Get.arguments as Map<String, dynamic>;
    _ctrl = Get.find<SupervisorController>();
    final id = _rep['id'].toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadRepInvoices(id);
      _ctrl.loadRepPayments(id);
      _ctrl.loadRepCustomers(id);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _rep['fullName'] ?? 'تفاصيل المندوب';
    final totalCollected =
        ((_rep['totalCollected'] as num?) ?? 0).toDouble();
    final customerCount = (_rep['customerCount'] as num?) ?? 0;
    final invoiceCount = (_rep['totalInvoices'] as num?) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'الفواتير'),
            Tab(text: 'المدفوعات'),
            Tab(text: 'العملاء'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── ملخص المندوب ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight.withValues(alpha: 0.08),
                  AppColors.primaryLight.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                    label: 'العملاء',
                    value: '$customerCount',
                    color: AppColors.primaryLight),
                _Divider(),
                _MiniStat(
                    label: 'الفواتير',
                    value: '$invoiceCount',
                    color: AppColors.warningLight),
                _Divider(),
                _MiniStat(
                    label: 'المحصّل',
                    value: Formatters.currency(totalCollected),
                    color: AppColors.successLight,
                    small: true),
              ],
            ),
          ),

          // ── تبويبات ──
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // تبويب الفواتير
                Obx(() {
                  if (_ctrl.isLoading.value &&
                      _ctrl.selectedRepInvoices.isEmpty) {
                    return const LoadingIndicator();
                  }
                  if (_ctrl.selectedRepInvoices.isEmpty) {
                    return const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'لا توجد فواتير');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _ctrl.selectedRepInvoices.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final inv = _ctrl.selectedRepInvoices[i];
                      final amount =
                          ((inv['totalAmount'] as num?) ?? 0).toDouble();
                      final status = InvoiceStatusHelper.parse(
                          inv['statusText'] ?? inv['status'],
                          fallback: '');
                      final statusColor =
                          InvoiceStatusHelper.color(status);
                      final statusLabel =
                          InvoiceStatusHelper.label(status);

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.receipt_long,
                                  color: statusColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'فاتورة #${inv['id'] ?? ''}',
                                    style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  if ((inv['customerName'] as String?)
                                          ?.isNotEmpty ==
                                      true)
                                    Text(inv['customerName']!,
                                        style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            color:
                                                AppColors.textSecondary)),
                                  if (inv['createdAt'] != null)
                                    Text(
                                      Formatters.date(
                                        DateTime.tryParse(
                                                inv['createdAt']
                                                    .toString()) ??
                                            DateTime.now(),
                                      ),
                                      style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: AppColors.textSecondary),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Formatters.currency(amount),
                                  style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(statusLabel,
                                      style: GoogleFonts.cairo(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),

                // تبويب المدفوعات
                Obx(() {
                  if (_ctrl.isLoading.value &&
                      _ctrl.selectedRepPayments.isEmpty) {
                    return const LoadingIndicator();
                  }
                  if (_ctrl.selectedRepPayments.isEmpty) {
                    return const EmptyState(
                        icon: Icons.payments_outlined,
                        title: 'لا توجد مدفوعات');
                  }
                  final totalPaid = _ctrl.selectedRepPayments.fold<double>(
                      0,
                      (s, p) =>
                          s + ((p['amount'] as num?) ?? 0).toDouble());
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              AppColors.success.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.success
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payments_rounded,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'إجمالي المدفوعات: ${Formatters.currency(totalPaid)}',
                              style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 16),
                          itemCount:
                              _ctrl.selectedRepPayments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final p = _ctrl.selectedRepPayments[i];
                            final amount =
                                ((p['amount'] as num?) ?? 0).toDouble();
                            final date = p['createdAt'] != null
                                ? Formatters.date(
                                    DateTime.tryParse(
                                            p['createdAt'].toString()) ??
                                        DateTime.now())
                                : '—';
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.success
                                        .withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.success
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.payments,
                                        color: AppColors.success,
                                        size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(Formatters.currency(amount),
                                            style: GoogleFonts.cairo(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: AppColors.success)),
                                        Text(date,
                                            style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: AppColors
                                                    .textSecondary)),
                                        if ((p['notes'] as String?)
                                                ?.isNotEmpty ==
                                            true)
                                          Text(p['notes']!,
                                              style: GoogleFonts.cairo(
                                                  fontSize: 11,
                                                  color: AppColors
                                                      .textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),

                // تبويب العملاء
                Obx(() {
                  if (_ctrl.isLoading.value &&
                      _ctrl.selectedRepCustomers.isEmpty) {
                    return const LoadingIndicator();
                  }
                  if (_ctrl.selectedRepCustomers.isEmpty) {
                    return const EmptyState(
                        icon: Icons.people_outline,
                        title: 'لا يوجد عملاء');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _ctrl.selectedRepCustomers.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final c = _ctrl.selectedRepCustomers[i];
                      final name = c['fullName'] ?? '?';
                      final balance =
                          (c['balance'] as num?)?.toDouble() ??
                              (c['totalDebt'] as num?)?.toDouble() ??
                              0.0;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.dividerLight),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryLight
                                  .withValues(alpha: 0.1),
                              child: Text(name[0],
                                  style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryLight)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(c['phone'] ?? '—',
                                      style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            if (balance != 0)
                              Text(
                                Formatters.currency(balance.abs()),
                                style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: balance > 0
                                        ? AppColors.error
                                        : AppColors.success),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool small;

  const _MiniStat(
      {required this.label,
      required this.value,
      required this.color,
      this.small = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
              fontSize: small ? 12 : 16,
              fontWeight: FontWeight.w800,
              color: color),
        ),
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 30, color: AppColors.dividerLight);
  }
}

