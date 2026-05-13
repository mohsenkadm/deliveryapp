// صفحة تفاصيل الطلب — السائق
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/customer_location_map.dart';
import '../../domain/entities/driver_entities.dart';
import '../controllers/driver_controllers.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments['order'] as DeliveryOrder;
    final controller = Get.find<DriverHomeController>();
    final statusColor = InvoiceStatusHelper.color(order.status);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('طلب #${order.orderNumber}'),
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 16, right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              InvoiceStatusHelper.label(order.status),
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── خريطة موقع العميل ──
            if (order.latitude != null && order.longitude != null) ...[
              CustomerLocationMap(
                latitude: order.latitude!,
                longitude: order.longitude!,
                title: order.storeName ?? order.customerName,
                subtitle: order.customerAddress,
              ).animate().fadeIn().slideY(begin: -0.05),
              const SizedBox(height: 14),
            ],

            // ── بطاقة معلومات العميل ──
            _SectionCard(
              title: 'معلومات العميل',
              icon: Icons.person_outlined,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.storefront_outlined,
                    label: 'المتجر / العميل',
                    value: order.storeName ?? order.customerName,
                  ),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'اسم التواصل',
                    value: order.customerName,
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'الهاتف',
                    value: order.customerPhone,
                    isPhone: true,
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'العنوان',
                    value: order.customerAddress,
                  ),
                  if (order.customerRegion != null)
                    _InfoRow(
                      icon: Icons.map_outlined,
                      label: 'المنطقة',
                      value: order.customerRegion!,
                    ),
                  // زر Google Maps
                  if (order.googleMapsUrl != null ||
                      (order.latitude != null && order.longitude != null))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: OutlinedButton.icon(
                        onPressed: () => _openMaps(order),
                        icon: const Icon(Icons.directions_rounded, size: 18),
                        label: Text('افتح في خرائط جوجل',
                            style: GoogleFonts.cairo(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: const BorderSide(color: Colors.teal),
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05),

            const SizedBox(height: 14),

            // ── تفاصيل الطلب ──
            _SectionCard(
              title: 'تفاصيل الفاتورة',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.tag_rounded,
                    label: 'رقم الفاتورة',
                    value: '#${order.orderNumber}',
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'التاريخ',
                    value: Formatters.dateTime(order.createdAt),
                  ),
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'الإجمالي',
                    value: Formatters.currency(order.totalAmount),
                    isBold: true,
                    valueColor: AppColors.primary,
                  ),
                  _InfoRow(
                    icon: Icons.check_circle_outline,
                    label: 'المدفوع',
                    value: Formatters.currency(order.paidAmount),
                  ),
                  _InfoRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'المتبقي',
                    value: Formatters.currency(order.remainingAmount),
                    isBold: true,
                    valueColor: order.remainingAmount > 0
                        ? AppColors.error
                        : AppColors.success,
                  ),
                  if (order.paymentStatus != null)
                    _InfoRow(
                      icon: Icons.credit_card_outlined,
                      label: 'حالة الدفع',
                      value: _paymentLabel(order.paymentStatus!),
                      valueColor: _paymentColor(order.paymentStatus!),
                    ),
                  if (order.notes != null && order.notes!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.note_outlined,
                      label: 'ملاحظات',
                      value: order.notes!,
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),

            // ── قائمة المنتجات ──
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 14),
              _SectionCard(
                title: 'المنتجات (${order.items.length})',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: order.items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text('${i + 1}',
                                      style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(item.productName,
                                    style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('× ${item.quantity}',
                                      style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: AppColors.textSecondary)),
                                  Text(
                                      Formatters.currency(item.subTotal > 0
                                          ? item.subTotal
                                          : item.price * item.quantity),
                                      style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary)),
                                  Text(
                                      'الوحدة: ${Formatters.currency(item.price)}',
                                      style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (i < order.items.length - 1)
                          Divider(
                              height: 1,
                              color:
                                  AppColors.dividerLight),
                      ],
                    );
                  }).toList(),
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),
            ],

            const SizedBox(height: 24),

            // ── أزرار الإجراءات ──
            _ActionSection(order: order, ctrl: controller)
                .animate()
                .fadeIn(delay: 200.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(DeliveryOrder order) async {
    final url = order.googleMapsUrl ??
        'https://maps.google.com/?q=${order.latitude},${order.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _paymentLabel(String s) {
    switch (s) {
      case 'Paid':
        return 'مدفوعة';
      case 'Partial':
        return 'دفعة جزئية';
      case 'Unpaid':
        return 'غير مدفوعة';
      default:
        return s;
    }
  }

  Color _paymentColor(String s) {
    switch (s) {
      case 'Paid':
        return AppColors.success;
      case 'Partial':
        return const Color(0xFFF59E0B);
      case 'Unpaid':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
}

// ─────────────────────────────────────────────
// قسم الأزرار
// ─────────────────────────────────────────────
class _ActionSection extends StatelessWidget {
  final DeliveryOrder order;
  final DriverHomeController ctrl;

  const _ActionSection({required this.order, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final status = order.status;

    return Column(
      children: [
        // استلام من المستودع
        if (status == 'WarehouseProcessing')
          Obx(() => CustomButton(
                text: 'تأكيد الاستلام من المستودع',
                icon: Icons.inventory_2_rounded,
                isLoading: ctrl.isActing.value,
                onPressed: () =>
                    ctrl.confirmPickup(order.id),
              )),

        // بدء التوصيل — حالات ما قبل «قيد التجهيز» قد تظهر للسائق؛ يُترك للخادم رفض PATCH إن لم يُسمح
        if (status == 'Accepted')
          Obx(() => CustomButton(
                text: 'بدء التوصيل',
                icon: Icons.local_shipping_rounded,
                isLoading: ctrl.isActing.value,
                onPressed: () =>
                    ctrl.updateStatus(order.id, 'AwaitingDelivery'),
              )),

        // تم التسليم — POST /deliver
        if (status == 'AwaitingDelivery') ...[
          Obx(() => CustomButton(
                text: 'تم التسليم',
                icon: Icons.check_circle_outline_rounded,
                isLoading: ctrl.isActing.value,
                backgroundColor: AppColors.success,
                onPressed: () => _confirmDelivered(
                    context, ctrl),
              )),
          const SizedBox(height: 12),
        ],

        // تحصيل نقدي (اختياري) — عند وجود متبقي
        if ((status == 'AwaitingDelivery' || status == 'Delivered') &&
            order.remainingAmount > 0) ...[
          const SizedBox(height: 12),
          Obx(() => OutlinedButton.icon(
                onPressed: ctrl.isActing.value
                    ? null
                    : () => ctrl.offerOptionalCashCollection(
                          orderId: order.id,
                          orderNumber: order.orderNumber.toString(),
                          remainingAmount: order.remainingAmount,
                        ),
                icon: const Icon(Icons.payments_outlined, size: 18),
                label: Text(
                  'تسجيل تحصيل نقدي (${Formatters.currency(order.remainingAmount)} متبقي)',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              )),
        ],

        // تأجيل الطلب
        if (status == 'AwaitingDelivery' || status == 'Delivered')
          Obx(() => CustomButton(
                text: 'تأجيل الطلب',
                icon: Icons.schedule_rounded,
                isLoading: ctrl.isActing.value,
                backgroundColor: const Color(0xFF9CA3AF),
                onPressed: () => _changeStatus(
                    context,
                    'Deferred',
                    'تأجيل الطلب',
                    'هل تريد تأجيل طلب #${order.orderNumber}؟'),
              )),
      ],
    );
  }

  Future<void> _confirmDelivered(
      BuildContext ctx, DriverHomeController ctrl) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title:
            Text('تأكيد التسليم', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text(
            'هل تم تسليم طلب #${order.orderNumber} للعميل فعلاً؟',
            style: GoogleFonts.cairo()),
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
    if (ok == true) {
      await ctrl.markDelivered(order.id);
      if (!ctx.mounted) return;
      await ctrl.offerOptionalCashCollection(
        orderId: order.id,
        orderNumber: order.orderNumber.toString(),
        remainingAmount: order.remainingAmount,
      );
      if (ctx.mounted) Get.back();
    }
  }

  Future<void> _changeStatus(
      BuildContext ctx, String status, String title, String message) async {
    final ok = await showDialog<bool>(
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
    if (ok == true) {
      await ctrl.updateStatus(order.id, status);
      Get.back();
    }
  }
}

// ─────────────────────────────────────────────
// مساعدات UI
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: GoogleFonts.cairo(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.dividerLight),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPhone;
  final bool isBold;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isPhone = false,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isPhone
                  ? () async {
                      final uri = Uri(scheme: 'tel', path: value);
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    }
                  : null,
              child: Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w500,
                  color: isPhone
                      ? AppColors.primary
                      : (valueColor ?? AppColors.textPrimary),
                  decoration:
                      isPhone ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

