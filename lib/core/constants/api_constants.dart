// ثوابت نقاط الاتصال بالخادم (API Endpoints)
// متوافقة مع DeliverySystem.API — الإصدار الموحّد
//
// ملاحظات معمارية مهمة:
// - يوجد ثلاث نقاط دخول للمصادقة فقط: /api/auth/admin , /api/auth/customer , /api/auth/employee
// - الموظفون جدول واحد (Employees) مع عمود Roles كقائمة CSV (يمكن لموظف امتلاك عدة أدوار).
// - كل الردود مغلّفة بـ ApiResponse<T> { success, messageAr, messageEn, data }.
// - JWT يبقى صالحاً 7 أيام افتراضياً (لا يوجد refresh token في هذه الواجهة).
class ApiConstants {
  ApiConstants._();

  /// رابط الخادم الأساسي
  static const String baseUrl = 'https://floppya918-003-site2.mtempurl.com';

  /// معرّف تطبيق OneSignal — يُحقن وقت البناء عبر:
  ///   `flutter run --dart-define=ONESIGNAL_APP_ID=xxxx`
  /// أو يُترك على القيمة الافتراضية (placeholder) أثناء التطوير المحلي.
  static const String oneSignalAppId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: 'YOUR_ONESIGNAL_APP_ID',
  );

  /// مسار هاب SignalR للإشعارات الفورية
  static const String signalRHub = '/hubs/notifications';

  // ════════════════════════════════════════════════════════════════
  // المصادقة (3 نقاط دخول فقط)
  // ════════════════════════════════════════════════════════════════

  /// POST تسجيل دخول الأدمن — { username, password } → AuthResponseDto
  static const String loginAdmin = '/api/auth/admin';

  /// POST تسجيل دخول العميل — { username, password } → AuthResponseDto
  static const String loginCustomer = '/api/auth/customer';

  /// POST تسجيل دخول الموظف (لكل التركيبات الممكنة من الأدوار)
  static const String loginEmployee = '/api/auth/employee';

  // أسماء قديمة محفوظة للتوافق مع الكود الموجود (تستخدم نفس نقاط الدخول)
  static const String loginDriver = loginEmployee;
  static const String loginRepresentative = loginEmployee;
  static const String loginRepresentativeEmployee = loginEmployee;
  static const String loginSupervisor = loginEmployee;
  static const String loginSalesManager = loginEmployee;

  // ── الملف الشخصي الموحّد ──
  /// GET الملف الشخصي للمستخدم الحالي (أي دور) — kind + profile
  static const String me = '/api/me';

  // ── العميل: تسجيل ذاتي + ملف شخصي ──
  /// POST تسجيل عميل جديد (ذاتي — ينشأ الحساب بحالة "بانتظار الموافقة")
  static const String registerCustomer = '/api/customer/register';

  /// GET الملف الشخصي للعميل الحالي
  @Deprecated('استخدم /api/me — الواجهة الموحَّدة')
  static const String customerProfile = '/api/customer/profile';

  // ── أُزيلت من الواجهة الجديدة (يحتفظ بها للتوافق فقط) ──
  @Deprecated('غير موجود في الواجهة الحالية — توكن JWT يدوم 7 أيام')
  static const String refreshToken = '/api/auth/refresh-token';
  @Deprecated('غير موجود في الواجهة الحالية — يتم تسجيل الخروج محلياً')
  static const String logout = '/api/auth/logout';
  @Deprecated('غير مدعوم في الواجهة الحالية')
  static const String changePassword = '/api/auth/change-password';

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

  // ملاحظة: إشعارات العميل أصبحت موحَّدة على /api/notifications.
  // التعريفات أدناه (بأسماء قديمة) ما تزال محفوظة كأسماء مستعارة لـ
  // `notifications` و`markNotificationRead`. (انظر قسم "نقاط مشتركة")

  // ══════════════════════════════════════════════════════════════
  // تطبيق السائق  →  /api/mobile/driver  [Bearer: Driver,Employee]
  // ══════════════════════════════════════════════════════════════

  /// GET طلبات السائق ?status=
  static const String driverOrders = '/api/mobile/driver/orders';

  /// GET تفاصيل طلب السائق
  static String driverOrderDetail(String id) => '/api/mobile/driver/orders/$id';

  /// POST تأكيد استلام الشحنة من المستودع (WarehouseProcessing → AwaitingDelivery)
  static String driverOrderPickup(String id) =>
      '/api/mobile/driver/orders/$id/pickup';

  /// POST تأكيد التسليم للعميل (AwaitingDelivery → Delivered)
  static String driverOrderDeliver(String id) =>
      '/api/mobile/driver/orders/$id/deliver';

  /// POST تحصيل نقدي اختياري من العميل — body: DriverCollectPaymentDto
  static String driverOrderCollect(String id) =>
      '/api/mobile/driver/orders/$id/collect';

  /// PATCH تحديث حالة الفاتورة — أهداف مسموحة: Delivered, Completed, Rejected (وغيرها حسب الخادم)
  static String driverOrderStatus(String id) =>
      '/api/mobile/driver/orders/$id/status';

  @Deprecated('استخدم driverOrderDeliver — التسليم عبر POST /deliver')
  static String driverConfirmDelivery(String id) => driverOrderDeliver(id);

  @Deprecated('استخدم driverOrderDeliver')
  static String driverDeliver(String id) => driverOrderDeliver(id);

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

  /// GET مخزون المستودع الفرعي (RepWarehouseDto — أسعار جملة/تجزئة وخصم لكل بند)
  static const String repWarehouse = '/api/mobile/rep/warehouse';

  /// GET منتجات برصيد في المستودعات الرئيسية فقط (?search=&categoryId=&warehouseId=&nearExpiryDays=)
  static const String repProductsMainWarehouses =
      '/api/mobile/rep/products/main-warehouses';

  /// GET قائمة المستودعات الرئيسية (id, name, branchId)
  static const String repWarehousesMain = '/api/mobile/rep/warehouses/main';

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

  /// GET إشعاراتي (الجهة المستهدفة تُحدَّد من دور المستخدم)
  static const String notifications = '/api/notifications';

  /// PATCH تعليم إشعار كمقروء
  static String markNotificationRead(String id) => '/api/notifications/$id/read';

  // أسماء قديمة محفوظة للتوافق — كل أنواع الإشعارات تستخدم نفس النقطة
  static const String customerNotifications = notifications;
  static String customerMarkNotificationRead(String id) => markNotificationRead(id);

  // ══════════════════════════════════════════════════════════════
  // الفواتير (مشتركة — للأدمن فقط)
  // ══════════════════════════════════════════════════════════════

  /// POST إنشاء فاتورة (نقطة دخول الأدمن)
  static const String createInvoice = '/api/invoices';
  static const String invoices = createInvoice;

  /// POST دفع فاتورة (كاملة أو جزئية) — body: { amount }
  static String invoicePay(String id) => '/api/invoices/$id/pay';

  /// PATCH تحديث حالة الفاتورة (تجاوز الأدمن) — body: { status }
  static String invoiceStatus(String id) => '/api/invoices/$id/status';

  // ── سير عمل الفاتورة (Invoice Workflow) ──
  /// POST قبول الفاتورة — Manager
  static String invoiceAccept(String id) => '/api/invoices/$id/accept';

  /// POST رفض الفاتورة — Manager
  static String invoiceReject(String id) => '/api/invoices/$id/reject';

  /// POST تأجيل الفاتورة — Manager
  static String invoiceDefer(String id) => '/api/invoices/$id/defer';

  /// POST بدء التجهيز في المستودع — Warehouse
  static String invoiceStartWarehouse(String id) =>
      '/api/invoices/$id/start-warehouse';

  /// POST إسناد سائق — Manager
  static String invoiceAssignDriver(String id) =>
      '/api/invoices/$id/assign-driver';

  /// POST إخراج للسائق (Dispatch) — Warehouse
  static String invoiceDispatch(String id) => '/api/invoices/$id/dispatch';

  /// POST دفع جزئي — Cashier
  static String invoicePayPartial(String id) =>
      '/api/invoices/$id/pay-partial';

  /// POST دفع كامل — Cashier
  static String invoicePayFull(String id) => '/api/invoices/$id/pay-full';

  // أسماء قديمة محفوظة للتوافق
  static String invoiceStatusAdmin(String id) => invoiceStatus(id);
  static String invoiceStatusDriver(String id) => invoiceStatus(id);

  // ══════════════════════════════════════════════════════════════
  // الإدارة الخلفية — الأدمن (جدول Admins فقط)
  // ══════════════════════════════════════════════════════════════

  /// POST إنشاء أدمن جديد
  static const String addAdmin = '/api/admin/add-admin';

  /// GET قائمة الأدمنز
  static const String admins = '/api/admin/admins';

  /// DELETE حذف أدمن
  static String adminById(String id) => '/api/admin/admins/$id';

  /// PATCH تفعيل/تعطيل أدمن
  static String adminToggleActive(String id) =>
      '/api/admin/admins/$id/toggle-active';

  /// GET / PUT صلاحيات الأدمن
  static String adminPermissions(String id) =>
      '/api/admin/admins/$id/permissions';

  // ══════════════════════════════════════════════════════════════
  // الإدارة الخلفية — العملاء (Admin only)
  // ══════════════════════════════════════════════════════════════

  /// قائمة وإنشاء العملاء (?search=&employeeId=&isApproved=)
  static const String customers = '/api/customers';

  /// جلب/تحديث/حذف عميل
  static String customerById(String id) => '/api/customers/$id';

  /// PATCH الموافقة على عميل
  static String customerApprove(String id) => '/api/customers/$id/approve';

  // ══════════════════════════════════════════════════════════════
  // الإدارة الخلفية — الموظفون (جدول واحد، يدعم أدواراً متعددة)
  // ══════════════════════════════════════════════════════════════

  /// قائمة وإنشاء الموظفين (?search=&employeeType=)
  static const String employees = '/api/employees';

  /// جلب/تحديث/حذف موظف
  static String employeeById(String id) => '/api/employees/$id';

  // ══════════════════════════════════════════════════════════════
  // الإدارة الخلفية — الفروع (Admin only)
  // ══════════════════════════════════════════════════════════════

  /// قائمة وإنشاء الفروع (?search=&isActive=)
  static const String branches = '/api/branches';
  static String branchById(String id) => '/api/branches/$id';

  // ══════════════════════════════════════════════════════════════
  // الإدارة الخلفية — التصنيفات
  // ══════════════════════════════════════════════════════════════

  /// قائمة (Authenticated) / إنشاء (Admin) — مع بحث
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';

  // ══════════════════════════════════════════════════════════════
  // الإدارة الخلفية — المنتجات
  // ══════════════════════════════════════════════════════════════

  /// قائمة (Authenticated) / إنشاء (Admin) — (?search=&categoryId=)
  static const String products = '/api/products';
  static String productById(String id) => '/api/products/$id';

  // ══════════════════════════════════════════════════════════════
  // الإدارة الخلفية — المستودعات (Admin only)
  // ══════════════════════════════════════════════════════════════

  /// قائمة وإنشاء المستودعات (?search=)
  static const String warehouses = '/api/warehouses';
  static String warehouseById(String id) => '/api/warehouses/$id';

  // ══════════════════════════════════════════════════════════════
  // الإدارة الخلفية — المخزون (Admin only)
  // ══════════════════════════════════════════════════════════════

  /// GET (?productId=&warehouseId=) و POST لإضافة/زيادة كمية
  static const String inventory = '/api/inventory';

  /// PUT (?quantity=N) لتعيين كمية مطلقة، DELETE لحذف الصف
  static String inventoryById(String id) => '/api/inventory/$id';

  // ══════════════════════════════════════════════════════════════
  // الإدارة الخلفية — العروض
  // ══════════════════════════════════════════════════════════════

  /// قائمة العروض النشطة (Authenticated)
  static const String offers = '/api/offers';

  /// قائمة كاملة فلترة (Admin)
  static const String offersAll = '/api/offers/all';

  /// GET فحص العروض الفعّالة (?productId=&promoCode=)
  static const String offersCheck = '/api/offers/check';

  /// GET التحقق من كود الخصم (?promoCode=&productId=)
  static const String offersValidatePromo = '/api/offers/validate-promo';

  /// عرض/تحديث/حذف عرض (Admin)
  static String offerById(String id) => '/api/offers/$id';

  // ══════════════════════════════════════════════════════════════
  // الإعدادات — شركة / إدارة
  // ══════════════════════════════════════════════════════════════

  /// GET إعدادات الشركة (SystemSettingsDto) — أي مستخدم مصدَّق (شعار، اسم، إلخ)
  static const String settingsCompany = '/api/settings/company';

  /// GET/PUT إعدادات النظام — Admin فقط
  static const String settings = '/api/settings';

  // ══════════════════════════════════════════════════════════════
  // أسماء قديمة محفوظة لتوافق الشاشات الإدارية الموجودة حالياً
  // ══════════════════════════════════════════════════════════════

  /// قائمة العملاء في الإدارة الخلفية → /api/customers
  static const String adminCustomers = customers;

  /// قائمة المندوبين في الإدارة الخلفية → /api/employees
  /// (يُستخدم مع `?employeeType=...` أو فلترة الأدوار من جانب العميل)
  static const String adminRepresentatives = employees;

  /// قائمة السائقين في الإدارة الخلفية → /api/employees
  static const String adminDrivers = employees;

  /// تقرير ملخّص — تقرير المدير
  static const String adminDashboard = '/api/mobile/manager/reports/summary';

  /// تقرير الديون — تقرير المدير
  static const String debts = '/api/mobile/manager/reports/debts';

  /// طلبات الموافقة المعلّقة — تقرير المدير
  static const String adminPendingApprovals = '/api/mobile/manager/customers/pending';
}