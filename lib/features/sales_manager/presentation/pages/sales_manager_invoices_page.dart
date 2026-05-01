// الفواتير المعلقة الموافقة — مدير المبيعات
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/sales_manager_controller.dart';

class SalesManagerInvoicesPage extends StatelessWidget {
  const SalesManagerInvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesManagerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفواتير المعلقة'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: ctrl.loadPendingInvoices),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.pendingInvoices.isEmpty) {
          return const LoadingIndicator();
        }
        if (ctrl.pendingInvoices.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'لا توجد فواتير معلقة',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.pendingInvoices.length,
          itemBuilder: (ctx, i) {
            final inv = ctrl.pendingInvoices[i];
            final id = inv['id']?.toString() ?? '';
            final amount = ((inv['totalAmount'] as num?) ?? 0).toDouble();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('فاتورة #$id',
                                  style: AppTextStyles.titleSmall),
                              Text(inv['customerName'] ?? '',
                                  style: AppTextStyles.bodySmall),
                              Text(inv['repName'] ?? '',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        Text(Formatters.formatCurrency(amount),
                            style: AppTextStyles.titleSmall
                                .copyWith(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('موافقة'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success),
                          onPressed: () => _confirmInvoice(context, 'موافقة',
                              () => ctrl.approveInvoice(id)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text('رفض'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error),
                          onPressed: () =>
                              _rejectWithReason(context, ctrl, id),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Future<void> _confirmInvoice(
      BuildContext ctx, String action, VoidCallback cb) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('تأكيد $action'),
        content: Text('هل تريد $action هذه الفاتورة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تأكيد')),
        ],
      ),
    );
    if (ok == true) cb();
  }

  Future<void> _rejectWithReason(
      BuildContext ctx, SalesManagerController ctrl, String id) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('رفض الفاتورة'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
              hintText: 'سبب الرفض (اختياري)',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('رفض')),
        ],
      ),
    );
    if (ok == true) {
      ctrl.rejectInvoice(id,
          reason: reasonCtrl.text.isEmpty ? null : reasonCtrl.text);
    }
  }
}
