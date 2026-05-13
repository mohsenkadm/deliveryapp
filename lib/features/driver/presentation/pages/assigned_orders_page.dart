import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/driver_entities.dart';
import '../controllers/driver_controllers.dart';

class AssignedOrdersPage extends GetView<DriverHomeController> {
  const AssignedOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات المسندة'),
        actions: [
          // فلتر الحالة
          Obx(() => PopupMenuButton<String?>(
                icon: const Icon(Icons.filter_list),
                initialValue: controller.selectedStatus.value,
                onSelected: (v) => controller.loadOrdersByStatus(v),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: null, child: Text('الكل')),
                  ...DriverHomeController.statusFilters.map(
                    (s) => PopupMenuItem(value: s['value'], child: Text(s['label']!)),
                  ),
                ],
              )),
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.loadData),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();
        if (controller.assignedOrders.isEmpty) {
          return const EmptyState(
            title: 'لا توجد طلبات',
            subtitle: 'لا توجد طلبات في انتظار التوصيل',
            icon: Icons.assignment_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.assignedOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _OrderCard(order: controller.assignedOrders[i], ctrl: controller),
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final DriverHomeController ctrl;

  const _OrderCard({required this.order, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final statusColor = InvoiceStatusHelper.color(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس البطاقة ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طلب #${order.orderNumber}',
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(InvoiceStatusHelper.label(order.status),
                      style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
          ),

          // ── معلومات العميل ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.person_outline, text: order.customerName),
                const SizedBox(height: 5),
                _InfoRow(icon: Icons.phone_outlined, text: order.customerPhone, isPhone: true),
                const SizedBox(height: 5),
                _InfoRow(icon: Icons.location_on_outlined, text: order.customerAddress),
                if (order.customerRegion != null) ...[
                  const SizedBox(height: 5),
                  _InfoRow(icon: Icons.map_outlined, text: order.customerRegion!),
                ],
              ],
            ),
          ),

          // ── المنتجات (مطوي) ──
          if (order.items.isNotEmpty)
            _ExpandableItems(items: order.items),

          // ── الإجمالي + الوقت ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Formatters.currency(order.totalAmount),
                        style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                    Text(Formatters.timeAgo(order.createdAt),
                        style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'مدفوع: ${Formatters.currency(order.paidAmount)} • متبقي: ${Formatters.currency(order.remainingAmount)}',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // ── أزرار الإجراءات ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: _ActionButtons(order: order, ctrl: ctrl),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final DeliveryOrder order;
  final DriverHomeController ctrl;

  const _ActionButtons({required this.order, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final status = order.status;

    return Column(
      children: [
        // زر خرائط جوجل إن توفرت الإحداثيات
        if (order.googleMapsUrl != null || (order.latitude != null && order.longitude != null))
          _btn(
            label: 'افتح في الخريطة',
            icon: Icons.map_rounded,
            color: Colors.teal,
            onTap: () async {
              final url = order.googleMapsUrl ??
                  'https://maps.google.com/?q=${order.latitude},${order.longitude}';
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),

        // استلام من المستودع
        if (status == 'WarehouseProcessing') ...[
          const SizedBox(height: 8),
          Obx(() => _btn(
                label: 'تأكيد الاستلام من المستودع',
                icon: Icons.inventory_2_rounded,
                color: AppColors.primary,
                loading: ctrl.isActing.value,
                onTap: () => ctrl.confirmPickup(order.id),
              )),
        ],

        if (status == 'Accepted') ...[
          const SizedBox(height: 8),
          Obx(() => _btn(
                label: 'بدء التوصيل',
                icon: Icons.local_shipping_rounded,
                color: AppColors.primary,
                loading: ctrl.isActing.value,
                onTap: () => ctrl.updateStatus(order.id, 'AwaitingDelivery'),
              )),
        ],

        // تم التسليم
        if (status == 'AwaitingDelivery') ...[
          const SizedBox(height: 8),
          Obx(() => _btn(
                label: 'تم التسليم',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                loading: ctrl.isActing.value,
                onTap: () => _confirmDelivery(context),
              )),
        ],

        if ((status == 'AwaitingDelivery' || status == 'Delivered') &&
            order.remainingAmount > 0) ...[
          const SizedBox(height: 8),
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
                  'تحصيل نقدي (${Formatters.currency(order.remainingAmount)})',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                ),
              )),
        ],

        // تأجيل
        if (status == 'AwaitingDelivery' || status == 'Delivered') ...[
          const SizedBox(height: 8),
          Obx(() => _btn(
                label: 'تأجيل الطلب',
                icon: Icons.schedule_rounded,
                color: const Color(0xFF9CA3AF),
                loading: ctrl.isActing.value,
                onTap: () => _confirmDefer(context),
              )),
        ],
      ],
    );
  }

  Widget _btn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onTap,
        icon: loading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Future<void> _confirmDelivery(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد التسليم'),
        content: Text('هل تم تسليم طلب #${order.orderNumber} للعميل؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تأكيد')),
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
    }
  }

  Future<void> _confirmDefer(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('تأجيل الطلب'),
        content: Text('هل تريد تأجيل طلب #${order.orderNumber}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تأكيد')),
        ],
      ),
    );
    if (ok == true) await ctrl.updateStatus(order.id, 'Deferred');
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPhone;

  const _InfoRow({required this.icon, required this.text, this.isPhone = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: GestureDetector(
            onTap: isPhone
                ? () async {
                    final uri = Uri(scheme: 'tel', path: text);
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  }
                : null,
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isPhone ? AppColors.primary : Colors.grey[700],
                decoration: isPhone ? TextDecoration.underline : null,
              ),
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableItems extends StatefulWidget {
  final List items;
  const _ExpandableItems({required this.items});

  @override
  State<_ExpandableItems> createState() => _ExpandableItemsState();
}

class _ExpandableItemsState extends State<_ExpandableItems> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 15, color: Colors.grey),
                const SizedBox(width: 6),
                Text('${widget.items.length} منتج', style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                const Spacer(),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: widget.items.map((item) {
                final name = item is Map ? (item['productName'] ?? '') : item.productName ?? '';
                final qty = item is Map ? (item['quantity'] ?? 0) : item.quantity ?? 0;
                return Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(name.toString(), style: GoogleFonts.cairo(fontSize: 13))),
                    Text('× $qty', style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
