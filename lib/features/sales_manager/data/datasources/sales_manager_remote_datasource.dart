// مصدر بيانات مدير المبيعات عن بُعد
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_parser.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/helpers.dart';

class SalesManagerRemoteDataSource {
  final DioClient _dioClient;
  SalesManagerRemoteDataSource(this._dioClient);

  Future<List<Map<String, dynamic>>> getReps() async {
    return parseApiList(await _dioClient.get(ApiConstants.managerReps));
  }

  Future<List<Map<String, dynamic>>> getRepInvoices(String repId,
      {String? status}) async {
    final params = <String, dynamic>{};
    final code = InvoiceStatusHelper.statusQueryParam(status);
    if (code != null) params['status'] = code;
    final r = await _dioClient.get(ApiConstants.managerRepInvoices(repId),
        queryParameters: params.isEmpty ? null : params);
    return parseApiList(r);
  }

  Future<List<Map<String, dynamic>>> getPendingCustomers() async {
    return parseApiList(
        await _dioClient.get(ApiConstants.managerPendingCustomers));
  }

  Future<void> approveCustomer(String id) async {
    parseApiVoid(
        await _dioClient.post(ApiConstants.managerApproveCustomer(id)));
  }

  Future<void> rejectCustomer(String id, {String? reason}) async {
    parseApiVoid(await _dioClient.post(
      ApiConstants.managerRejectCustomer(id),
      data: reason != null ? {'reason': reason} : null,
    ));
  }

  Future<List<Map<String, dynamic>>> getPendingInvoices() async {
    return parseApiList(
        await _dioClient.get(ApiConstants.managerPendingInvoices));
  }

  Future<void> approveInvoice(String id) async {
    parseApiVoid(
        await _dioClient.post(ApiConstants.managerApproveInvoice(id)));
  }

  Future<void> rejectInvoice(String id, {String? reason}) async {
    parseApiVoid(await _dioClient.post(
      ApiConstants.managerRejectInvoice(id),
      data: reason != null ? {'reason': reason} : null,
    ));
  }

  Future<Map<String, dynamic>> getSalesSummary({String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final r = await _dioClient.get(ApiConstants.managerSummaryReport,
        queryParameters: params.isEmpty ? null : params);

    return parseApi<Map<String, dynamic>>(r, (body) {
      if (body is List) {
        double totalSales = 0;
        double totalCollected = 0;
        double totalDebts = 0;
        int totalInvoices = 0;
        for (final e in body) {
          if (e is! Map) continue;
          totalSales += ((e['totalAmount'] as num?) ?? 0).toDouble();
          totalCollected += ((e['totalPaid'] as num?) ?? 0).toDouble();
          totalDebts += ((e['totalDebt'] as num?) ?? 0).toDouble();
          totalInvoices += ((e['totalInvoices'] as num?) ?? 0).toInt();
        }
        return <String, dynamic>{
          'totalSales': totalSales,
          'totalCollected': totalCollected,
          'totalDebts': totalDebts,
          'totalInvoices': totalInvoices,
          'totalReps': body.length,
          'reps': body
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        };
      }
      if (body is Map) return Map<String, dynamic>.from(body);
      return <String, dynamic>{};
    });
  }

  Future<List<Map<String, dynamic>>> getDebtsReport() async {
    return parseApiList(
        await _dioClient.get(ApiConstants.managerDebtsReport));
  }

  Future<List<Map<String, dynamic>>> getPaymentsReport({bool? verified}) async {
    final params = <String, dynamic>{};
    if (verified != null) params['verified'] = verified;
    final r = await _dioClient.get(ApiConstants.managerPaymentsReport,
        queryParameters: params.isEmpty ? null : params);
    return parseApiList(r);
  }

  Future<List<Map<String, dynamic>>> getPendingPayments() async {
    return parseApiList(
        await _dioClient.get(ApiConstants.managerPaymentsPending));
  }

  Future<void> verifyPayment(String id) async {
    parseApiVoid(
        await _dioClient.post(ApiConstants.managerPaymentVerify(id)));
  }

  Future<Map<String, dynamic>> getRepLiability(String repId) async {
    final r = await _dioClient.get(ApiConstants.managerRepLiability(repId));
    return parseApiMap(r);
  }
}
