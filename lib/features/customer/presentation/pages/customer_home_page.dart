import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/notification_badge.dart';
import '../controllers/customer_controllers.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';

class CustomerHomePage extends GetView<CustomerHomeController> {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final notificationService = Get.find<NotificationService>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accentLight.withValues(alpha: 0.15),
              child: Text(
                authService.userName.isNotEmpty ? authService.userName[0] : '👤',
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accentLight),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً 👋', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
                  Text(authService.userName, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Notification icon with badge
          Obx(() => NotificationBadge(
                count: notificationService.unreadCount.value,
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Get.toNamed(AppRoutes.customerNotifications),
                ),
              )),
          // Cart icon with badge
          Obx(() => Badge(
                isLabelVisible: cartController.itemCount > 0,
                label: Text('${cartController.itemCount}', style: const TextStyle(fontSize: 10)),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Get.toNamed(AppRoutes.cart),
                ),
              )),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // ── Stats cards (horizontal scroll) ──
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _MiniStatCard(
                      icon: Icons.receipt_long_rounded,
                      label: 'طلباتي',
                      value: '${controller.ordersCount}',
                      color: AppColors.primaryLight,
                      onTap: () => Get.toNamed(AppRoutes.myOrders),
                    ),
                    _MiniStatCard(
                      icon: Icons.money_off_rounded,
                      label: 'مديونياتي',
                      value: '${controller.debtsTotal.toStringAsFixed(0)} د.ع',
                      color: AppColors.errorLight,
                      onTap: () => Get.toNamed(AppRoutes.myDebts),
                    ),
                    _MiniStatCard(
                      icon: Icons.check_circle_rounded,
                      label: 'المدفوع',
                      value: '${controller.paidTotal.toStringAsFixed(0)} د.ع',
                      color: AppColors.successLight,
                    ),
                    _MiniStatCard(
                      icon: Icons.local_shipping_rounded,
                      label: 'طلبات نشطة',
                      value: '${controller.activeOrdersCount}',
                      color: AppColors.secondaryLight,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.05),
              const SizedBox(height: 20),

              // ── Categories (horizontal chips) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الأقسام', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.categories),
                      child: Text('عرض الكل', style: GoogleFonts.cairo(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final cat = controller.categories[index];
                    return CategoryChip(
                      category: cat,
                      onTap: () => Get.toNamed(AppRoutes.products, arguments: {'categoryId': cat.id}),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),

              // ── Products grid (2 columns) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المنتجات', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.products),
                      child: Text('عرض الكل', style: GoogleFonts.cairo(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.products.length > 6 ? 6 : controller.products.length,
                  itemBuilder: (_, index) {
                    final product = controller.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Get.toNamed(AppRoutes.productDetails, arguments: {'product': product}),
                      onAddToCart: () => cartController.addToCart(product),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}

/// Compact stat card for horizontal scrolling
class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
