// صفحة تفاصيل الفاتورة — المندوب
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/representative_controllers.dart';

class RepInvoiceDetailPage extends GetView<RepresentativeHomeController> {
  const RepInvoiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String invoiceId;
    if (args is Map<String, dynamic>) {
      invoiceId = args['id']?.toString() ?? '';
    } else {
      invoiceId = args?.toString() ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (invoiceId.isNotEmpty) controller.loadInvoiceDetail(invoiceId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'فاتورة #$invoiceId',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadInvoiceDetail(invoiceId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) return const LoadingIndicator();

        final inv = controller.invoiceDetail.value;
        if (inv == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('لم يتم تحميل الفاتورة',
                    style: GoogleFonts.cairo(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        final status = inv['status']?.toString() ?? '';
        final statusColor = InvoiceStatusHelper.color(status);
        final statusLabel = InvoiceStatusHelper.label(status);
        final items = (inv['items'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        final totalAmount = (inv['totalAmount'] as num?)?.toDouble() ?? 0;
        final discount = (inv['discount'] as num?)?.toDouble() ?? 0;
        final paidAmount = (inv['paidAmount'] as num?)?.toDouble() ?? 0;
        final remaining = totalAmount - paidAmount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── رأس الفاتورة ──
              _SectionCard(
                title: 'معلومات الفاتورة',
                child: Column(
                  children: [
                    _InfoRow(
                        label: 'رقم الفاتورة', value: '#${inv['id'] ?? ''}'),
                    _InfoRow(
                      label: 'التاريخ',
                      value: inv['createdAt'] != null
                          ? Formatters.date(
                              DateTime.tryParse(
                                      inv['createdAt'].toString()) ??
                                  DateTime.now())
                          : '—',
                    ),
                    _InfoRow(
                      label: 'الحالة',
                      valueWidget: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor),
                        ),
                      ),
                    ),
                    if (inv['notes'] != null &&
                        inv['notes'].toString().isNotEmpty)
                      _InfoRow(
                          label: 'ملاحظات', value: inv['notes'].toString()),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── معلومات العميل ──
              _SectionCard(
                title: 'معلومات العميل',
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'الاسم',
                      value: inv['customerName'] ??
                          inv['customer']?['fullName'] ??
                          '—',
                    ),
                    _InfoRow(
                      label: 'المتجر',
                      value: inv['storeName'] ??
                          inv['customer']?['storeName'] ??
                          '—',
                    ),
                    _InfoRow(
                      label: 'الهاتف',
                      value: inv['customerPhone'] ??
                          inv['customer']?['phone'] ??
                          '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── الأصناف ──
              if (items.isNotEmpty) ...[
                _SectionCard(
                  title: 'الأصناف (${items.length})',
                  child: Column(
                    children: items.map((item) {
                      final qty =
                          (item['quantity'] as num?)?.toDouble() ?? 0;
                      final price =
                          (item['price'] as num?)?.toDouble() ?? 0;
                      final subtotal = qty * price;
                      final isLast = items.last == item;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : Border(
                                  bottom: BorderSide(
                                      color: AppColors.dividerLight,
                                      width: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['productName'] ??
                                        item['product']?['name'] ??
                                        'منتج',
                                    style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${qty.truncateToDouble() == qty ? qty.toInt() : qty} × ${Formatters.currency(price)}',
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.currency(subtotal),
                              style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── الملخص المالي ──
              _SectionCard(
                title: 'الملخص المالي',
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'الإجمالي',
                      value: Formatters.currency(totalAmount),
                      valueColor: AppColors.primary,
                      bold: true,
                    ),
                    if (discount > 0)
                      _InfoRow(
                        label: 'الخصم',
                        value: '- ${Formatters.currency(discount)}',
                        valueColor: AppColors.success,
                      ),
                    _InfoRow(
                      label: 'المدفوع',
                      value: Formatters.currency(paidAmount),
                      valueColor: AppColors.success,
                    ),
                    _InfoRow(
                      label: 'المتبقي',
                      value: Formatters.currency(remaining),
                      valueColor:
                          remaining > 0 ? AppColors.error : AppColors.success,
                      bold: true,
                    ),
                  ],
                ),
              ),

              // ── زر تحصيل دفعة ──
              if (remaining > 0) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () =>
                      Get.toNamed(AppRoutes.collectPayment, arguments: inv),
                  icon: const Icon(Icons.payment),
                  label: Text(
                    'تحصيل دفعة — ${Formatters.currency(remaining)}',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// UI Helpers
// ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color? valueColor;
  final bool bold;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          if (valueWidget != null)
            valueWidget!
          else
            Flexible(
              child: Text(
                value ?? '—',
                textAlign: TextAlign.end,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight:
                      bold ? FontWeight.w700 : FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
