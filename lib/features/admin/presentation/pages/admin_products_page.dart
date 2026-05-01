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
import '../controllers/admin_controllers.dart';

class AdminProductsPage extends GetView<AdminProductsController> {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final search = ''.obs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إدارة المنتجات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'إضافة منتج',
            onPressed: () => _showProductSheet(context, null),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => search.value = v,
              style: GoogleFonts.cairo(),
              decoration: InputDecoration(
                hintText: 'بحث باسم المنتج...',
                hintStyle:
                    GoogleFonts.cairo(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingIndicator();
              final filtered = controller.products.where((p) {
                final q = search.value.toLowerCase();
                return q.isEmpty ||
                    (p['name'] ?? '').toString().toLowerCase().contains(q);
              }).toList();
              if (filtered.isEmpty) {
                return const EmptyState(
                    title: 'لا توجد منتجات',
                    icon: Icons.inventory_2_outlined);
              }
              return RefreshIndicator(
                onRefresh: controller.loadData,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ProductCard(
                    product: filtered[i],
                    onEdit: () =>
                        _showProductSheet(context, filtered[i]),
                    onDelete: () => _confirmDelete(
                        context, filtered[i]['id'].toString()),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    Get.dialog(AlertDialog(
      title: Text('تأكيد الحذف', style: GoogleFonts.cairo()),
      content: Text('هل أنت متأكد من حذف هذا المنتج؟',
          style: GoogleFonts.cairo()),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: GoogleFonts.cairo())),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.deleteProduct(id);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('حذف', style: GoogleFonts.cairo()),
        ),
      ],
    ));
  }

  void _showProductSheet(
      BuildContext context, Map<String, dynamic>? existing) {
    controller.clearForm();
    final isEdit = existing != null;
    if (isEdit) {
      controller.nameController.text =
          existing['name']?.toString() ?? '';
      controller.priceController.text =
          existing['price']?.toString() ?? '';
      controller.descriptionController.text =
          existing['description']?.toString() ?? '';
      controller.selectedCategoryId.value =
          existing['categoryId']?.toString();
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(isEdit ? 'تعديل المنتج' : 'إضافة منتج',
                    style: GoogleFonts.cairo(
                        fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: controller.nameController,
                  label: 'اسم المنتج',
                  prefixIcon: Icons.inventory_2_outlined,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: controller.priceController,
                  label: 'السعر',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: controller.descriptionController,
                  label: 'الوصف',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Obx(() => DropdownButtonFormField<String>(
                      initialValue:
                          controller.selectedCategoryId.value,
                      decoration: InputDecoration(
                        labelText: 'القسم',
                        labelStyle: GoogleFonts.cairo(),
                        prefixIcon:
                            const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: controller.categories
                          .map((c) => DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Text(c['name'] ?? '',
                                  style: GoogleFonts.cairo())))
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedCategoryId.value = v,
                    )),
                const SizedBox(height: 20),
                Obx(() => CustomButton(
                      text: isEdit ? 'حفظ التعديلات' : 'إضافة المنتج',
                      onPressed: isEdit
                          ? () => controller.updateProduct(
                              existing['id'].toString())
                          : controller.createProduct,
                      isLoading: controller.isSubmitting.value,
                    )),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ──────────────────────────────────────────────────────
// بطاقة المنتج
// ──────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard(
      {required this.product,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? '';
    final price = (product['price'] ?? 0).toDouble();
    final category = product['categoryName'] ?? product['category']?['name'] ?? '';
    final isAvailable = product['isAvailable'] != false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: AppColors.primaryLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.cairo(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                if (category.isNotEmpty)
                  Text(category,
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                Row(children: [
                  Text(Formatters.currency(price),
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successLight)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isAvailable
                              ? AppColors.successLight
                              : AppColors.errorLight)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(isAvailable ? 'متوفر' : 'غير متوفر',
                        style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? AppColors.successLight
                                : AppColors.errorLight)),
                  ),
                ]),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 20, color: AppColors.primaryLight),
                onPressed: onEdit,
                tooltip: 'تعديل',
                constraints: const BoxConstraints(
                    minWidth: 32, minHeight: 32),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.errorLight),
                onPressed: onDelete,
                tooltip: 'حذف',
                constraints: const BoxConstraints(
                    minWidth: 32, minHeight: 32),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
