import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controllers.dart';

class PendingApprovalsPage extends GetView<AdminCustomersController> {
  const PendingApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الموافقة')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.pendingApprovals.isEmpty) {
          return const Center(child: Text('لا توجد طلبات معلقة'));
        }
        return ListView.builder(
          itemCount: controller.pendingApprovals.length,
          itemBuilder: (_, i) {
            final c = controller.pendingApprovals[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['fullName'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                    Text(c['phone'] ?? ''),
                    Text(c['email'] ?? ''),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.approveCustomer(c['id'].toString()),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('موافقة'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => controller.rejectCustomer(c['id'].toString()),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('رفض'),
                          ),
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
}
