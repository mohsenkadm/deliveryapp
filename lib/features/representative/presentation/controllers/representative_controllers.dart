// متحكمات المندوب — العملاء، الفواتير، المدفوعات، الديون، المستودع، النقل
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/unit_price_resolver.dart';
import '../../data/datasources/representative_remote_datasource.dart';
import '../../data/models/rep_models.dart';

class RepresentativeHomeController extends GetxController {
  late final RepresentativeRemoteDataSource _ds;

  /// فهرس تبويب الشريط السفلي في شاشة المندوب الرئيسية.
  final repBottomNavIndex = 0.obs;

  /// فهرس تبويب «الفواتير» في [RepresentativeMainPage] — يجب أن يطابق ترتيب عناصر `pages`.
  static const int repInvoicesNavIndex = 2;

  /// فهرس تبويب «ذمتي» للمندوب المفرد (بعد الديون).
  static const int repLiabilityNavIndex = 4;

  bool get showLiabilityTab =>
      Get.find<AuthService>().isIndividualRepresentative;

  // ── العملاء ──
  final customers = <Map<String, dynamic>>[].obs;
  final pendingCustomers = <Map<String, dynamic>>[].obs;
  final isLoadingCustomers = true.obs;

  // ── الفواتير ──
  final invoices = <Map<String, dynamic>>[].obs;
  final selectedInvoiceStatus = Rxn<String>();
  final selectedDriverId = Rxn<int>();
  final branchDrivers = <Map<String, dynamic>>[].obs;
  final isLoadingInvoices = false.obs;

  // ── ذمة المندوب المفرد ──
  final liability = Rxn<RepLiabilityDto>();
  final pendingSettlementInvoices = <Map<String, dynamic>>[].obs;
  final isLoadingLiability = false.obs;

  /// مخازن النقل/الإرجاع من GET warehouses/transfer
  final transferWarehouses = Rxn<RepTransferWarehousesDto>();
  final selectedMainWarehouseIdForTransfer = Rxn<String>();
  final isLoadingTransferWarehouses = false.obs;

  // ── المدفوعات ──
  final payments = <Map<String, dynamic>>[].obs;
  final isLoadingPayments = false.obs;

  // ── الديون ──
  final debts = <Map<String, dynamic>>[].obs;
  final isLoadingDebts = false.obs;

  // ── المستودع ──
  final warehouseItems = <Map<String, dynamic>>[].obs;
  final isLoadingWarehouse = false.obs;

  /// معرف المستودع الرئيسي (يُستنتج من رد الـ API أو أول بند).
  final repMainWarehouseId = Rxn<int>();
  /// معرف مستودع المندوب الفرعي.
  final repSubWarehouseId = Rxn<int>();

  // ── أوامر النقل ──
  final transferOrders = <Map<String, dynamic>>[].obs;
  final isLoadingTransfers = false.obs;

  /// بعد نجاح طلب نقل/إرجاع: يُضبط على `1` ليفتح [RepWarehousePage] تبويب «أوامر النقل».
  final repWarehouseSubTabIndex = Rxn<int>();

  // ── سلة إنشاء الفاتورة ──
  /// عناصر السلة لإنشاء فاتورة جديدة. كل عنصر يحوي:
  /// productId, productName, quantity, price, maxStock
  final invoiceCart = <RepCartItem>[].obs;
  final selectedInvoiceCustomerId = Rxn<String>();
  /// 0 = Immediate, 1 = Scheduled
  final invoiceScheduleType = 0.obs;
  final invoiceScheduledDate = Rxn<DateTime>();
  final invoicePromoCode = ''.obs;
  final invoiceBranchId = Rxn<String>();

  /// مندوب جملة: مستودعات رئيسية + منتجاتها لشاشة إنشاء الفاتورة.
  final mainWarehouses = <Map<String, dynamic>>[].obs;
  final mainWarehouseProducts = <Map<String, dynamic>>[].obs;
  final selectedMainWarehouseIdForInvoice = Rxn<String>();
  final isLoadingMainProducts = false.obs;
  final isSearchingInvoiceProducts = false.obs;

