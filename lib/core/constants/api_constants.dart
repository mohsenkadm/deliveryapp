// ثوابت نقاط الاتصال بالخادم (API Endpoints)
class ApiConstants {
  ApiConstants._();

  /// رابط الخادم الأساسي
  static const String baseUrl = 'https://floppya918-003-site2.mtempurl.com';

  /// معرّف تطبيق OneSignal
  static const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';

  /// مسار هاب SignalR للإشعارات الفورية
  static const String signalRHub = '/hubs/notifications';

  // ── المصادقة ──
  /// POST تسجيل دخول العميل — { phone, password }
  static const String loginCustomer = '/api/customer/login';
  /// POST تسجيل عميل جديد (ذاتي)
  static const String registerCustomer = '/api/customer/register';
  /// GET الملف الشخصي للعميل
  static const String customerProfile = '/api/customer/profile';

  /// POST تسجيل دخول الموظفين (سائق/مندوب/مشرف/مدير/أدمن)
  /// { username, password } → { token, role }
  static const String loginEmployee = '/api/admin/login';

  /// POST إضافة أدمن جديد [Bearer: Admin]
  static const String addAdmin = '/api/admin/add-admin';

  // ── المصادقة - مشتركة ──
  /// POST تغيير كلمة المرور
  static const String changePassword = '/api/auth/change-password';
  /// POST تحديث التوكن
  static const String refreshToken = '/api/auth/refresh-token';
  /// POST تسجيل الخروج
  static const String logout = '/api/auth/logout';

  // ══════════════════════════════════════════════════════════════
  // تطبيق العميل  →  /api/mobile/customer  [Bearer: Customer]
  // ══════════════════════════════════════════════════════════════

  /// GET المنتجات ?search=&categoryId=&branchId=&page=&pageSize=
  static const String customerProducts = '/api/mobile/customer/products';

  /// GET الطلبات ?status=
  static const String customerOrders = '/api/mobile/customer/orders';

  /// POST إنشاء طلب
  static const String customerCreateOrder = '/api/mobile/customer/orders';

  /// GET تفاصيل طلب
  static String customerOrderDetail(String id) => '/api/mobile/customer/orders/$id';

  /// POST إلغاء طلب (Pending فقط)
  static String customerCancelOrder(String id) => '/api/mobile/customer/orders/$id/cancel';

  /// GET فاتورة HTML — للعرض في WebView
  static String customerOrderInvoice(String id) => '/api/mobile/customer/orders/$id/invoice';

  /// GET ملخص الديون
  static const String customerDebts = '/api/mobile/customer/debts';

  /// GET إشعارات العميل
  static const String customerNotifications = '/api/mobile/customer/notifications';

  /// PATCH تعليم إشعار العميل كمقروء
  static String customerMarkNotificationRead(String id) =>
      '/api/mobile/customer/notifications/$id/read';

  // ══════════════════════════════════════════════════════════════
  // تطبيق السائق  →  /api/mobile/driver  [Bearer: Driver,Employee]
  // ══════════════════════════════════════════════════════════════

  /// GET طلبات السائق ?status=
  static const String driverOrders = '/api/mobile/driver/orders';

  /// GET تفاصيل طلب السائق
  static String driverOrderDetail(String id) => '/api/mobile/driver/orders/$id';

  /// POST تأكيد التوصيل
  static String driverDeliver(String id) => '/api/mobile/driver/orders/$id/deliver';

  /// POST تحصيل دفعة من عميل
  static String driverCollectPayment(String id) =>
      '/api/mobile/driver/orders/$id/collect-payment';

  /// POST تسليم نقدية للشركة
  static const String driverSubmitPayment = '/api/mobile/driver/payments/submit';

  /// PATCH تحديث حالة طلب السائق
  static String driverOrderStatus(String id) => '/api/mobile/driver/orders/$id/status';

  /// GET ملخص أداء السائق
  static const String driverSummary = '/api/mobile/driver/summary';

  // ══════════════════════════════════════════════════════════════
  // تطبيق المندوب  →  /api/mobile/rep  [Bearer: Representative,Employee]
  // ══════════════════════════════════════════════════════════════

  /// GET عملاء المندوب ?pendingApproval=true|false
  static const String repCustomers = '/api/mobile/rep/customers';

  /// POST إضافة عميل عبر المندوب
  static const String repAddCustomer = '/api/mobile/rep/customers';

  /// GET فواتير المندوب ?status=
  static const String repInvoices = '/api/mobile/rep/invoices';

  /// POST إنشاء فاتورة للعميل
  static const String repCreateInvoice = '/api/mobile/rep/invoices';

  /// GET تفاصيل فاتورة
  static String repInvoiceDetail(String id) => '/api/mobile/rep/invoices/$id';

  /// POST تحصيل دفعة من عميل
  static const String repCollectPayment = '/api/mobile/rep/payments/collect';

  /// POST تسليم نقدية للمحاسب
  static const String repSubmitPayment = '/api/mobile/rep/payments/submit';

  /// GET سجل المدفوعات
  static const String repPayments = '/api/mobile/rep/payments';

  /// GET ديون عملاء المندوب
  static const String repDebts = '/api/mobile/rep/debts';

  /// GET مخزون المستودع الفرعي
  static const String repWarehouse = '/api/mobile/rep/warehouse';

  /// POST طلب نقل مخزون (رئيسي → فرعي)
  static const String repTransferOrders = '/api/mobile/rep/transfer-orders';

