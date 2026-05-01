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

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  late final AdminRemoteDataSource _ds;
  final _categories = <Map<String, dynamic>>[].obs;
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
      _categories.value = await _ds.getAllCategories();
    } catch (_) {
      SnackbarHelper.showError('فشل تحميل الأقسام');
    }
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إدارة الأقسام', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('قسم جديد', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (_isLoading.value) return const LoadingIndicator();
        if (_categories.isEmpty) {
          return const EmptyState(
            title: 'لا توجد أقسام',
            subtitle: 'أضف أقساماً لتصنيف المنتجات',
            icon: Icons.category_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: _load,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) => _CategoryCard(
              category: _categories[i],
              onEdit: () => _showCategoryDialog(context, existing: _categories[i]),
              onDelete: () => _deleteCategory(_categories[i]['id']?.toString() ?? ''),
            ),
          ),
        );
      }),
    );
  }

  void _showCategoryDialog(BuildContext context, {Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;
    final isEdit = existing != null;

    Get.dialog(
      AlertDialog(
        title: Text(isEdit ? 'تعديل القسم' : 'إضافة قسم جديد',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameCtrl,
                label: 'اسم القسم',
                prefixIcon: Icons.category_rounded,
                validator: (v) => v!.isEmpty ? 'اسم القسم مطلوب' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: descCtrl,
                label: 'الوصف (اختياري)',
                prefixIcon: Icons.description_outlined,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('إلغاء', style: GoogleFonts.cairo())),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : () async {
              if (!formKey.currentState!.validate()) return;
              isLoading.value = true;
              try {
                final data = {'name': nameCtrl.text.trim(), 'description': descCtrl.text.trim()};
                if (isEdit) {
                  await _ds.updateCategory(existing['id'].toString(), data);
                  SnackbarHelper.showSuccess('تم تحديث القسم');
                } else {
                  await _ds.createCategory(data);
                  SnackbarHelper.showSuccess('تم إضافة القسم');
                }
                Get.back();
                _load();
              } catch (_) {
                SnackbarHelper.showError(isEdit ? 'فشل تحديث القسم' : 'فشل إضافة القسم');
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

  Future<void> _deleteCategory(String id) async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
      title: Text('تأكيد الحذف', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      content: Text('هل تريد حذف هذا القسم؟', style: GoogleFonts.cairo()),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('إلغاء', style: GoogleFonts.cairo())),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorLight),
          onPressed: () => Get.back(result: true),
          child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
        ),
      ],
    ));
    if (confirmed != true) return;
    try {
      await _ds.deleteCategory(id);
      SnackbarHelper.showSuccess('تم حذف القسم');
      _load();
    } catch (_) {
      SnackbarHelper.showError('فشل حذف القسم');
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({required this.category, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name = category['name'] ?? 'قسم';
    final productsCount = category['productsCount'] ?? 0;
    final colors = [
      AppColors.primaryLight,
      AppColors.successLight,
      AppColors.warningLight,
      AppColors.secondaryLight,
      AppColors.accentLight,
    ];
    final colorIndex = (name.hashCode.abs()) % colors.length;
    final color = colors[colorIndex];

    return Container(
      padding: const EdgeInsets.all(14),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.category_rounded, color: color, size: 20),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (v) { if (v == 'edit') onEdit(); else onDelete(); },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit_outlined, size: 16), const SizedBox(width: 8), Text('تعديل', style: GoogleFonts.cairo())])),
                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppColors.errorLight), const SizedBox(width: 8), Text('حذف', style: GoogleFonts.cairo(color: AppColors.errorLight))])),
                ],
                child: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 18),
              ),
            ],
          ),
          const Spacer(),
          Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('$productsCount منتج', style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
