// صفحة إنشاء فاتورة المندوب — تصفح منتجات المستودع، إضافة للسلة،
// اختيار العميل، ثم إرسال الفاتورة.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/representative_controllers.dart';

class RepCreateInvoicePage extends GetView<RepresentativeHomeController> {
  const RepCreateInvoicePage({super.key});

  // قراءة آمنة للسعر/الكمية من بيانات صنف المستودع.
  double _price(Map<String, dynamic> item) {
    final p = item['retailPrice'] ??
        item['price'] ??
        item['unitPrice'] ??
        item['salePrice'] ??
        0;
    return (p is num) ? p.toDouble() : double.tryParse(p.toString()) ?? 0;
  }

  int _stock(Map<String, dynamic> item) {
    final q = item['quantity'] ?? item['stockQuantity'] ?? 0;
    return (q is num) ? q.toInt() : int.tryParse(q.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final search = ''.obs;

    // تأكد من تحميل المستودع والعملاء.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.warehouseItems.isEmpty &&
          !controller.isLoadingWarehouse.value) {
        controller.loadWarehouse();
      }
      if (controller.customers.isEmpty &&
          !controller.isLoadingCustomers.value) {
        controller.loadCustomers();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء فاتورة'),
        actions: [
          Obx(() {
            final count = controller.invoiceCartCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  tooltip: 'السلة',
                  onPressed: () => _openCartSheet(context),
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ── شريط البحث ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) => search.value = v.trim(),
            ),
          ),

          // ── قائمة المنتجات ──
          Expanded(
            child: Obx(() {
              if (controller.isLoadingWarehouse.value) {
                return const LoadingIndicator();
              }
              final q = search.value.toLowerCase();
              final items = controller.warehouseItems.where((it) {
                if (q.isEmpty) return true;
                final name = (it['productName'] ?? '').toString().toLowerCase();
                final code = (it['productCode'] ?? it['code'] ?? '')
                    .toString()
                    .toLowerCase();
                return name.contains(q) || code.contains(q);
              }).toList();

              if (items.isEmpty) {
                return const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'لا توجد منتجات',
                  subtitle:
                      'لم يتم العثور على منتجات في مستودعك. اطلب نقل مخزون أولاً.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = items[i];
                  final productId =
                      (item['productId'] ?? item['id'] ?? '').toString();
                  final name = (item['productName'] ?? '').toString();
                  final stock = _stock(item);
                  final price = _price(item);

                  return _ProductRow(
                    productId: productId,
                    name: name,
                    stock: stock,
                    price: price,
                    onAdd: () {
                      if (productId.isEmpty) {
                        SnackbarHelper.showError('معرف المنتج غير صالح');
                        return;
                      }
                      if (stock <= 0) {
                        SnackbarHelper.showError('المنتج غير متوفر في المخزون');
                        return;
                      }
                      controller.addProductToCart(
                        productId: productId,
                        productName: name,
                        price: price,
                        maxStock: stock,
                      );
                      SnackbarHelper.showSuccess('تمت الإضافة إلى السلة');
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),

      // ── شريط سفلي بالإجمالي + زر فتح السلة ──
      bottomNavigationBar: Obx(() {
        if (controller.invoiceCart.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${controller.invoiceCartCount} عنصر',
                          style: GoogleFonts.cairo(fontSize: 12)),
                      Text(
                        Formatters.currency(controller.invoiceCartTotal),
                        style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _openCartSheet(context),
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text('متابعة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _openCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CartSheet(controller: controller),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String productId;
  final String name;
  final int stock;
  final double price;
  final VoidCallback onAdd;

  const _ProductRow({
    required this.productId,
    required this.name,
    required this.stock,
    required this.price,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final available = stock > 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.cairo(
                        fontSize: 14, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(Formatters.currency(price),
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Text('متوفر: $stock',
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: available ? Colors.green : Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: available ? onAdd : null,
            icon: const Icon(Icons.add),
            tooltip: 'إضافة',
          ),
        ],
      ),
    );
  }
}

class _CartSheet extends StatelessWidget {
  final RepresentativeHomeController controller;
  const _CartSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final notesCtrl = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('سلة الفاتورة',
              style: GoogleFonts.cairo(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          // ── اختيار العميل ──
          Text('العميل',
              style: GoogleFonts.cairo(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedInvoiceCustomerId.value,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'اختر العميل',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
                items: controller.customers.map((c) {
                  return DropdownMenuItem(
                    value: c['id']?.toString(),
                    child: Text(
                      (c['fullName'] ?? c['storeName'] ?? '').toString(),
                      style: GoogleFonts.cairo(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) =>
                    controller.selectedInvoiceCustomerId.value = v,
              )),

          const SizedBox(height: 16),

          // ── قائمة عناصر السلة ──
          Flexible(
            child: Obx(() {
              if (controller.invoiceCart.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'السلة فارغة',
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: controller.invoiceCart.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (_, i) {
                  final item = controller.invoiceCart[i];
                  return _CartItemRow(
                    item: item,
                    onInc: () => controller.updateCartQuantity(
                        item.productId, item.quantity + 1),
                    onDec: () => controller.updateCartQuantity(
                        item.productId, item.quantity - 1),
                    onRemove: () => controller.removeFromCart(item.productId),
                    onPriceChanged: (v) =>
                        controller.updateCartPrice(item.productId, v),
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 12),
          TextField(
            controller: notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'ملاحظات (اختياري)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الإجمالي',
                        style: GoogleFonts.cairo(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(Formatters.currency(controller.invoiceCartTotal),
                        style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Obx(() => CustomButton(
                text: 'إنشاء الفاتورة',
                isLoading: controller.isActing.value,
                onPressed: () =>
                    controller.submitInvoiceFromCart(notes: notesCtrl.text),
              )),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final RepCartItem item;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;
  final ValueChanged<double> onPriceChanged;

  const _CartItemRow({
    required this.item,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final priceCtrl =
        TextEditingController(text: item.price.toStringAsFixed(2));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName,
                  style: GoogleFonts.cairo(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              SizedBox(
                width: 110,
                height: 36,
                child: TextField(
                  controller: priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'السعر',
                    labelStyle: GoogleFonts.cairo(fontSize: 11),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                  ),
                  onSubmitted: (v) =>
                      onPriceChanged(double.tryParse(v) ?? item.price),
                  onEditingComplete: () => onPriceChanged(
                      double.tryParse(priceCtrl.text) ?? item.price),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // عدّاد الكمية
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onDec,
                icon: const Icon(Icons.remove, size: 18),
                visualDensity: VisualDensity.compact,
              ),
              Text('${item.quantity}',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              IconButton(
                onPressed: onInc,
                icon: const Icon(Icons.add, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline, color: Colors.red),
        ),
      ],
    );
  }
}
