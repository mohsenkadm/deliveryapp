// مصدر بيانات مدير المبيعات عن بُعد
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class SalesManagerRemoteDataSource {
  final DioClient _dioClient;
  SalesManagerRemoteDataSource(this._dioClient);

  Future<List<Map<String, dynamic>>> getReps() async {
    final r = await _dioClient.get(ApiConstants.managerReps);
    final List data = r.data['data'] ?? r.data;
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getRepInvoices(String repId,
      {String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final r = await _dioClient.get(ApiConstants.managerRepInvoices(repId),
        queryParameters: params);
    final List data = r.data['data'] ?? r.data;
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPendingCustomers() async {
    final r = await _dioClient.get(ApiConstants.managerPendingCustomers);
    final List data = r.data['data'] ?? r.data;
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> approveCustomer(String id) async {
    await _dioClient.post(ApiConstants.managerApproveCustomer(id));
  }

  Future<void> rejectCustomer(String id) async {
    await _dioClient.post(ApiConstants.managerRejectCustomer(id));
  }

  Future<List<Map<String, dynamic>>> getPendingInvoices() async {
    final r = await _dioClient.get(ApiConstants.managerPendingInvoices);
    final List data = r.data['data'] ?? r.data;
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> approveInvoice(String id) async {
    await _dioClient.post(ApiConstants.managerApproveInvoice(id));
  }

  Future<void> rejectInvoice(String id, {String? reason}) async {
    await _dioClient.post(ApiConstants.managerRejectInvoice(id),
        data: reason != null ? {'reason': reason} : null);
  }

  Future<Map<String, dynamic>> getSalesSummary({String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final r = await _dioClient.get(ApiConstants.managerSummaryReport,
        queryParameters: params);
    return (r.data['data'] ?? r.data) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getDebtsReport() async {
    final r = await _dioClient.get(ApiConstants.managerDebtsReport);
    final List data = r.data['data'] ?? r.data;
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPaymentsReport({bool? verified}) async {
    final params = <String, dynamic>{};
    if (verified != null) params['verified'] = verified;
    final r = await _dioClient.get(ApiConstants.managerPaymentsReport,
        queryParameters: params);
    final List data = r.data['data'] ?? r.data;
    return data.cast<Map<String, dynamic>>();
  }
}
