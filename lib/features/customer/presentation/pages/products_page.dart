import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/customer_controllers.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../../domain/entities/customer_entities.dart';

class ProductsPage extends GetView<ProductsController> {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final homeController = Get.find<CustomerHomeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('المنتجات')),
      body: Column(
        children: [
          // Category filter
          SizedBox(
            height: 55,
            child: Obx(() => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: homeController.categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return CategoryChip(
                        category: const Category(id: '', name: 'الكل'),
                        isSelected: controller.selectedCategoryId.value?.isEmpty ?? true,
                        onTap: () => controller.filterByCategory(null),
                      );
                    }
                    final cat = homeController.categories[index - 1];
                    return CategoryChip(
                      category: cat,
                      isSelected: controller.selectedCategoryId.value == cat.id,
                      onTap: () => controller.filterByCategory(cat.id),
                    );
                  },
                )),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingIndicator();
              if (controller.products.isEmpty) {
                return const EmptyState(title: 'لا توجد منتجات', icon: Icons.inventory_2_outlined);
              }
              return RefreshIndicator(
                onRefresh: () => controller.loadProducts(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 12, mainAxisSpacing: 12,
                  ),
                  itemCount: controller.products.length,
                  itemBuilder: (_, index) {
                    final product = controller.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Get.toNamed(AppRoutes.productDetails, arguments: {'product': product}),
                      onAddToCart: () => cartController.addToCart(product),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