  double get invoiceCartTotal =>
      invoiceCart.fold(0.0, (s, i) => s + i.quantity * i.price);

  int get invoiceCartCount =>
      invoiceCart.fold(0, (s, i) => s + i.quantity);

  final isActing = false.obs;

  // نماذج تسجيل العميل
  final nameController = TextEditingController();
  final storeNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final regionController = TextEditingController();
  final registerFormKey = GlobalKey<FormState>();

  /// نوع العميل: Retail (مفرد) أو Wholesale (جملة)
  final clientType = 'Retail'.obs;

  // ── أهداف المندوب (قراءة فقط) ──
  final selectedGoalYear = DateTime.now().year.obs;
  final selectedGoalMonth = DateTime.now().month.obs;
  final historyFrom = Rxn<DateTime>();
  final historyTo = Rxn<DateTime>();
  final currentGoal = Rxn<RepGoalProgressDto>();
  final goalsHistory = <RepGoalProgressDto>[].obs;
  final isLoadingGoals = false.obs;

  Future<void> _refreshOnNotification() async {
    await loadInvoices();
    if (showLiabilityTab) await loadLiability();
  }

  @override
  void onInit() {
    super.onInit();
    _ds = RepresentativeRemoteDataSource(Get.find<DioClient>());
    SignalRService.to.registerRefresh(_refreshOnNotification);
    loadCustomers();
    loadInvoices();
  }

  @override
  void onClose() {
    SignalRService.to.unregisterRefresh(_refreshOnNotification);
    nameController.dispose();
    storeNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    regionController.dispose();
    super.onClose();
  }

  // ── العملاء ──

  Future<void> loadCustomers({bool? pendingApproval}) async {
    isLoadingCustomers.value = true;
    try {
      final data = await _ds.getCustomers(pendingApproval: pendingApproval);
      if (pendingApproval == true) {
        pendingCustomers.value = data;
      } else {
        customers.value = data;
      }
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل العملاء');
    }
    isLoadingCustomers.value = false;
  }

