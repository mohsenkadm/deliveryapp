// متحكمات السائق — الطلبات، الاستلام من المستودع، التسليم، التحصيل، الحالات
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../domain/entities/driver_entities.dart';

class DriverHomeController extends GetxController {
  late final DriverRemoteDataSource _ds;

  final assignedOrders = <DeliveryOrder>[].obs;
  final completedOrders = <DeliveryOrder>[].obs;
  final summary = Rxn<DriverSummary>();
  final isLoading = true.obs;
  final isLoadingCompleted = false.obs;
  final isActing = false.obs;
  final isUpdating = false.obs;
  final completedTodayCount = 0.obs;
  final selectedStatus = Rxn<String>();

  static const List<Map<String, String>> statusFilters = [
    {'label': 'الكل', 'value': ''},
    {'label': 'قيد التجهيز', 'value': 'WarehouseProcessing'},
    {'label': 'في التوصيل', 'value': 'AwaitingDelivery'},
    {'label': 'تم التسليم', 'value': 'Delivered'},
    {'label': 'مرفوض', 'value': 'Rejected'},
  ];

  @override
  void onInit() {
    super.onInit();
    _ds = DriverRemoteDataSource(Get.find<DioClient>());
  }

  @override
  void onReady() {
    super.onReady();
    // بعد أول إطار — يكون التوكن والمسار جاهزين (onInit قد يكون مبكراً جداً)
    loadData();
    // تحميل مسبق للمكتملة حتى يكون تبويب «المكتملة» جاهزاً دون انتظار أول زيارة
    loadCompletedDeliveries();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([
      _loadOrders(null),
      _loadSummary(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadOrders(String? status) async {
    try {
      final orders = await _ds.getOrders(status: status);
      assignedOrders.value = orders;
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل الطلبات');
    }
  }

  Future<void> loadOrdersByStatus(String? status) async {
    isLoading.value = true;
    selectedStatus.value = status?.isEmpty == true ? null : status;
    try {
      final orders = await _ds.getOrders(status: selectedStatus.value);
      assignedOrders.value = orders;
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل الطلبات');
    }
    isLoading.value = false;
  }

  Future<void> loadCompletedDeliveries() async {
    isLoadingCompleted.value = true;
    try {
      final orders = await _ds.getOrders(status: 'Completed');
      completedOrders.value = orders;
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل التوصيلات المكتملة');
    }
    isLoadingCompleted.value = false;
  }

  Future<void> _loadSummary() async {
    try {
      final s = await _ds.getSummary();
      summary.value = s;
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل ملخص الأداء');
    }
  }

  Future<void> refreshSummary() async {
    await _loadSummary();
  }

  /// تأكيد الاستلام من المستودع (قبل التوصيل)
  Future<void> confirmPickup(String orderId) async {
    isActing.value = true;
    try {
      await _ds.confirmPickup(orderId);
      SnackbarHelper.showSuccess('تم تأكيد الاستلام من المستودع');
      await loadData();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تأكيد الاستلام');
    }
    isActing.value = false;
  }

  /// تأكيد التسليم للعميل (AwaitingDelivery → Delivered)
  Future<void> markDelivered(String orderId) async {
    isActing.value = true;
    try {
      await _ds.confirmDelivered(orderId);
      SnackbarHelper.showSuccess('تم تأكيد التسليم بنجاح');
      await loadData();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تأكيد التسليم');
    }
    isActing.value = false;
  }

  /// تحصيل نقدي من العميل عند التوصيل (اختياري)
  Future<void> collectFromCustomer(
    String orderId, {
    bool recordPayment = true,
    required double amount,
    String? notes,
  }) async {
    isActing.value = true;
    try {
      await _ds.collectPayment(
        orderId,
        recordPayment: recordPayment,
        amount: amount,
        notes: notes,
      );
      SnackbarHelper.showSuccess('تم تسجيل التحصيل');
      await loadData();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تسجيل التحصيل');
    }
    isActing.value = false;
  }

  /// بعد التسليم: عرض حوار اختياري لتسجيل تحصيل نقدي (POST /collect).
  Future<void> offerOptionalCashCollection({
    required String orderId,
    required String orderNumber,
    required double remainingAmount,
  }) async {
    if (remainingAmount <= 0) return;
    final want = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تحصيل نقدي؟',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text(
          'المتبقي على الطلب #$orderNumber: ${Formatters.currency(remainingAmount)}\n\nهل تريد تسجيل مبلغ تحصّلته من العميل الآن؟',
          style: GoogleFonts.cairo(height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('لاحقاً', style: GoogleFonts.cairo()),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text('نعم، تسجيل التحصيل', style: GoogleFonts.cairo()),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (want != true) return;

    final amountCtrl =
        TextEditingController(text: remainingAmount.toStringAsFixed(0));
    final noteCtrl = TextEditingController();
    try {
      final submit = await Get.dialog<bool>(
        AlertDialog(
          title: Text('مبلغ التحصيل',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'المبلغ',
                  hintText: Formatters.currency(remainingAmount),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: Text('تسجيل', style: GoogleFonts.cairo()),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      if (submit != true) return;

      final raw = amountCtrl.text.replaceAll(',', '').trim();
      final amt = double.tryParse(raw) ?? 0;
      if (amt <= 0) {
        SnackbarHelper.showError('أدخل مبلغاً أكبر من صفر');
        return;
      }
      if (amt > remainingAmount + 0.009) {
        SnackbarHelper.showError('المبلغ أكبر من المتبقي على الفاتورة');
        return;
      }
      final notes = noteCtrl.text.trim();
      await collectFromCustomer(
        orderId,
        amount: amt,
        notes: notes.isEmpty ? null : notes,
      );
    } finally {
      amountCtrl.dispose();
      noteCtrl.dispose();
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    isActing.value = true;
    isUpdating.value = true;
    try {
      await _ds.updateOrderStatus(orderId, status);
      SnackbarHelper.showSuccess('تم تحديث حالة الطلب');
      await loadData();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحديث الحالة');
    }
    isActing.value = false;
    isUpdating.value = false;
  }
}
