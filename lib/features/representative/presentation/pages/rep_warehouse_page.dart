// صفحة مخزون المستودع الفرعي — المندوب
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/representative_controllers.dart';

class RepWarehousePage extends StatefulWidget {
  const RepWarehousePage({super.key});

  @override
  State<RepWarehousePage> createState() => _RepWarehousePageState();
}

class _RepWarehousePageState extends State<RepWarehousePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final ctrl = Get.find<RepresentativeHomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadWarehouse();
      ctrl.loadTransferOrders();
    });
  }

  @override
  void dispose() {
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
        onPressed: () => _showTransferSheet(context, ctrl),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('طلب نقل / إرجاع'),
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
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.error.withOpacity(0.15),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: qty > 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                    title: Text(item['productName'] ?? '',
                        style: AppTextStyles.titleSmall),
                    subtitle: Text(
                        'المستودع: ${item['warehouseName'] ?? ''}',
                        style: AppTextStyles.bodySmall),
                    trailing: Chip(
                      label: Text('$qty',
                          style: TextStyle(
                              color: qty > 0
                                  ? AppColors.success
                                  : AppColors.error)),
                      backgroundColor: qty > 0
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
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
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.transferOrders.length,
              itemBuilder: (ctx, i) {
                final t = ctrl.transferOrders[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title:
                        Text(t['type'] ?? t['transferType'] ?? 'نقل مخزون',
                            style: AppTextStyles.titleSmall),
                    subtitle: Text(
                        'الحالة: ${t['status'] ?? ''} • ${t['createdAt']?.toString().substring(0, 10) ?? ''}',
                        style: AppTextStyles.bodySmall),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showTransferSheet(
      BuildContext ctx, RepresentativeHomeController ctrl) {
    final productIdCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isReturn = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx2, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('طلب نقل مخزون',
                    style: AppTextStyles.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                // نوع النقل
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('طلب من الرئيسي'),
                        selected: !isReturn,
                        onSelected: (_) =>
                            setModalState(() => isReturn = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('إرجاع للرئيسي'),
                        selected: isReturn,
                        onSelected: (_) =>
                            setModalState(() => isReturn = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: productIdCtrl,
                  label: 'معرّف المنتج',
                  hint: 'أدخل معرّف المنتج',
                  prefixIcon: Icons.qr_code,
                  validator: (v) =>
                      v?.isEmpty == true ? 'الرجاء إدخال معرّف المنتج' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: qtyCtrl,
                  label: 'الكمية',
                  hint: 'أدخل الكمية',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.numbers,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'الرجاء إدخال الكمية';
                    if (int.tryParse(v!) == null || int.parse(v) <= 0) {
                      return 'كمية غير صحيحة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: notesCtrl,
                  label: 'ملاحظات (اختياري)',
                  prefixIcon: Icons.note_outlined,
                ),
                const SizedBox(height: 20),
                Obx(() => CustomButton(
                      text: isReturn ? 'تأكيد الإرجاع' : 'تأكيد الطلب',
                      isLoading: ctrl.isActing.value,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final data = {
                          'items': [
                            {
                              'productId': productIdCtrl.text,
                              'quantity': int.parse(qtyCtrl.text),
                            }
                          ],
                          if (notesCtrl.text.isNotEmpty)
                            'notes': notesCtrl.text,
                        };
                        if (isReturn) {
                          await ctrl.returnTransfer(data);
                        } else {
                          await ctrl.requestTransfer(data);
                        }
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
