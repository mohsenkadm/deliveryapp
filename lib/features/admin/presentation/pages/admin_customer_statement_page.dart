import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminCustomerStatementPage extends StatefulWidget {
  const AdminCustomerStatementPage({super.key});

  @override
  State<AdminCustomerStatementPage> createState() => _AdminCustomerStatementPageState();
}

class _AdminCustomerStatementPageState extends State<AdminCustomerStatementPage> with SingleTickerProviderStateMixin {
  late final AdminRemoteDataSource _ds;
  late final TabController _tabController;
  final _isLoading = true.obs;

  final _invoices = <Map<String, dynamic>>[].obs;
  final _payments = <Map<String, dynamic>>[].obs;
  final _debts = <Map<String, dynamic>>[].obs;
  final _summary = <String, dynamic>{}.obs;

  late final Map<String, dynamic> _customer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    final args = Get.arguments;
    _customer = (args is Map<String, dynamic>) ? args : {};
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final customerId = _customer['id']?.toString() ?? '';
    if (customerId.isEmpty) return;
    _isLoading.value = true;
    try {
      final result = await _ds.getCustomerStatement(customerId);
      _invoices.value = (result['invoices'] as List? ?? []).cast<Map<String, dynamic>>();
      _payments.value = (result['payments'] as List? ?? []).cast<Map<String, dynamic>>();
      _debts.value = (result['debts'] as List? ?? []).cast<Map<String, dynamic>>();
      _summary.value = result['summary'] as Map<String, dynamic>? ?? {};
    } catch (_) {}
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final name = _customer['fullName'] ?? _customer['name'] ?? 'عميل';
    // ignore: unused_local_variable
    final phone = _customer['phone'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('كشف حساب', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16)),
            if (name.isNotEmpty) Text(name, style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: Text('الفواتير', style: GoogleFonts.cairo(fontWeight: FontWeight.w600))),
            Tab(child: Text('المدفوعات', style: GoogleFonts.cairo(fontWeight: FontWeight.w600))),
            Tab(child: Text('الديون', style: GoogleFonts.cairo(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) return const LoadingIndicator();
        return Column(
          children: [
            _buildSummaryBanner(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _InvoicesTab(invoices: _invoices),
                  _PaymentsTab(payments: _payments),
                  _DebtsTab(debts: _debts),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryBanner() {
    final totalInvoices = _summary['totalInvoices'] ?? _invoices.length;
    final totalPaid = (_summary['totalPaid'] ?? 0).toDouble();
    final totalDebt = (_summary['totalDebt'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryStat(icon: Icons.receipt_long_rounded, label: 'الفواتير', value: '$totalInvoices'),
          _VertDivider(),
          _SummaryStat(icon: Icons.check_circle_rounded, label: 'المدفوع', value: Formatters.currency(totalPaid)),
          _VertDivider(),
          _SummaryStat(icon: Icons.money_off_rounded, label: 'الدين', value: Formatters.currency(totalDebt), valueColor: totalDebt > 0 ? const Color(0xFFFFCDD2) : Colors.white),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 40, width: 1, color: Colors.white.withValues(alpha: 0.3));
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryStat({required this.icon, required this.label, required this.value, this.valueColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: Colors.white70, size: 18),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: valueColor, fontSize: 14)),
      Text(label, style: GoogleFonts.cairo(fontSize: 10, color: Colors.white70)),
    ]);
  }
}

class _InvoicesTab extends StatelessWidget {
  final List<Map<String, dynamic>> invoices;
  const _InvoicesTab({required this.invoices});

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const EmptyState(title: 'لا توجد فواتير', icon: Icons.receipt_long_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final inv = invoices[i];
        final status = inv['status'] ?? 'Pending';
        final total = (inv['totalAmount'] ?? 0).toDouble();
        final date = inv['createdAt'] != null ? DateTime.tryParse(inv['createdAt'].toString()) : null;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: InvoiceStatusHelper.color(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_long_rounded, color: InvoiceStatusHelper.color(status), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('فاتورة #${inv['invoiceNumber'] ?? inv['id']}',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13)),
                  if (date != null) Text(Formatters.date(date), style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(Formatters.currency(total),
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: InvoiceStatusHelper.color(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(InvoiceStatusHelper.label(status),
                      style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600,
                          color: InvoiceStatusHelper.color(status))),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  const _PaymentsTab({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const EmptyState(title: 'لا توجد مدفوعات', icon: Icons.payment_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final pay = payments[i];
        final amount = (pay['amount'] ?? 0).toDouble();
        final date = pay['createdAt'] != null ? DateTime.tryParse(pay['createdAt'].toString()) : null;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.successLight.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.payments_rounded, color: AppColors.successLight, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pay['notes'] ?? 'دفعة', style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13)),
                  if (date != null) Text(Formatters.date(date), style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ),
              Text(Formatters.currency(amount),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: AppColors.successLight, fontSize: 15)),
            ],
          ),
        );
      },
    );
  }
}

class _DebtsTab extends StatelessWidget {
  final List<Map<String, dynamic>> debts;
  const _DebtsTab({required this.debts});

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) {
      return const EmptyState(title: 'لا توجد ديون', icon: Icons.money_off_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: debts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final debt = debts[i];
        final amount = (debt['amount'] ?? 0).toDouble();
        final paid = (debt['paidAmount'] ?? 0).toDouble();
        final remaining = amount - paid;
        final date = debt['createdAt'] != null ? DateTime.tryParse(debt['createdAt'].toString()) : null;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.errorLight.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('دين #${debt['id']}', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13)),
                  if (date != null) Text(Formatters.date(date), style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DebtStat('المبلغ', Formatters.currency(amount), AppColors.textSecondary),
                  _DebtStat('المدفوع', Formatters.currency(paid), AppColors.successLight),
                  _DebtStat('المتبقي', Formatters.currency(remaining), remaining > 0 ? AppColors.errorLight : AppColors.successLight),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DebtStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DebtStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textSecondary)),
    Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
  ]);
}
