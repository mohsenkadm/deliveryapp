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

class CustomerInvoicesPage extends GetView<RepresentativeHomeController> {
  const CustomerInvoicesPage({super.key});

  static const _statuses = [
    '',
    'Pending',
    'Accepted',
    'WarehouseProcessing',
    'AwaitingDelivery',
    'Delivered',
    'Completed',
    'Rejected',
    'Deferred',
  ];
  static const _statusLabels = [
    'الكل',
    'انتظار',
    'موافق',
    'تجهيز',
    'في التوصيل',
    'مُسلّم',
    'مكتمل',
    'مرفوض',
    'مؤجل',
  ];

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final customer = args is Map<String, dynamic> ? args : null;
    final customerId = customer?['id']?.toString();
    final title = customer != null
        ? 'فواتير ${customer['fullName'] ?? ''}'
        : 'الفواتير';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (customerId != null) {
        controller.loadCustomerInvoices(customerId);
      } else {
        controller.loadInvoices();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => customerId != null
                ? controller.loadCustomerInvoices(customerId)
                : controller.loadInvoices(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customer != null)
            FloatingActionButton.small(
              heroTag: 'collect',
              onPressed: () =>
                  Get.toNamed(AppRoutes.collectPayment, arguments: customer),
              backgroundColor: AppColors.success,
              child: const Icon(Icons.payment, color: Colors.white),
            ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () => Get.toNamed(AppRoutes.repCreateInvoice),
            icon: const Icon(Icons.add),
            label: Text('فاتورة جديدة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── فلتر الحالة (للعرض الكلي فقط) ──
          if (customerId == null)
            Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: List.generate(_statuses.length, (i) {
                      final selected =
                          (controller.selectedInvoiceStatus.value ?? '') ==
                              _statuses[i];
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: FilterChip(
                          label: Text(_statusLabels[i],
                              style: GoogleFonts.cairo(fontSize: 12)),
                          selected: selected,
                          onSelected: (_) =>
                              controller.loadInvoices(status: _statuses[i]),
                        ),
                      );
                    }),
                  ),
                )),

          Expanded(
            child: Obx(() {
              if (controller.isLoadingInvoices.value) {
                return const LoadingIndicator();
              }

              final invoices = customerId != null
                  ? controller.customerInvoices
                  : controller.invoices;

              if (invoices.isEmpty) {
                return const EmptyState(
                  title: 'لا توجد فواتير',
                  icon: Icons.receipt_long_outlined,
                );
              }

              return RefreshIndicator(
                onRefresh: () => customerId != null
                    ? controller.loadCustomerInvoices(customerId)
                    : controller.loadInvoices(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: invoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final inv = invoices[i];
                    final status = inv['status']?.toString() ?? '';
                    final statusColor = InvoiceStatusHelper.color(status);
                    final statusLabel = InvoiceStatusHelper.label(status);

                    return GestureDetector(
                      onTap: () => Get.toNamed(
                          AppRoutes.repInvoiceDetail,
                          arguments: inv),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.receipt_long_outlined,
                                  color: statusColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'فاتورة #${inv['id'] ?? ''}',
                                    style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  if (inv['customerName'] != null)
                                    Text(
                                      inv['customerName'].toString(),
                                      style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  Text(
                                    inv['createdAt'] != null
                                        ? Formatters.date(
                                            DateTime.tryParse(inv['createdAt']
                                                    .toString()) ??
                                                DateTime.now())
                                        : '',
                                    style: GoogleFonts.cairo(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Formatters.currency(
                                      (inv['totalAmount'] as num?)
                                              ?.toDouble() ??
                                          0),
                                  style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color:
                                        statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: GoogleFonts.cairo(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
