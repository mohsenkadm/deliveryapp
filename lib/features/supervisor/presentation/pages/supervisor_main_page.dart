// الصفحة الرئيسية للمشرف — bottom navigation
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../controllers/supervisor_controller.dart';
import 'supervisor_reps_page.dart';
import 'supervisor_pending_customers_page.dart';
import 'supervisor_sales_report_page.dart';
import '../../../settings/presentation/widgets/role_settings_tab.dart';

class SupervisorMainPage extends StatefulWidget {
  const SupervisorMainPage({super.key});

  @override
  State<SupervisorMainPage> createState() => _SupervisorMainPageState();
}

class _SupervisorMainPageState extends State<SupervisorMainPage> {
  int _currentIndex = 0;

  static const _pages = [
    SupervisorRepsPage(),
    SupervisorPendingCustomersPage(),
    SupervisorSalesReportPage(),
    RoleSettingsTab(notificationsRoute: AppRoutes.supervisorNotifications),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupervisorController>();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
        },
        destinations: [
          NavigationDestination(
            icon: Obx(() => Badge(
                  isLabelVisible: ctrl.reps.isNotEmpty,
                  label: Text('${ctrl.reps.length}'),
                  child: const Icon(Icons.people_outline),
                )),
            selectedIcon: const Icon(Icons.people),
            label: 'المندوبون',
          ),
          NavigationDestination(
            icon: Obx(() => Badge(
                  isLabelVisible: ctrl.pendingCustomers.isNotEmpty,
                  label: Text('${ctrl.pendingCustomers.length}'),
                  child: const Icon(Icons.person_add_outlined),
                )),
            selectedIcon: const Icon(Icons.person_add),
            label: 'موافقات',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'التقارير',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
