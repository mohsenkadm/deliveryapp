import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../settings/presentation/widgets/role_settings_tab.dart';
import '../controllers/driver_controllers.dart';
import 'assigned_orders_page.dart';
import 'completed_deliveries_page.dart';
import 'driver_home_page.dart';
import 'driver_summary_page.dart';

class DriverMainPage extends StatefulWidget {
  const DriverMainPage({super.key});

  @override
  State<DriverMainPage> createState() => _DriverMainPageState();
}

class _DriverMainPageState extends State<DriverMainPage> {
  final _tabIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DriverHomePage(),
      const AssignedOrdersPage(),
      const CompletedDeliveriesPage(),
      const DriverSummaryPage(),
      const RoleSettingsTab(notificationsRoute: AppRoutes.driverNotifications),
    ];

    return Obx(() {
      final idx = _tabIndex.value.clamp(0, pages.length - 1);
      return Scaffold(
        body: IndexedStack(
          index: idx,
          sizing: StackFit.expand,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) {
            _tabIndex.value = i;
            // تبويب «الطلبات» — إعادة تحميل التوصيلات النشطة فوراً
            if (i == 1) {
              try {
                Get.find<DriverHomeController>().loadData();
              } catch (_) {}
            }
            if (i == 2) {
              try {
                Get.find<DriverHomeController>().loadCompletedDeliveries();
              } catch (_) {}
            }
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'الرئيسية'),
            NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment_rounded),
                label: 'الطلبات'),
            NavigationDestination(
                icon: Icon(Icons.check_circle_outlined),
                selectedIcon: Icon(Icons.check_circle_rounded),
                label: 'المكتملة'),
            NavigationDestination(
                icon: Icon(Icons.bar_chart_rounded),
                selectedIcon: Icon(Icons.bar_chart_rounded),
                label: 'الملخص'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'الإعدادات'),
          ],
        ),
      );
    });
  }
}
