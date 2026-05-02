import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/admin_controllers.dart';

class AdminMainPage extends StatelessWidget {
  const AdminMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AdminScaffold();
  }
}

class _AdminScaffold extends GetView<AdminDashboardController> {
  const _AdminScaffold();

  @override
  Widget build(BuildContext context) {
    final currentIndex = 0.obs;
    const pages = [
      _AdminDashboard(),
      _AdminManagement(),
      _AdminNotifications(),
      _AdminSettingsTab(),
    ];

    return Scaffold(
      drawer: const _AdminDrawer(),
      body: Obx(() => pages[currentIndex.value]),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: currentIndex.value,
            onDestinationSelected: (i) => currentIndex.value = i,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'لوحة التحكم'),
              const NavigationDestination(icon: Icon(Icons.manage_accounts_outlined), selectedIcon: Icon(Icons.manage_accounts_rounded), label: 'الإدارة'),
              NavigationDestination(
                icon: Obx(() => Badge(
                      isLabelVisible: (controller.stats['pendingApprovals'] ?? 0) > 0,
                      label: Text('${controller.stats['pendingApprovals'] ?? 0}', style: const TextStyle(fontSize: 10)),
                      child: const Icon(Icons.notifications_outlined),
                    )),
                selectedIcon: const Icon(Icons.notifications_rounded),
                label: 'الإشعارات',
              ),
              const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'الإعدادات'),
            ],
          )),
    );
  }
}

// ── Admin Dashboard ──
class _AdminDashboard extends GetView<AdminDashboardController> {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(ctx).openDrawer())),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              child: Text('👑', style: GoogleFonts.cairo(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('لوحة التحكم', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                  Text(authService.userName, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Obx(() {
            final pending = controller.stats['pendingApprovals'] ?? 0;
            return Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending', style: const TextStyle(fontSize: 10)),
              child: IconButton(
                icon: const Icon(Icons.pending_actions_rounded),
                onPressed: () => Get.toNamed(AppRoutes.pendingApprovals),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Stats Grid (2x2) ──
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _AdminStatCard(icon: Icons.attach_money_rounded, label: 'إجمالي المبيعات', value: '${controller.stats['totalSales'] ?? 0}', color: AppColors.successLight),
                  _AdminStatCard(icon: Icons.shopping_bag_rounded, label: 'عدد الطلبات', value: '${controller.stats['totalOrders'] ?? 0}', color: AppColors.primaryLight),
                  _AdminStatCard(icon: Icons.local_shipping_rounded, label: 'توصيلات نشطة', value: '${controller.stats['activeDeliveries'] ?? 0}', color: AppColors.secondaryLight),
                  _AdminStatCard(icon: Icons.money_off_rounded, label: 'الديون', value: '${controller.stats['totalDebts'] ?? 0}', color: AppColors.errorLight),
                ],
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 24),

              // ── Sales Chart (last 7 days) ──
              Text('مبيعات آخر 7 أيام', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
                ),
                child: _SalesChart(salesData: controller.weeklySales),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),

              // ── Quick Actions ──
              Text('إجراءات سريعة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.3,
                children: [
                  _QuickAction(icon: Icons.person_add_rounded, label: 'إضافة عميل', color: AppColors.primaryLight, onTap: () => Get.toNamed('/admin/customers')),
                  _QuickAction(icon: Icons.support_agent_rounded, label: 'إضافة مندوب', color: AppColors.secondaryLight, onTap: () => Get.toNamed('/admin/representatives')),
                  _QuickAction(icon: Icons.local_shipping_rounded, label: 'إضافة سائق', color: AppColors.inProgress, onTap: () => Get.toNamed('/admin/drivers')),
                  _QuickAction(icon: Icons.inventory_2_rounded, label: 'إضافة منتج', color: AppColors.successLight, onTap: () => Get.toNamed('/admin/products')),
                ],
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),

              // ── Pending Approvals Alert ──
              Obx(() {
                final pending = controller.stats['pendingApprovals'] ?? 0;
                if (pending <= 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.warningLight.withValues(alpha: 0.3)),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.pending_actions_rounded, color: AppColors.warningLight, size: 32),
                    title: Text('$pending طلب موافقة معلق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    subtitle: Text('انقر للمراجعة', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => Get.toNamed(AppRoutes.pendingApprovals),
                  ),
                ).animate().fadeIn(delay: 600.ms);
              }),
            ],
          ),
        );
      }),
    );
  }
}

