// صفحة إنشاء فاتورة المندوب — تصفح منتجات المستودع، إضافة للسلة،
// اختيار العميل، ثم إرسال الفاتورة.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/unit_price_resolver.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/debounced_product_autocomplete.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/product_quantity_stepper.dart';
import '../controllers/representative_controllers.dart';

class RepCreateInvoicePage extends GetView<RepresentativeHomeController> {
  const RepCreateInvoicePage({super.key});

  // قراءة سعر الوحدة من بيانات صنف المستودع (جملة أو مفرد حسب نوع المندوب).
  double _price(Map<String, dynamic> item) => resolveUnitPrice(
        item,
        preferWholesale: controller.preferWholesaleUnitPrices,
      );

  int _stock(Map<String, dynamic> item) {
    final q = item['quantity'] ??
        item['mainWarehouseStock'] ??
        item['stockQuantity'] ??
        0;
    if (q is num) return q.toInt();
    return int.tryParse(q.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // تحميل المنتجات: جملة من المستودعات الرئيسية، مفرد من المستودع الفرعي.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args is Map && args['customerId'] != null) {
        controller.selectedInvoiceCustomerId.value =
            args['customerId'].toString();
      }
      if (controller.preferWholesaleUnitPrices) {
        if (!controller.isLoadingMainProducts.value &&
            controller.mainWarehouses.isEmpty &&
            controller.mainWarehouseProducts.isEmpty) {
          controller.loadMainWarehousesAndProductsForInvoice();
        }
      } else if (controller.warehouseItems.isEmpty &&
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إنشاء فاتورة'),
            if (controller.preferWholesaleUnitPrices)
              Text(
                'منتجات المستودعات الرئيسية — اختر المستودع ثم أضف للسلة',
                style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w500),
              ),
          ],
        ),
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
          Obx(() {
            if (!controller.preferWholesaleUnitPrices) {
              return const SizedBox.shrink();
            }
            if (controller.mainWarehouses.isEmpty) {
              return const SizedBox.shrink();
            }
            final ids = controller.mainWarehouses
                .map((w) => w['id']?.toString())
                .whereType<String>()
                .where((e) => e.isNotEmpty)
                .toList();
            final current = controller.selectedMainWarehouseIdForInvoice.value;
            final effective =
                (current != null && ids.contains(current)) ? current : ids.first;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'المستودع الرئيسي',
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                value: effective,
                items: controller.mainWarehouses
                    .map((w) => DropdownMenuItem<String>(
                          value: w['id']?.toString(),
                          child: Text(
                            (w['name'] ?? w['id'] ?? '').toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .where((e) => e.value != null && e.value!.isNotEmpty)
                    .cast<DropdownMenuItem<String>>()
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  controller.selectedMainWarehouseIdForInvoice.value = v;
                  controller.refreshMainWarehouseProductsForInvoice();
                },
              ),
            );
          }),
          // ── بحث المنتجات (إكمال تلقائي + debounce 300ms) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Obx(() => DebouncedProductAutocomplete(
                  hintText: 'ابحث عن منتج لإضافته للسلة...',
                  isLoading: controller.isSearchingInvoiceProducts.value,
                  preferWholesale: controller.preferWholesaleUnitPrices,
                  onSearch: controller.searchProductsForInvoice,
                  onSelected: controller.addSearchedProductToCart,
                )),
          ),

          // ── قائمة المنتجات (عند عدم البحث) ──
          Expanded(
            child: Obx(() {
              final wholesale = controller.preferWholesaleUnitPrices;
              final loading = wholesale
                  ? controller.isLoadingMainProducts.value
                  : controller.isLoadingWarehouse.value;
              if (loading) {
                return const LoadingIndicator();
              }
              final source = wholesale
                  ? controller.mainWarehouseProducts
                  : controller.warehouseItems;
              final items = source;

              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'لا توجد منتجات',
                  subtitle: wholesale
                      ? 'لا يوجد مخزون في المستودع الرئيسي المحدد لهذا البحث.'
                      : 'لم يتم العثور على منتجات في مستودعك. اطلب نقل مخزون أولاً.',
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
                  final name =
                      (item['productName'] ?? item['name'] ?? '').toString();
                  final stock = _stock(item);
                  final price = _price(item);

                  return Obx(() {
                    final qty = controller.cartQuantityFor(productId);
                    return _ProductRow(
                      productId: productId,
                      name: name,
                      stock: stock,
                      price: price,
                      quantity: qty,
                      onIncrement: () {
                        if (productId.isEmpty) {
                          SnackbarHelper.showError('معرف المنتج غير صالح');
                          return;
                        }
                        if (stock <= 0) {
                          SnackbarHelper.showError(
                              'المنتج غير متوفر في المخزون');
                          return;
                        }
                        controller.addProductToCart(
                          productId: productId,
                          productName: name,
                          price: price,
                          maxStock: stock,
                        );
                      },
                      onDecrement: () => controller.updateCartQuantity(
                          productId, qty - 1),
                    );
                  });
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
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductRow({
    required this.productId,
    required this.name,
    required this.stock,
    required this.price,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
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
          ProductQuantityStepper(
            quantity: quantity,
            enabled: available,
            maxQuantity: stock > 0 ? stock : null,
            onAdd: onIncrement,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
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
          Obx(() {
            final approved = controller.customers
                .where((c) =>
                    c['isApproved'] != false &&
                    c['id'] != null &&
                    c['id'].toString().isNotEmpty)
                .toList();
            var selected = controller.selectedInvoiceCustomerId.value;
            if (selected != null &&
                !approved.any((c) => c['id']?.toString() == selected)) {
              selected = null;
            }
            if (approved.isEmpty) {
              return Text(
                'لا يوجد عملاء معتمدون — أضف عميلاً وانتظر موافقة الإدارة',
                style: GoogleFonts.cairo(
                    fontSize: 13, color: AppColors.textSecondary),
              );
            }
            return DropdownButtonFormField<String>(
              value: selected,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'اختر العميل',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
              ),
              items: approved.map((c) {
                final id = c['id']!.toString();
                return DropdownMenuItem(
                  value: id,
                  child: Text(
                    (c['fullName'] ?? c['storeName'] ?? '').toString(),
                    style: GoogleFonts.cairo(),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) =>
                  controller.selectedInvoiceCustomerId.value = v,
            );
          }),

          const SizedBox(height: 12),

          // ── جدولة التسليم ──
          Text('نوع التسليم',
              style: GoogleFonts.cairo(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Obx(() => Wrap(spacing: 6, children: [
                ChoiceChip(
                  label: const Text('فوري'),
                  selected: controller.invoiceScheduleType.value == 0,
                  onSelected: (_) => controller.invoiceScheduleType.value = 0,
                ),
                ChoiceChip(
                  label: const Text('مجدول'),
                  selected: controller.invoiceScheduleType.value == 1,
                  onSelected: (_) => controller.invoiceScheduleType.value = 1,
                ),
                if (controller.invoiceScheduleType.value == 1)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            controller.invoiceScheduledDate.value ??
                                now.add(const Duration(days: 1)),
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        controller.invoiceScheduledDate.value = picked;
                      }
                    },
                    icon: const Icon(Icons.event, size: 16),
                    label: Text(
                        controller.invoiceScheduledDate.value == null
                            ? 'اختر التاريخ'
                            : controller.invoiceScheduledDate.value!
                                .toIso8601String()
                                .split('T')
                                .first,
                        style: GoogleFonts.cairo(fontSize: 12)),
                  ),
              ])),
          const SizedBox(height: 12),

          // ── كود ترويجي ──
          TextField(
            decoration: InputDecoration(
              hintText: 'كود ترويجي (اختياري)',
              hintStyle: GoogleFonts.cairo(),
              prefixIcon: const Icon(Icons.local_offer_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
            onChanged: (v) => controller.invoicePromoCode.value = v,
          ),

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

  const _CartItemRow({
    required this.item,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(
                Formatters.currency(item.price),
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
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
