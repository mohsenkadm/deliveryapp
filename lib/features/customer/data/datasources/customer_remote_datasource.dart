import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/customer_models.dart';

// مصدر بيانات العميل عن بُعد
class CustomerRemoteDataSource {
  final DioClient _dioClient;
  CustomerRemoteDataSource(this._dioClient);

  /// GET المنتجات مع بحث وفلترة وترقيم صفحات
  Future<ProductListResult> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? branchId,
  }) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (branchId != null) params['branchId'] = branchId;

    final response = await _dioClient.get(
        ApiConstants.customerProducts,
        queryParameters: params);

    final body = response.data['data'] ?? response.data;
    if (body is Map) {
      final List raw = body['data'] ?? [];
      return ProductListResult(
        total: body['total'] ?? 0,
        page: body['page'] ?? page,
        pageSize: body['pageSize'] ?? pageSize,
        items: raw.map((e) => ProductModel.fromJson(e)).toList(),
      );
    }
    // fallback: plain list
    final List raw = body is List ? body : [];
    return ProductListResult(
      total: raw.length,
      page: page,
      pageSize: pageSize,
      items: raw.map((e) => ProductModel.fromJson(e)).toList(),
    );
  }

  /// GET الطلبات مع فلتر الحالة
  Future<List<OrderModel>> getMyOrders({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final response = await _dioClient.get(
        ApiConstants.customerOrders,
        queryParameters: params);
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }

  /// GET تفاصيل طلب
  Future<OrderModel> getOrderDetail(String id) async {
    final response =
        await _dioClient.get(ApiConstants.customerOrderDetail(id));
    return OrderModel.fromJson(response.data['data'] ?? response.data);
  }

  /// POST إنشاء طلب (Checkout)
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    String? notes,
    String? address,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.customerCreateOrder,
      data: {
        'items': items,
        if (notes != null) 'notes': notes,
        if (address != null) 'address': address,
      },
    );
    return OrderModel.fromJson(response.data['data'] ?? response.data);
  }

  /// POST إلغاء طلب (Pending فقط)
  Future<void> cancelOrder(String id) async {
    await _dioClient.post(ApiConstants.customerCancelOrder(id));
  }

  /// GET رابط HTML فاتورة — يُعرض في WebView
  String getInvoiceUrl(String id) =>
      '${ApiConstants.baseUrl}${ApiConstants.customerOrderInvoice(id)}';

  /// GET ملخص الديون
  Future<DebtSummaryModel> getMyDebts() async {
    final response = await _dioClient.get(ApiConstants.customerDebts);
    return DebtSummaryModel.fromJson(
        response.data['data'] ?? response.data);
  }

  /// GET إشعارات العميل
  Future<List<NotificationModel>> getNotifications() async {
    final response =
        await _dioClient.get(ApiConstants.customerNotifications);
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  /// PATCH تعليم إشعار كمقروء
  Future<void> markNotificationRead(String id) async {
    await _dioClient.patch(
        ApiConstants.customerMarkNotificationRead(id));
  }
}

/// نتيجة قائمة المنتجات مع بيانات الترقيم
class ProductListResult {
  final int total;
  final int page;
  final int pageSize;
  final List<ProductModel> items;
  ProductListResult({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.items,
  });
}