  /// POST إعادة مخزون (فرعي → رئيسي)
  static const String repReturnTransfer = '/api/mobile/rep/transfer-orders/return';

  /// GET قائمة أوامر النقل ?status=
  static const String repTransferOrdersList = '/api/mobile/rep/transfer-orders';

  // ══════════════════════════════════════════════════════════════
  // تطبيق المشرف  →  /api/mobile/supervisor  [Bearer: Supervisor,Employee]
  // ══════════════════════════════════════════════════════════════

  /// GET قائمة المندوبين مع الإحصائيات
  static const String supervisorReps = '/api/mobile/supervisor/reps';

  /// GET فواتير مندوب ?status=
  static String supervisorRepInvoices(String repId) =>
      '/api/mobile/supervisor/reps/$repId/invoices';

  /// GET مدفوعات مندوب
  static String supervisorRepPayments(String repId) =>
      '/api/mobile/supervisor/reps/$repId/payments';

  /// GET عملاء مندوب
  static String supervisorRepCustomers(String repId) =>
      '/api/mobile/supervisor/reps/$repId/customers';

  /// GET العملاء المعلقة موافقتهم
  static const String supervisorPendingCustomers =
      '/api/mobile/supervisor/customers/pending';

  /// POST الموافقة على عميل
  static String supervisorApproveCustomer(String id) =>
      '/api/mobile/supervisor/customers/$id/approve';

  /// POST رفض عميل
  static String supervisorRejectCustomer(String id) =>
      '/api/mobile/supervisor/customers/$id/reject';

  /// GET تقرير المبيعات ?from=&to=
  static const String supervisorSalesReport = '/api/mobile/supervisor/reports/sales';

  // ══════════════════════════════════════════════════════════════
  // تطبيق مدير المبيعات  →  /api/mobile/manager  [Bearer: SalesManager,Employee]
  // ══════════════════════════════════════════════════════════════

  /// GET قائمة المندوبين
  static const String managerReps = '/api/mobile/manager/reps';

  /// GET فواتير مندوب ?status=
  static String managerRepInvoices(String repId) =>
      '/api/mobile/manager/reps/$repId/invoices';

  /// GET العملاء المعلقة موافقتهم
  static const String managerPendingCustomers =
      '/api/mobile/manager/customers/pending';

  /// POST الموافقة على عميل
  static String managerApproveCustomer(String id) =>
      '/api/mobile/manager/customers/$id/approve';

  /// POST رفض عميل
  static String managerRejectCustomer(String id) =>
      '/api/mobile/manager/customers/$id/reject';

  /// GET الفواتير المعلقة للموافقة
  static const String managerPendingInvoices =
      '/api/mobile/manager/invoices/pending';

  /// POST الموافقة على فاتورة
  static String managerApproveInvoice(String id) =>
      '/api/mobile/manager/invoices/$id/approve';

  /// POST رفض فاتورة
  static String managerRejectInvoice(String id) =>
      '/api/mobile/manager/invoices/$id/reject';

  /// GET تقرير ملخص ?from=&to=
  static const String managerSummaryReport = '/api/mobile/manager/reports/summary';

  /// GET تقرير الديون
  static const String managerDebtsReport = '/api/mobile/manager/reports/debts';

  /// GET تقرير المدفوعات ?verified=true|false
  static const String managerPaymentsReport = '/api/mobile/manager/reports/payments';

  // ══════════════════════════════════════════════════════════════
  // نقاط مشتركة
  // ══════════════════════════════════════════════════════════════

  /// GET إشعاراتي (حسب الدور)
  static const String notifications = '/api/notifications';

  /// PATCH تعليم إشعار كمقروء
  static String markNotificationRead(String id) => '/api/notifications/$id/read';

  /// GET فواتير العميل (مشترك)
  static const String sharedCustomerInvoices = '/api/invoices/customer';

  /// GET فواتير المندوب (مشترك)
  static const String sharedRepresentativeInvoices = '/api/invoices/representative';

  /// GET فواتير السائق (مشترك)
  static const String sharedDriverInvoices = '/api/invoices/driver';

  /// POST إنشاء فاتورة (مشترك)
  static const String createInvoice = '/api/invoices';

  /// POST دفع فاتورة
  static String invoicePay(String id) => '/api/invoices/$id/pay';

  /// PATCH تحديث حالة الفاتورة من السائق
  static String invoiceStatusDriver(String id) => '/api/invoices/$id/status/driver';

  /// PATCH تحديث حالة الفاتورة من المدير
  static String invoiceStatusAdmin(String id) => '/api/invoices/$id/status/admin';

  // ── لإبقاء التوافق مع الكود القديم ──
  static const String loginAdmin = loginEmployee;
  static const String loginDriver = loginEmployee;
  static const String loginRepresentative = loginEmployee;

  // ── الأدمن (Admin) ──
  static const String adminDashboard = '/api/admin/dashboard';
  static const String adminCustomers = '/api/admin/customers';
  static const String products = '/api/admin/products';
  static const String categories = '/api/admin/categories';
  static const String warehouses = '/api/admin/warehouses';
  static const String inventory = '/api/admin/inventory';
  static const String invoices = '/api/admin/invoices';
  static const String adminRepresentatives = '/api/admin/representatives';
  static const String adminDrivers = '/api/admin/drivers';
  static const String debts = '/api/admin/debts';
  static const String adminPendingApprovals = '/api/admin/pending-approvals';
}
