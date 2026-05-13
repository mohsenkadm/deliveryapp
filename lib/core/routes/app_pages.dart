// صفحات التطبيق — ربط المسارات بالصفحات والربط
import 'package:get/get.dart';
import 'app_routes.dart';

// Splash & Onboarding
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

// Auth
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/customer_login_page.dart';
import '../../features/auth/presentation/pages/driver_login_page.dart';
import '../../features/auth/presentation/pages/representative_login_page.dart';
import '../../features/auth/presentation/pages/admin_login_page.dart';
import '../../features/auth/presentation/pages/customer_register_page.dart';
import '../../features/auth/presentation/pages/registration_pending_page.dart';
import '../../features/auth/presentation/pages/role_picker_page.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';

// Customer
import '../../features/customer/presentation/pages/customer_main_page.dart';
import '../../features/customer/presentation/pages/products_page.dart';
import '../../features/customer/presentation/pages/product_details_page.dart';
import '../../features/customer/presentation/pages/categories_page.dart';
import '../../features/customer/presentation/pages/cart_page.dart';
import '../../features/customer/presentation/pages/checkout_page.dart';
import '../../features/customer/presentation/pages/my_orders_page.dart';
import '../../features/customer/presentation/pages/order_details_page.dart';
import '../../features/customer/presentation/pages/my_debts_page.dart';
import '../../features/customer/presentation/pages/customer_notifications_page.dart';
import '../../features/customer/presentation/bindings/customer_binding.dart';

// Driver
import '../../features/driver/presentation/pages/driver_main_page.dart';
import '../../features/driver/presentation/pages/assigned_orders_page.dart';
import '../../features/driver/presentation/pages/order_tracking_page.dart';
import '../../features/driver/presentation/pages/completed_deliveries_page.dart';
import '../../features/driver/presentation/pages/driver_notifications_page.dart';
import '../../features/driver/presentation/bindings/driver_binding.dart';

// Representative
import '../../features/representative/presentation/pages/representative_main_page.dart';
import '../../features/representative/presentation/pages/register_customer_page.dart';
import '../../features/representative/presentation/pages/customer_invoices_page.dart';
import '../../features/representative/presentation/pages/collect_payment_page.dart';
import '../../features/representative/presentation/bindings/representative_binding.dart';

// Supervisor
import '../../features/supervisor/presentation/pages/supervisor_main_page.dart';
import '../../features/supervisor/presentation/pages/supervisor_rep_detail_page.dart';
import '../../features/supervisor/presentation/pages/supervisor_notifications_page.dart';
import '../../features/supervisor/presentation/bindings/supervisor_binding.dart';

// Sales Manager
import '../../features/sales_manager/presentation/pages/sales_manager_main_page.dart';
import '../../features/sales_manager/presentation/pages/sales_manager_rep_detail_page.dart';
import '../../features/sales_manager/presentation/pages/sales_manager_notifications_page.dart';
import '../../features/sales_manager/presentation/bindings/sales_manager_binding.dart';

// Driver extra
import '../../features/driver/presentation/pages/driver_summary_page.dart';

// Customer extra
import '../../features/customer/presentation/pages/invoice_viewer_page.dart';

// Representative extra
import '../../features/representative/presentation/pages/rep_payments_page.dart';
import '../../features/representative/presentation/pages/rep_warehouse_page.dart';
import '../../features/representative/presentation/pages/rep_create_invoice_page.dart';
import '../../features/representative/presentation/pages/rep_debts_page.dart';
import '../../features/representative/presentation/pages/rep_invoice_detail_page.dart';
import '../../features/representative/presentation/pages/rep_transfer_product_picker_page.dart';

// Representative extra (notifications)
import '../../features/representative/presentation/pages/representative_notifications_page.dart';

