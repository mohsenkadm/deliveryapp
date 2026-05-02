// صفحة تسجيل الدخول الموحدة — تبويبان: عميل / موظف
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),

            // ── Tab Bar ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.dividerLight),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle:
                    GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: GoogleFonts.cairo(fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '👤  عميل'),
                  Tab(text: '👔  موظف'),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            // ── Tab Content ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _CustomerLoginTab(),
                  _EmployeeLoginTab(),
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
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.local_shipping_rounded,
                size: 34, color: AppColors.primary),
          )
              .animate()
              .fadeIn()
              .scale(
                  begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0)),
          const SizedBox(height: 12),
          Text('مرحباً بك',
                  style: GoogleFonts.cairo(
                      fontSize: 24, fontWeight: FontWeight.w700))
              .animate()
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 2),
          Text('سجّل دخولك للمتابعة',
                  style: GoogleFonts.cairo(
                      fontSize: 13, color: AppColors.textSecondary))
              .animate()
              .fadeIn(delay: 150.ms),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// تبويب تسجيل دخول العميل — phone + password
// ──────────────────────────────────────────────────────
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
            const SizedBox(height: 24),
            Obx(() => CustomButton(
                  text: 'تسجيل الدخول',
                  isLoading: ctrl.isLoading.value,
                  onPressed: ctrl.loginCustomer,
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ليس لديك حساب؟',
                    style: GoogleFonts.cairo(
                        fontSize: 14, color: AppColors.textSecondary)),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.customerRegister),
                  child: Text('إنشاء حساب جديد',
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// تبويب تسجيل دخول الموظف — username + password
// ──────────────────────────────────────────────────────
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
            // Info chip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppColors.primaryLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'للسائقين والمندوبين والمشرفين ومديري المبيعات والمسؤولين',
                        style: GoogleFonts.cairo(
                            fontSize: 12, color: AppColors.primaryLight)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            Obx(() => CustomButton(
                  text: 'تسجيل الدخول',
                  isLoading: ctrl.isLoading.value,
                  onPressed: ctrl.loginAdmin,
                )),
          ],
        ),
      ),
    );
  }
}
