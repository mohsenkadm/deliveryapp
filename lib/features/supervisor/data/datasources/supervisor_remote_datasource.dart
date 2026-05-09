// مصدر بيانات المشرف عن بُعد
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class SupervisorRemoteDataSource {
  final DioClient _dioClient;
  SupervisorRemoteDataSource(this._dioClient);

  /// GET قائمة المندوبين مع إحصائياتهم
  Future<List<Map<String, dynamic>>> getReps() async {
    final response = await _dioClient.get(ApiConstants.supervisorReps);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  /// GET فواتير مندوب ?status=
  Future<List<Map<String, dynamic>>> getRepInvoices(String repId,
      {String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final response = await _dioClient.get(
        ApiConstants.supervisorRepInvoices(repId),
        queryParameters: params);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  /// GET مدفوعات مندوب
  Future<List<Map<String, dynamic>>> getRepPayments(String repId) async {
    final response = await _dioClient
        .get(ApiConstants.supervisorRepPayments(repId));
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  /// GET عملاء مندوب
  Future<List<Map<String, dynamic>>> getRepCustomers(String repId) async {
    final response = await _dioClient
        .get(ApiConstants.supervisorRepCustomers(repId));
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  /// GET العملاء المعلقة موافقتهم
  Future<List<Map<String, dynamic>>> getPendingCustomers() async {
    final response =
        await _dioClient.get(ApiConstants.supervisorPendingCustomers);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  /// POST الموافقة على عميل
  Future<void> approveCustomer(String id) async {
    await _dioClient.post(ApiConstants.supervisorApproveCustomer(id));
  }

  /// POST رفض عميل — body اختياري: { reason? }
  Future<void> rejectCustomer(String id, {String? reason}) async {
    await _dioClient.post(
      ApiConstants.supervisorRejectCustomer(id),
      data: reason != null ? {'reason': reason} : null,
    );
  }

  /// GET تقرير المبيعات ?from=&to=
  Future<List<Map<String, dynamic>>> getSalesReport(
      {String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final response = await _dioClient.get(
        ApiConstants.supervisorSalesReport,
        queryParameters: params);
    final List data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }
}
