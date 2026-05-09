import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../settings/presentation/widgets/role_settings_tab.dart';
import '../controllers/customer_controllers.dart';
import 'customer_home_page.dart';
import 'products_page.dart';
import 'cart_page.dart';
import 'my_orders_page.dart';

class CustomerMainPage extends StatelessWidget {
  const CustomerMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = 0.obs;
    final cartController = Get.find<CartController>();

    final pages = [
      const CustomerHomePage(),
      const ProductsPage(),
      const CartPage(),
      const MyOrdersPage(),
      const RoleSettingsTab(notificationsRoute: AppRoutes.customerNotifications),
    ];

    return Obx(() => Scaffold(
          body: pages[currentIndex.value],
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex.value,
            onDestinationSelected: (i) => currentIndex.value = i,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'الرئيسية',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'المنتجات',
              ),
              NavigationDestination(
                icon: Obx(() => Badge(
                      isLabelVisible: cartController.itemCount > 0,
                      label: Text('${cartController.itemCount}', style: const TextStyle(fontSize: 10)),
                      child: const Icon(Icons.shopping_cart_outlined),
                    )),
                selectedIcon: Obx(() => Badge(
                      isLabelVisible: cartController.itemCount > 0,
                      label: Text('${cartController.itemCount}', style: const TextStyle(fontSize: 10)),
                      child: const Icon(Icons.shopping_cart_rounded),
                    )),
                label: 'السلة',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'طلباتي',
              ),
              const NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'الإعدادات',
              ),
            ],
          ),
        ));
  }
}

