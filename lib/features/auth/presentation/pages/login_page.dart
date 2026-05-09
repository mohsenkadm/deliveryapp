// صفحة تسجيل الدخول الموحدة — ثلاثة تبويبات: عميل / موظف / مسؤول
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabColors = [
    Color(0xFF10B981),
    Color(0xFF2E7DFF),
    Color(0xFFEC4899),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color get _activeColor => _tabColors[_tabController.index];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _CustomerLoginTab(),
                  _EmployeeLoginTab(),
                  _AdminLoginTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _activeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.local_shipping_rounded, size: 34, color: _activeColor),
          )
              .animate()
              .fadeIn()
              .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0)),
          const SizedBox(height: 12),
          Text('مرحباً بك',
                  style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700))
              .animate()
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 2),
          Text('سجّل دخولك للمتابعة',
                  style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary))
              .animate()
              .fadeIn(delay: 150.ms),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [_activeColor, _activeColor.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _activeColor.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        padding: EdgeInsets.zero,
        tabs: [
          _TabItem(icon: Icons.person_rounded,      label: 'عميل',   isActive: _tabController.index == 0),
          _TabItem(icon: Icons.badge_rounded,        label: 'موظف',   isActive: _tabController.index == 1),
          _TabItem(icon: Icons.admin_panel_settings, label: 'مسؤول', isActive: _tabController.index == 2),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  const _TabItem({required this.icon, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 42,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.cairo(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

// ── تبويب العميل ──────────────────────────────────────
class _CustomerLoginTab extends StatelessWidget {
  const _CustomerLoginTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: ctrl.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const _InfoBanner(
              icon: Icons.shopping_bag_outlined,
              text: 'تصفّح المنتجات واطلب التوصيل بسهولة',
              color: Color(0xFF10B981),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'رقم الهاتف',
              hint: '07XXXXXXXX',
              controller: ctrl.phoneController,
              validator: Validators.required,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Obx(() => CustomTextField(
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  controller: ctrl.passwordController,
                  validator: Validators.password,
                  obscureText: ctrl.obscurePassword.value,
                  prefixIcon: Icons.lock_outlined,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(ctrl.obscurePassword.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => ctrl.obscurePassword.toggle(),
                  ),
                )),
            const SizedBox(height: 28),
            Obx(() => CustomButton(
                  text: 'تسجيل الدخول',
                  isLoading: ctrl.isLoading.value,
                  onPressed: ctrl.loginCustomer,
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.dividerLight)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('أو',
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
                Expanded(child: Divider(color: AppColors.dividerLight)),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.customerRegister),
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: Text('إنشاء حساب عميل جديد',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── تبويب الموظف ──────────────────────────────────────
class _EmployeeLoginTab extends StatelessWidget {
  const _EmployeeLoginTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: ctrl.employeeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const _InfoBanner(
              icon: Icons.badge_rounded,
              text: 'للسائقين والمندوبين والمشرفين ومديري المبيعات',
              color: Color(0xFF2E7DFF),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'اسم المستخدم',
              hint: 'أدخل اسم المستخدم',
              controller: ctrl.usernameController,
              validator: Validators.required,
              prefixIcon: Icons.person_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Obx(() => CustomTextField(
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  controller: ctrl.passwordController,
                  validator: Validators.password,
                  obscureText: ctrl.obscurePassword.value,
                  prefixIcon: Icons.lock_outlined,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(ctrl.obscurePassword.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => ctrl.obscurePassword.toggle(),
                  ),
                )),
            const SizedBox(height: 28),
            Obx(() => CustomButton(
                  text: 'تسجيل الدخول',
                  isLoading: ctrl.isLoading.value,
                  onPressed: ctrl.loginEmployee,
                )),
          ],
        ),
      ),
    );
  }
}

// ── تبويب المسؤول ──────────────────────────────────────
class _AdminLoginTab extends StatelessWidget {
  const _AdminLoginTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: ctrl.adminFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const _InfoBanner(
              icon: Icons.admin_panel_settings_rounded,
              text: 'لوحة التحكم الكاملة وإدارة النظام',
              color: Color(0xFFEC4899),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'اسم المستخدم',
              hint: 'أدخل اسم المستخدم',
              controller: ctrl.adminUsernameController,
              validator: Validators.required,
              prefixIcon: Icons.manage_accounts_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Obx(() => CustomTextField(
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  controller: ctrl.adminPasswordController,
                  validator: Validators.password,
                  obscureText: ctrl.adminObscurePassword.value,
                  prefixIcon: Icons.lock_outlined,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(ctrl.adminObscurePassword.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => ctrl.adminObscurePassword.toggle(),
                  ),
                )),
            const SizedBox(height: 28),
            Obx(() => CustomButton(
                  text: 'دخول لوحة التحكم',
                  isLoading: ctrl.isLoading.value,
                  onPressed: ctrl.loginAdmin,
                )),
          ],
        ),
      ),
    );
  }
}

// ── بانر معلومات مشترك ──────────────────────────────
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoBanner(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.cairo(fontSize: 12.5, color: color, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
