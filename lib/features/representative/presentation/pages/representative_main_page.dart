import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/representative_controllers.dart';
import 'customer_invoices_page.dart';
import 'rep_debts_page.dart';
import 'rep_warehouse_page.dart';
import 'rep_payments_page.dart';

class RepresentativeMainPage extends GetView<RepresentativeHomeController> {
  const RepresentativeMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = 0.obs;
    final pages = [
      const _RepHomeTab(),
      const _MyCustomersTab(),
      const CustomerInvoicesPage(),
      const RepDebtsPage(),
      const RepWarehousePage(),
      const RepPaymentsPage(),
      const _RepSettingsTab(),
    ];

    return Obx(() => Scaffold(
          body: pages[currentIndex.value],
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex.value,
            onDestinationSelected: (i) => currentIndex.value = i,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
              NavigationDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people_rounded), label: 'عملائي'),
              NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'الفواتير'),
              NavigationDestination(icon: Icon(Icons.money_off_csred_outlined), selectedIcon: Icon(Icons.money_off_csred_rounded), label: 'الديون'),
              NavigationDestination(icon: Icon(Icons.warehouse_outlined), selectedIcon: Icon(Icons.warehouse_rounded), label: 'المستودع'),
              NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet_rounded), label: 'السجلات'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'الإعدادات'),
            ],
          ),
        ));
  }
}

// ── Home Tab ──
class _RepHomeTab extends GetView<RepresentativeHomeController> {
  const _RepHomeTab();

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondaryLight.withValues(alpha: 0.15),
              child: Text('🧾', style: GoogleFonts.cairo(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً 👋', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                  Text(authService.userName, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Get.toNamed(AppRoutes.representativeNotifications)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingCustomers.value) return const LoadingIndicator();

        return RefreshIndicator(
          onRefresh: controller.loadCustomers,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Stats ──
              Row(
                children: [
                  _RepStat(icon: Icons.people_rounded, label: 'عملائي', value: '${controller.customers.length}', color: AppColors.primaryLight),
                  const SizedBox(width: 10),
                  _RepStat(icon: Icons.payments_rounded, label: 'المحصّل', value: '${controller.payments.length}', color: AppColors.successLight),
                  const SizedBox(width: 10),
                  _RepStat(icon: Icons.money_off_rounded, label: 'الفواتير', value: '${controller.invoices.length}', color: AppColors.errorLight),
                ],
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 24),

              // ── Quick Actions ──
              Text('إجراءات سريعة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.person_add_rounded,
                      label: 'إضافة عميل',
                      color: AppColors.primaryLight,
                      onTap: () => Get.toNamed(AppRoutes.registerCustomer),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.payment_rounded,
                      label: 'تحصيل دفعة',
                      color: AppColors.successLight,
                      onTap: () => Get.toNamed(AppRoutes.collectPayment),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),

              // ── Recent Customers ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('آخر العملاء', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.customerInvoices),
                    child: Text('عرض الكل', style: GoogleFonts.cairo(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...controller.customers.take(5).map((c) => _CustomerListItem(customer: c)),
            ],
          ),
        );
      }),
    );
  }
}

// ── My Customers Tab ──
class _MyCustomersTab extends StatefulWidget {
  const _MyCustomersTab();

  @override
  State<_MyCustomersTab> createState() => _MyCustomersTabState();
}

class _MyCustomersTabState extends State<_MyCustomersTab> {
  bool _showPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.find<RepresentativeHomeController>().loadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RepresentativeHomeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('عملائي',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                FilterChip(
                  label: Text('الكل',
                      style: GoogleFonts.cairo(fontSize: 12)),
                  selected: !_showPending,
                  onSelected: (_) {
                    setState(() => _showPending = false);
                    ctrl.loadCustomers();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('انتظار الموافقة',
                      style: GoogleFonts.cairo(fontSize: 12)),
                  selected: _showPending,
                  onSelected: (_) {
                    setState(() => _showPending = true);
                    ctrl.loadCustomers(pendingApproval: true);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.registerCustomer),
        icon: const Icon(Icons.person_add_rounded),
        label: Text('إضافة عميل',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (ctrl.isLoadingCustomers.value) return const LoadingIndicator();

        final list =
            _showPending ? ctrl.pendingCustomers : ctrl.customers;

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline,
                    size: 64,
                    color: AppColors.textSecondary.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text(
                  _showPending
                      ? 'لا يوجد عملاء في انتظار الموافقة'
                      : 'لا يوجد عملاء حالياً',
                  style: GoogleFonts.cairo(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ctrl.loadCustomers(
              pendingApproval: _showPending ? true : null),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            itemCount: list.length,
            itemBuilder: (_, i) => _CustomerListItem(customer: list[i]),
          ),
        );
      }),
    );
  }
}

// ── Settings Tab ──
class _RepSettingsTab extends StatelessWidget {
  const _RepSettingsTab();

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

class _RepStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RepStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _CustomerListItem extends StatelessWidget {
  final Map<String, dynamic> customer;

  const _CustomerListItem({required this.customer});

  @override
  Widget build(BuildContext context) {
    final balance = (customer['balance'] as num?)?.toDouble() ??
        (customer['totalDebt'] as num?)?.toDouble() ??
        0.0;
    final isPending = customer['isApproved'] == false ||
        customer['status']?.toString() == 'PendingApproval';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Theme.of(context).cardTheme.color ?? AppColors.surface,
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
          child: Text(
            '${customer['fullName']?[0] ?? '?'}',
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700, color: AppColors.primaryLight),
          ),
        ),
        title: Text(customer['fullName'] ?? '',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((customer['storeName'] as String?)?.isNotEmpty == true)
              Text(customer['storeName']!,
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: AppColors.textSecondary)),
            Text(customer['phone'] ?? '',
                style: GoogleFonts.cairo(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (balance != 0)
              Text(
                Formatters.currency(balance.abs()),
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: balance > 0 ? AppColors.error : AppColors.success,
                ),
              ),
            if (isPending)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warningLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'انتظار',
                  style: GoogleFonts.cairo(
                      fontSize: 9,
                      color: AppColors.warningLight,
                      fontWeight: FontWeight.w600),
                ),
              )
            else
              const Icon(Icons.chevron_left, size: 16),
          ],
        ),
        onTap: () =>
            Get.toNamed(AppRoutes.customerInvoices, arguments: customer),
      ),
    );
  }
}
