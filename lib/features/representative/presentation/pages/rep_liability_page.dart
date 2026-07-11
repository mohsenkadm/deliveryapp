// شاشة ذمة المندوب المفرد — ملخص + فواتير بانتظار التسليم
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/representative_controllers.dart';

class RepLiabilityPage extends StatefulWidget {
  const RepLiabilityPage({super.key});

  @override
  State<RepLiabilityPage> createState() => _RepLiabilityPageState();
}

class _RepLiabilityPageState extends State<RepLiabilityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RepresentativeHomeController>().loadLiability();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RepresentativeHomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ذمتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ctrl.loadLiability,
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingLiability.value && ctrl.liability.value == null) {
          return const LoadingIndicator();
        }
        final l = ctrl.liability.value;
        if (l == null) {
          return const EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'لا توجد بيانات ذمة',
            subtitle: 'اسحب للتحديث أو حاول لاحقاً',
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadLiability,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(
                collected: l.collectedFromCustomers,
                submitted: l.submittedToCompany,
                verified: l.verifiedSubmitted,
                pending: l.pendingLiability,
                pendingCount: l.pendingSettlementInvoiceCount,
              ),
              const SizedBox(height: 20),
              Text(
                'فواتير بانتظار التسليم (${ctrl.pendingSettlementInvoices.length})',
                style: GoogleFonts.cairo(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (ctrl.pendingSettlementInvoices.isEmpty)
                const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'لا توجد فواتير معلّقة',
                  subtitle: 'جميع المبيعات مُسلّمة للمحاسب',
                )
              else
                ...ctrl.pendingSettlementInvoices.map((inv) {
                  final id = inv['id']?.toString() ?? '';
                  final total =
                      (inv['totalAmount'] as num?)?.toDouble() ?? 0;
                  final statusLabel =
                      InvoiceStatusHelper.displayLabel(inv);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        'فاتورة #$id',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(statusLabel,
                              style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          Text(
                            Formatters.currency(total),
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
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
                              onPressed: () =>
                                  ctrl.submitSettlementForInvoice(inv),
                              child: Text('تسليم',
                                  style: GoogleFonts.cairo(fontSize: 12)),
                            )),
                      onTap: () => Get.toNamed(
                        AppRoutes.repInvoiceDetail,
                        arguments: inv,
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double collected;
  final double submitted;
  final double verified;
  final double pending;
  final int pendingCount;

  const _SummaryCard({
    required this.collected,
    required this.submitted,
    required this.verified,
    required this.pending,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ملخص الذمة',
              style: GoogleFonts.cairo(
                  color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          _row('محصّل من العملاء', collected, Colors.white),
          _row('مُسلّم للمحاسب', submitted, Colors.white70),
          _row('مُحقّق', verified, Colors.white70),
          const Divider(color: Colors.white24, height: 20),
          _row('الذمة المتبقية', pending, Colors.amberAccent, bold: true),
          if (pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$pendingCount فاتورة بانتظار التسليم',
                style: GoogleFonts.cairo(
                    color: Colors.white70, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.cairo(
                  color: color,
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          Text(Formatters.currency(value),
              style: GoogleFonts.cairo(
                  color: color,
                  fontSize: bold ? 18 : 14,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}
