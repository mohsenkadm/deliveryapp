import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/rep_warehouse_inventory_result.dart';

// مصدر بيانات المندوب عن بُعد
class RepresentativeRemoteDataSource {
  final DioClient _dioClient;
  RepresentativeRemoteDataSource(this._dioClient);

  // ── العملاء ──

  /// GET عملاء المندوب ?pendingApproval=true|false
  Future<List<Map<String, dynamic>>> getCustomers(
      {bool? pendingApproval}) async {
    final params = <String, dynamic>{};
    if (pendingApproval != null) {
      params['pendingApproval'] = pendingApproval;
    }
    final response = await _dioClient.get(ApiConstants.repCustomers,
        queryParameters: params);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  /// POST إضافة عميل جديد عبر المندوب
  Future<void> addCustomer(Map<String, dynamic> data) async {
    await _dioClient.post(ApiConstants.repAddCustomer, data: data);
  }

  // ── الفواتير ──

  /// GET فواتير المندوب ?status=
  Future<List<Map<String, dynamic>>> getInvoices({String? status, String? customerId}) async {
    final params = <String, dynamic>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (customerId != null) params['customerId'] = customerId;
    final response = await _dioClient.get(ApiConstants.repInvoices,
        queryParameters: params);
    final raw = response.data['data'] ?? response.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// GET تفاصيل فاتورة
  Future<Map<String, dynamic>> getInvoiceDetail(String id) async {
    final response =
        await _dioClient.get(ApiConstants.repInvoiceDetail(id));
    return (response.data['data'] ?? response.data)
        as Map<String, dynamic>;
  }

  /// POST إنشاء فاتورة للعميل
  Future<Map<String, dynamic>> createInvoice(
      Map<String, dynamic> data) async {
    final response = await _dioClient.post(
        ApiConstants.repCreateInvoice, data: data);
    return (response.data['data'] ?? response.data)
        as Map<String, dynamic>;
  }

  // ── المدفوعات ──

  /// POST تحصيل دفعة من عميل
  Future<void> collectPayment({
    String? invoiceId,
    String? customerId,
    required double amount,
    String? notes,
  }) async {
    await _dioClient.post(ApiConstants.repCollectPayment, data: {
      if (invoiceId != null) 'invoiceId': invoiceId,
      if (customerId != null) 'customerId': customerId,
      'amount': amount,
      if (notes != null) 'notes': notes,
    });
  }

  /// POST تسليم نقدية للمحاسب
  Future<void> submitPayment({
    String? invoiceId,
    required double amount,
    String? notes,
  }) async {
    await _dioClient.post(ApiConstants.repSubmitPayment, data: {
      if (invoiceId != null) 'invoiceId': invoiceId,
      'amount': amount,
      if (notes != null) 'notes': notes,
    });
  }

  /// GET سجل المدفوعات
  Future<List<Map<String, dynamic>>> getPayments() async {
    final response = await _dioClient.get(ApiConstants.repPayments);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  // ── الديون ──

  /// GET ديون العملاء
  Future<List<Map<String, dynamic>>> getDebts() async {
    final response = await _dioClient.get(ApiConstants.repDebts);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  // ── المستودع ──

  /// GET مخزون المستودع الفرعي للمندوب (بدون استعلام قديم).
  Future<RepWarehouseInventoryResult> getWarehouseInventory() async {
    final response = await _dioClient.get(ApiConstants.repWarehouse);
    return RepWarehouseInventoryResult.fromResponse(
      response.data,
      fromMainWarehouse: false,
    );
  }

  /// GET المستودعات الرئيسية (id, name, branchId)
  Future<List<Map<String, dynamic>>> getMainWarehouses() async {
    final response = await _dioClient.get(ApiConstants.repWarehousesMain);
    final raw = response.data['data'] ?? response.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// يوحّد حقول واجهة المنتج من ردّ `main-warehouses` (id/name/mainWarehouseStock/…).
  static Map<String, dynamic> _normalizeMainWarehouseProductRow(
      Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);
    m['productId'] ??= m['id'];
    m['productName'] ??= m['name'];
    m['productCode'] ??= m['code'];

    if (m['quantity'] == null) {
      int stock = 0;
      final main = m['mainWarehouseStock'];
      if (main is num) {
        stock = main.toInt();
      } else {
        stock = int.tryParse(main?.toString() ?? '') ?? 0;
      }
      if (stock <= 0) {
        final list = m['stocksByWarehouse'];
        if (list is List) {
          for (final e in list) {
            if (e is Map) {
              final q = e['quantity'];
              if (q is num) stock += q.toInt();
            }
          }
        }
      }
      m['quantity'] = stock;
    }
    return m;
  }

  /// GET منتجات برصيد في المستودعات الرئيسية فقط.
  Future<List<Map<String, dynamic>>> getMainWarehouseProducts({
    String? search,
    String? categoryId,
    String? warehouseId,
    int? nearExpiryDays,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (warehouseId != null) params['warehouseId'] = warehouseId;
    if (nearExpiryDays != null) params['nearExpiryDays'] = nearExpiryDays;

    final response = await _dioClient.get(
      ApiConstants.repProductsMainWarehouses,
      queryParameters: params.isEmpty ? null : params,
    );
    final envelope = response.data['data'] ?? response.data;
    if (envelope is List) {
      return envelope
          .whereType<Map>()
          .map((e) => _normalizeMainWarehouseProductRow(
              Map<String, dynamic>.from(e)))
          .toList();
    }
    if (envelope is Map) {
      final inner = envelope['data'] ?? envelope['items'];
      if (inner is List) {
        return inner
            .whereType<Map>()
            .map((e) => _normalizeMainWarehouseProductRow(
                Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return const [];
  }

  // ── أوامر النقل ──

  /// POST طلب نقل مخزون (رئيسي → فرعي) — نفس شكل الـ API:
  /// `fromWarehouseId`, `toWarehouseId`, `orderType`, `notes`, `details[]`.
  Future<void> requestTransfer(Map<String, dynamic> body) async {
    await _dioClient.post(ApiConstants.repTransferOrders, data: body);
  }

  /// POST إرجاع مخزون (فرعي → رئيسي).
  Future<void> returnTransfer(Map<String, dynamic> body) async {
    await _dioClient.post(ApiConstants.repReturnTransfer, data: body);
  }

  /// GET قائمة أوامر النقل ?status=
  Future<List<Map<String, dynamic>>> getTransferOrders(
      {String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final response = await _dioClient.get(
        ApiConstants.repTransferOrdersList,
        queryParameters: params.isEmpty ? null : params);
    final raw = response.data['data'] ?? response.data;
    if (raw is! List) return const [];
    return raw
        .map((e) => e is Map ? Map<String, dynamic>.from(e) : null)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  /// GET فحص العروض الفعّالة (?productId=&promoCode=)
  Future<List<Map<String, dynamic>>> checkOffers({
    String? productId,
    String? promoCode,
  }) async {
    final params = <String, dynamic>{};
    if (productId != null) params['productId'] = productId;
    if (promoCode != null) params['promoCode'] = promoCode;
    if (params.isEmpty) return const [];
    final response = await _dioClient
        .get(ApiConstants.offersCheck, queryParameters: params);
    final raw = response.data['data'] ?? response.data;
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }
}
