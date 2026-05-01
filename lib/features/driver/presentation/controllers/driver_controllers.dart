// متحكمات السائق — الطلبات، التوصيل، تحصيل الدفع، ملخص الأداء
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../domain/entities/driver_entities.dart';

class DriverHomeController extends GetxController {
  late final DriverRemoteDataSource _ds;

  final assignedOrders = <DeliveryOrder>[].obs;
  final completedOrders = <DeliveryOrder>[].obs;
  final summary = Rxn<DriverSummary>();
  final isLoading = true.obs;
  final isActing = false.obs;
  final isUpdating = false.obs;
  final completedTodayCount = 0.obs;
  final selectedStatus = Rxn<String>();

  static const List<Map<String, String>> statusFilters = [
    {'label': 'الكل', 'value': ''},
    {'label': 'في التوصيل', 'value': 'AwaitingDelivery'},
    {'label': 'تم التسليم', 'value': 'Delivered'},
    {'label': 'مكتمل', 'value': 'Completed'},
    {'label': 'مرفوض', 'value': 'Rejected'},
  ];

  @override
  void onInit() {
    super.onInit();
    _ds = DriverRemoteDataSource(Get.find<DioClient>());
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([
      _loadOrders('AwaitingDelivery'),
      _loadSummary(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadOrders(String status) async {
    try {
      final orders = await _ds.getOrders(status: status);
      assignedOrders.value = orders;
    } catch (_) {}
  }

  Future<void> loadOrdersByStatus(String? status) async {
    isLoading.value = true;
    selectedStatus.value = status?.isEmpty == true ? null : status;
    try {
      final orders = await _ds.getOrders(status: selectedStatus.value);
      assignedOrders.value = orders;
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> loadCompletedDeliveries() async {
    isLoading.value = true;
    try {
      final orders = await _ds.getOrders(status: 'Completed');
      completedOrders.value = orders;
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> _loadSummary() async {
    try {
      final s = await _ds.getSummary();
      summary.value = s;
    } catch (_) {}
  }

  Future<void> refreshSummary() async {
    await _loadSummary();
  }

  /// تأكيد التوصيل
  Future<void> confirmDelivery(String orderId) async {
    isActing.value = true;
    try {
      await _ds.confirmDelivery(orderId);
      SnackbarHelper.showSuccess('تم تأكيد التوصيل بنجاح');
      await loadData();
    } catch (e) {
      SnackbarHelper.showError('فشل تأكيد التوصيل');
    }
    isActing.value = false;
  }

  /// تحصيل دفعة من عميل
  Future<void> collectPayment(
      String orderId, double amount, String? notes) async {
    isActing.value = true;
    try {
      await _ds.collectPayment(orderId, amount, notes);
      SnackbarHelper.showSuccess('تم تسجيل الدفعة بنجاح');
      await loadData();
    } catch (e) {
      SnackbarHelper.showError('فشل تسجيل الدفعة');
    }
    isActing.value = false;
  }

  /// تسليم نقدية للشركة
  Future<void> submitPayment(
      {String? invoiceId, required double amount, String? notes}) async {
    isActing.value = true;
    try {
      await _ds.submitPayment(
          invoiceId: invoiceId, amount: amount, notes: notes);
      SnackbarHelper.showSuccess('تم تسليم النقدية بنجاح');
    } catch (e) {
      SnackbarHelper.showError('فشل تسليم النقدية');
    }
    isActing.value = false;
  }

  Future<void> updateStatus(String orderId, String status) async {
    isActing.value = true;
    isUpdating.value = true;
    try {
      await _ds.updateOrderStatus(orderId, status);
      SnackbarHelper.showSuccess('تم تحديث حالة الطلب');
      await loadData();
    } catch (e) {
      SnackbarHelper.showError('فشل تحديث الحالة');
    }
    isActing.value = false;
    isUpdating.value = false;
  }
}
