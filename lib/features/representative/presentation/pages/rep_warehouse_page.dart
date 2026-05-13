// صفحة مخزون المستودع الفرعي — المندوب
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import 'rep_transfer_product_picker_page.dart';
import '../controllers/representative_controllers.dart';

String _repWarehouseSubtitle(Map<String, dynamic> item) {
  final parts = <String>[];
  final wn = item['warehouseName']?.toString();
  if (wn != null && wn.isNotEmpty) parts.add('المستودع: $wn');
  final wp = item['wholesalePrice'];
  final rp = item['retailPrice'];
  final dp = item['discountPercentage'];
  if (wp != null) parts.add('جملة: $wp');
  if (rp != null) parts.add('تجزئة: $rp');
  if (dp != null) parts.add('خصم: $dp%');
  return parts.isEmpty ? '—' : parts.join(' • ');
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

String _transferDateShort(dynamic v) {
  if (v == null) return '—';
  final s = v.toString();
  if (s.length >= 10) return s.substring(0, 10);
  return s;
}

List<Map<String, dynamic>> _transferDetailsList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((e) => e is Map ? Map<String, dynamic>.from(e) : null)
      .whereType<Map<String, dynamic>>()
      .toList();
}

Color _transferStatusColor(int? code, String statusText) {
  final t = statusText.toLowerCase();
  if (code == 3 || t.contains('مكتمل')) return AppColors.success;
  if (code == 0 || t.contains('معلق') || t.contains('انتظار')) {
    return const Color(0xFFF59E0B);
  }
  if (t.contains('رفض')) return AppColors.error;
  return AppColors.primary;
}

class RepWarehousePage extends StatefulWidget {
  const RepWarehousePage({super.key});

  @override
  State<RepWarehousePage> createState() => _RepWarehousePageState();
}