  Future<void> addCustomer() async {
    if (!registerFormKey.currentState!.validate()) return;
    isActing.value = true;
    try {
      await _ds.addCustomer({
        'fullName': nameController.text.trim(),
        'storeName': storeNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'region': regionController.text.trim(),
        'clientType': clientType.value,
      });
      nameController.clear();
      storeNameController.clear();
      phoneController.clear();
      addressController.clear();
      regionController.clear();
      Get.back();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackbarHelper.showSuccess(
            'تم حفظ بيانات العميل بنجاح. سيتم تفعيل الحساب بعد موافقة الإدارة.');
        loadCustomers();
      });
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل إضافة العميل');
    } finally {
      isActing.value = false;
    }
  }

  Future<void> addCustomerWithPhoto({
    required String fullName,
    required String phone,
    required String address,
    required String region,
    required String clientType,
    required double latitude,
    required double longitude,
    required String photoPath,
    String? storeName,
  }) async {
    await _ds.addCustomerWithPhoto(
      fullName: fullName,
      phone: phone,
      address: address,
      region: region,
      clientType: clientType,
      latitude: latitude,
      longitude: longitude,
      photoPath: photoPath,
      storeName: storeName,
    );
  }

  // ── أهداف المندوب ──

  static const List<String> _monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  String monthLabel(int month) =>
      month >= 1 && month <= 12 ? _monthNames[month - 1] : '$month';

  List<int> get goalYearOptions {
    final now = DateTime.now().year;
    return List.generate(5, (i) => now - i);
  }

  Future<void> loadRepGoals() async {
    isLoadingGoals.value = true;
    try {
      currentGoal.value = await _ds.getCurrentGoal(
        year: selectedGoalYear.value,
        month: selectedGoalMonth.value,
      );
      final history = await _ds.getGoalsHistory(
        year: selectedGoalYear.value,
        month: selectedGoalMonth.value,
        from: historyFrom.value,
        to: historyTo.value,
      );
      goalsHistory.value = _filterGoalsHistory(history);
    } catch (e) {
      currentGoal.value = null;
      goalsHistory.clear();
      SnackbarHelper.handleApiError(e, 'فشل تحميل الأهداف');
    }
    isLoadingGoals.value = false;
  }

  List<RepGoalProgressDto> _filterGoalsHistory(List<RepGoalProgressDto> raw) {
    final from = historyFrom.value;
    final to = historyTo.value;
    if (from == null && to == null) return raw;
    return raw.where((g) {
      final d = DateTime(g.year, g.month);
      if (from != null && d.isBefore(DateTime(from.year, from.month))) {
        return false;
      }
      if (to != null && d.isAfter(DateTime(to.year, to.month))) {
        return false;
      }
      return true;
    }).toList();
  }

  void setGoalYear(int year) {
    selectedGoalYear.value = year;
    loadRepGoals();
  }

  void setGoalMonth(int month) {
    selectedGoalMonth.value = month;
    loadRepGoals();
  }

  void setGoalsHistoryRange(DateTime? from, DateTime? to) {
    historyFrom.value = from;
    historyTo.value = to;
    loadRepGoals();
  }

  // ── الفواتير ──

  // فواتير عميل محدد
  final customerInvoices = <Map<String, dynamic>>[].obs;

  // تفاصيل فاتورة
  final invoiceDetail = Rxn<Map<String, dynamic>>();
  final isLoadingDetail = false.obs;

  Future<void> loadCustomerInvoices(String customerId) async {
    isLoadingInvoices.value = true;
    try {
      final data = await _ds.getInvoices(customerId: customerId);
      customerInvoices.value = data;
    } catch (e) {
      customerInvoices.clear();
      SnackbarHelper.handleApiError(e, 'فشل تحميل فواتير العميل');
    }
    isLoadingInvoices.value = false;
  }

  Future<void> loadInvoiceDetail(String id) async {
    isLoadingDetail.value = true;
    try {
      invoiceDetail.value = await _ds.getInvoiceDetail(id);
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل تفاصيل الفاتورة');
    }
    isLoadingDetail.value = false;
  }

  Future<void> loadInvoices({String? status, int? driverId}) async {
    isLoadingInvoices.value = true;
    if (status != null) {
      selectedInvoiceStatus.value = status.isEmpty ? null : status;
    }
    if (driverId != null) {
      selectedDriverId.value = driverId == 0 ? null : driverId;
    }
    try {
      invoices.value = await _ds.getInvoices(
        status: selectedInvoiceStatus.value,
        driverId: selectedDriverId.value,
      );
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل الفواتير');
    }
    isLoadingInvoices.value = false;
  }

  Future<void> loadBranchDrivers() async {
    try {
      branchDrivers.value = await _ds.getDrivers();
    } catch (e) {
      branchDrivers.clear();
    }
  }

  Future<void> loadLiability() async {
    if (!showLiabilityTab) return;
    isLoadingLiability.value = true;
    try {
      liability.value = await _ds.getLiability();
      pendingSettlementInvoices.value =
          await _ds.getPendingSettlementInvoices();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل الذمة');
    }
    isLoadingLiability.value = false;
  }

  Future<void> loadTransferWarehouses() async {
    isLoadingTransferWarehouses.value = true;
    try {
      final dto = await _ds.getTransferWarehouses();
      transferWarehouses.value = dto;
      if (dto.subWarehouse != null) {
        repSubWarehouseId.value = dto.subWarehouse!.id;
      }
      if (dto.mainWarehouses.isNotEmpty &&
          selectedMainWarehouseIdForTransfer.value == null) {
        selectedMainWarehouseIdForTransfer.value =
            dto.mainWarehouses.first.id.toString();
      }
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل مخازن النقل');
    }
    isLoadingTransferWarehouses.value = false;
  }

  /// تسليم فاتورة للمحاسب (مندوب مفرد — invoiceId مطلوب).
  Future<void> submitSettlementForInvoice(
    Map<String, dynamic> invoice, {
    String? notes,
  }) async {
    final invoiceId = invoice['id']?.toString();
    if (invoiceId == null || invoiceId.isEmpty) {
      SnackbarHelper.showError('معرف الفاتورة غير صالح');
      return;
    }
    final amount = (invoice['totalAmount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) {
      SnackbarHelper.showError('مبلغ الفاتورة غير صالح');
      return;
    }
    isActing.value = true;
    try {
      await _ds.submitPayment(
        invoiceId: invoiceId,
        amount: amount,
        notes: notes,
      );
      SnackbarHelper.showSuccess('تم تسجيل التسليم للمحاسب');
      await loadPayments();
      await loadLiability();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تسليم المحاسب');
    }
    isActing.value = false;
  }

  Future<void> createInvoice(Map<String, dynamic> data) async {
    isActing.value = true;
    try {
      await _ds.createInvoice(data);
      SnackbarHelper.showSuccess('تم إنشاء الفاتورة بنجاح');
      loadInvoices();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل إنشاء الفاتورة');
    }
    isActing.value = false;
  }

  // ── إدارة سلة الفاتورة ──

  /// إضافة منتج للسلة (يأتي عادةً من قائمة المستودع).
  void addProductToCart({
    required String productId,
    required String productName,
    required double price,
    int quantity = 1,
    int? maxStock,
  }) {
    if (price <= 0) {
      SnackbarHelper.showError(
          'سعر المنتج غير متوفر — تحقق من سعر الجملة في المستودع');
      return;
    }
    final i = invoiceCart.indexWhere((e) => e.productId == productId);
    if (i != -1) {
      final next = invoiceCart[i].quantity + quantity;
      if (maxStock != null && next > maxStock) {
        SnackbarHelper.showError('الكمية المتاحة في المستودع: $maxStock');
        return;
      }
      invoiceCart[i].quantity = next;
      invoiceCart.refresh();
    } else {
      invoiceCart.add(RepCartItem(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity,
        maxStock: maxStock,
      ));
    }
  }

  void updateCartQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final i = invoiceCart.indexWhere((e) => e.productId == productId);
    if (i == -1) return;
    final item = invoiceCart[i];
    if (item.maxStock != null && quantity > item.maxStock!) {
      SnackbarHelper.showError('الكمية المتاحة في المستودع: ${item.maxStock}');
      return;
    }
    item.quantity = quantity;
    invoiceCart.refresh();
  }

  int cartQuantityFor(String productId) {
    final i = invoiceCart.indexWhere((e) => e.productId == productId);
    return i == -1 ? 0 : invoiceCart[i].quantity;
  }

  void updateCartPrice(String productId, double price) {
    final i = invoiceCart.indexWhere((e) => e.productId == productId);
    if (i == -1) return;
    invoiceCart[i].price = price;
    invoiceCart.refresh();
  }

  void removeFromCart(String productId) {
    invoiceCart.removeWhere((e) => e.productId == productId);
  }

  void clearInvoiceCart() {
    invoiceCart.clear();
    selectedInvoiceCustomerId.value = null;
    invoiceScheduleType.value = 0;
    invoiceScheduledDate.value = null;
    invoicePromoCode.value = '';
    invoiceBranchId.value = null;
    selectedMainWarehouseIdForInvoice.value = null;
    mainWarehouseProducts.clear();
  }

  /// مستودعات رئيسية + منتجاتها — مندوب الجملة في شاشة إنشاء الفاتورة.
  Future<void> loadMainWarehousesAndProductsForInvoice() async {
    isLoadingMainProducts.value = true;
    try {
      mainWarehouses.value = await _ds.getMainWarehouses();
      if (mainWarehouses.isEmpty) {
        mainWarehouseProducts.clear();
        return;
      }
      selectedMainWarehouseIdForInvoice.value ??=
          mainWarehouses.first['id']?.toString();
      await refreshMainWarehouseProductsForInvoice();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل مستودعات الجملة');
      mainWarehouseProducts.clear();
    }
    isLoadingMainProducts.value = false;
  }

  Future<void> refreshMainWarehouseProductsForInvoice() async {
    if (!preferWholesaleUnitPrices) return;
    isLoadingMainProducts.value = true;
    try {
      mainWarehouseProducts.value = await _ds.getMainWarehouseProducts(
        warehouseId: selectedMainWarehouseIdForInvoice.value,
      );
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل المنتجات');
      mainWarehouseProducts.clear();
    }
    isLoadingMainProducts.value = false;
  }

  /// بحث منتجات لإضافتها للفاتورة — debounce من الواجهة.
  Future<List<Map<String, dynamic>>> searchProductsForInvoice(
      String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    isSearchingInvoiceProducts.value = true;
    try {
      if (preferWholesaleUnitPrices) {
        final results = await _ds.getMainWarehouseProducts(
          search: q,
          warehouseId: selectedMainWarehouseIdForInvoice.value,
        );
        mainWarehouseProducts.value = results;
        return results;
      }

      if (warehouseItems.isEmpty && !isLoadingWarehouse.value) {
        await loadWarehouse();
      }
      final lower = q.toLowerCase();
      return warehouseItems.where((it) {
        final name =
            (it['productName'] ?? it['name'] ?? '').toString().toLowerCase();
        final code = (it['productCode'] ?? it['code'] ?? '')
            .toString()
            .toLowerCase();
        return name.contains(lower) || code.contains(lower);
      }).toList();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل البحث عن المنتجات');
      return const [];
    } finally {
      isSearchingInvoiceProducts.value = false;
    }
  }

  /// إضافة منتج من نتيجة البحث إلى السلة.
  void addSearchedProductToCart(Map<String, dynamic> item) {
    final productId =
        (item['productId'] ?? item['id'] ?? '').toString();
    final name =
        (item['productName'] ?? item['name'] ?? '').toString();
    final stockRaw = item['quantity'] ??
        item['mainWarehouseStock'] ??
        item['stockQuantity'] ??
        0;
    final stock = stockRaw is num
        ? stockRaw.toInt()
        : int.tryParse(stockRaw.toString()) ?? 0;
    final price = resolveUnitPrice(item);

    if (productId.isEmpty) {
      SnackbarHelper.showError('معرف المنتج غير صالح');
      return;
    }
    if (stock <= 0) {
      SnackbarHelper.showError('المنتج غير متوفر في المخزون');
      return;
    }
    addProductToCart(
      productId: productId,
      productName: name,
      price: price,
      maxStock: stock,
    );
    SnackbarHelper.showSuccess('تمت إضافة $name للسلة');
  }

  /// إنشاء الفاتورة من السلة بعد اختيار العميل.
  /// POST `/api/mobile/rep/invoices`: الخادم يضبط `employeeId` من JWT و`invoiceSource` = مندوب (1).
  Future<void> submitInvoiceFromCart({String? notes}) async {
    if (selectedInvoiceCustomerId.value == null) {
      SnackbarHelper.showError('يرجى اختيار العميل');
      return;
    }
    if (invoiceCart.isEmpty) {
      SnackbarHelper.showError('السلة فارغة — أضف منتجاً واحداً على الأقل');
      return;
    }
    if (invoiceScheduleType.value == 1 && invoiceScheduledDate.value == null) {
      SnackbarHelper.showError('حدّد تاريخ التسليم المجدول');
      return;
    }
    int toId(String? s) {
      if (s == null || s.isEmpty) return 0;
      return int.tryParse(s) ?? 0;
    }

    final customerId = toId(selectedInvoiceCustomerId.value);
    if (customerId == 0) {
      SnackbarHelper.showError('معرف العميل غير صالح');
      return;
    }

    final details = invoiceCart
        .map((c) => {
              'productId': toId(c.productId),
              'quantity': c.quantity,
              'unitPrice': c.price,
              'discount': 0.0,
            })
        .toList();
    if (details.any((d) => (d['productId'] as int) <= 0)) {
      SnackbarHelper.showError('معرّف أحد المنتجات غير صالح');
      return;
    }
    if (details.any((d) => (d['quantity'] as int) <= 0)) {
      SnackbarHelper.showError('الكمية يجب أن تكون أكبر من صفر');
      return;
    }
    if (details.any((d) => (d['unitPrice'] as num) <= 0)) {
      SnackbarHelper.showError('سعر البيع يجب أن يكون أكبر من صفر');
      return;
    }

    final auth = Get.find<AuthService>();
    final body = <String, dynamic>{
      'customerId': customerId,
      if (invoicePromoCode.value.trim().isNotEmpty)
        'promoCode': invoicePromoCode.value.trim(),
      if (invoiceBranchId.value != null &&
          int.tryParse(invoiceBranchId.value!) != null)
        'branchId': int.parse(invoiceBranchId.value!),
      'deliveryScheduleType': invoiceScheduleType.value,
      if (invoiceScheduleType.value == 1 &&
          invoiceScheduledDate.value != null)
        'scheduledDeliveryDate':
            invoiceScheduledDate.value!.toUtc().toIso8601String(),
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      'details': details,
    };

    // مندوب الجملة: يحدد المستودع الرئيسي لخصم المخزون والتحقق منه
    if (auth.isWholesaleRepresentative) {
      final whId =
          int.tryParse(selectedMainWarehouseIdForInvoice.value ?? '');
      if (whId == null || whId <= 0) {
        SnackbarHelper.showError('اختر المستودع الرئيسي أولاً');
        return;
      }
      body['warehouseId'] = whId;
    }

    isActing.value = true;
    try {
      await _ds.createInvoice(body);
      clearInvoiceCart();
      await loadInvoices();
      Get.back();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final auth = Get.find<AuthService>();
        if (auth.isIndividualRepresentative) {
          loadLiability();
          repBottomNavIndex.value = repLiabilityNavIndex;
          SnackbarHelper.showSuccess(
              'تم البيع — بانتظار تسليم المحاسب');
        } else {
          repBottomNavIndex.value = repInvoicesNavIndex;
          SnackbarHelper.showSuccess('تم إنشاء الفاتورة بنجاح');
        }
      });
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل إنشاء الفاتورة');
    }
    isActing.value = false;
  }

  // ── المدفوعات ──

  Future<void> loadPayments() async {
    isLoadingPayments.value = true;
    try {
      payments.value = await _ds.getPayments();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل المدفوعات');
    }
    isLoadingPayments.value = false;
  }

  Future<void> collectPayment({
    String? invoiceId,
    String? customerId,
    required double amount,
    String? notes,
  }) async {
    isActing.value = true;
    try {
      await _ds.collectPayment(
        invoiceId: invoiceId,
        customerId: customerId,
        amount: amount,
        notes: notes,
      );
      SnackbarHelper.showSuccess('تم تحصيل الدفعة بنجاح');
      await loadPayments();
      await loadDebts();
      if (Get.currentRoute == AppRoutes.collectPayment) {
        Get.back();
      }
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحصيل الدفعة');
    }
    isActing.value = false;
  }

  Future<void> submitPayment({
    String? invoiceId,
    required double amount,
    String? notes,
  }) async {
    if (showLiabilityTab &&
        (invoiceId == null || invoiceId.isEmpty)) {
      SnackbarHelper.showError(
          'معرف الفاتورة مطلوب لتسليم المبلغ للمحاسب');
      return;
    }
    isActing.value = true;
    try {
      await _ds.submitPayment(
          invoiceId: invoiceId, amount: amount, notes: notes);
      SnackbarHelper.showSuccess('تم تسليم المبلغ للمحاسب بنجاح');
      await loadPayments();
      if (showLiabilityTab) await loadLiability();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تسليم المبلغ');
    }
    isActing.value = false;
  }

  // ── الديون ──

  Future<void> loadDebts() async {
    isLoadingDebts.value = true;
    try {
      debts.value = await _ds.getDebts();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل الديون');
    }
    isLoadingDebts.value = false;
  }

  // ── المستودع ──

  /// تحميل مخزون المستودع الفرعي للمندوب (GET /api/mobile/rep/warehouse).
  Future<void> loadWarehouse() async {
    isLoadingWarehouse.value = true;
    try {
      final result = await _ds.getWarehouseInventory();
      warehouseItems.value = result.items;
      repSubWarehouseId.value ??=
          result.subWarehouseId ?? result.warehouseIdFromFirstItem();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل بيانات المستودع');
    }
    isLoadingWarehouse.value = false;
  }

  /// جلب معرفي المستودع الرئيسي والفرعي إن لم يكونا محفوظين بعد.
  Future<void> ensureWarehouseRoutingIds() async {
    if (repMainWarehouseId.value != null && repSubWarehouseId.value != null) {
      return;
    }
    try {
      final sub = await _ds.getWarehouseInventory();
      repSubWarehouseId.value ??=
          sub.subWarehouseId ?? sub.warehouseIdFromFirstItem();
      final mains = await _ds.getMainWarehouses();
      if (mains.isNotEmpty) {
        final id = mains.first['id'];
        repMainWarehouseId.value ??=
            id is int ? id : int.tryParse(id?.toString() ?? '');
      }
    } catch (_) {}
  }

  /// مخزون لشاشة طلب نقل (رئيسي) أو إرجاع (فرعي).
  Future<List<Map<String, dynamic>>> fetchInventoryLinesForTransfer(
      bool isReturn) async {
    if (isReturn) {
      final result = await _ds.getWarehouseInventory();
      return result.items;
    }
    return _ds.getMainWarehouseProducts(
      warehouseId: selectedMainWarehouseIdForTransfer.value ??
          repMainWarehouseId.value?.toString(),
    );
  }

  /// إرسال طلب نقل أو إرجاع — جسم الـ API الكامل.
  Future<void> submitStockTransfer({
    required bool isReturn,
    required List<Map<String, dynamic>> details,
    String? notes,
  }) async {
    isActing.value = true;
    try {
      await ensureWarehouseRoutingIds();
      final auth = Get.find<AuthService>();
      final mainWhId = int.tryParse(
              selectedMainWarehouseIdForTransfer.value ?? '') ??
          repMainWarehouseId.value ??
          0;
      final subId = repSubWarehouseId.value ?? 0;

      if (auth.isIndividualRepresentative) {
        if (mainWhId <= 0) {
          SnackbarHelper.showError('اختر المستودع الرئيسي أولاً');
          isActing.value = false;
          return;
        }
      } else if (mainWhId == 0 || subId == 0) {
        SnackbarHelper.showError(
            'تعذر تحديد المستودعات. تأكد من أن الخادم يُرجع معرف المستودع في بيانات المخزون.');
        isActing.value = false;
        return;
      }

      final body = <String, dynamic>{
        'fromWarehouseId': isReturn ? 0 : mainWhId,
        'toWarehouseId': isReturn ? mainWhId : 0,
        'orderType': 0,
        'notes': notes ?? '',
        'details': details,
      };
      if (!auth.isIndividualRepresentative) {
        body['fromWarehouseId'] = isReturn ? subId : mainWhId;
        body['toWarehouseId'] = isReturn ? mainWhId : subId;
      }
      if (isReturn) {
        await _ds.returnTransfer(body);
      } else {
        await _ds.requestTransfer(body);
      }
      await loadTransferOrders();
      await loadWarehouse();
      Get.back();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        repWarehouseSubTabIndex.value = 1;
        SnackbarHelper.showSuccess('تم الحفظ');
      });
    } catch (e) {
      SnackbarHelper.handleApiError(
          e, isReturn ? 'فشل إرسال طلب الإرجاع' : 'فشل إرسال طلب النقل');
    }
    isActing.value = false;
  }

  // ── أوامر النقل ──

  Future<void> loadTransferOrders({String? status}) async {
    isLoadingTransfers.value = true;
    try {
      transferOrders.value =
          await _ds.getTransferOrders(status: status);
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل أوامر النقل');
    }
    isLoadingTransfers.value = false;
  }

  /// أسعار جملة في شاشة إنشاء الفاتورة عند مندوب الجملة.
  bool get preferWholesaleUnitPrices =>
      Get.find<AuthService>().isWholesaleRepresentative;
}

/// عنصر في سلة فاتورة المندوب — قابل للتعديل (qty/price).
class RepCartItem {
  final String productId;
  final String productName;
  int quantity;
  double price;
  final int? maxStock;

  RepCartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.maxStock,
  });

  double get total => quantity * price;
}
