// موافقات العملاء — مدير المبيعات
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/sales_manager_controller.dart';

class SalesManagerPendingPage extends StatelessWidget {
  const SalesManagerPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesManagerController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('موافقات العملاء',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
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
            subtitle: 'جميع الطلبات تمت معالجتها',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.pendingCustomers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final c = ctrl.pendingCustomers[i];
            final id = c['id']?.toString() ?? '';
            final name = c['fullName'] ?? '?';
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.warningLight.withValues(alpha: 0.25)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              AppColors.warningLight.withValues(alpha: 0.12),
                          child: Text(name[0],
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warningLight,
                                  fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              if ((c['storeName'] as String?)
                                      ?.isNotEmpty ==
                                  true)
                                Text(c['storeName']!,
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              if ((c['phone'] as String?)?.isNotEmpty ==
                                  true)
                                Text(c['phone']!,
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('معلق',
                              style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warningLight)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: Text('موافقة',
                              style: GoogleFonts.cairo(fontSize: 13)),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.successLight,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10)),
                          onPressed: () => _confirm(
                              context,
                              'تأكيد الموافقة',
                              'هل تريد قبول طلب $name؟',
                              () => ctrl.approveCustomer(id)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: Text('رفض',
                              style: GoogleFonts.cairo(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.errorLight,
                              side: BorderSide(
                                  color: AppColors.errorLight),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10)),
                          onPressed: () => _confirm(
                              context,
                              'تأكيد الرفض',
                              'هل تريد رفض طلب $name؟',
                              () => ctrl.rejectCustomer(id)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (50 + i * 40).ms).slideY(begin: 0.05, end: 0);
          },
        );
      }),
    );
  }

  Future<void> _confirm(BuildContext ctx, String title, String msg,
      VoidCallback cb) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        content: Text(msg,
            style: GoogleFonts.cairo(), textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('إلغاء',
                  style: GoogleFonts.cairo(color: AppColors.textSecondary))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('تأكيد', style: GoogleFonts.cairo())),
        ],
      ),
    );
    if (ok == true) cb();
  }
}