// ── Sales Chart Widget ──
class _SalesChart extends StatelessWidget {
  final List<double> salesData;

  const _SalesChart({required this.salesData});

  @override
  Widget build(BuildContext context) {
    final days = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
    final data = salesData.isEmpty ? List.filled(7, 0.0) : salesData;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (data.reduce((a, b) => a > b ? a : b) * 1.3).clamp(100, double.infinity),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(0)} د.ع',
                GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(days[idx], style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textSecondary)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                color: AppColors.primaryLight,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Admin Drawer ──
class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF8B5CF6), const Color(0xFF8B5CF6).withValues(alpha: 0.7)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Text('👑', style: TextStyle(fontSize: 28))),
                const SizedBox(height: 12),
                Text(authService.userName, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('مسؤول النظام', style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          _drawerTile(Icons.dashboard_rounded, 'لوحة التحكم', () => Get.back()),
          _drawerTile(Icons.people_rounded, 'إدارة العملاء', () { Get.back(); Get.toNamed('/admin/customers'); }),
          _drawerTile(Icons.inventory_2_rounded, 'إدارة المنتجات', () { Get.back(); Get.toNamed('/admin/products'); }),
          _drawerTile(Icons.category_rounded, 'إدارة الأقسام', () { Get.back(); Get.toNamed(AppRoutes.manageCategories); }),
          _drawerTile(Icons.warehouse_rounded, 'إدارة المخازن', () { Get.back(); Get.toNamed(AppRoutes.manageWarehouses); }),
          _drawerTile(Icons.receipt_long_rounded, 'الفواتير', () { Get.back(); Get.toNamed(AppRoutes.manageInvoices); }),
          _drawerTile(Icons.support_agent_rounded, 'المندوبين', () { Get.back(); Get.toNamed(AppRoutes.manageRepresentatives); }),
          _drawerTile(Icons.delivery_dining_rounded, 'السائقين', () { Get.back(); Get.toNamed(AppRoutes.manageDrivers); }),
          _drawerTile(Icons.money_off_rounded, 'الديون والتسويات', () { Get.back(); Get.toNamed('/admin/debts'); }),
          const Divider(),
          _drawerTile(Icons.pending_actions_rounded, 'طلبات الموافقة', () { Get.back(); Get.toNamed(AppRoutes.pendingApprovals); }),
          _drawerTile(Icons.analytics_rounded, 'التحليلات', () { Get.back(); Get.toNamed(AppRoutes.analytics); }),
          _drawerTile(Icons.history_rounded, 'سجل النشاط', () { Get.back(); Get.toNamed(AppRoutes.activityLogs); }),
          const Divider(),
          _drawerTile(Icons.settings_rounded, 'الإعدادات', () { Get.back(); Get.toNamed(AppRoutes.settings); }),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('تسجيل الخروج', style: GoogleFonts.cairo(color: Colors.red)),
            onTap: () { Get.back(); Get.find<AuthController>().logout(); },
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: GoogleFonts.cairo(fontSize: 14)),
      onTap: onTap,
    );
  }
}

