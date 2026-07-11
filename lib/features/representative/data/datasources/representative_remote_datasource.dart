import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_parser.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/helpers.dart';
import '../models/rep_models.dart';
import '../models/rep_warehouse_inventory_result.dart';

// مصدر بيانات المندوب عن بُعد
class RepresentativeRemoteDataSource {
  final DioClient _dioClient;
  RepresentativeRemoteDataSource(this._dioClient);

  Future<List<Map<String, dynamic>>> getCustomers(
      {bool? pendingApproval}) async {
    final params = <String, dynamic>{};
    if (pendingApproval != null) {
      params['pendingApproval'] = pendingApproval;
    }
    final response = await _dioClient.get(ApiConstants.repCustomers,
        queryParameters: params.isEmpty ? null : params);
    return parseApiList(response);
  }

  Future<void> addCustomer(Map<String, dynamic> data) async {
    parseApiVoid(
        await _dioClient.post(ApiConstants.repAddCustomer, data: data));
  }

  Future<List<Map<String, dynamic>>> getInvoices({
    String? status,
    String? customerId,
    int? driverId,
  }) async {
    final params = <String, dynamic>{};
    final code = InvoiceStatusHelper.statusQueryParam(status);
    if (code != null) params['status'] = code;
    if (customerId != null && customerId.isNotEmpty) {
      params['customerId'] = customerId;
    }
    if (driverId != null) params['driverId'] = driverId;
    final response = await _dioClient.get(ApiConstants.repInvoices,
        queryParameters: params.isEmpty ? null : params);
    return parseApiList(response);
  }

  Future<Map<String, dynamic>> getInvoiceDetail(String id) async {
    final response =
        await _dioClient.get(ApiConstants.repInvoiceDetail(id));
    return parseApiMap(response);
  }

  Future<Map<String, dynamic>> createInvoice(
      Map<String, dynamic> data) async {
    final response = await _dioClient.post(
        ApiConstants.repCreateInvoice, data: data);
    return parseApiMap(response);
  }

  Future<void> collectPayment({
    String? invoiceId,
    String? customerId,
    required double amount,
    String? notes,
  }) async {
    parseApiVoid(await _dioClient.post(ApiConstants.repCollectPayment, data: {
      if (invoiceId != null) 'invoiceId': invoiceId,
      if (customerId != null) 'customerId': customerId,
      'amount': amount,
      if (notes != null) 'notes': notes,
    }));
  }

  Future<void> submitPayment({
    String? invoiceId,
    required double amount,
    String? notes,
  }) async {
    parseApiVoid(await _dioClient.post(ApiConstants.repSubmitPayment, data: {
      if (invoiceId != null) 'invoiceId': invoiceId,
      'amount': amount,
      if (notes != null) 'notes': notes,
    }));
  }

  Future<List<Map<String, dynamic>>> getPayments() async {
    final response = await _dioClient.get(ApiConstants.repPayments);
    return parseApiList(response);
  }

  Future<List<Map<String, dynamic>>> getDebts() async {
    final response = await _dioClient.get(ApiConstants.repDebts);
    return parseApiList(response);
  }

  Future<RepLiabilityDto> getLiability() async {
    final response = await _dioClient.get(ApiConstants.repLiability);
    return parseApi(response, (data) => RepLiabilityDto.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : const {}));
  }

  Future<List<Map<String, dynamic>>> getPendingSettlementInvoices() async {
    final response =
        await _dioClient.get(ApiConstants.repInvoicesPendingSettlement);
    return parseApiList(response);
  }

  Future<RepTransferWarehousesDto> getTransferWarehouses() async {
    final response =
        await _dioClient.get(ApiConstants.repWarehousesTransfer);
    return parseApi(response, (data) => RepTransferWarehousesDto.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : const {}));
  }

  Future<List<Map<String, dynamic>>> getDrivers() async {
    final response = await _dioClient.get(ApiConstants.repDrivers);
    return parseApiList(response);
  }

  Future<RepWarehouseInventoryResult> getWarehouseInventory() async {
    final response = await _dioClient.get(ApiConstants.repWarehouse);
    return RepWarehouseInventoryResult.fromResponse(
      response.data,
      fromMainWarehouse: false,
    );
  }

  Future<List<Map<String, dynamic>>> getMainWarehouses() async {
    final response = await _dioClient.get(ApiConstants.repWarehousesMain);
    return parseApiList(response);
  }

  static Map<String, dynamic> _normalizeMainWarehouseProductRow(
      Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);
    m['productId'] ??= m['id'];
    m['productName'] ??= m['name'];
    m['productCode'] ??= m['code'];
    final nested = m['product'];
    if (nested is Map) {
      final p = Map<String, dynamic>.from(nested);
      m['productId'] ??= p['id'];
      m['productName'] ??= p['name'];
      m['wholesalePrice'] ??= p['wholesalePrice'];
      m['retailPrice'] ??= p['retailPrice'];
      m['unitPrice'] ??= p['unitPrice'] ?? p['price'];
    }
    m['wholesalePrice'] ??= m['wholesaleUnitPrice'];
    m['retailPrice'] ??= m['price'] ?? m['unitPrice'];

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
    return parseApi<List<Map<String, dynamic>>>(response, (data) {
      List raw;
      if (data is List) {
        raw = data;
      } else if (data is Map) {
        raw = data['products'] ?? data['data'] ?? data['items'] ?? [];
      } else {
        return const [];
      }
      return raw
          .whereType<Map>()
          .map((e) => _normalizeMainWarehouseProductRow(
              Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<void> requestTransfer(Map<String, dynamic> body) async {
    parseApiVoid(await _dioClient.post(
        ApiConstants.repTransferOrders, data: body));
  }

  Future<void> returnTransfer(Map<String, dynamic> body) async {
    parseApiVoid(
        await _dioClient.post(ApiConstants.repReturnTransfer, data: body));
  }

  Future<List<Map<String, dynamic>>> getTransferOrders(
      {String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) {
      final code = int.tryParse(status) ??
          InvoiceStatusHelper.statusQueryParam(status);
      if (code != null) params['status'] = code;
    }
    final response = await _dioClient.get(
      ApiConstants.repTransferOrdersList,
      queryParameters: params.isEmpty ? null : params,
    );
    return parseApiList(response);
  }

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
