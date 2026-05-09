import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../settings/presentation/widgets/role_settings_tab.dart';
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
      const RoleSettingsTab(notificationsRoute: AppRoutes.driverNotifications),
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

// Settings tab moved to shared RoleSettingsTab widget.