// ── Admin Management Tab ──
class _AdminManagement extends StatelessWidget {
  const _AdminManagement();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الإدارة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _ManagementCard(icon: Icons.people_rounded, title: 'إدارة العملاء', subtitle: 'عرض وإدارة العملاء', color: AppColors.primaryLight, onTap: () => Get.toNamed('/admin/customers')),
          _ManagementCard(icon: Icons.inventory_2_rounded, title: 'إدارة المنتجات', subtitle: 'إضافة وتعديل المنتجات', color: AppColors.successLight, onTap: () => Get.toNamed('/admin/products')),
          _ManagementCard(icon: Icons.category_rounded, title: 'إدارة الأقسام', subtitle: 'تصنيف المنتجات', color: AppColors.accentLight, onTap: () => Get.toNamed(AppRoutes.manageCategories)),
          _ManagementCard(icon: Icons.warehouse_rounded, title: 'إدارة المخازن', subtitle: 'المخزون والمستودعات', color: Colors.teal, onTap: () => Get.toNamed(AppRoutes.manageWarehouses)),
          _ManagementCard(icon: Icons.storage_rounded, title: 'إدارة المخزون', subtitle: 'كميات المخزون', color: Colors.indigo, onTap: () => Get.toNamed(AppRoutes.manageInventory)),
          _ManagementCard(icon: Icons.receipt_long_rounded, title: 'الفواتير', subtitle: 'جميع الفواتير', color: AppColors.secondaryLight, onTap: () => Get.toNamed(AppRoutes.manageInvoices)),
          _ManagementCard(icon: Icons.support_agent_rounded, title: 'المندوبين', subtitle: 'إدارة المندوبين', color: Colors.purple, onTap: () => Get.toNamed(AppRoutes.manageRepresentatives)),
          _ManagementCard(icon: Icons.delivery_dining_rounded, title: 'السائقين', subtitle: 'إدارة السائقين', color: AppColors.inProgress, onTap: () => Get.toNamed(AppRoutes.manageDrivers)),
          _ManagementCard(icon: Icons.money_off_rounded, title: 'الديون والتسويات', subtitle: 'إدارة الديون', color: AppColors.errorLight, onTap: () => Get.toNamed(AppRoutes.debtsSettlement)),
          _ManagementCard(icon: Icons.pending_actions_rounded, title: 'طلبات الموافقة', subtitle: 'الطلبات المعلقة', color: AppColors.warningLight, onTap: () => Get.toNamed(AppRoutes.pendingApprovals)),
        ],
      ),
    );
  }
}

// ── Admin Notifications Tab ──
class _AdminNotifications extends StatelessWidget {
  const _AdminNotifications();

  @override
  Widget build(BuildContext context) {
    final service = Get.find<NotificationService>();
    service.fetchNotifications();

    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: service.fetchNotifications,
          ),
        ],
      ),
      body: Obx(() {
        if (service.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('لا توجد إشعارات', style: GoogleFonts.cairo(color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: service.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final n = service.notifications[i];
            final isRead = n['isRead'] == true;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isRead
                    ? Theme.of(context).cardTheme.color
                    : AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: isRead
                    ? null
                    : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => service.markAsRead(n['id'].toString()),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n['title'] ?? '', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(n['body'] ?? n['message'] ?? '', style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.timeAgo(DateTime.tryParse(n['createdAt'] ?? '') ?? DateTime.now()),
                            style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Admin Settings Tab ──
class _AdminSettingsTab extends StatelessWidget {
  const _AdminSettingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: ListView(
        children: [
          _settingsTile(Icons.person_outline, 'الملف الشخصي', () => Get.toNamed(AppRoutes.profile)),
          _settingsTile(Icons.lock_outline, 'تغيير كلمة المرور', () => Get.toNamed(AppRoutes.changePassword)),
          _settingsTile(Icons.dark_mode_outlined, 'المظهر', () => Get.toNamed(AppRoutes.themeSettings)),
          const Divider(height: 1),
          _settingsTile(Icons.info_outline, 'حول التطبيق', () => Get.toNamed(AppRoutes.aboutApp)),
          _settingsTile(Icons.privacy_tip_outlined, 'سياسة الخصوصية', () => Get.toNamed(AppRoutes.privacyPolicy)),
          _settingsTile(Icons.support_agent_outlined, 'الدعم الفني', () => Get.toNamed(AppRoutes.technicalSupport)),
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

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.cairo()),
      trailing: const Icon(Icons.chevron_left),
      onTap: onTap,
    );
  }
}

// ── Shared Widgets ──

class _AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AdminStatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: color))),
          ],
        ),
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_left, size: 20),
        onTap: onTap,
      ),
    );
  }
}
