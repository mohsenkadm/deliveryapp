import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/admin_controllers.dart';

class AdminInventoryPage extends GetView<AdminInventoryController> {
  const AdminInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إدارة المخزون', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadInventory(),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showUpdateInventorySheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // فلتر المستودع
          Obx(() {
            if (controller.warehouses.isEmpty) return const SizedBox.shrink();
            return Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'الكل',
                    selected: controller.selectedWarehouseId.value == null,
                    onTap: () {
                      controller.selectedWarehouseId.value = null;
                      controller.loadInventory();
                    },
                  ),
                  ...controller.warehouses.map((w) {
                    final id = w['id']?.toString();
                    return _FilterChip(
                      label: w['name'] ?? 'مستودع',
                      selected: controller.selectedWarehouseId.value == id,
                      onTap: () {
                        controller.selectedWarehouseId.value = id;
                        controller.loadInventory(warehouseId: id);
                      },
                    );
                  }),
                ],
              ),
            );
          }),
          // قائمة المخزون
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingIndicator();
              if (controller.inventory.isEmpty) {
                return const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'لا يوجد مخزون',
                  subtitle: 'لم يتم تسجيل أي مخزون بعد',
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.loadInventory(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.inventory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _InventoryCard(item: controller.inventory[i]),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUpdateInventorySheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('تحديث المخزون', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showUpdateInventorySheet(BuildContext context) {
    controller.clearForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UpdateInventorySheet(controller: controller),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.dividerLight,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final productName = item['productName'] ?? item['product']?['name'] ?? 'منتج';
    final warehouseName = item['warehouseName'] ?? item['warehouse']?['name'] ?? '';
    final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
    final isLow = quantity < 10;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLow
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.dividerLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (isLow ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: isLow ? AppColors.error : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (warehouseName.isNotEmpty)
                  Text(
                    warehouseName,
                    style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$quantity',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isLow ? AppColors.error : AppColors.primary,
                ),
              ),
              Text(
                'وحدة',
                style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary),
              ),
              if (isLow)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'مخزون منخفض',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
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

class _UpdateInventorySheet extends StatelessWidget {
  final AdminInventoryController controller;

  const _UpdateInventorySheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تحديث المخزون',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              // اختيار المستودع
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedWarehouseId.value,
                    decoration: InputDecoration(
                      labelText: 'المستودع',
                      prefixIcon: const Icon(Icons.warehouse_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: controller.warehouses.map((w) {
                      return DropdownMenuItem<String>(
                        value: w['id']?.toString(),
                        child: Text(w['name'] ?? 'مستودع', style: GoogleFonts.cairo()),
                      );
                    }).toList(),
                    onChanged: (v) => controller.selectedWarehouseId.value = v,
                    validator: (v) => v == null ? 'يرجى اختيار المستودع' : null,
                  )),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.productIdController,
                label: 'معرف المنتج (Product ID)',
                prefixIcon: Icons.qr_code_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.quantityController,
                label: 'الكمية',
                prefixIcon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'مطلوب';
                  if (int.tryParse(v) == null) return 'أدخل رقماً صحيحاً';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: 'تحديث المخزون',
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.updateInventory,
                  )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
