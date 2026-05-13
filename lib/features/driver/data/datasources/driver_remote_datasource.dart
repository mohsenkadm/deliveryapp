import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/helpers.dart';
import '../models/driver_models.dart';

// مصدر بيانات السائق عن بُعد — مسارات /api/mobile/driver
class DriverRemoteDataSource {
  final DioClient _dioClient;
  DriverRemoteDataSource(this._dioClient);

  /// GET طلبات السائق مع فلتر الحالة.
  /// عند حذف الفلتر يعيد الخادم خط الأنابيب النشط مع حقول المبالغ.
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

  /// POST تأكيد الاستلام من المستودع — WarehouseProcessing → AwaitingDelivery
  Future<void> confirmPickup(String orderId) async {
    await _dioClient.post(ApiConstants.driverOrderPickup(orderId));
  }

  /// POST تأكيد التسليم للعميل — AwaitingDelivery → Delivered
  Future<void> confirmDelivered(String orderId) async {
    await _dioClient.post(ApiConstants.driverOrderDeliver(orderId));
  }

  /// POST تحصيل نقدي من العميل (اختياري) — DriverCollectPaymentDto
  Future<void> collectPayment(
    String orderId, {
    bool recordPayment = true,
    double amount = 0,
    String? notes,
  }) async {
    await _dioClient.post(
      ApiConstants.driverOrderCollect(orderId),
      data: <String, dynamic>{
        'recordPayment': recordPayment,
        'amount': amount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  /// PATCH تحديث الحالة — مثلاً مؤجل أو مرفوض (لا يُستخدم للتسليم أو الإكمال).
  ///
  /// للانتقال إلى Delivered من AwaitingDelivery يُفضَّل استخدام [confirmDelivered].
  Future<void> updateOrderStatus(String orderId, String status) async {
    // التسليم إلى Delivered عبر POST /deliver فقط — لا يُستخدم PATCH هنا.
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
    await _dioClient.patch(
      ApiConstants.driverOrderStatus(orderId),
      data: {'status': code},
    );
  }

  @Deprecated('استخدم confirmDelivered')
  Future<void> confirmDelivery(String orderId) =>
      confirmDelivered(orderId);

  /// GET ملخص الأداء
  Future<DriverSummaryModel> getSummary() async {
    final response = await _dioClient.get(ApiConstants.driverSummary);
    return DriverSummaryModel.fromJson(
        response.data['data'] ?? response.data);
  }
}
