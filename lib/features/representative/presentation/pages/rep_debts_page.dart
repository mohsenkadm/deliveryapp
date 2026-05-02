// صفحة ديون العملاء — المندوب
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/representative_controllers.dart';

class RepDebtsPage extends StatefulWidget {
  const RepDebtsPage({super.key});

  @override
  State<RepDebtsPage> createState() => _RepDebtsPageState();
}

class _RepDebtsPageState extends State<RepDebtsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.find<RepresentativeHomeController>().loadDebts());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RepresentativeHomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ديون العملاء'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: ctrl.loadDebts),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingDebts.value) return const LoadingIndicator();
        if (ctrl.debts.isEmpty) {
          return const EmptyState(
            icon: Icons.money_off_csred_outlined,
            title: 'لا توجد ديون',
            subtitle: 'جميع عملاؤك سدّدوا مستحقاتهم',
          );
        }

        final totalDebt = ctrl.debts.fold<double>(
            0, (s, d) => s + ((d['totalDebt'] as num?) ?? 0).toDouble());

        return Column(
          children: [
            // ملخص إجمالي
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إجمالي الديون:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(Formatters.formatCurrency(totalDebt),
                      style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ctrl.debts.length,
                itemBuilder: (ctx, i) {
                  final d = ctrl.debts[i];
                  final debt =
                      ((d['totalDebt'] as num?) ?? 0).toDouble();
                  final count = d['invoiceCount'] ?? 0;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.error.withValues(alpha: 0.15),
                        child: Icon(Icons.person_outline,
                            color: AppColors.error),
                      ),
                      title: Text(d['fullName'] ?? '',
                          style: AppTextStyles.titleSmall),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (d['storeName'] != null)
                            Text(d['storeName'],
                                style: AppTextStyles.bodySmall),
                          Text('${d['phone'] ?? ''} • $count فاتورة',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                      trailing: Text(
                        Formatters.formatCurrency(debt),
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
    );
  }
}
