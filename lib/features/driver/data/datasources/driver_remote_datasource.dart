import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_parser.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/helpers.dart';
import '../models/driver_models.dart';

// مصدر بيانات السائق عن بُعد — مسارات /api/mobile/driver
class DriverRemoteDataSource {
  final DioClient _dioClient;
  DriverRemoteDataSource(this._dioClient);

  /// GET طلبات السائق مع فلتر الحالة.
  Future<List<DeliveryOrderModel>> getOrders({String? status}) async {
    final params = <String, dynamic>{};
    final code = InvoiceStatusHelper.statusQueryParam(status);
    if (code != null) params['status'] = code;
    final response = await _dioClient.get(
      ApiConstants.driverOrders,
      queryParameters: params.isEmpty ? null : params,
    );
    return parseApi<List<DeliveryOrderModel>>(response, (data) {
      if (data == null) return <DeliveryOrderModel>[];
      final List raw = data is List ? data : [];
      return raw
          .map((e) => DeliveryOrderModel.fromJson(
              e is Map ? Map<String, dynamic>.from(e) : const {}))
          .toList();
    });
  }

  Future<DeliveryOrderModel> getOrderDetail(String id) async {
    final response =
        await _dioClient.get(ApiConstants.driverOrderDetail(id));
    return parseApi(response, (data) => DeliveryOrderModel.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : const {}));
  }

  Future<void> confirmPickup(String orderId) async {
    parseApiVoid(
        await _dioClient.post(ApiConstants.driverOrderPickup(orderId)));
  }

  Future<void> confirmDelivered(String orderId) async {
    parseApiVoid(
        await _dioClient.post(ApiConstants.driverOrderDeliver(orderId)));
  }

  Future<void> collectPayment(
    String orderId, {
    bool recordPayment = true,
    double amount = 0,
    String? notes,
  }) async {
    parseApiVoid(await _dioClient.post(
      ApiConstants.driverOrderCollect(orderId),
      data: <String, dynamic>{
        'recordPayment': recordPayment,
        'amount': amount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    ));
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    const allowed = {
      'AwaitingDelivery',
      'Rejected',
      'Deferred',
    };
    if (!allowed.contains(status)) {
      throw ArgumentError(
          'حالة غير مسموحة للسائق: $status. القيم المسموحة: $allowed');
    }
    final code = InvoiceStatusHelper.toInt(status);
    if (code == null) {
      throw ArgumentError('قيمة الحالة غير معروفة: $status');
    }
    parseApiVoid(await _dioClient.patch(
      ApiConstants.driverOrderStatus(orderId),
      data: {'status': code},
    ));
  }

  @Deprecated('استخدم confirmDelivered')
  Future<void> confirmDelivery(String orderId) =>
      confirmDelivered(orderId);

  Future<DriverSummaryModel> getSummary() async {
    final response = await _dioClient.get(ApiConstants.driverSummary);
    return parseApi(response, (data) => DriverSummaryModel.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : const {}));
  }

  Future<List<Map<String, dynamic>>> getPayments({bool? isVerified}) async {
    final params = <String, dynamic>{};
    if (isVerified != null) params['isVerified'] = isVerified;
    final response = await _dioClient.get(
      ApiConstants.driverPayments,
      queryParameters: params.isEmpty ? null : params,
    );
    return parseApiList(response);
  }

  Future<void> submitPayments({
    required double amount,
    String? notes,
  }) async {
    parseApiVoid(await _dioClient.post(ApiConstants.driverPaymentsSubmit, data: {
      'amount': amount,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    }));
  }
}
