import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
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
      appBar: AppBar(
        title: const Text('المنتجات'),
        actions: [
          Obx(() => Badge(
                isLabelVisible: cartController.itemCount > 0,
                label: Text('${cartController.itemCount}',
                    style: const TextStyle(fontSize: 10)),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Get.toNamed(AppRoutes.cart),
                ),
              )),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── شريط البحث ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                hintStyle: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          controller.onSearchChanged('');
                        },
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),

          // ── فلتر التصنيفات ──
          SizedBox(
            height: 52,
            child: Obx(() => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: homeController.categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return Obx(() => CategoryChip(
                            category: const Category(id: '', name: 'الكل'),
                            isSelected: controller.selectedCategoryId.value == null,
                            onTap: () => controller.filterByCategory(null),
                          ));
                    }
                    final cat = homeController.categories[index - 1];
                    return Obx(() => CategoryChip(
                          category: cat,
                          isSelected: controller.selectedCategoryId.value == cat.id,
                          onTap: () => controller.filterByCategory(cat.id),
                        ));
                  },
                )),
          ),

          // ── فلتر "قارب على الانتهاء" ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() {
              final active = controller.nearExpiryDays.value != null;
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilterChip(
                  selected: active,
                  avatar: Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: active ? Colors.white : Colors.red,
                  ),
                  label: Text(
                    active
                        ? 'قارب على الانتهاء (${controller.nearExpiryDays.value} يوم)'
                        : 'قارب على الانتهاء',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : Colors.red,
                    ),
                  ),
                  selectedColor: Colors.red,
                  backgroundColor: Colors.red.withValues(alpha: 0.08),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                  onSelected: (_) =>
                      controller.filterByNearExpiry(active ? null : 7),
                ),
              );
            }),
          ),

          // ── شبكة المنتجات ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingIndicator();
              if (controller.products.isEmpty) {
                return EmptyState(
                  title: controller.searchQuery.value.isNotEmpty
                      ? 'لا توجد نتائج لـ "${controller.searchQuery.value}"'
                      : 'لا توجد منتجات',
                  icon: Icons.inventory_2_outlined,
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.loadProducts(reset: true),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
                        !controller.isLoadingMore.value &&
                        controller.hasMore) {
                      controller.loadProducts();
                    }
                    return false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: controller.products.length + (controller.isLoadingMore.value ? 2 : 0),
                    itemBuilder: (_, index) {
                      if (index >= controller.products.length) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      final product = controller.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => Get.toNamed(AppRoutes.productDetails, arguments: {'product': product}),
                        onAddToCart: () => cartController.addToCart(product),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
