// إدارة الفروع — للأدمن
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/branches_controller.dart';

class AdminBranchesPage extends StatelessWidget {
  const AdminBranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(BranchesController(), tag: 'branches');

    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الفروع',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: ctrl.load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text('فرع جديد', style: GoogleFonts.cairo()),
        onPressed: () => _openSheet(context, ctrl, null),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث باسم الفرع...',
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
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) return const LoadingIndicator();
              if (ctrl.branches.isEmpty) {
                return const EmptyState(
                  icon: Icons.store_mall_directory_outlined,
                  title: 'لا توجد فروع',
                  subtitle: 'اضغط زر "فرع جديد" لإضافة فرع',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: ctrl.branches.length,
                itemBuilder: (ctx, i) {
                  final b = ctrl.branches[i];
                  final active = (b['isActive'] as bool?) ?? true;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: active
                            ? AppColors.success.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.store,
                          color: active ? AppColors.success : Colors.grey,
                        ),
                      ),
                      title: Text(b['name'] ?? '',
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (b['region'] != null)
                            Text('المنطقة: ${b['region']}',
                                style: GoogleFonts.cairo(fontSize: 12)),
                          if (b['address'] != null)
                            Text('العنوان: ${b['address']}',
                                style: GoogleFonts.cairo(fontSize: 12)),
                          if (b['phone'] != null)
                            Text('الهاتف: ${b['phone']}',
                                style: GoogleFonts.cairo(fontSize: 12)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') {
                            _openSheet(context, ctrl, b);
                          } else if (v == 'delete') {
                            _confirmDelete(context, ctrl, b['id'].toString());
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

  void _openSheet(BuildContext ctx, BranchesController ctrl,
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
                Text(isEdit ? 'تعديل الفرع' : 'فرع جديد',
                    style: GoogleFonts.cairo(
                        fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: ctrl.nameCtrl,
                  label: 'اسم الفرع',
                  prefixIcon: Icons.store,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: ctrl.regionCtrl,
                  label: 'المنطقة',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: ctrl.addressCtrl,
                  label: 'العنوان',
                  prefixIcon: Icons.map_outlined,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: ctrl.phoneCtrl,
                  label: 'الهاتف',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                if (isEdit) ...[
                  const SizedBox(height: 12),
                  Obx(() => SwitchListTile(
                        value: ctrl.isActive.value,
                        onChanged: (v) => ctrl.isActive.value = v,
                        title: Text('نشط', style: GoogleFonts.cairo()),
                      )),
                ],
                const SizedBox(height: 20),
                Obx(() => CustomButton(
                      text: isEdit ? 'حفظ التعديلات' : 'إضافة الفرع',
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

  void _confirmDelete(
      BuildContext ctx, BranchesController ctrl, String id) {
    Get.dialog(AlertDialog(
      title: Text('حذف الفرع', style: GoogleFonts.cairo()),
      content: Text('هل تريد حذف هذا الفرع؟', style: GoogleFonts.cairo()),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('إلغاء', style: GoogleFonts.cairo()),
        ),
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
