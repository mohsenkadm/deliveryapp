import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/admin_controllers.dart';

class AdminProductsPage extends GetView<AdminProductsController> {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المنتجات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.products.isEmpty) {
          return const Center(child: Text('لا توجد منتجات'));
        }
        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView.builder(
            itemCount: controller.products.length,
            itemBuilder: (_, i) {
              final p = controller.products[i];
              return ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(p['name'] ?? ''),
                subtitle: Text('${p['price'] ?? 0} د.ع'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteProduct(p['id'].toString()),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showAddProductSheet(BuildContext context) {
    controller.clearForm();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('إضافة منتج', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                CustomTextField(controller: controller.nameController, label: 'اسم المنتج', validator: Validators.required),
                const SizedBox(height: 12),
                CustomTextField(controller: controller.priceController, label: 'السعر', keyboardType: TextInputType.number, validator: Validators.required),
                const SizedBox(height: 12),
                CustomTextField(controller: controller.descriptionController, label: 'الوصف', maxLines: 3),
                const SizedBox(height: 12),
                Obx(() => DropdownButtonFormField<String>(
                      initialValue: controller.selectedCategoryId.value,
                      decoration: const InputDecoration(labelText: 'القسم'),
                      items: controller.categories.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? ''))).toList(),
                      onChanged: (v) => controller.selectedCategoryId.value = v,
                    )),
                const SizedBox(height: 16),
                Obx(() => CustomButton(text: 'إضافة', onPressed: controller.createProduct, isLoading: controller.isSubmitting.value)),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
