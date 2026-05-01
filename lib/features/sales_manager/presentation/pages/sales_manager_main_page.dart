// الصفحة الرئيسية لمدير المبيعات
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_manager_controller.dart';
import 'sales_manager_reps_page.dart';
import 'sales_manager_pending_page.dart';
import 'sales_manager_invoices_page.dart';
import 'sales_manager_reports_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class SalesManagerMainPage extends StatefulWidget {
  const SalesManagerMainPage({super.key});

  @override
  State<SalesManagerMainPage> createState() => _SalesManagerMainPageState();
}

class _SalesManagerMainPageState extends State<SalesManagerMainPage> {
  int _currentIndex = 0;

  final _pages = const [
    SalesManagerRepsPage(),
    SalesManagerPendingPage(),
    SalesManagerInvoicesPage(),
    SalesManagerReportsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesManagerController>();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
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
            label: 'العملاء',
          ),
          NavigationDestination(
            icon: Obx(() => Badge(
                  isLabelVisible: ctrl.pendingInvoices.isNotEmpty,
                  label: Text('${ctrl.pendingInvoices.length}'),
                  child: const Icon(Icons.receipt_long_outlined),
                )),
            selectedIcon: const Icon(Icons.receipt_long),
            label: 'الفواتير',
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
