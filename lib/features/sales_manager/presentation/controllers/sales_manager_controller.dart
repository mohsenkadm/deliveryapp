// متحكم مدير المبيعات
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/signalr_service.dart';
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
  final pendingPaymentsVerify = <Map<String, dynamic>>[].obs;
  final salesSummary = Rxn<Map<String, dynamic>>();
  final repLiability = Rxn<Map<String, dynamic>>();

  final isLoading = true.obs;
  final isActing = false.obs;

  Future<void> _refreshOnNotification() async {
    await Future.wait([
      loadPendingPaymentsVerify(),
      loadPendingInvoices(),
      loadPendingCustomers(),
    ]);
  }

  @override
  void onInit() {
    super.onInit();
    _ds = SalesManagerRemoteDataSource(Get.find<DioClient>());
    SignalRService.to.registerRefresh(_refreshOnNotification);
    _loadInitialData();
  }

  @override
  void onClose() {
    SignalRService.to.unregisterRefresh(_refreshOnNotification);
    super.onClose();
  }

  void _loadInitialData() {
    loadReps();
    loadSalesSummary();
    loadPendingCustomers();
    loadPendingInvoices();
  }

  Future<void> loadReps() async {
    isLoading.value = true;
    try {
      reps.value = await _ds.getReps();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل المندوبين');
    }
    isLoading.value = false;
  }

  Future<void> loadRepInvoices(String repId, {String? status}) async {
    isLoading.value = true;
    try {
      selectedRepInvoices.value =
          await _ds.getRepInvoices(repId, status: status);
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل فواتير المندوب');
    }
    isLoading.value = false;
  }

  Future<void> loadPendingCustomers() async {
    try {
      pendingCustomers.value = await _ds.getPendingCustomers();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل الموافقات المعلقة');
    }
  }

  Future<void> approveCustomer(String id) async {
    isActing.value = true;
    try {
      await _ds.approveCustomer(id);
      SnackbarHelper.showSuccess('تمت الموافقة على العميل');
      await loadPendingCustomers();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشلت عملية الموافقة');
    }
    isActing.value = false;
  }

  Future<void> loadRepLiability(String repId) async {
    try {
      repLiability.value = await _ds.getRepLiability(repId);
    } catch (e) {
      repLiability.value = null;
      SnackbarHelper.handleApiError(e, 'فشل تحميل ذمة المندوب');
    }
  }

  Future<void> rejectCustomer(String id, {String? reason}) async {
    isActing.value = true;
    try {
      await _ds.rejectCustomer(id, reason: reason);
      SnackbarHelper.showSuccess('تم رفض العميل');
      await loadPendingCustomers();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشلت عملية الرفض');
    }
    isActing.value = false;
  }

  Future<void> loadPendingInvoices() async {
    try {
      pendingInvoices.value = await _ds.getPendingInvoices();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل الفواتير المعلقة');
    }
  }

  Future<void> approveInvoice(String id) async {
    isActing.value = true;
    try {
      await _ds.approveInvoice(id);
      SnackbarHelper.showSuccess('تمت الموافقة على الفاتورة');
      await loadPendingInvoices();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشلت عملية الموافقة على الفاتورة');
    }
    isActing.value = false;
  }

  /// رفض فاتورة معلّقة — إرجاع المخزون يتم على السيرفر (مندوب مفرد).
  /// لا تعديل كميات محلية؛ قائمة الفواتير تُحدَّث من الـ API بعد الرفض.
  Future<void> rejectInvoice(String id, {String? reason}) async {
    isActing.value = true;
    try {
      await _ds.rejectInvoice(id, reason: reason);
      SnackbarHelper.showSuccess('تم رفض الفاتورة');
      await loadPendingInvoices();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشلت عملية رفض الفاتورة');
    }
    isActing.value = false;
  }

  Future<void> loadSalesSummary({String? from, String? to}) async {
    isLoading.value = true;
    try {
      salesSummary.value =
          await _ds.getSalesSummary(from: from, to: to);
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل ملخص المبيعات');
    }
    isLoading.value = false;
  }

  Future<void> loadDebtsReport() async {
    isLoading.value = true;
    try {
      debtsReport.value = await _ds.getDebtsReport();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل تقرير الديون');
    }
    isLoading.value = false;
  }

  Future<void> loadPaymentsReport({bool? verified}) async {
    isLoading.value = true;
    try {
      paymentsReport.value =
          await _ds.getPaymentsReport(verified: verified);
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل تقرير المدفوعات');
    }
    isLoading.value = false;
  }

  Future<void> loadPendingPaymentsVerify() async {
    isLoading.value = true;
    try {
      pendingPaymentsVerify.value = await _ds.getPendingPayments();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل الدفعات المعلّقة');
    }
    isLoading.value = false;
  }

  Future<void> verifyPayment(String id) async {
    isActing.value = true;
    try {
      await _ds.verifyPayment(id);
      SnackbarHelper.showSuccess('تم التحقق والاعتماد');
      await loadPendingPaymentsVerify();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل التحقق');
    }
    isActing.value = false;
  }
}
