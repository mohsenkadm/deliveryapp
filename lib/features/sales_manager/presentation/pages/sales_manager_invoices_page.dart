// الفواتير المعلقة — مدير المبيعات
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
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
        title: Text('الفواتير المعلقة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
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
            subtitle: 'تمت مراجعة جميع الفواتير',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.pendingInvoices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final inv = ctrl.pendingInvoices[i];
            final id = inv['id']?.toString() ?? '';
            final amount =
                ((inv['totalAmount'] as num?) ?? 0).toDouble();
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
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.warningLight
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.receipt_long_rounded,
                              color: AppColors.warningLight, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('فاتورة #$id',
                                  style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              if ((inv['customerName'] as String?)
                                      ?.isNotEmpty ==
                                  true)
                                Text(inv['customerName']!,
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              if ((inv['repName'] as String?)?.isNotEmpty ==
                                  true)
                                Text(
                                  inv['repName']!,
                                  style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.currency(amount),
                          style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight),
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
                          onPressed: () => _confirmAction(
                              context,
                              'موافقة على الفاتورة',
                              'هل تريد قبول الفاتورة #$id؟',
                              () => ctrl.approveInvoice(id)),
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
                              side:
                                  BorderSide(color: AppColors.errorLight),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10)),
                          onPressed: () =>
                              _rejectWithReason(context, ctrl, id),
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

  Future<void> _confirmAction(BuildContext ctx, String title, String msg,
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
                  style:
                      GoogleFonts.cairo(color: AppColors.textSecondary))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('تأكيد', style: GoogleFonts.cairo())),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('رفض الفاتورة #$id',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اذكر سبب الرفض (اختياري)',
                style: GoogleFonts.cairo(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'سبب الرفض...',
                hintStyle: GoogleFonts.cairo(color: AppColors.textSecondary),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('إلغاء',
                  style:
                      GoogleFonts.cairo(color: AppColors.textSecondary))),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.errorLight),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('رفض', style: GoogleFonts.cairo())),
        ],
      ),
    );
    if (ok == true) {
      ctrl.rejectInvoice(id,
          reason: reasonCtrl.text.trim().isEmpty
              ? null
              : reasonCtrl.text.trim());
    }
  }
}
