// مصدر بيانات المشرف عن بُعد
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_parser.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/helpers.dart';

class SupervisorRemoteDataSource {
  final DioClient _dioClient;
  SupervisorRemoteDataSource(this._dioClient);

  Future<List<Map<String, dynamic>>> getReps() async {
    return parseApiList(await _dioClient.get(ApiConstants.supervisorReps));
  }

  Future<List<Map<String, dynamic>>> getRepInvoices(String repId,
      {String? status}) async {
    final params = <String, dynamic>{};
    final code = InvoiceStatusHelper.statusQueryParam(status);
    if (code != null) params['status'] = code;
    final response = await _dioClient.get(
      ApiConstants.supervisorRepInvoices(repId),
      queryParameters: params.isEmpty ? null : params,
    );
    return parseApiList(response);
  }

  Future<List<Map<String, dynamic>>> getRepPayments(String repId) async {
    return parseApiList(await _dioClient
        .get(ApiConstants.supervisorRepPayments(repId)));
  }

  Future<List<Map<String, dynamic>>> getRepCustomers(String repId) async {
    return parseApiList(await _dioClient
        .get(ApiConstants.supervisorRepCustomers(repId)));
  }

  Future<List<Map<String, dynamic>>> getPendingCustomers() async {
    return parseApiList(
        await _dioClient.get(ApiConstants.supervisorPendingCustomers));
  }

  Future<void> approveCustomer(String id) async {
    parseApiVoid(
        await _dioClient.post(ApiConstants.supervisorApproveCustomer(id)));
  }

  Future<void> rejectCustomer(String id, {String? reason}) async {
    parseApiVoid(await _dioClient.post(
      ApiConstants.supervisorRejectCustomer(id),
      data: reason != null ? {'reason': reason} : null,
    ));
  }

  Future<List<Map<String, dynamic>>> getSalesReport(
      {String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final response = await _dioClient.get(
      ApiConstants.supervisorSalesReport,
      queryParameters: params.isEmpty ? null : params,
    );
    return parseApiList(response);
  }
}
