import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controllers.dart';

class AdminDebtsPage extends GetView<AdminDebtsController> {
  const AdminDebtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الديون والتسويات')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.debts.isEmpty) {
          return const Center(child: Text('لا توجد ديون'));
        }
        return RefreshIndicator(
          onRefresh: controller.loadDebts,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.debts.length,
            itemBuilder: (_, i) {
              final d = controller.debts[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.money_off, color: Colors.red),
                  title: Text(d['customerName'] ?? ''),
                  subtitle: Text('${d['amount'] ?? 0} د.ع'),
                  trailing: TextButton(
                    onPressed: () => _showSettleDialog(context, d),
                    child: const Text('تسوية'),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showSettleDialog(BuildContext context, Map<String, dynamic> debt) {
    final amountCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('تسوية دين'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('العميل: ${debt['customerName']}'),
          Text('المبلغ المستحق: ${debt['amount']} د.ع'),
          const SizedBox(height: 12),
          TextField(
            controller: amountCtrl,
            decoration: const InputDecoration(labelText: 'مبلغ التسوية'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountCtrl.text);
            if (amount != null && amount > 0) {
              controller.settleDebt(debt['id'].toString(), amount);
              Get.back();
            }
          },
          child: const Text('تسوية'),
        ),
      ],
    ));
  }
}