// Admin
import '../../features/admin/presentation/pages/admin_main_page.dart';
import '../../features/admin/presentation/pages/admin_customers_page.dart';
import '../../features/admin/presentation/pages/admin_products_page.dart';
import '../../features/admin/presentation/pages/pending_approvals_page.dart';
import '../../features/admin/presentation/pages/admin_debts_page.dart';
import '../../features/admin/presentation/pages/admin_representatives_page.dart';
import '../../features/admin/presentation/pages/admin_drivers_page.dart';
import '../../features/admin/presentation/pages/admin_categories_page.dart';
import '../../features/admin/presentation/pages/admin_warehouses_page.dart';
import '../../features/admin/presentation/pages/admin_invoices_page.dart';
import '../../features/admin/presentation/pages/admin_analytics_page.dart';
import '../../features/admin/presentation/pages/admin_customer_statement_page.dart';
import '../../features/admin/presentation/bindings/admin_binding.dart';
import '../../features/admin/presentation/pages/admin_inventory_page.dart';
import '../../features/admin/presentation/pages/admin_branches_page.dart';
import '../../features/admin/presentation/pages/admin_offers_page.dart';
import '../../features/admin/presentation/pages/admin_system_settings_page.dart';
import '../../features/admin/presentation/pages/admin_permissions_page.dart';
import '../../features/admin/presentation/pages/admin_customer_form_page.dart';
import '../../features/admin/presentation/pages/admin_create_invoice_page.dart';
import '../../features/admin/presentation/pages/admin_create_admin_page.dart';
import '../../features/admin/presentation/pages/admin_employee_form_page.dart';
// Settings
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/branding_settings_page.dart';
import '../../features/settings/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/theme_settings_page.dart';
import '../../features/settings/presentation/pages/change_password_page.dart';
import '../../features/settings/presentation/pages/about_app_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/technical_support_page.dart';
import '../../features/settings/presentation/bindings/settings_binding.dart';

class AppPages {
  static final pages = <GetPage>[
    // Splash & Onboarding
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingPage()),

    // Auth — roleSelection يستخدمها الموظفون متعددو الأدوار لاختيار workspace
    GetPage(name: AppRoutes.roleSelection, page: () => const RolePickerPage(), binding: AuthBinding()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage(), binding: AuthBinding()),
    GetPage(name: AppRoutes.customerLogin, page: () => const CustomerLoginPage(), binding: AuthBinding()),
    GetPage(name: AppRoutes.driverLogin, page: () => const DriverLoginPage(), binding: AuthBinding()),
    GetPage(name: AppRoutes.representativeLogin, page: () => const RepresentativeLoginPage(), binding: AuthBinding()),
    GetPage(name: AppRoutes.adminLogin, page: () => const AdminLoginPage(), binding: AuthBinding()),
    GetPage(name: AppRoutes.customerRegister, page: () => const CustomerRegisterPage(), binding: AuthBinding()),
    GetPage(name: AppRoutes.registrationPending, page: () => const RegistrationPendingPage()),

    // Customer
    GetPage(name: AppRoutes.customer, page: () => const CustomerMainPage(), binding: CustomerBinding()),
    GetPage(name: AppRoutes.products, page: () => const ProductsPage()),
    GetPage(name: AppRoutes.productDetails, page: () => const ProductDetailsPage()),
    GetPage(name: AppRoutes.categories, page: () => const CategoriesPage()),
    GetPage(name: AppRoutes.cart, page: () => const CartPage()),
    GetPage(name: AppRoutes.checkout, page: () => const CheckoutPage()),
    GetPage(name: AppRoutes.myOrders, page: () => const MyOrdersPage()),
    GetPage(name: AppRoutes.orderDetails, page: () => const OrderDetailsPage()),
    GetPage(name: AppRoutes.myDebts, page: () => const MyDebtsPage()),
    GetPage(name: AppRoutes.customerNotifications, page: () => const CustomerNotificationsPage(), binding: CustomerBinding()),

    // Driver
    GetPage(name: AppRoutes.driver, page: () => const DriverMainPage(), binding: DriverBinding()),
    GetPage(name: AppRoutes.assignedOrders, page: () => const AssignedOrdersPage(), binding: DriverBinding()),
    GetPage(name: AppRoutes.orderTracking, page: () => const OrderTrackingPage()),
    GetPage(name: AppRoutes.completedDeliveries, page: () => const CompletedDeliveriesPage()),
    GetPage(name: AppRoutes.driverNotifications, page: () => const DriverNotificationsPage()),

    // Representative
    GetPage(name: AppRoutes.representative, page: () => const RepresentativeMainPage(), binding: RepresentativeBinding()),
    GetPage(name: AppRoutes.registerCustomer, page: () => const RegisterCustomerPage()),
    GetPage(name: AppRoutes.customerInvoices, page: () => const CustomerInvoicesPage()),
    GetPage(name: AppRoutes.collectPayment, page: () => const CollectPaymentPage()),

    // Supervisor
    GetPage(name: AppRoutes.supervisor, page: () => const SupervisorMainPage(), binding: SupervisorBinding()),
    GetPage(name: AppRoutes.supervisorRepDetail, page: () => const SupervisorRepDetailPage()),

    // Sales Manager
    GetPage(name: AppRoutes.salesManager, page: () => const SalesManagerMainPage(), binding: SalesManagerBinding()),
    GetPage(name: AppRoutes.salesManagerRepDetail, page: () => const SalesManagerRepDetailPage()),

