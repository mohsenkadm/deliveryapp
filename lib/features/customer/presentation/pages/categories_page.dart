import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/customer_controllers.dart';
import '../../../../core/routes/app_routes.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<CustomerHomeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('الأقسام')),
      body: Obx(() {
        if (homeController.isLoading.value) return const LoadingIndicator();
        if (homeController.categories.isEmpty) return const EmptyState(title: 'لا توجد أقسام', icon: Icons.category_outlined);

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: homeController.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final cat = homeController.categories[index];
            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Theme.of(context).cardTheme.color,
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(cat.name),
              subtitle: Text('${cat.productCount} منتج'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.toNamed(AppRoutes.products, arguments: {'categoryId': cat.id}),
            );
          },
        );
      }),
    );
  }
}
