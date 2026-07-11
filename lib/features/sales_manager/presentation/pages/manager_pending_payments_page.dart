import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/sales_manager_controller.dart';

/// دفعات المندوبين بانتظار التحقق — للمحاسب/مدير المبيعات.
class ManagerPendingPaymentsPage extends StatefulWidget {
  const ManagerPendingPaymentsPage({super.key});

  @override
  State<ManagerPendingPaymentsPage> createState() =>
      _ManagerPendingPaymentsPageState();
}

class _ManagerPendingPaymentsPageState
    extends State<ManagerPendingPaymentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<SalesManagerController>().loadPendingPaymentsVerify();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesManagerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('دفعات بانتظار التحقق'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ctrl.loadPendingPaymentsVerify,
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.pendingPaymentsVerify.isEmpty) {
          return const LoadingIndicator();
        }
        if (ctrl.pendingPaymentsVerify.isEmpty) {
          return const EmptyState(
            icon: Icons.verified_user_outlined,
            title: 'لا توجد دفعات معلّقة',
            subtitle: 'جميع التسليمات مُحقّقة',
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.loadPendingPaymentsVerify,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.pendingPaymentsVerify.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final p = ctrl.pendingPaymentsVerify[i];
              final id = p['id']?.toString() ?? '';
              final amount = (p['amount'] as num?)?.toDouble() ?? 0;
              final repName = p['representativeName'] ??
                  p['employeeName'] ??
                  p['repName'] ??
                  '';
              return Card(
                child: ListTile(
                  title: Text(Formatters.currency(amount),
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (repName.toString().isNotEmpty)
                        Text('المندوب: $repName',
                            style: GoogleFonts.cairo(fontSize: 12)),
                      if (p['invoiceId'] != null)
                        Text('فاتورة #${p['invoiceId']}',
                            style: GoogleFonts.cairo(fontSize: 12)),
                      Text(
                        p['createdAt']?.toString().substring(0, 10) ?? '',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  trailing: Obx(() => ctrl.isActing.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FilledButton(
                          onPressed: id.isEmpty
                              ? null
                              : () => ctrl.verifyPayment(id),
                          child: Text('تحقق',
                              style: GoogleFonts.cairo(fontSize: 12)),
                        )),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
