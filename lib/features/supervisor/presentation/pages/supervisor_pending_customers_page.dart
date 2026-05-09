// العملاء المعلقة موافقتهم — المشرف
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/client_type_badge.dart';
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
        title: Obx(() => Text(
              'طلبات التسجيل${ctrl.pendingCustomers.isEmpty ? '' : ' (${ctrl.pendingCustomers.length})'}',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ctrl.loadPendingCustomers,
          ),
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

        return RefreshIndicator(
          onRefresh: ctrl.loadPendingCustomers,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.pendingCustomers.length,
            itemBuilder: (ctx, i) {
              final c = ctrl.pendingCustomers[i];
              final id = c['id']?.toString() ?? '';
              final name = c['fullName'] ?? '?';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.warningLight.withValues(alpha: 0.3)),
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
                                AppColors.warningLight.withValues(alpha: 0.15),
                            child: Text(
                              name[0],
                              style: GoogleFonts.cairo(
                                  color: AppColors.warningLight,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                if ((c['storeName'] as String?)
                                        ?.isNotEmpty ==
                                    true)
                                  Text(c['storeName']!,
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
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'انتظار',
                              style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: AppColors.warningLight,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // تفاصيل
                      _DetailRow(
                          icon: Icons.phone_outlined,
                          text: c['phone'] ?? '—'),
                      if ((c['address'] as String?)?.isNotEmpty == true)
                        _DetailRow(
                            icon: Icons.location_on_outlined,
                            text: c['address']!),
                      if ((c['region'] as String?)?.isNotEmpty == true)
                        _DetailRow(
                            icon: Icons.map_outlined,
                            text: 'المنطقة: ${c['region']}'),
                      if ((c['clientType'] as String?)?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: ClientTypeBadge(
                              type: c['clientType'] as String?),
                        ),
                      const SizedBox(height: 12),
                      // أزرار الموافقة / الرفض
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => OutlinedButton.icon(
                                  onPressed: ctrl.isActing.value
                                      ? null
                                      : () => _confirmAction(
                                          context,
                                          'تأكيد الرفض',
                                          'هل تريد رفض تسجيل $name؟',
                                          () => ctrl.rejectCustomer(id)),
                                  icon: const Icon(Icons.cancel_outlined,
                                      size: 18),
                                  label: Text('رفض',
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w600)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: BorderSide(
                                        color: AppColors.error
                                            .withValues(alpha: 0.5)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(() => FilledButton.icon(
                                  onPressed: ctrl.isActing.value
                                      ? null
                                      : () => _confirmAction(
                                          context,
                                          'تأكيد الموافقة',
                                          'هل تريد الموافقة على تسجيل $name؟',
                                          () =>
                                              ctrl.approveCustomer(id)),
                                  icon: const Icon(
                                      Icons.check_circle_outline,
                                      size: 18),
                                  label: Text('موافقة',
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w600)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (50 + i * 40).ms)
                  .slideY(begin: 0.05, end: 0);
            },
          ),
        );
      }),
    );
  }

  Future<void> _confirmAction(BuildContext ctx, String title,
      String message, VoidCallback onConfirm) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title:
            Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text(message, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('إلغاء', style: GoogleFonts.cairo())),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('تأكيد', style: GoogleFonts.cairo())),
        ],
      ),
    );
    if (result == true) onConfirm();
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: GoogleFonts.cairo(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

