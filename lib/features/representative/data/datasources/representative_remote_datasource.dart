import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

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
    if (status != null) params['status'] = status;
    if (customerId != null) params['customerId'] = customerId;
    final response = await _dioClient.get(ApiConstants.repInvoices,
        queryParameters: params);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
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

  /// GET مخزون المستودع الفرعي
  Future<List<Map<String, dynamic>>> getWarehouseInventory() async {
    final response = await _dioClient.get(ApiConstants.repWarehouse);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  // ── أوامر النقل ──

  /// POST طلب نقل مخزون (رئيسي → فرعي).
  /// الخادم يفرض النوع `OutboundToRepWarehouse` تلقائياً، لكن نُمرّره أيضاً
  /// لضمان وضوح النية على جانب العميل.
  Future<void> requestTransfer(Map<String, dynamic> data) async {
    final body = <String, dynamic>{
      ...data,
      'orderType': 'OutboundToRepWarehouse',
    };
    await _dioClient.post(ApiConstants.repTransferOrders, data: body);
  }

  /// POST إعادة مخزون (فرعي → رئيسي). النوع: `ReturnToMainWarehouse`.
  Future<void> returnTransfer(Map<String, dynamic> data) async {
    final body = <String, dynamic>{
      ...data,
      'orderType': 'ReturnToMainWarehouse',
    };
    await _dioClient.post(ApiConstants.repReturnTransfer, data: body);
  }

  /// GET قائمة أوامر النقل ?status=
  Future<List<Map<String, dynamic>>> getTransferOrders(
      {String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final response = await _dioClient.get(
        ApiConstants.repTransferOrdersList,
        queryParameters: params);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }
}