    // Driver extra screens
    GetPage(name: AppRoutes.driverSummary, page: () => const DriverSummaryPage()),

    // Customer extra screens
    GetPage(name: AppRoutes.invoiceViewer, page: () => const InvoiceViewerPage()),

    // Representative extra screens
    GetPage(name: AppRoutes.repPayments, page: () => const RepPaymentsPage()),
    GetPage(name: AppRoutes.repWarehouse, page: () => const RepWarehousePage()),
    GetPage(name: AppRoutes.repCreateInvoice, page: () => const RepCreateInvoicePage()),
    GetPage(name: AppRoutes.repTransferPicker, page: () => const RepTransferProductPickerPage()),
    GetPage(name: AppRoutes.repDebts, page: () => const RepDebtsPage()),
    GetPage(name: AppRoutes.repInvoiceDetail, page: () => const RepInvoiceDetailPage()),

    // Admin
    GetPage(name: AppRoutes.representativeNotifications, page: () => const RepresentativeNotificationsPage()),
    GetPage(name: AppRoutes.admin, page: () => const AdminMainPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.adminDashboard, page: () => const AdminMainPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageCustomers, page: () => const AdminCustomersPage(), binding: AdminBinding()),
    GetPage(name: '/admin/customers', page: () => const AdminCustomersPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageProducts, page: () => const AdminProductsPage(), binding: AdminBinding()),
    GetPage(name: '/admin/products', page: () => const AdminProductsPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.pendingApprovals, page: () => const PendingApprovalsPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.debtsSettlement, page: () => const AdminDebtsPage(), binding: AdminBinding()),
    GetPage(name: '/admin/debts', page: () => const AdminDebtsPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageRepresentatives, page: () => const AdminRepresentativesPage(), binding: AdminBinding()),
    GetPage(name: '/admin/representatives', page: () => const AdminRepresentativesPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageDrivers, page: () => const AdminDriversPage(), binding: AdminBinding()),
    GetPage(name: '/admin/drivers', page: () => const AdminDriversPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageCategories, page: () => const AdminCategoriesPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageWarehouses, page: () => const AdminWarehousesPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageInventory, page: () => const AdminInventoryPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageInvoices, page: () => const AdminInvoicesPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.analytics, page: () => const AdminAnalyticsPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.adminNotifications, page: () => const AdminMainPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageBranches, page: () => const AdminBranchesPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageOffers, page: () => const AdminOffersPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.systemSettings, page: () => const AdminSystemSettingsPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.adminPermissions, page: () => const AdminPermissionsPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.customerStatement, page: () => const AdminCustomerStatementPage(), binding: AdminBinding()),
    GetPage(name: '/admin/customer-statement', page: () => const AdminCustomerStatementPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.adminCustomerForm, page: () => const AdminCustomerFormPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.adminCreateInvoice, page: () => const AdminCreateInvoicePage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.adminCreateAdmin, page: () => const AdminCreateAdminPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.adminEmployeeForm, page: () => const AdminEmployeeFormPage(), binding: AdminBinding()),

    // Supervisor / Sales Manager — notifications
    GetPage(name: AppRoutes.supervisorNotifications, page: () => const SupervisorNotificationsPage()),
    GetPage(name: AppRoutes.salesManagerNotifications, page: () => const SalesManagerNotificationsPage()),

    // Settings
    GetPage(name: AppRoutes.settings, page: () => const SettingsPage(), binding: SettingsBinding()),
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage(), binding: SettingsBinding()),
    GetPage(name: AppRoutes.editProfile, page: () => const ProfilePage(), binding: SettingsBinding()),
    GetPage(name: AppRoutes.themeSettings, page: () => const ThemeSettingsPage(), binding: SettingsBinding()),
    GetPage(name: AppRoutes.brandingSettings, page: () => const BrandingSettingsPage()),
    GetPage(name: AppRoutes.changePassword, page: () => ChangePasswordPage(), binding: SettingsBinding()),
    GetPage(name: AppRoutes.aboutApp, page: () => const AboutAppPage()),
    GetPage(name: AppRoutes.privacyPolicy, page: () => const PrivacyPolicyPage()),
    GetPage(name: AppRoutes.technicalSupport, page: () => const TechnicalSupportPage()),

    // Deep-link aliases — used by OneSignal push notification handler
    GetPage(name: AppRoutes.orderDetailsAlias, page: () => const OrderDetailsPage()),
    GetPage(name: AppRoutes.invoiceDetailsAlias, page: () => const RepInvoiceDetailPage()),
    GetPage(name: AppRoutes.notificationsAlias, page: () => const CustomerNotificationsPage(), binding: CustomerBinding()),
  ];
}
