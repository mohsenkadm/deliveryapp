// متحكم مدير المبيعات
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/sales_manager_remote_datasource.dart';

class SalesManagerController extends GetxController {
  late final SalesManagerRemoteDataSource _ds;

  final reps = <Map<String, dynamic>>[].obs;
  final selectedRepInvoices = <Map<String, dynamic>>[].obs;
  final pendingCustomers = <Map<String, dynamic>>[].obs;
  final pendingInvoices = <Map<String, dynamic>>[].obs;
  final debtsReport = <Map<String, dynamic>>[].obs;
  final paymentsReport = <Map<String, dynamic>>[].obs;
  final salesSummary = Rxn<Map<String, dynamic>>();

  final isLoading = true.obs;
  final isActing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _ds = SalesManagerRemoteDataSource(Get.find<DioClient>());
    _loadInitialData();
  }

  void _loadInitialData() {
    loadReps();
    loadPendingCustomers();
    loadPendingInvoices();
  }

  Future<void> loadReps() async {
    isLoading.value = true;
    try {
      reps.value = await _ds.getReps();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> loadRepInvoices(String repId, {String? status}) async {
    isLoading.value = true;
    try {
      selectedRepInvoices.value =
          await _ds.getRepInvoices(repId, status: status);
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> loadPendingCustomers() async {
    try {
      pendingCustomers.value = await _ds.getPendingCustomers();
    } catch (_) {}
  }

  Future<void> approveCustomer(String id) async {
    isActing.value = true;
    try {
      await _ds.approveCustomer(id);
      SnackbarHelper.showSuccess('تمت الموافقة على العميل');
      await loadPendingCustomers();
    } catch (_) {
      SnackbarHelper.showError('فشلت عملية الموافقة');
    }
    isActing.value = false;
  }

  Future<void> rejectCustomer(String id) async {
    isActing.value = true;
    try {
      await _ds.rejectCustomer(id);
      SnackbarHelper.showSuccess('تم رفض العميل');
      await loadPendingCustomers();
    } catch (_) {
      SnackbarHelper.showError('فشلت عملية الرفض');
    }
    isActing.value = false;
  }

  Future<void> loadPendingInvoices() async {
    try {
      pendingInvoices.value = await _ds.getPendingInvoices();
    } catch (_) {}
  }

  Future<void> approveInvoice(String id) async {
    isActing.value = true;
    try {
      await _ds.approveInvoice(id);
      SnackbarHelper.showSuccess('تمت الموافقة على الفاتورة');
      await loadPendingInvoices();
    } catch (_) {
      SnackbarHelper.showError('فشلت عملية الموافقة');
    }
    isActing.value = false;
  }

  Future<void> rejectInvoice(String id, {String? reason}) async {
    isActing.value = true;
    try {
      await _ds.rejectInvoice(id, reason: reason);
      SnackbarHelper.showSuccess('تم رفض الفاتورة');
      await loadPendingInvoices();
    } catch (_) {
      SnackbarHelper.showError('فشلت عملية الرفض');
    }
    isActing.value = false;
  }

  Future<void> loadSalesSummary({String? from, String? to}) async {
    isLoading.value = true;
    try {
      salesSummary.value =
          await _ds.getSalesSummary(from: from, to: to);
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> loadDebtsReport() async {
    isLoading.value = true;
    try {
      debtsReport.value = await _ds.getDebtsReport();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> loadPaymentsReport({bool? verified}) async {
    isLoading.value = true;
    try {
      paymentsReport.value =
          await _ds.getPaymentsReport(verified: verified);
    } catch (_) {}
    isLoading.value = false;
  }
}
