import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_parser.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/helpers.dart';
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
    int? nearExpiryDays,
  }) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (branchId != null) params['branchId'] = branchId;
    if (nearExpiryDays != null) params['nearExpiryDays'] = nearExpiryDays;

    final response = await _dioClient.get(
      ApiConstants.customerProducts,
      queryParameters: params,
    );

    return parseApi<ProductListResult>(response, (data) {
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        final List raw = m['products'] ?? m['data'] ?? m['items'] ?? [];
        return ProductListResult(
          total: ((m['totalCount'] ?? m['total'] ?? 0) as num).toInt(),
          page: (m['page'] as num?)?.toInt() ?? page,
          pageSize: (m['pageSize'] as num?)?.toInt() ?? pageSize,
          items: raw
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      if (data is List) {
        return ProductListResult(
          total: data.length,
          page: page,
          pageSize: pageSize,
          items: data
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return ProductListResult(
        total: 0,
        page: page,
        pageSize: pageSize,
        items: const [],
      );
    });
  }

  /// GET قائمة التصنيفات (?search=)
  Future<List<CategoryModel>> getCategories({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _dioClient.get(
      ApiConstants.categories,
      queryParameters: params.isEmpty ? null : params,
    );
    return parseApi<List<CategoryModel>>(response, (data) {
      if (data == null) return <CategoryModel>[];
      final List raw = data is List
          ? data
          : (data is Map
              ? (data['data'] ?? data['items'] ?? [])
              : []);
      return raw
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// GET الطلبات مع فلتر الحالة
  Future<List<OrderModel>> getMyOrders({String? status}) async {
    final params = <String, dynamic>{};
    final code = InvoiceStatusHelper.statusQueryParam(status);
    if (code != null) params['status'] = code;
    final response = await _dioClient.get(
      ApiConstants.customerOrders,
      queryParameters: params.isEmpty ? null : params,
    );
    return parseApi<List<OrderModel>>(response, (data) {
      if (data == null) return <OrderModel>[];
      final List raw = data is List ? data : [];
      return raw.map((e) => OrderModel.fromJson(e)).toList();
    });
  }

  /// GET تفاصيل طلب
  Future<OrderModel> getOrderDetail(String id) async {
    final response =
        await _dioClient.get(ApiConstants.customerOrderDetail(id));
    return parseApi(response, (data) => OrderModel.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : const {}));
  }

  /// POST إنشاء طلب — CreateInvoiceDto (لا ترسل customerId — من JWT).
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    String? notes,
    String? promoCode,
    String? address,
    String deliveryScheduleType = 'Immediate',
    DateTime? scheduledDeliveryDate,
  }) async {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    num toNum(dynamic v) {
      if (v is num) return v;
      return num.tryParse(v?.toString() ?? '') ?? 0;
    }

    final details = items.map((m) {
      return <String, dynamic>{
        'productId': toInt(m['productId'] ?? m['product_id'] ?? m['id']),
        'quantity': toInt(m['quantity'] ?? m['qty'] ?? 1),
        'unitPrice': toNum(m['unitPrice'] ?? m['price'] ?? 0),
        'discount': toNum(m['discount'] ?? 0),
      };
    }).toList();

    final scheduleInt =
        deliveryScheduleType.toLowerCase() == 'scheduled' ? 1 : 0;

    final body = <String, dynamic>{
      if (promoCode != null && promoCode.trim().isNotEmpty)
        'promoCode': promoCode.trim(),
      'deliveryScheduleType': scheduleInt,
      if (scheduleInt == 1 && scheduledDeliveryDate != null)
        'scheduledDeliveryDate':
            scheduledDeliveryDate.toUtc().toIso8601String(),
      'details': details,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final response = await _dioClient.post(
      ApiConstants.customerCreateOrder,
      data: body,
    );
    return parseApi(response, (data) => OrderModel.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : const {}));
  }

  /// POST إلغاء طلب (Pending فقط)
  Future<void> cancelOrder(String id) async {
    parseApiVoid(await _dioClient.post(ApiConstants.customerCancelOrder(id)));
  }

  /// GET رابط HTML فاتورة — يُعرض في WebView
  String getInvoiceUrl(String id) =>
      '${ApiConstants.baseUrl}${ApiConstants.customerOrderInvoice(id)}';

  /// GET ملخص الديون مع فلاتر التاريخ/المبلغ والفرز.
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
    return parseApi(response, (data) => DebtSummaryModel.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : const {}));
  }

  /// GET إشعارات العميل
  Future<List<NotificationModel>> getNotifications() async {
    final response =
        await _dioClient.get(ApiConstants.customerNotifications);
    return parseApi<List<NotificationModel>>(response, (data) {
      final List raw = data is List ? data : [];
      return raw.map((e) => NotificationModel.fromJson(e)).toList();
    });
  }

  /// PATCH تعليم إشعار كمقروء
  Future<void> markNotificationRead(String id) async {
    parseApiVoid(await _dioClient.patch(
        ApiConstants.customerMarkNotificationRead(id)));
  }

  /// GET فحص العروض الفعّالة على منتج أو كود ترويجي
  Future<List<Map<String, dynamic>>> checkOffers({
    String? productId,
    String? promoCode,
  }) async {
    final params = <String, dynamic>{};
    if (productId != null) params['productId'] = productId;
    if (promoCode != null) params['promoCode'] = promoCode;
    if (params.isEmpty) return const [];
    final response = await _dioClient.get(
      ApiConstants.offersCheck,
      queryParameters: params,
    );
    return parseApi<List<Map<String, dynamic>>>(response, (data) {
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return const [];
    });
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