class _RepWarehousePageState extends State<RepWarehousePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final Worker _repWarehouseTabWorker;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final ctrl = Get.find<RepresentativeHomeController>();
    _repWarehouseTabWorker = ever(ctrl.repWarehouseSubTabIndex, (int? v) {
      if (v == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (v >= 0 && v < _tabs.length) _tabs.animateTo(v);
        ctrl.repWarehouseSubTabIndex.value = null;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadWarehouse();
      ctrl.loadTransferOrders();
    });
  }

  @override
  void dispose() {
    _repWarehouseTabWorker.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RepresentativeHomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المستودع الفرعي'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'المخزون'),
            Tab(text: 'أوامر النقل'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTransferActions(context, ctrl),
        icon: const Icon(Icons.swap_horiz_rounded),
        label: const Text('نقل مخزون'),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // تبويب المخزون
          Obx(() {
            if (ctrl.isLoadingWarehouse.value) return const LoadingIndicator();
            if (ctrl.warehouseItems.isEmpty) {
              return const EmptyState(
                icon: Icons.warehouse_outlined,
                title: 'المستودع فارغ',
                subtitle: 'لا يوجد مخزون في مستودعك الفرعي حالياً',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.warehouseItems.length,
              itemBuilder: (ctx, i) {
                final item = ctrl.warehouseItems[i];
                final qty = item['quantity'] ?? 0;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: qty > 0
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: qty > 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                    title: Text(item['productName'] ?? '',
                        style: AppTextStyles.titleSmall),
                    subtitle: Text(
                        _repWarehouseSubtitle(item),
                        style: AppTextStyles.bodySmall),
                    trailing: Chip(
                      label: Text('$qty',
                          style: TextStyle(
                              color: qty > 0
                                  ? AppColors.success
                                  : AppColors.error)),
                      backgroundColor: qty > 0
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    ),
                  ),
                );
              },
            );
          }),

          // تبويب أوامر النقل
          Obx(() {
            if (ctrl.isLoadingTransfers.value) return const LoadingIndicator();
            if (ctrl.transferOrders.isEmpty) {
              return const EmptyState(
                icon: Icons.sync_outlined,
                title: 'لا توجد أوامر نقل',
                subtitle: 'لم يتم طلب أي نقل مخزون بعد',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: ctrl.transferOrders.length,
              itemBuilder: (ctx, i) {
                return _RepTransferOrderCard(
                    order: ctrl.transferOrders[i]);
              },
            );
          }),
        ],
      ),
    );
  }

  void _openTransferActions(
      BuildContext context, RepresentativeHomeController ctrl) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'نقل المخزون',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: AppColors.primary.withValues(alpha: 0.06),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Icon(Icons.downloading_rounded,
                      color: AppColors.primary),
                ),
                title: Text('طلب من الرئيسي',
                    style: AppTextStyles.titleSmall
                        .copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  'تصفّح مخزون المستودع الرئيسي واختر المنتجات',
                  style: AppTextStyles.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Get.toNamed(
                    AppRoutes.repTransferPicker,
                    arguments: const RepTransferPickerArgs(isReturn: false),
                  );
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: const Color(0xFF3949AB).withValues(alpha: 0.08),
                leading: CircleAvatar(
                  backgroundColor:
                      const Color(0xFF3949AB).withValues(alpha: 0.2),
                  child: const Icon(Icons.upload_rounded,
                      color: Color(0xFF3949AB)),
                ),
                title: Text('إرجاع للرئيسي',
                    style: AppTextStyles.titleSmall
                        .copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  'اختر منتجات من مستودعك لإرجاعها للمستودع الرئيسي',
                  style: AppTextStyles.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Get.toNamed(
                    AppRoutes.repTransferPicker,
                    arguments: const RepTransferPickerArgs(isReturn: true),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة أمر نقل وفق رد `GET /api/mobile/rep/transfer-orders`.
class _RepTransferOrderCard extends StatelessWidget {
  const _RepTransferOrderCard({required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final orderNumber =
        order['orderNumber']?.toString() ?? '#${order['id'] ?? ''}';
    final orderTypeText = order['orderTypeText']?.toString() ?? '';
    final fromW = order['fromWarehouseName']?.toString() ?? '';
    final toW = order['toWarehouseName']?.toString() ?? '';
    final statusText = order['statusText']?.toString() ??
        (order['status'] != null ? order['status'].toString() : '—');
    final statusCode = _asInt(order['status']);
    final statusColor = _transferStatusColor(statusCode, statusText);
    final requestedAt = order['requestedAt'] ?? order['createdAt'];
    final approvedAt = order['approvedAt'];
    final completedAt = order['completedAt'];
    final requester = order['requestedByEmployeeName']?.toString();
    final notes = order['notes']?.toString().trim();
    final details = _transferDetailsList(order['details']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Icon(Icons.swap_horiz_rounded, color: statusColor, size: 22),
          ),
          title: Text(
            orderNumber,
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (orderTypeText.isNotEmpty)
                  Text(
                    orderTypeText,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                const SizedBox(height: 6),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    label: Text(
                      'حالة الطلب: $statusText',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    side: BorderSide.none,
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (fromW.isNotEmpty)
                    _kvRow('من', fromW, icon: Icons.south_west_outlined),
                  if (toW.isNotEmpty)
                    _kvRow('إلى', toW, icon: Icons.north_east_outlined),
                  _kvRow(
                    'تاريخ الطلب',
                    _transferDateShort(requestedAt),
                    icon: Icons.event_outlined,
                  ),
                  if (approvedAt != null)
                    _kvRow(
                      'تاريخ الموافقة',
                      _transferDateShort(approvedAt),
                      icon: Icons.verified_outlined,
                    ),
                  if (completedAt != null)
                    _kvRow(
                      'تاريخ الإكمال',
                      _transferDateShort(completedAt),
                      icon: Icons.done_all_outlined,
                    ),
                  if (requester != null && requester.isNotEmpty)
                    _kvRow(
                      'طالب الأمر',
                      requester,
                      icon: Icons.person_outline,
                    ),
                  if (notes != null && notes.isNotEmpty)
                    _kvRow('ملاحظات', notes, icon: Icons.notes_outlined),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('الأصناف', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 8),
                    ...details.map((d) => _detailLine(d)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kvRow(String label, String value, {IconData? icon}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailLine(Map<String, dynamic> d) {
    final name = d['productName']?.toString() ?? '';
    final rq = d['requestedQuantity'];
    final aq = d['approvedQuantity'];
    final qtyLine = aq != null
        ? 'مطلوب: $rq • موافق: $aq'
        : 'الكمية المطلوبة: $rq';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 18, color: AppColors.primary.withValues(alpha: 0.75)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleSmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  qtyLine,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
