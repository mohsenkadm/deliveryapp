import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/driver_models.dart';

// مصدر بيانات السائق عن بُعد
class DriverRemoteDataSource {
  final DioClient _dioClient;
  DriverRemoteDataSource(this._dioClient);

  /// GET طلبات السائق مع فلتر الحالة
  Future<List<DeliveryOrderModel>> getOrders({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final response = await _dioClient.get(ApiConstants.driverOrders,
        queryParameters: params);
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => DeliveryOrderModel.fromJson(e)).toList();
  }

  /// GET تفاصيل طلب مع بيانات العميل والموقع
  Future<DeliveryOrderModel> getOrderDetail(String id) async {
    final response =
        await _dioClient.get(ApiConstants.driverOrderDetail(id));
    return DeliveryOrderModel.fromJson(
        response.data['data'] ?? response.data);
  }

  /// POST تأكيد التوصيل
  Future<void> confirmDelivery(String orderId) async {
    await _dioClient.post(ApiConstants.driverDeliver(orderId));
  }

  /// POST تحصيل دفعة من عميل
  Future<void> collectPayment(
      String orderId, double amount, String? notes) async {
    await _dioClient.post(
      ApiConstants.driverCollectPayment(orderId),
      data: {
        'amount': amount,
        if (notes != null) 'notes': notes,
      },
    );
  }

  /// POST تسليم نقدية للشركة
  Future<void> submitPayment(
      {String? invoiceId, required double amount, String? notes}) async {
    await _dioClient.post(
      ApiConstants.driverSubmitPayment,
      data: {
        if (invoiceId != null) 'invoiceId': invoiceId,
        'amount': amount,
        if (notes != null) 'notes': notes,
      },
    );
  }

  /// PATCH تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _dioClient.patch(
      ApiConstants.driverOrderStatus(orderId),
      data: {'status': status},
    );
  }

  /// GET ملخص الأداء
  Future<DriverSummaryModel> getSummary() async {
    final response = await _dioClient.get(ApiConstants.driverSummary);
    return DriverSummaryModel.fromJson(
        response.data['data'] ?? response.data);
  }
}
