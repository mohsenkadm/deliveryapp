import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/customer_models.dart';

// مصدر بيانات العميل عن بُعد
class CustomerRemoteDataSource {
  final DioClient _dioClient;
  CustomerRemoteDataSource(this._dioClient);

  /// GET المنتجات مع بحث وفلترة وترقيم صفحات
  /// [nearExpiryDays] أظهر فقط المنتجات المنتهية خلال X يوم.
  Future<ProductListResult> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? branchId,
    int? nearExpiryDays,
  }) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (branchId != null) params['branchId'] = branchId;
    if (nearExpiryDays != null) params['nearExpiryDays'] = nearExpiryDays;

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

  /// GET قائمة التصنيفات (?search=)
  Future<List<CategoryModel>> getCategories({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _dioClient.get(
      ApiConstants.categories,
      queryParameters: params.isEmpty ? null : params,
    );
    final body = response.data['data'] ?? response.data;
    final List raw = body is List ? body : (body['data'] ?? body['items'] ?? []);
    return raw
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
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

  /// POST إنشاء طلب — يستخدم `CreateInvoiceDto`.
  /// يقوم الخادم تلقائياً بحقن `customerId` من توكن JWT.
  ///
  /// شكل عنصر `details`:
  ///   { productId, quantity, unitPrice?, discount? }
  ///
  /// [deliveryScheduleType]: 'Immediate' أو 'Scheduled'.
  /// [scheduledDeliveryDate]: مطلوب عندما يكون النوع 'Scheduled'.
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    String? notes,
    String? promoCode,
    String? address, // غير مستخدم — مُحتفَظ به للتوافق مع الواجهات القديمة
    String deliveryScheduleType = 'Immediate',
    DateTime? scheduledDeliveryDate,
  }) async {
    // قبول كلا الشكلين {productId, quantity, ...} و{id, qty} لأقصى توافق.
    final details = items.map((m) {
      final productId = m['productId'] ?? m['product_id'] ?? m['id'];
      final quantity = m['quantity'] ?? m['qty'] ?? 1;
      return <String, dynamic>{
        'productId': productId,
        'quantity': quantity,
        if (m['unitPrice'] != null) 'unitPrice': m['unitPrice'],
        if (m['discount'] != null) 'discount': m['discount'],
      };
    }).toList();

    final response = await _dioClient.post(
      ApiConstants.customerCreateOrder,
      data: {
        'dto': {
          'invoiceSource': 2, // Customer (enum int)
          'details': details,
          if (notes != null) 'notes': notes,
          if (promoCode != null) 'promoCode': promoCode,
          'deliveryScheduleType': deliveryScheduleType,
          if (scheduledDeliveryDate != null)
            'scheduledDeliveryDate':
                scheduledDeliveryDate.toUtc().toIso8601String(),
        },
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

  /// GET ملخص الديون مع فلاتر التاريخ/المبلغ والفرز.
  ///
  /// [sortBy] = `date` | `amount`. [sortDir] = `asc` | `desc`.
  Future<DebtSummaryModel> getMyDebts({
    DateTime? from,
    DateTime? to,
    double? minAmount,
    double? maxAmount,
    String? sortBy,
    String? sortDir,
  }) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from.toUtc().toIso8601String();
    if (to != null) params['to'] = to.toUtc().toIso8601String();
    if (minAmount != null) params['minAmount'] = minAmount;
    if (maxAmount != null) params['maxAmount'] = maxAmount;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortDir != null) params['sortDir'] = sortDir;

    final response = await _dioClient.get(
      ApiConstants.customerDebts,
      queryParameters: params.isEmpty ? null : params,
    );
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
