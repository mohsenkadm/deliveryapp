// العملاء المعلقة موافقتهم — المشرف
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/supervisor_controller.dart';

class SupervisorPendingCustomersPage extends StatelessWidget {
  const SupervisorPendingCustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupervisorController>();

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
        if (ctrl.isActing.value && ctrl.pendingCustomers.isEmpty) {
          return const LoadingIndicator();
        }
        if (ctrl.pendingCustomers.isEmpty) {
          return const EmptyState(
            icon: Icons.check_circle_outline,
            title: 'لا يوجد طلبات معلقة',
            subtitle: 'جميع طلبات التسجيل تمت معالجتها',
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
                      child: Text(
                        (c['fullName'] ?? '?')[0],
                        style: const TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['fullName'] ?? '', style: AppTextStyles.titleSmall),
                          Text(c['storeName'] ?? '', style: AppTextStyles.bodySmall),
                          Text(c['phone'] ?? '', style: AppTextStyles.bodySmall),
                          if (c['region'] != null)
                            Text('المنطقة: ${c['region']}',
                                style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          color: AppColors.success,
                          tooltip: 'موافقة',
                          onPressed: () => _confirmAction(
                              context, 'تأكيد الموافقة',
                              'هل تريد الموافقة على تسجيل هذا العميل؟',
                              () => ctrl.approveCustomer(id)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          color: AppColors.error,
                          tooltip: 'رفض',
                          onPressed: () => _confirmAction(
                              context, 'تأكيد الرفض',
                              'هل تريد رفض تسجيل هذا العميل؟',
                              () => ctrl.rejectCustomer(id)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Future<void> _confirmAction(BuildContext ctx, String title, String message,
      VoidCallback onConfirm) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    if (result == true) onConfirm();
  }
}
