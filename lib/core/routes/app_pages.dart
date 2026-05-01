// صفحات التطبيق — ربط المسارات بالصفحات والربط
import 'package:get/get.dart';
import 'app_routes.dart';

// Splash & Onboarding
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

// Auth
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/customer_login_page.dart';
import '../../features/auth/presentation/pages/driver_login_page.dart';
import '../../features/auth/presentation/pages/representative_login_page.dart';
import '../../features/auth/presentation/pages/admin_login_page.dart';
import '../../features/auth/presentation/pages/customer_register_page.dart';
import '../../features/auth/presentation/pages/registration_pending_page.dart';
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
import '../../features/supervisor/presentation/bindings/supervisor_binding.dart';

// Sales Manager
import '../../features/sales_manager/presentation/pages/sales_manager_main_page.dart';
import '../../features/sales_manager/presentation/pages/sales_manager_rep_detail_page.dart';
import '../../features/sales_manager/presentation/bindings/sales_manager_binding.dart';

// Driver extra
import '../../features/driver/presentation/pages/driver_summary_page.dart';
import '../../features/driver/presentation/pages/driver_collect_payment_page.dart';
import '../../features/driver/presentation/pages/driver_submit_payment_page.dart';

// Customer extra
import '../../features/customer/presentation/pages/invoice_viewer_page.dart';

// Representative extra
import '../../features/representative/presentation/pages/rep_payments_page.dart';
import '../../features/representative/presentation/pages/rep_warehouse_page.dart';
import '../../features/representative/presentation/pages/rep_create_invoice_page.dart';

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
import '../../features/admin/presentation/pages/admin_activity_logs_page.dart';
import '../../features/admin/presentation/pages/admin_customer_statement_page.dart';
import '../../features/admin/presentation/bindings/admin_binding.dart';
import '../../features/admin/presentation/pages/admin_inventory_page.dart';

// Settings
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/theme_settings_page.dart';
import '../../features/settings/presentation/pages/change_password_page.dart';
import '../../features/settings/presentation/pages/about_app_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/technical_support_page.dart';

class AppPages {
  static final pages = <GetPage>[
    // Splash & Onboarding
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingPage()),

    // Auth
    GetPage(name: AppRoutes.roleSelection, page: () => const RoleSelectionPage(), binding: AuthBinding()),
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
    GetPage(name: AppRoutes.customerNotifications, page: () => const CustomerNotificationsPage()),

    // Driver
    GetPage(name: AppRoutes.driver, page: () => const DriverMainPage(), binding: DriverBinding()),
    GetPage(name: AppRoutes.assignedOrders, page: () => const AssignedOrdersPage()),
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
    GetPage(name: AppRoutes.driverCollectPayment, page: () => const DriverCollectPaymentPage()),
    GetPage(name: AppRoutes.driverSubmitPayment, page: () => const DriverSubmitPaymentPage()),

    // Customer extra screens
    GetPage(name: AppRoutes.invoiceViewer, page: () => const InvoiceViewerPage()),

    // Representative extra screens
    GetPage(name: AppRoutes.repPayments, page: () => const RepPaymentsPage()),
    GetPage(name: AppRoutes.repWarehouse, page: () => const RepWarehousePage()),
    GetPage(name: AppRoutes.repCreateInvoice, page: () => const RepCreateInvoicePage()),

    // Admin
    GetPage(name: AppRoutes.representativeNotifications, page: () => const RepresentativeNotificationsPage()),
    GetPage(name: AppRoutes.admin, page: () => const AdminMainPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.adminDashboard, page: () => const AdminMainPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.manageCustomers, page: () => const AdminCustomersPage()),
    GetPage(name: '/admin/customers', page: () => const AdminCustomersPage()),
    GetPage(name: AppRoutes.manageProducts, page: () => const AdminProductsPage()),
    GetPage(name: '/admin/products', page: () => const AdminProductsPage()),
    GetPage(name: AppRoutes.pendingApprovals, page: () => const PendingApprovalsPage()),
    GetPage(name: AppRoutes.debtsSettlement, page: () => const AdminDebtsPage()),
    GetPage(name: '/admin/debts', page: () => const AdminDebtsPage()),
    GetPage(name: AppRoutes.manageRepresentatives, page: () => const AdminRepresentativesPage()),
    GetPage(name: '/admin/representatives', page: () => const AdminRepresentativesPage()),
    GetPage(name: AppRoutes.manageDrivers, page: () => const AdminDriversPage()),
    GetPage(name: '/admin/drivers', page: () => const AdminDriversPage()),
    GetPage(name: AppRoutes.manageCategories, page: () => const AdminCategoriesPage()),
    GetPage(name: AppRoutes.manageWarehouses, page: () => const AdminWarehousesPage()),
    GetPage(name: AppRoutes.manageInventory, page: () => const AdminInventoryPage()),
    GetPage(name: AppRoutes.manageInvoices, page: () => const AdminInvoicesPage()),
    GetPage(name: AppRoutes.analytics, page: () => const AdminAnalyticsPage()),
    GetPage(name: AppRoutes.activityLogs, page: () => const AdminActivityLogsPage()),
    GetPage(name: AppRoutes.adminNotifications, page: () => const AdminMainPage(), binding: AdminBinding()),
    GetPage(name: AppRoutes.customerStatement, page: () => const AdminCustomerStatementPage()),
    GetPage(name: '/admin/customer-statement', page: () => const AdminCustomerStatementPage()),

    // Settings
    GetPage(name: AppRoutes.settings, page: () => const SettingsPage()),
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
    GetPage(name: AppRoutes.editProfile, page: () => const ProfilePage()),
    GetPage(name: AppRoutes.themeSettings, page: () => const ThemeSettingsPage()),
    GetPage(name: AppRoutes.changePassword, page: () => ChangePasswordPage()),
    GetPage(name: AppRoutes.aboutApp, page: () => const AboutAppPage()),
    GetPage(name: AppRoutes.privacyPolicy, page: () => const PrivacyPolicyPage()),
    GetPage(name: AppRoutes.technicalSupport, page: () => const TechnicalSupportPage()),
  ];
}
