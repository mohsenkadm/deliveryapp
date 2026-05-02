// الصفحة الرئيسية — ملخص مدير المبيعات
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/sales_manager_controller.dart';

class SalesManagerHomePage extends StatelessWidget {
  const SalesManagerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesManagerController>();
    final auth = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ctrl.loadSalesSummary(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ctrl.loadSalesSummary(),
        child: Obx(() {
          if (ctrl.isLoading.value && ctrl.salesSummary.value == null) {
            return const LoadingIndicator();
          }
          final s = ctrl.salesSummary.value ?? {};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── ترحيب ──
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLight,
                      AppColors.primaryLight.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.waving_hand_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('مرحباً، ${auth.userName}',
                              style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text('إليك ملخص اليوم',
                              style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.bar_chart_rounded,
                        color: Colors.white54, size: 32),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),

              // ── شبكة الإحصائيات ──
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(
                    label: 'إجمالي المبيعات',
                    value: Formatters.currency(
                        ((s['totalSales'] as num?) ?? 0).toDouble()),
                    icon: Icons.trending_up_rounded,
                    color: AppColors.primaryLight,
                    index: 0,
                  ),
                  _StatCard(
                    label: 'إجمالي التحصيل',
                    value: Formatters.currency(
                        ((s['totalCollected'] as num?) ?? 0).toDouble()),
                    icon: Icons.payments_rounded,
                    color: AppColors.successLight,
                    index: 1,
                  ),
                  _StatCard(
                    label: 'إجمالي الديون',
                    value: Formatters.currency(
                        ((s['totalDebts'] as num?) ?? 0).toDouble()),
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.errorLight,
                    index: 2,
                  ),
                  _StatCard(
                    label: 'عدد الفواتير',
                    value: '${s['totalInvoices'] ?? 0}',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.warningLight,
                    index: 3,
                  ),
                  _StatCard(
                    label: 'عدد العملاء',
                    value: '${s['totalCustomers'] ?? 0}',
                    icon: Icons.people_rounded,
                    color: AppColors.secondaryLight,
                    index: 4,
                  ),
                  _StatCard(
                    label: 'عدد المندوبين',
                    value: '${s['totalReps'] ?? 0}',
                    icon: Icons.badge_rounded,
                    color: AppColors.primaryLight,
                    index: 5,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── موافقات معلقة ──
              Obx(() {
                final hasPendingCustomers = ctrl.pendingCustomers.isNotEmpty;
                final hasPendingInvoices = ctrl.pendingInvoices.isNotEmpty;
                if (!hasPendingCustomers && !hasPendingInvoices) {
                  return const SizedBox();
                }
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.warningLight.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications_active_rounded,
                              color: AppColors.warningLight, size: 18),
                          const SizedBox(width: 6),
                          Text('موافقات معلقة',
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warningLight)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (hasPendingCustomers)
                        Text(
                          '• ${ctrl.pendingCustomers.length} طلب عميل جديد',
                          style: GoogleFonts.cairo(fontSize: 13),
                        ),
                      if (hasPendingInvoices)
                        Text(
                          '• ${ctrl.pendingInvoices.length} فاتورة بانتظار الموافقة',
                          style: GoogleFonts.cairo(fontSize: 13),
                        ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms);
              }),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int index;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: GoogleFonts.cairo(
                    fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (80 + index * 60).ms).slideY(begin: 0.1, end: 0);
  }
}
