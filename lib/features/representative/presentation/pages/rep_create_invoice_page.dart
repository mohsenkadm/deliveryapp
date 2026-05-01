import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/representative_controllers.dart';

class RepCreateInvoicePage extends GetView<RepresentativeHomeController> {
  const RepCreateInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCustomerId = Rxn<String>();
    final notes = TextEditingController();
    final items = <_InvoiceItem>[].obs;

    // اضافة صنف اولي
    items.add(_InvoiceItem());

    double calcTotal() => items.fold(0, (sum, i) {
          final qty = double.tryParse(i.qtyCtrl.text) ?? 0;
          final price = double.tryParse(i.priceCtrl.text) ?? 0;
          return sum + qty * price;
        });

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء فاتورة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة صنف',
            onPressed: () => items.add(_InvoiceItem()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingCustomers.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── اختيار العميل ──
              Text('العميل', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                    value: selectedCustomerId.value,
                    decoration: InputDecoration(
                      hintText: 'اختر العميل',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: controller.customers.map((c) {
                      return DropdownMenuItem(
                        value: c['id']?.toString(),
                        child: Text(c['fullName'] ?? '', style: GoogleFonts.cairo()),
                      );
                    }).toList(),
                    onChanged: (v) => selectedCustomerId.value = v,
                  )),

              const SizedBox(height: 24),

              // ── الأصناف ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الأصناف', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text('إضافة صنف', style: GoogleFonts.cairo(fontSize: 13)),
                    onPressed: () => items.add(_InvoiceItem()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => Column(
                    children: items.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      return _ItemRow(
                        key: ValueKey(item),
                        item: item,
                        onRemove: items.length > 1 ? () => items.removeAt(i) : null,
                        onChanged: () => items.refresh(),
                      );
                    }).toList(),
                  )),

              // ── الإجمالي ──
              const SizedBox(height: 16),
              Obx(() {
                final _ = items.length; // trigger rebuild
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(Formatters.currency(calcTotal()),
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                );
              }),

              // ── ملاحظات ──
              const SizedBox(height: 20),
              Text('ملاحظات', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: notes,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'أي ملاحظات إضافية...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              // ── زر الإرسال ──
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: 'إنشاء الفاتورة',
                    isLoading: controller.isActing.value,
                    onPressed: () {
                      if (selectedCustomerId.value == null) {
                        Get.snackbar('خطأ', 'يرجى اختيار العميل',
                            backgroundColor: AppColors.error, colorText: Colors.white);
                        return;
                      }
                      if (items.any((i) => i.productIdCtrl.text.trim().isEmpty)) {
                        Get.snackbar('خطأ', 'يرجى إدخال كود المنتج لكل الأصناف',
                            backgroundColor: AppColors.error, colorText: Colors.white);
                        return;
                      }
                      final data = {
                        'customerId': selectedCustomerId.value,
                        'notes': notes.text.trim().isEmpty ? null : notes.text.trim(),
                        'items': items.map((i) => {
                              'productId': i.productIdCtrl.text.trim(),
                              'quantity': int.tryParse(i.qtyCtrl.text) ?? 1,
                              'price': double.tryParse(i.priceCtrl.text) ?? 0,
                            }).toList(),
                      };
                      controller.createInvoice(data);
                    },
                  )),
            ],
          ),
        );
      }),
    );
  }
}

class _InvoiceItem {
  final productIdCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();
}

class _ItemRow extends StatelessWidget {
  final _InvoiceItem item;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _ItemRow({super.key, required this.item, this.onRemove, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: item.productIdCtrl,
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    labelText: 'كود المنتج',
                    labelStyle: GoogleFonts.cairo(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'حذف',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item.qtyCtrl,
                  onChanged: (_) => onChanged(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الكمية',
                    labelStyle: GoogleFonts.cairo(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: item.priceCtrl,
                  onChanged: (_) => onChanged(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'السعر',
                    labelStyle: GoogleFonts.cairo(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
