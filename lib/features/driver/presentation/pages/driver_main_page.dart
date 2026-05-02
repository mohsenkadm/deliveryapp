import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'driver_home_page.dart';
import 'assigned_orders_page.dart';
import 'completed_deliveries_page.dart';
import 'driver_summary_page.dart';

class DriverMainPage extends StatelessWidget {
  const DriverMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = 0.obs;
    final pages = [
      const DriverHomePage(),
      const AssignedOrdersPage(),
      const CompletedDeliveriesPage(),
      const DriverSummaryPage(),
      const _DriverSettingsTab(),
    ];

    return Obx(() => Scaffold(
          body: pages[currentIndex.value],
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex.value,
            onDestinationSelected: (i) => currentIndex.value = i,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
              NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'الطلبات'),
              NavigationDestination(icon: Icon(Icons.check_circle_outlined), selectedIcon: Icon(Icons.check_circle_rounded), label: 'المكتملة'),
              NavigationDestination(icon: Icon(Icons.bar_chart_rounded), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'الملخص'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'الإعدادات'),
            ],
          ),
        ));
  }
}

class _DriverSettingsTab extends StatelessWidget {
  const _DriverSettingsTab();

  @override
  Widget build(BuildContext context) {
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
            onTap: () => Get.find<AuthController>().logout(),
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
