// تفاصيل المندوب — المشرف (فواتير + مدفوعات + عملاء)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_rep['fullName'] ?? 'تفاصيل المندوب'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'الفواتير'),
            Tab(text: 'المدفوعات'),
            Tab(text: 'العملاء'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // تبويب الفواتير
          Obx(() {
            if (_ctrl.isLoading.value && _ctrl.selectedRepInvoices.isEmpty) {
              return const LoadingIndicator();
            }
            if (_ctrl.selectedRepInvoices.isEmpty) {
              return const EmptyState(
                  icon: Icons.receipt_long_outlined, title: 'لا توجد فواتير');
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ctrl.selectedRepInvoices.length,
              itemBuilder: (ctx, i) {
                final inv = _ctrl.selectedRepInvoices[i];
                final amount =
                    ((inv['totalAmount'] as num?) ?? 0).toDouble();
                final status = inv['status'] ?? '';
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.receipt_long,
                        color: InvoiceStatusHelper.color(status)),
                    title: Text('فاتورة #${inv['id'] ?? ''}',
                        style: AppTextStyles.titleSmall),
                    subtitle: Text(inv['customerName'] ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.formatCurrency(amount),
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.primary)),
                        Chip(
                          label: Text(InvoiceStatusHelper.label(status),
                              style: const TextStyle(fontSize: 11)),
                          backgroundColor:
                              InvoiceStatusHelper.color(status).withOpacity(0.1),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // تبويب المدفوعات
          Obx(() {
            if (_ctrl.selectedRepPayments.isEmpty) {
              return const EmptyState(
                  icon: Icons.payments_outlined, title: 'لا توجد مدفوعات');
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ctrl.selectedRepPayments.length,
              itemBuilder: (ctx, i) {
                final p = _ctrl.selectedRepPayments[i];
                final amount = ((p['amount'] as num?) ?? 0).toDouble();
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.payments,
                        color: AppColors.success),
                    title: Text(Formatters.formatCurrency(amount)),
                    subtitle: Text(
                        p['createdAt']?.toString().substring(0, 10) ?? ''),
                  ),
                );
              },
            );
          }),

          // تبويب العملاء
          Obx(() {
            if (_ctrl.selectedRepCustomers.isEmpty) {
              return const EmptyState(
                  icon: Icons.people_outline, title: 'لا يوجد عملاء');
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ctrl.selectedRepCustomers.length,
              itemBuilder: (ctx, i) {
                final c = _ctrl.selectedRepCustomers[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Text((c['fullName'] ?? '?')[0])),
                    title: Text(c['fullName'] ?? ''),
                    subtitle: Text(c['phone'] ?? ''),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
