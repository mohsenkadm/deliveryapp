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

  /// POST تحديث حالة الطلب
  ///
  /// الواجهة الحالية تقبل فقط `AwaitingDelivery` أو `Completed` من السائق.
  /// أي قيمة أخرى ستُرفض من جانب العميل قبل إرسالها للخادم.
  Future<void> updateOrderStatus(String orderId, String status) async {
    const allowed = {'AwaitingDelivery', 'Completed'};
    if (!allowed.contains(status)) {
      throw ArgumentError(
          'حالة غير مسموحة للسائق: $status. القيم المسموحة: $allowed');
    }
    await _dioClient.post(
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
