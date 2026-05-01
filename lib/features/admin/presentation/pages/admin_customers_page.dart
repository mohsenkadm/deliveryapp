import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controllers.dart';

class AdminCustomersPage extends GetView<AdminCustomersController> {
  const AdminCustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة العملاء')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadCustomers,
          child: ListView.builder(
            itemCount: controller.customers.length,
            itemBuilder: (_, i) {
              final c = controller.customers[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${c['fullName']?[0] ?? '?'}')),
                title: Text(c['fullName'] ?? ''),
                subtitle: Text(c['phone'] ?? ''),
                trailing: PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'statement', child: Text('كشف حساب')),
                  ],
                  onSelected: (v) {
                    if (v == 'statement') {
                      Get.toNamed('/admin/customer-statement', arguments: c);
                    }
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
