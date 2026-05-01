import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
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
      const _SettingsTab(),
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

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    // Re-use settings from the settings feature
    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: ListView(
        children: [
          _tile(Icons.person_outline, 'الملف الشخصي', () => Get.toNamed(AppRoutes.profile)),
          _tile(Icons.lock_outline, 'تغيير كلمة المرور', () => Get.toNamed(AppRoutes.changePassword)),
          _tile(Icons.dark_mode_outlined, 'المظهر', () => Get.toNamed(AppRoutes.themeSettings)),
          const Divider(height: 1),
          _tile(Icons.info_outline, 'حول التطبيق', () => Get.toNamed(AppRoutes.aboutApp)),
          _tile(Icons.privacy_tip_outlined, 'سياسة الخصوصية', () => Get.toNamed(AppRoutes.privacyPolicy)),
          _tile(Icons.support_agent_outlined, 'الدعم الفني', () => Get.toNamed(AppRoutes.technicalSupport)),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('تسجيل الخروج', style: GoogleFonts.cairo(color: Colors.red)),
            trailing: const Icon(Icons.chevron_left, color: Colors.red),
            onTap: () => Get.find<dynamic>().logout(),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.cairo()),
      trailing: const Icon(Icons.chevron_left),
      onTap: onTap,
    );
  }
}
