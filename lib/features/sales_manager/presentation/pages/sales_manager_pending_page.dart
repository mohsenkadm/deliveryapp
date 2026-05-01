// موافقات العملاء — مدير المبيعات (يشبه صفحة المشرف)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/sales_manager_controller.dart';

class SalesManagerPendingPage extends StatelessWidget {
  const SalesManagerPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesManagerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('موافقات العملاء'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: ctrl.loadPendingCustomers),
        ],
      ),
      body: Obx(() {
        if (ctrl.pendingCustomers.isEmpty) {
          return const EmptyState(
            icon: Icons.check_circle_outline,
            title: 'لا يوجد طلبات معلقة',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.pendingCustomers.length,
          itemBuilder: (ctx, i) {
            final c = ctrl.pendingCustomers[i];
            final id = c['id']?.toString() ?? '';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.15),
                      child: Text((c['fullName'] ?? '?')[0],
                          style: const TextStyle(color: Colors.orange,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['fullName'] ?? '',
                              style: AppTextStyles.titleSmall),
                          Text(c['storeName'] ?? '',
                              style: AppTextStyles.bodySmall),
                          Text(c['phone'] ?? '',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Column(children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        color: AppColors.success,
                        onPressed: () =>
                            _confirm(context, 'موافقة', () => ctrl.approveCustomer(id)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined),
                        color: AppColors.error,
                        onPressed: () =>
                            _confirm(context, 'رفض', () => ctrl.rejectCustomer(id)),
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

  Future<void> _confirm(
      BuildContext ctx, String action, VoidCallback cb) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('تأكيد $action'),
        content: Text('هل تريد $action هذا العميل؟'),
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
}
