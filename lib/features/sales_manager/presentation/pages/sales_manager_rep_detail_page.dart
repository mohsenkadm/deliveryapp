// تفاصيل مندوب — مدير المبيعات
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/sales_manager_controller.dart';

class SalesManagerRepDetailPage extends StatefulWidget {
  const SalesManagerRepDetailPage({super.key});

  @override
  State<SalesManagerRepDetailPage> createState() =>
      _SalesManagerRepDetailPageState();
}

class _SalesManagerRepDetailPageState
    extends State<SalesManagerRepDetailPage> {
  late final Map<String, dynamic> _rep;
  late final SalesManagerController _ctrl;
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    _rep = Get.arguments as Map<String, dynamic>;
    _ctrl = Get.find<SalesManagerController>();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _ctrl.loadRepInvoices(_rep['id'].toString()));
  }

  @override
  Widget build(BuildContext context) {
    final name = _rep['fullName'] ?? 'تفاصيل المندوب';
    final totalSales =
        ((_rep['totalSales'] as num?) ?? 0).toDouble();
    final collected =
        ((_rep['totalCollected'] as num?) ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(name,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                _ctrl.loadRepInvoices(_rep['id'].toString(),
                    status: _statusFilter.isEmpty ? null : _statusFilter),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── ملخص ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                    label: 'المبيعات',
                    value: Formatters.currency(totalSales),
                    color: AppColors.primaryLight),
                Container(
                    width: 1,
                    height: 28,
                    color: AppColors.dividerLight),
                _MiniStat(
                    label: 'المحصّل',
                    value: Formatters.currency(collected),
                    color: AppColors.successLight),
              ],
            ),
          ),

          // ── فلتر الحالة ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final entry in [
                  ('', 'الكل'),
                  ('Pending', 'معلق'),
                  ('Accepted', 'مقبول'),
                  ('Delivered', 'تم التسليم'),
                  ('Completed', 'مكتمل'),
                  ('Rejected', 'مرفوض'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(entry.$2,
                          style: GoogleFonts.cairo(fontSize: 12)),
                      selected: _statusFilter == entry.$1,
                      onSelected: (v) {
                        setState(() => _statusFilter = entry.$1);
                        _ctrl.loadRepInvoices(
                            _rep['id'].toString(),
                            status:
                                entry.$1.isEmpty ? null : entry.$1);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── قائمة الفواتير ──
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoading.value &&
                  _ctrl.selectedRepInvoices.isEmpty) {
                return const LoadingIndicator();
              }
              if (_ctrl.selectedRepInvoices.isEmpty) {
                return const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'لا توجد فواتير');
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: _ctrl.selectedRepInvoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final inv = _ctrl.selectedRepInvoices[i];
                  final amount =
                      ((inv['totalAmount'] as num?) ?? 0).toDouble();
                  final status = InvoiceStatusHelper.parse(
                      inv['statusText'] ?? inv['status'],
                      fallback: '');
                  final statusColor = InvoiceStatusHelper.color(status);
                  final statusLabel = InvoiceStatusHelper.label(status);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(Icons.receipt_long,
                              color: statusColor, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('فاتورة #${inv['id'] ?? ''}',
                                  style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                              if ((inv['customerName'] as String?)
                                      ?.isNotEmpty ==
                                  true)
                                Text(inv['customerName']!,
                                    style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.currency(amount),
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLight),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(statusLabel,
                                  style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (40 + i * 35).ms);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
