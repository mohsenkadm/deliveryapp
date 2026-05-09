import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/employee_roles.dart';

/// مصدر بيانات الإدارة الخلفية — متوافق مع الواجهة الموحّدة الجديدة.
///
/// نقاط مهمة:
/// - العملاء: /api/customers (CRUD) + PATCH /:id/approve
/// - الموظفون: /api/employees (CRUD) — جدول واحد بأدوار CSV
/// - المنتجات/التصنيفات/المستودعات/المخزون: مسارات /api/{resource}
/// - الفواتير: PATCH /api/invoices/:id/status
/// - تقارير المدير: /api/mobile/manager/reports/...
class AdminRemoteDataSource {
  final DioClient _dio;
  AdminRemoteDataSource(this._dio);

  // ── لوحة التحكم ──

  /// تقرير ملخّص يستخدمه الأدمن كـ"لوحة تحكم" مبدئية.
  Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await _dio.get(ApiConstants.adminDashboard);
    final body = res.data;
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return Map<String, dynamic>.from(body as Map);
  }

  // ── العملاء ──

  Future<List<Map<String, dynamic>>> getAllCustomers({int page = 1}) async {
    final res = await _dio.get(ApiConstants.customers,
        queryParameters: {'page': page});
    return _list(res.data);
  }

  /// PATCH الموافقة على عميل — متوافق مع الواجهة الجديدة
  Future<void> approveCustomer(String id) async {
    await _dio.patch(ApiConstants.customerApprove(id));
  }

  /// رفض/حذف عميل — الواجهة الحالية لا توفّر "رفض"؛ نستخدم DELETE.
  Future<void> rejectCustomer(String id) async {
    await _dio.delete(ApiConstants.customerById(id));
  }

  // ── المنتجات ──

  Future<List<Map<String, dynamic>>> getAllProducts({int page = 1}) async {
    final res = await _dio.get(ApiConstants.products,
        queryParameters: {'page': page});
    return _list(res.data);
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.products, data: data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _dio.put(ApiConstants.productById(id), data: data);
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete(ApiConstants.productById(id));
  }

  // ── التصنيفات ──

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final res = await _dio.get(ApiConstants.categories);
    return _list(res.data);
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.categories, data: data);
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _dio.put(ApiConstants.categoryById(id), data: data);
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete(ApiConstants.categoryById(id));
  }

  // ── المستودعات ──

  Future<List<Map<String, dynamic>>> getAllWarehouses() async {
    final res = await _dio.get(ApiConstants.warehouses);
    return _list(res.data);
  }

  Future<void> createWarehouse(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.warehouses, data: data);
  }

  Future<void> updateWarehouse(String id, Map<String, dynamic> data) async {
    await _dio.put(ApiConstants.warehouseById(id), data: data);
  }

  // ── المخزون ──

  Future<List<Map<String, dynamic>>> getInventory(
      {String? productId, String? warehouseId}) async {
    final res = await _dio.get(ApiConstants.inventory, queryParameters: {
      if (productId != null) 'productId': productId,
      if (warehouseId != null) 'warehouseId': warehouseId,
    });
    return _list(res.data);
  }

  /// POST لإضافة/زيادة كمية — body: { productId, warehouseId, quantity }
  Future<void> addInventory(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.inventory, data: data);
  }

  /// PUT لتعيين كمية مطلقة — `?quantity=N`
  Future<void> setInventoryQuantity(String id, int quantity) async {
    await _dio.put(ApiConstants.inventoryById(id),
        queryParameters: {'quantity': quantity});
  }

  /// DELETE صف مخزون
  Future<void> deleteInventory(String id) async {
    await _dio.delete(ApiConstants.inventoryById(id));
  }

  /// متروك للتوافق — يفرز POST/PUT حسب وجود `id`.
  Future<void> updateInventory(Map<String, dynamic> data) async {
    final id = data['id']?.toString();
    final qty = data['quantity'];
    if (id != null && qty is int) {
      await setInventoryQuantity(id, qty);
    } else {
      await addInventory(data);
    }
  }

  // ── الفواتير ──

  /// قائمة الفواتير المتاحة للأدمن.
  ///
  /// ⚠️ الواجهة الحالية لا توفّر `GET /api/invoices`. النقطة الوحيدة
  /// المتاحة لإدراج الفواتير هي تقرير "الفواتير المعلّقة" للمدير، والتي
  /// يستطيع الأدمن الوصول إليها.
  Future<List<Map<String, dynamic>>> getAllInvoices({int page = 1}) async {
    final res = await _dio.get(ApiConstants.managerPendingInvoices);
    return _list(res.data);
  }

  /// PATCH تحديث حالة فاتورة — body: { status }
  Future<void> updateInvoiceStatus(String id, String status) async {
    await _dio.patch(ApiConstants.invoiceStatus(id), data: {'status': status});
  }

  // ── الموظفون (يحلّ محلّ "المندوبون" و"السائقون" المنفصلَين) ──

  /// قائمة الموظفين الذين يحملون دوراً معيّناً.
  /// الواجهة لا توفّر فلتر مباشراً للأدوار، لذا نفلتر على جانب العميل.
  Future<List<Map<String, dynamic>>> getEmployeesByRole(String role) async {
    final res = await _dio.get(ApiConstants.employees);
    final list = _list(res.data);
    return list.where((e) {
      final rolesRaw = e['roles'] ?? e['Roles'] ?? '';
      if (rolesRaw is List) {
        return rolesRaw.any((r) => r.toString() == role);
      }
      return rolesRaw.toString().split(',').contains(role);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAllRepresentatives() =>
      getEmployeesByRole(EmployeeRoles.representative);

  Future<List<Map<String, dynamic>>> getAllDrivers() =>
      getEmployeesByRole(EmployeeRoles.driver);

  /// إنشاء موظف جديد — جدول واحد، يقبل `selectedRoles[]` متعدّدة.
  Future<void> createEmployee(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.employees, data: data);
  }

  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    await _dio.put(ApiConstants.employeeById(id), data: data);
  }

  Future<void> deleteEmployee(String id) async {
    await _dio.delete(ApiConstants.employeeById(id));
  }

  // ── الديون ──

  /// تقرير ديون المندوبين (من نقطة المدير).
  Future<List<Map<String, dynamic>>> getAllDebts() async {
    final res = await _dio.get(ApiConstants.debts);
    return _list(res.data);
  }

  /// تسوية دين — غير موجود في الواجهة الحالية. أُبقي على الاسم لتوافق الواجهة.
  @Deprecated('غير مدعوم في الواجهة الحالية')
  Future<void> settleDebt(String id, Map<String, dynamic> data) async {
    // يمكن استبدالها بدفع جزئي/كامل عبر POST /api/invoices/{id}/pay عند الحاجة.
    await _dio.post(ApiConstants.invoicePay(id),
        data: {'amount': data['amount'] ?? 0});
  }

  // ── كشف حساب العميل ──
  // ملاحظة: الواجهة الحالية لا تحتوي على endpoint مخصّص لكشف الحساب.
  // نُجمّعه من فواتير العميل + ديونه عند الحاجة.
  @Deprecated('سيتم استبدالها بدمج /api/customers/{id} + الفواتير + الديون')
  Future<Map<String, dynamic>> getCustomerStatement(String customerId) async {
    final res = await _dio.get(ApiConstants.customerById(customerId));
    return Map<String, dynamic>.from(
        (res.data is Map && res.data['data'] is Map)
            ? res.data['data']
            : res.data);
  }

  // ── الموافقات المعلقة ──

  Future<List<Map<String, dynamic>>> getPendingApprovals() async {
    final res = await _dio.get(ApiConstants.adminPendingApprovals);
    return _list(res.data);
  }

  // ── سجل النشاط ──
  // غير موجود رسمياً في الواجهة. يبقى placeholder لاحتمال إضافته لاحقاً.
  @Deprecated('غير موجود في الواجهة الحالية')
  Future<List<Map<String, dynamic>>> getActivityLogs() async {
    return const [];
  }

  // ── الفروع ──

  Future<List<Map<String, dynamic>>> getBranches({String? search, bool? isActive}) async {
    final res = await _dio.get(ApiConstants.branches, queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    });
    return _list(res.data);
  }

  Future<void> createBranch(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.branches, data: data);
  }

  Future<void> updateBranch(String id, Map<String, dynamic> data) async {
    await _dio.put(ApiConstants.branchById(id), data: data);
  }

  Future<void> deleteBranch(String id) async {
    await _dio.delete(ApiConstants.branchById(id));
  }

  // ── العروض ──

  Future<List<Map<String, dynamic>>> getOffers({String? search, bool? isActive}) async {
    final res = await _dio.get(ApiConstants.offersAll, queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    });
    return _list(res.data);
  }

  Future<void> createOffer(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.offers, data: data);
  }

  Future<void> updateOffer(String id, Map<String, dynamic> data) async {
    await _dio.put(ApiConstants.offerById(id), data: data);
  }

  Future<void> deleteOffer(String id) async {
    await _dio.delete(ApiConstants.offerById(id));
  }

  /// التحقق من كود الخصم
  Future<Map<String, dynamic>?> validatePromo(String promoCode, {String? productId}) async {
    final res = await _dio.get(ApiConstants.offersValidatePromo, queryParameters: {
      'promoCode': promoCode,
      if (productId != null) 'productId': productId,
    });
    final body = res.data;
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return null;
  }

  // ── إعدادات النظام ──

  Future<Map<String, dynamic>> getSystemSettings() async {
    final res = await _dio.get(ApiConstants.settings);
    final body = res.data;
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return Map<String, dynamic>.from(body is Map ? body : <String, dynamic>{});
  }

  Future<void> updateSystemSettings(Map<String, dynamic> data) async {
    await _dio.put(ApiConstants.settings, data: data);
  }

  // ── صلاحيات الأدمن ──

  Future<List<Map<String, dynamic>>> getAdmins() async {
    final res = await _dio.get(ApiConstants.admins);
    return _list(res.data);
  }

  Future<List<Map<String, dynamic>>> getAdminPermissions(String adminId) async {
    final res = await _dio.get(ApiConstants.adminPermissions(adminId));
    return _list(res.data);
  }

  Future<void> updateAdminPermissions(String adminId, List<Map<String, dynamic>> perms) async {
    await _dio.put(ApiConstants.adminPermissions(adminId), data: perms);
  }

  // ── أدوات مساعدة ──

  static List<Map<String, dynamic>> _list(dynamic body) {
    final raw = (body is Map && body['data'] != null) ? body['data'] : body;
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }
}
