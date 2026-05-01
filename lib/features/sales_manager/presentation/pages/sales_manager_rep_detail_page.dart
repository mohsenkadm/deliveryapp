// تفاصيل مندوب — مدير المبيعات
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/sales_manager_controller.dart';

class SalesManagerRepDetailPage extends StatefulWidget {
  const SalesManagerRepDetailPage({super.key});

  @override
  State<SalesManagerRepDetailPage> createState() =>
      _SalesManagerRepDetailPageState();
}

class _SalesManagerRepDetailPageState
    extends State<SalesManagerRepDetailPage> {
  late final Map<String, dynamic> _rep;
  late final SalesManagerController _ctrl;

  @override
  void initState() {
    super.initState();
    _rep = Get.arguments as Map<String, dynamic>;
    _ctrl = Get.find<SalesManagerController>();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _ctrl.loadRepInvoices(_rep['id'].toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_rep['fullName'] ?? 'تفاصيل المندوب')),
      body: Obx(() {
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
            final amount = ((inv['totalAmount'] as num?) ?? 0).toDouble();
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
                    Text(InvoiceStatusHelper.label(status),
                        style: TextStyle(
                            color: InvoiceStatusHelper.color(status),
                            fontSize: 11)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
