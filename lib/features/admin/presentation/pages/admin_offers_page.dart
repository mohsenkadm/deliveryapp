// إدارة العروض والترويج — للأدمن (يدعم كل أنواع OfferType من الـ backend)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/offers_controller.dart';

class AdminOffersPage extends StatelessWidget {
  const AdminOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(OffersController(), tag: 'offers');
    return Scaffold(
      appBar: AppBar(
        title: Text('العروض والترويج',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: ctrl.load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text('عرض جديد', style: GoogleFonts.cairo()),
        onPressed: () => _openSheet(context, ctrl, null),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) {
                      ctrl.search.value = v;
                      ctrl.load();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => DropdownButton<bool?>(
                      value: ctrl.filterActive.value,
                      hint: Text('الكل', style: GoogleFonts.cairo()),
                      items: [
                        DropdownMenuItem(
                            value: null,
                            child: Text('الكل', style: GoogleFonts.cairo())),
                        DropdownMenuItem(
                            value: true,
                            child:
                                Text('نشط', style: GoogleFonts.cairo())),
                        DropdownMenuItem(
                            value: false,
                            child: Text('متوقف', style: GoogleFonts.cairo())),
                      ],
                      onChanged: (v) {
                        ctrl.filterActive.value = v;
                        ctrl.load();
                      },
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) return const LoadingIndicator();
              if (ctrl.offers.isEmpty) {
                return const EmptyState(
                  icon: Icons.local_offer_outlined,
                  title: 'لا توجد عروض',
                  subtitle: 'اضغط زر "عرض جديد" لإضافة عرض',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: ctrl.offers.length,
                itemBuilder: (ctx, i) {
                  final o = ctrl.offers[i];
                  final type = OfferTypeKind.fromValue(
                      ((o['offerType'] as num?) ?? 0).toInt());
                  final active = (o['isActive'] as bool?) ?? true;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: active
                            ? AppColors.primaryLight.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.15),
                        child: Icon(_iconForType(type),
                            color: active
                                ? AppColors.primaryLight
                                : Colors.grey),
                      ),
                      title: Text(o['name'] ?? '',
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(type.labelAr,
                              style: GoogleFonts.cairo(fontSize: 12)),
                          if (o['promoCode'] != null &&
                              (o['promoCode'] as String).isNotEmpty)
                            Text('الكود: ${o['promoCode']}',
                                style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: AppColors.primaryLight)),
                          if (o['endDate'] != null)
                            Text(
                                'ينتهي: ${Formatters.date(DateTime.tryParse(o['endDate'].toString()) ?? DateTime.now())}',
                                style: GoogleFonts.cairo(fontSize: 12)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') {
                            _openSheet(context, ctrl, o);
                          } else if (v == 'delete') {
                            _confirmDelete(context, ctrl, o['id'].toString());
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'edit', child: Text('تعديل')),
                          const PopupMenuItem(
                              value: 'delete', child: Text('حذف')),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(OfferTypeKind t) {
    switch (t) {
      case OfferTypeKind.percentage:
        return Icons.percent;
      case OfferTypeKind.fixedAmount:
        return Icons.attach_money;
      case OfferTypeKind.buyXGetY:
        return Icons.add_shopping_cart;
      case OfferTypeKind.freeShipping:
        return Icons.local_shipping;
      case OfferTypeKind.bundle:
        return Icons.inventory_2;
      case OfferTypeKind.promoCode:
        return Icons.confirmation_number;
    }
  }

  void _openSheet(BuildContext ctx, OffersController ctrl,
      Map<String, dynamic>? existing) {
    ctrl.clearForm();
    final isEdit = existing != null;
    if (isEdit) ctrl.fill(existing);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: ctrl.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(isEdit ? 'تعديل العرض' : 'عرض جديد',
                    style: GoogleFonts.cairo(
                        fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: ctrl.nameCtrl,
                  label: 'اسم العرض',
                  prefixIcon: Icons.label_outline,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: ctrl.descCtrl,
                  label: 'الوصف',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Obx(() => DropdownButtonFormField<OfferTypeKind>(
                      initialValue: ctrl.offerType.value,
                      items: OfferTypeKind.values
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.labelAr,
                                  style: GoogleFonts.cairo())))
                          .toList(),
                      onChanged: (v) =>
                          v != null ? ctrl.offerType.value = v : null,
                      decoration: InputDecoration(
                        labelText: 'نوع العرض',
                        labelStyle: GoogleFonts.cairo(),
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    )),
                const SizedBox(height: 12),
                Obx(() => DropdownButtonFormField<String>(
                      initialValue: ctrl.selectedProductId.value,
                      items: ctrl.products
                          .map<DropdownMenuItem<String>>((p) =>
                              DropdownMenuItem(
                                  value: p['id'].toString(),
                                  child: Text(p['name'] ?? '',
                                      style: GoogleFonts.cairo())))
                          .toList(),
                      onChanged: (v) => ctrl.selectedProductId.value = v,
                      decoration: InputDecoration(
                        labelText: 'المنتج (اختياري)',
                        labelStyle: GoogleFonts.cairo(),
                        prefixIcon:
                            const Icon(Icons.inventory_2_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    )),
                const SizedBox(height: 12),
                Obx(() => Column(
                      children: [
                        if (ctrl.offerType.value ==
                                OfferTypeKind.percentage ||
                            ctrl.offerType.value ==
                                OfferTypeKind.fixedAmount ||
                            ctrl.offerType.value ==
                                OfferTypeKind.promoCode)
                          CustomTextField(
                            controller: ctrl.discountValueCtrl,
                            label: ctrl.offerType.value ==
                                    OfferTypeKind.percentage
                                ? 'نسبة الخصم %'
                                : 'قيمة الخصم',
                            prefixIcon: Icons.discount,
                            keyboardType: TextInputType.number,
                          ),
                        if (ctrl.offerType.value ==
                            OfferTypeKind.buyXGetY) ...[
                          CustomTextField(
                            controller: ctrl.minQuantityCtrl,
                            label: 'الحد الأدنى للشراء (X)',
                            prefixIcon: Icons.shopping_basket_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: ctrl.freeQuantityCtrl,
                            label: 'الكمية المجانية (Y)',
                            prefixIcon: Icons.card_giftcard,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        if (ctrl.offerType.value ==
                            OfferTypeKind.promoCode) ...[
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: ctrl.promoCodeCtrl,
                            label: 'كود الخصم',
                            prefixIcon: Icons.confirmation_number,
                          ),
                        ],
                      ],
                    )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                                ctrl.startDate.value == null
                                    ? 'تاريخ البداية'
                                    : Formatters.date(ctrl.startDate.value!),
                                style: GoogleFonts.cairo(fontSize: 12)),
                            onPressed: () => _pickDate(ctx, ctrl.startDate),
                          )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => OutlinedButton.icon(
                            icon: const Icon(Icons.event, size: 16),
                            label: Text(
                                ctrl.endDate.value == null
                                    ? 'تاريخ الانتهاء'
                                    : Formatters.date(ctrl.endDate.value!),
                                style: GoogleFonts.cairo(fontSize: 12)),
                            onPressed: () => _pickDate(ctx, ctrl.endDate),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() => SwitchListTile(
                      value: ctrl.isActive.value,
                      onChanged: (v) => ctrl.isActive.value = v,
                      title: Text('عرض نشط', style: GoogleFonts.cairo()),
                    )),
                const SizedBox(height: 20),
                Obx(() => CustomButton(
                      text: isEdit ? 'حفظ التعديلات' : 'إضافة العرض',
                      isLoading: ctrl.isSubmitting.value,
                      onPressed: () async {
                        final ok = isEdit
                            ? await ctrl.save(existing['id'].toString())
                            : await ctrl.create();
                        if (ok) Get.back();
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _pickDate(
      BuildContext ctx, Rxn<DateTime> target) async {
    final picked = await showDatePicker(
      context: ctx,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDate: target.value ?? DateTime.now(),
    );
    if (picked != null) target.value = picked;
  }

  void _confirmDelete(
      BuildContext ctx, OffersController ctrl, String id) {
    Get.dialog(AlertDialog(
      title: Text('حذف العرض', style: GoogleFonts.cairo()),
      content: Text('هل تريد حذف هذا العرض؟', style: GoogleFonts.cairo()),
      actions: [
        TextButton(
            onPressed: Get.back,
            child: Text('إلغاء', style: GoogleFonts.cairo())),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            Get.back();
            ctrl.remove(id);
          },
          child: Text('حذف', style: GoogleFonts.cairo()),
        ),
      ],
    ));
  }
}
