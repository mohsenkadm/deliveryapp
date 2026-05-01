// متحكم المشرف
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/supervisor_remote_datasource.dart';

class SupervisorController extends GetxController {
  late final SupervisorRemoteDataSource _ds;

  final reps = <Map<String, dynamic>>[].obs;
  final selectedRepInvoices = <Map<String, dynamic>>[].obs;
  final selectedRepPayments = <Map<String, dynamic>>[].obs;
  final selectedRepCustomers = <Map<String, dynamic>>[].obs;
  final pendingCustomers = <Map<String, dynamic>>[].obs;
  final salesReport = <Map<String, dynamic>>[].obs;

  final isLoading = true.obs;
  final isActing = false.obs;
  final selectedRepId = Rxn<String>();
  final selectedRepName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _ds = SupervisorRemoteDataSource(Get.find<DioClient>());
    loadReps();
    loadPendingCustomers();
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

  Future<void> loadRepPayments(String repId) async {
    isLoading.value = true;
    try {
      selectedRepPayments.value = await _ds.getRepPayments(repId);
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> loadRepCustomers(String repId) async {
    isLoading.value = true;
    try {
      selectedRepCustomers.value = await _ds.getRepCustomers(repId);
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

  Future<void> loadSalesReport({String? from, String? to}) async {
    isLoading.value = true;
    try {
      salesReport.value = await _ds.getSalesReport(from: from, to: to);
    } catch (_) {}
    isLoading.value = false;
  }
}
