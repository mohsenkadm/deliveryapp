// صفحة التقارير — مدير المبيعات (ملخص + ديون + مدفوعات)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  DateTime? _from, _to;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    final ctrl = Get.find<SalesManagerController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadSalesSummary();
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
        title: const Text('التقارير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _pickRange(context, ctrl),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'ملخص المبيعات'),
            Tab(text: 'الديون'),
            Tab(text: 'المدفوعات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ملخص المبيعات
          Obx(() {
            if (ctrl.isLoading.value && ctrl.salesSummary.value == null) {
              return const LoadingIndicator();
            }
            final s = ctrl.salesSummary.value;
            if (s == null) {
              return const EmptyState(
                  icon: Icons.bar_chart_outlined, title: 'لا توجد بيانات');
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryItem('إجمالي الفواتير',
                    '${s['totalInvoices'] ?? 0}'),
                _SummaryItem('إجمالي المبيعات',
                    Formatters.formatCurrency(
                        ((s['totalSales'] as num?) ?? 0).toDouble())),
                _SummaryItem('إجمالي التحصيل',
                    Formatters.formatCurrency(
                        ((s['totalCollected'] as num?) ?? 0).toDouble())),
                _SummaryItem('إجمالي الديون',
                    Formatters.formatCurrency(
                        ((s['totalDebts'] as num?) ?? 0).toDouble()),
                    valueColor: AppColors.error),
                _SummaryItem('عدد العملاء', '${s['totalCustomers'] ?? 0}'),
                _SummaryItem('عدد المندوبين', '${s['totalReps'] ?? 0}'),
              ],
            );
          }),

          // الديون
          Obx(() {
            if (ctrl.isLoading.value && ctrl.debtsReport.isEmpty) {
              return const LoadingIndicator();
            }
            if (ctrl.debtsReport.isEmpty) {
              return const EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'لا توجد ديون');
            }
            final total = ctrl.debtsReport.fold<double>(
                0,
                (s, d) =>
                    s + ((d['totalDebt'] as num?) ?? 0).toDouble());
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.error.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي الديون',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(Formatters.formatCurrency(total),
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.debtsReport.length,
                    itemBuilder: (ctx, i) {
                      final d = ctrl.debtsReport[i];
                      return Card(
                        child: ListTile(
                          title: Text(d['customerName'] ?? ''),
                          subtitle:
                              Text('${d['invoiceCount'] ?? 0} فاتورة غير مسددة'),
                          trailing: Text(
                            Formatters.formatCurrency(
                                ((d['totalDebt'] as num?) ?? 0).toDouble()),
                            style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),

          // المدفوعات
          Obx(() {
            if (ctrl.isLoading.value && ctrl.paymentsReport.isEmpty) {
              return const LoadingIndicator();
            }
            if (ctrl.paymentsReport.isEmpty) {
              return const EmptyState(
                  icon: Icons.payments_outlined, title: 'لا توجد مدفوعات');
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.paymentsReport.length,
              itemBuilder: (ctx, i) {
                final p = ctrl.paymentsReport[i];
                final amount = ((p['amount'] as num?) ?? 0).toDouble();
                final isVerified = p['isVerified'] == true;
                return Card(
                  child: ListTile(
                    leading: Icon(
                      isVerified
                          ? Icons.verified_outlined
                          : Icons.pending_outlined,
                      color: isVerified ? AppColors.success : Colors.orange,
                    ),
                    title: Text(Formatters.formatCurrency(amount)),
                    subtitle:
                        Text('${p['repName'] ?? ''} • ${p['createdAt']?.toString().substring(0, 10) ?? ''}'),
                    trailing: isVerified
                        ? const Chip(label: Text('مُسوّى'))
                        : null,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Future<void> _pickRange(
      BuildContext ctx, SalesManagerController ctrl) async {
    final range = await showDateRangePicker(
      context: ctx,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      setState(() {
        _from = range.start;
        _to = range.end;
      });
      ctrl.loadSalesSummary(
        from: Formatters.toApiDate(_from!),
        to: Formatters.toApiDate(_to!),
      );
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryItem(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.primary),
        ),
      ),
    );
  }
}
