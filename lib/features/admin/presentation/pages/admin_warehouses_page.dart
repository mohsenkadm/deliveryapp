import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminWarehousesPage extends StatefulWidget {
  const AdminWarehousesPage({super.key});

  @override
  State<AdminWarehousesPage> createState() => _AdminWarehousesPageState();
}

class _AdminWarehousesPageState extends State<AdminWarehousesPage> {
  late final AdminRemoteDataSource _ds;
  final _warehouses = <Map<String, dynamic>>[].obs;
  final _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    _load();
  }

  Future<void> _load() async {
    _isLoading.value = true;
    try {
      _warehouses.value = await _ds.getAllWarehouses();
    } catch (_) {
      SnackbarHelper.showError('فشل تحميل المخازن');
    }
    _isLoading.value = false;
  }

  Future<void> _confirmDelete(Map<String, dynamic> w) async {
    final name = (w['name'] ?? 'المخزن').toString();
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الحذف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text('هل تريد حذف "$name"؟', style: GoogleFonts.cairo()),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('إلغاء', style: GoogleFonts.cairo())),
          TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorLight),
              child: Text('حذف', style: GoogleFonts.cairo())),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _ds.deleteWarehouse(w['id'].toString());
      SnackbarHelper.showSuccess('تم حذف المخزن');
      _load();
    } catch (_) {
      SnackbarHelper.showError('فشل حذف المخزن');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إدارة المخازن', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWarehouseDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('مخزن جديد', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (_isLoading.value) return const LoadingIndicator();
        if (_warehouses.isEmpty) {
          return const EmptyState(
            title: 'لا توجد مخازن',
            subtitle: 'أضف مخازن لإدارة المخزون',
            icon: Icons.warehouse_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _warehouses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _WarehouseCard(
              warehouse: _warehouses[i],
              onEdit: () => _showWarehouseDialog(context, existing: _warehouses[i]),
              onDelete: () => _confirmDelete(_warehouses[i]),
            ),
          ),
        );
      }),
    );
  }

  void _showWarehouseDialog(BuildContext context, {Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final locationCtrl = TextEditingController(text: existing?['location'] ?? '');
    final capacityCtrl = TextEditingController(text: existing?['capacity']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;
    final isEdit = existing != null;

    Get.dialog(
      AlertDialog(
        title: Text(isEdit ? 'تعديل المخزن' : 'إضافة مخزن جديد',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameCtrl,
                  label: 'اسم المخزن',
                  prefixIcon: Icons.warehouse_rounded,
                  validator: (v) => v!.isEmpty ? 'اسم المخزن مطلوب' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: locationCtrl,
                  label: 'الموقع',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => v!.isEmpty ? 'الموقع مطلوب' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: capacityCtrl,
                  label: 'السعة الاستيعابية',
                  prefixIcon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('إلغاء', style: GoogleFonts.cairo())),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : () async {
              if (!formKey.currentState!.validate()) return;
              isLoading.value = true;
              try {
                final data = {
                  'name': nameCtrl.text.trim(),
                  'location': locationCtrl.text.trim(),
                  if (capacityCtrl.text.isNotEmpty) 'capacity': int.tryParse(capacityCtrl.text),
                };
                if (isEdit) {
                  await _ds.updateWarehouse(existing['id'].toString(), data);
                  SnackbarHelper.showSuccess('تم تحديث المخزن');
                } else {
                  await _ds.createWarehouse(data);
                  SnackbarHelper.showSuccess('تم إضافة المخزن');
                }
                Get.back();
                _load();
              } catch (_) {
                SnackbarHelper.showError(isEdit ? 'فشل تحديث المخزن' : 'فشل إضافة المخزن');
              }
              isLoading.value = false;
            },
            child: isLoading.value
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(isEdit ? 'حفظ' : 'إضافة', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
          )),
        ],
      ),
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  final Map<String, dynamic> warehouse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _WarehouseCard(
      {required this.warehouse,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name = warehouse['name'] ?? 'مخزن';
    final location = warehouse['location'] ?? '';
    final capacity = warehouse['capacity'];
    final itemsCount = warehouse['itemsCount'] ?? 0;
    final usagePercent = capacity != null && capacity > 0 ? (itemsCount / capacity).clamp(0.0, 1.0) as double : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warehouse_rounded, color: Colors.teal, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16)),
                    if (location.isNotEmpty)
                      Row(children: [
                        Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(location, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit, color: AppColors.primary),
              IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: AppColors.errorLight),
            ],
          ),
          if (capacity != null) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الطاقة الاستيعابية', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                Text('$itemsCount / $capacity',
                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
                        color: usagePercent > 0.8 ? AppColors.errorLight : AppColors.primary)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usagePercent,
                minHeight: 8,
                backgroundColor: AppColors.dividerLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  usagePercent > 0.8 ? AppColors.errorLight : AppColors.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text('$itemsCount صنف مخزّن', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
