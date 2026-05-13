import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../controllers/admin_controllers.dart';

class AdminInvoicesPage extends GetView<AdminOrdersController> {
  const AdminInvoicesPage({super.key});

  static const _statuses = [
    'الكل', 'Pending', 'Accepted', 'WarehouseProcessing',
    'AwaitingDelivery', 'Delivered', 'Completed', 'Rejected', 'Deferred',
  ];
  static const _statusLabels = [
    'الكل', 'معلق', 'مقبول', 'في المستودع',
    'في انتظار التوصيل', 'تم التوصيل', 'مكتمل', 'مرفوض', 'مؤجل',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedStatus = 'الكل'.obs;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.adminCreateInvoice);
          if (result == true) controller.loadInvoices();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: Text('فاتورة جديدة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
      ),
      appBar: AppBar(
        title: Text('الفواتير', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Obx(() {
            // اقرأ القيمة هنا لضمان تسجيل اشتراك Rx قبل بناء الـ ListView
            final current = selectedStatus.value;
            return SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _statuses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = current == _statuses[i];
                  return GestureDetector(
                    onTap: () => selectedStatus.value = _statuses[i],
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.dividerLight),
                      ),
                      child: Text(_statusLabels[i],
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();
        // اقرأ القيمة هنا لضمان تسجيل اشتراك Rx
        final current = selectedStatus.value;
        final all = controller.invoices;
        final filtered = current == 'الكل'
            ? all
            : all.where((inv) {
                final s = InvoiceStatusHelper.parse(
                    inv['statusText'] ?? inv['status'],
                    fallback: '');
                return s == current;
              }).toList();
        if (filtered.isEmpty) {
          return const EmptyState(
              title: 'لا توجد فواتير',
              icon: Icons.receipt_long_outlined);
        }
        return RefreshIndicator(
          onRefresh: controller.loadInvoices,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _InvoiceCard(
              invoice: filtered[i],
              onChanged: controller.loadInvoices,
            ),
          ),
        );
      }),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Map<String, dynamic> invoice;
  final VoidCallback onChanged;
  const _InvoiceCard({required this.invoice, required this.onChanged});

  AdminRemoteDataSource get _ds => AdminRemoteDataSource(Get.find<DioClient>());

  Future<void> _payDialog(BuildContext context, double remaining) async {
    final ctrl = TextEditingController(
        text: remaining > 0 ? remaining.toStringAsFixed(2) : '');
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تسجيل دفعة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'المبلغ',
            labelStyle: GoogleFonts.cairo(),
            helperText: 'المتبقي: ${Formatters.currency(remaining)}',
            helperStyle: GoogleFonts.cairo(fontSize: 11),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('إلغاء', style: GoogleFonts.cairo())),
          ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text('دفع', style: GoogleFonts.cairo())),
        ],
      ),
    );
    if (ok != true) return;
    final amount = double.tryParse(ctrl.text.trim()) ?? 0;
    if (amount <= 0) {
      SnackbarHelper.showError('أدخل مبلغاً صحيحاً');
      return;
    }
    try {
      await _ds.payInvoice(invoice['id'].toString(), amount);
      SnackbarHelper.showSuccess('تم تسجيل الدفعة');
      onChanged();
    } catch (_) {
      SnackbarHelper.showError('فشل الدفع');
    }
  }

  Future<void> _statusDialog(BuildContext context) async {
    const statuses = [
      ('Pending', 'معلق'),
      ('Accepted', 'مقبول'),
      ('Rejected', 'مرفوض'),
      ('Deferred', 'مؤجل'),
      ('WarehouseProcessing', 'في المستودع'),
      ('AwaitingDelivery', 'في انتظار التوصيل'),
      ('Delivered', 'تم التوصيل'),
      ('Completed', 'مكتمل'),
    ];
    final picked = await Get.dialog<String>(
      SimpleDialog(
        title: Text('تحديث الحالة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        children: statuses
            .map((s) => SimpleDialogOption(
                  onPressed: () => Get.back(result: s.$1),
                  child: Text(s.$2, style: GoogleFonts.cairo()),
                ))
            .toList(),
      ),
    );
    if (picked == null) return;
    try {
      await _ds.updateInvoiceStatus(invoice['id'].toString(), picked);
      SnackbarHelper.showSuccess('تم تحديث الحالة');
      onChanged();
    } catch (_) {
      SnackbarHelper.showError('فشل تحديث الحالة');
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = invoice['invoiceNumber'] ?? invoice['id'] ?? '';
    final customer = invoice['customerName'] ?? invoice['customer']?['fullName'] ?? 'عميل';
    final status = InvoiceStatusHelper.parse(
        invoice['statusText'] ?? invoice['status'], fallback: 'Pending');
    final totalRaw = invoice['totalAmount'] ?? invoice['total'] ?? 0;
    final total = totalRaw is num
        ? totalRaw.toDouble()
        : double.tryParse(totalRaw.toString()) ?? 0.0;
    final paidRaw = invoice['paidAmount'] ?? 0;
    final paid = paidRaw is num
        ? paidRaw.toDouble()
        : double.tryParse(paidRaw.toString()) ?? 0.0;
    final remaining = (total - paid).clamp(0.0, double.infinity);
    final createdAt = invoice['createdAt'] != null ? DateTime.tryParse(invoice['createdAt'].toString()) : null;
    final statusColor = InvoiceStatusHelper.color(status);
    final statusLabel = InvoiceStatusHelper.label(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('فاتورة #$id', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(customer, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel,
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (v) async {
                  switch (v) {
                    case 'pay':
                      await _payDialog(context, remaining);
                      break;
                    case 'status':
                      await _statusDialog(context);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'pay',
                    child: Row(children: [
                      Icon(Icons.payments_outlined,
                          size: 18, color: AppColors.successLight),
                      const SizedBox(width: 8),
                      Text('تسجيل دفعة',
                          style: GoogleFonts.cairo(fontSize: 13)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'status',
                    child: Row(children: [
                      const Icon(Icons.swap_horiz, size: 18),
                      const SizedBox(width: 8),
                      Text('تحديث الحالة',
                          style: GoogleFonts.cairo(fontSize: 13)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.monetization_on_outlined, size: 15, color: AppColors.successLight),
                const SizedBox(width: 5),
                Text(Formatters.currency(total),
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.successLight, fontSize: 14)),
              ]),
              if (createdAt != null)
                Text(Formatters.date(createdAt), style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
