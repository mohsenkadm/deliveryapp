// مسارات التطبيق — أسماء جميع الصفحات
abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const roleSelection = '/role-selection';

  // Auth
  static const login = '/login';
  static const customerLogin = '/customer-login';
  static const driverLogin = '/driver-login';
  static const representativeLogin = '/representative-login';
  static const adminLogin = '/admin-login';
  static const customerRegister = '/customer-register';
  static const registrationPending = '/registration-pending';

  // Customer
  static const customer = '/customer';
  static const customerHome = '/customer/home';
  static const products = '/customer/products';
  static const productDetails = '/customer/product-details';
  static const categories = '/customer/categories';
  static const cart = '/customer/cart';
  static const checkout = '/customer/checkout';
  static const myOrders = '/customer/my-orders';
  static const orderDetails = '/customer/order-details';
  static const myDebts = '/customer/my-debts';
  static const customerNotifications = '/customer/notifications';

  // Driver
  static const driver = '/driver';
  static const driverHome = '/driver/home';
  static const assignedOrders = '/driver/assigned-orders';
  static const orderTracking = '/driver/order-tracking';
  static const completedDeliveries = '/driver/completed-deliveries';
  static const driverNotifications = '/driver/notifications';

  // Representative
  static const representative = '/representative';
  static const representativeHome = '/representative/home';
  static const myCustomers = '/representative/my-customers';
  static const registerCustomer = '/representative/register-customer';
  static const customerInvoices = '/representative/customer-invoices';
  static const collectPayment = '/representative/collect-payment';
  static const representativeNotifications = '/representative/notifications';

  // Supervisor
  static const supervisor = '/supervisor';
  static const supervisorRepDetail = '/supervisor/rep-detail';
  static const supervisorNotifications = '/supervisor/notifications';

  // Sales Manager
  static const salesManager = '/sales-manager';
  static const salesManagerRepDetail = '/sales-manager/rep-detail';
  static const salesManagerNotifications = '/sales-manager/notifications';

  // Driver extra screens
  static const driverSummary = '/driver/summary';

  // Customer extra screens
  static const invoiceViewer = '/customer/invoice-viewer';

  // Representative extra screens
  static const repPayments = '/representative/payments';
  static const repWarehouse = '/representative/warehouse';
  static const repTransferPicker = '/representative/transfer-picker';
  static const repCreateInvoice = '/representative/create-invoice';
  static const repDebts = '/representative/debts';
  static const repInvoiceDetail = '/representative/invoice-detail';

  // Admin
  static const admin = '/admin';
  static const adminDashboard = '/admin/dashboard';
  static const manageCustomers = '/admin/manage-customers';
  static const pendingApprovals = '/admin/pending-approvals';
  static const manageRepresentatives = '/admin/manage-representatives';
  static const manageDrivers = '/admin/manage-drivers';
  static const manageProducts = '/admin/manage-products';
  static const manageCategories = '/admin/manage-categories';
  static const manageWarehouses = '/admin/manage-warehouses';
  static const manageInventory = '/admin/manage-inventory';
  static const manageInvoices = '/admin/manage-invoices';
  static const customerStatement = '/admin/customer-statement';
  static const analytics = '/admin/analytics';
  static const debtsSettlement = '/admin/debts-settlement';
  static const adminNotifications = '/admin/notifications';
  static const manageBranches = '/admin/manage-branches';
  static const manageOffers = '/admin/manage-offers';
  static const systemSettings = '/admin/system-settings';
  static const adminPermissions = '/admin/permissions';
  static const adminCustomerForm = '/admin/customer-form';
  static const adminCreateInvoice = '/admin/create-invoice';
  static const adminCreateAdmin = '/admin/create-admin';
  static const adminEmployeeForm = '/admin/employee-form';

  // Settings (shared)
  static const settings = '/settings';
  static const profile = '/settings/profile';
  static const editProfile = '/settings/edit-profile';
  static const themeSettings = '/settings/theme';
  static const aboutApp = '/settings/about';
  static const privacyPolicy = '/settings/privacy';
  static const technicalSupport = '/settings/support';
  static const changePassword = '/settings/change-password';
  static const brandingSettings = '/settings/branding';

  // Deep-link aliases (used by OneSignal push notification handler)
  static const orderDetailsAlias = '/order-details';
  static const invoiceDetailsAlias = '/invoice-details';
  static const notificationsAlias = '/notifications';
}
