// قائمة المندوبين — المشرف (الصفحة الرئيسية)
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/supervisor_controller.dart';

class SupervisorRepsPage extends StatelessWidget {
  const SupervisorRepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupervisorController>();
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
              child: Text('👁', style: GoogleFonts.cairo(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً 👋',
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: AppColors.textSecondary)),
                  Text(authService.userName,
                      style: GoogleFonts.cairo(
                          fontSize: 15, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: ctrl.loadReps),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.reps.isEmpty) {
          return const LoadingIndicator();
        }

        // ── إحصائيات سريعة ──
        final totalReps = ctrl.reps.length;
        final totalInvoices = ctrl.reps.fold<int>(
            0, (s, r) => s + ((r['totalInvoices'] as num?) ?? 0).toInt());
        final totalCollected = ctrl.reps.fold<double>(
            0,
            (s, r) =>
                s + ((r['totalCollected'] as num?) ?? 0).toDouble());
        final totalCustomers = ctrl.reps.fold<int>(
            0,
            (s, r) =>
                s + ((r['customerCount'] as num?) ?? 0).toInt());

        return RefreshIndicator(
          onRefresh: ctrl.loadReps,
          child: CustomScrollView(
            slivers: [
              // ── لوحة الإحصائيات ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('لمحة عامة',
                              style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700))
                          .animate()
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.people_rounded,
                            label: 'المندوبون',
                            value: '$totalReps',
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            icon: Icons.people_outline,
                            label: 'العملاء',
                            value: '$totalCustomers',
                            color: AppColors.secondaryLight,
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.receipt_long_rounded,
                            label: 'الفواتير',
                            value: '$totalInvoices',
                            color: AppColors.warningLight,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            icon: Icons.payments_rounded,
                            label: 'إجمالي المحصّل',
                            value: Formatters.currency(totalCollected),
                            color: AppColors.successLight,
                            small: true,
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 20),
                      Text('المندوبون (${ctrl.reps.length})',
                          style: GoogleFonts.cairo(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // ── قائمة المندوبين ──
              if (ctrl.reps.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.people_outline,
                    title: 'لا يوجد مندوبون',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _RepCard(rep: ctrl.reps[i], ctrl: ctrl)
                          .animate()
                          .fadeIn(delay: (50 + i * 40).ms)
                          .slideY(begin: 0.05, end: 0),
                      childCount: ctrl.reps.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// بطاقة المندوب
// ─────────────────────────────────────────────
class _RepCard extends StatelessWidget {
  final Map<String, dynamic> rep;
  final SupervisorController ctrl;

  const _RepCard({required this.rep, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final totalCollected =
        ((rep['totalCollected'] as num?) ?? 0).toDouble();
    final invoiceCount = (rep['totalInvoices'] as num?) ?? 0;
    final customerCount = (rep['customerCount'] as num?) ?? 0;
    final name = rep['fullName'] ?? '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ctrl.selectedRepId.value = rep['id']?.toString();
          ctrl.selectedRepName.value = name;
          Get.toNamed(AppRoutes.supervisorRepDetail, arguments: rep);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    AppColors.primaryLight.withValues(alpha: 0.12),
                child: Text(
                  name[0],
                  style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: GoogleFonts.cairo(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    if ((rep['phone'] as String?)?.isNotEmpty == true)
                      Text(rep['phone']!,
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Pill(
                            label: '$customerCount عميل',
                            color: AppColors.primaryLight),
                        const SizedBox(width: 6),
                        _Pill(
                            label: '$invoiceCount فاتورة',
                            color: AppColors.warningLight),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(totalCollected),
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success),
                  ),
                  Text('محصّل',
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_left, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets مساعدة
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool small;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.cairo(
                        fontSize: small ? 12 : 16,
                        fontWeight: FontWeight.w700,
                        color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(label,
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.cairo(fontSize: 11, color: color)),
    );
  }
}

