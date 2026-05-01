import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

// مصدر بيانات المدير عن بُعد
class AdminRemoteDataSource {
  final DioClient _dio;
  AdminRemoteDataSource(this._dio);

  // ── لوحة التحكم ──

  /// جلب إحصائيات لوحة التحكم
  Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await _dio.get(ApiConstants.adminDashboard);
    return res.data;
  }

  // ── العملاء ──

  /// جلب جميع العملاء
  Future<List<Map<String, dynamic>>> getAllCustomers({int page = 1}) async {
    final res = await _dio.get(ApiConstants.adminCustomers, queryParameters: {'page': page});
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  /// الموافقة على عميل
  Future<void> approveCustomer(String id) async {
    await _dio.put('${ApiConstants.adminCustomers}/$id/approve');
  }

  /// رفض عميل
  Future<void> rejectCustomer(String id) async {
    await _dio.put('${ApiConstants.adminCustomers}/$id/reject');
  }

  // ── المنتجات ──

  /// جلب جميع المنتجات
  Future<List<Map<String, dynamic>>> getAllProducts({int page = 1}) async {
    final res = await _dio.get(ApiConstants.products, queryParameters: {'page': page});
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  /// إنشاء منتج جديد
  Future<void> createProduct(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.products, data: data);
  }

  /// تعديل منتج
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _dio.put('${ApiConstants.products}/$id', data: data);
  }

  /// حذف منتج
  Future<void> deleteProduct(String id) async {
    await _dio.delete('${ApiConstants.products}/$id');
  }

  // ── التصنيفات ──

  /// جلب جميع التصنيفات
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final res = await _dio.get(ApiConstants.categories);
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  /// إنشاء تصنيف
  Future<void> createCategory(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.categories, data: data);
  }

  /// تعديل تصنيف
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _dio.put('${ApiConstants.categories}/$id', data: data);
  }

  /// حذف تصنيف
  Future<void> deleteCategory(String id) async {
    await _dio.delete('${ApiConstants.categories}/$id');
  }

  // ── المستودعات ──

  /// جلب جميع المستودعات
  Future<List<Map<String, dynamic>>> getAllWarehouses() async {
    final res = await _dio.get(ApiConstants.warehouses);
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  /// إنشاء مستودع
  Future<void> createWarehouse(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.warehouses, data: data);
  }

  // ── المخزون ──

  /// جلب المخزون
  Future<List<Map<String, dynamic>>> getInventory({String? warehouseId}) async {
    final res = await _dio.get(ApiConstants.inventory, queryParameters: {if (warehouseId != null) 'warehouseId': warehouseId});
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  /// تحديث المخزون
  Future<void> updateInventory(Map<String, dynamic> data) async {
    await _dio.put(ApiConstants.inventory, data: data);
  }

  // ── الفواتير ──

  /// جلب جميع الفواتير
  Future<List<Map<String, dynamic>>> getAllInvoices({int page = 1}) async {
    final res = await _dio.get(ApiConstants.invoices, queryParameters: {'page': page});
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  /// تحديث حالة فاتورة من المدير (PATCH)
  Future<void> updateInvoiceStatus(String id, String status) async {
    await _dio.patch(ApiConstants.invoiceStatusAdmin(id), data: {'status': status});
  }

  // ── المندوبين ──

  /// جلب جميع المندوبين
  Future<List<Map<String, dynamic>>> getAllRepresentatives() async {
    final res = await _dio.get(ApiConstants.adminRepresentatives);
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  // ── السائقين ──

  /// جلب جميع السائقين
  Future<List<Map<String, dynamic>>> getAllDrivers() async {
    final res = await _dio.get(ApiConstants.adminDrivers);
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  // ── الديون ──

  /// جلب جميع الديون
  Future<List<Map<String, dynamic>>> getAllDebts() async {
    final res = await _dio.get(ApiConstants.debts);
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  /// تسوية دين
  Future<void> settleDebt(String id, Map<String, dynamic> data) async {
    await _dio.put('${ApiConstants.debts}/$id/settle', data: data);
  }

  // ── كشف حساب العميل ──

  /// جلب كشف حساب عميل
  Future<Map<String, dynamic>> getCustomerStatement(String customerId) async {
    final res = await _dio.get('${ApiConstants.adminCustomers}/$customerId/statement');
    return res.data;
  }

  // ── الموافقات المعلقة ──

  /// جلب قائمة الموافقات المعلقة
  Future<List<Map<String, dynamic>>> getPendingApprovals() async {
    final res = await _dio.get(ApiConstants.adminPendingApprovals);
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }

  // ── إضافة موظف (مندوب / سائق) ──

  /// إنشاء موظف جديد
  Future<void> createEmployee(Map<String, dynamic> data) async {
    await _dio.post('/api/admin/employees', data: data);
  }

  // ── تحديث مخزن ──

  /// تحديث بيانات مخزن
  Future<void> updateWarehouse(String id, Map<String, dynamic> data) async {
    await _dio.put('${ApiConstants.warehouses}/$id', data: data);
  }

  // ── سجل النشاط ──

  /// جلب سجل النشاط
  Future<List<Map<String, dynamic>>> getActivityLogs() async {
    final res = await _dio.get('/api/admin/activity-logs');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? res.data);
  }
}
