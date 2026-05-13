// متحكمات المندوب — العملاء، الفواتير، المدفوعات، الديون، المستودع، النقل
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/representative_remote_datasource.dart';

class RepresentativeHomeController extends GetxController {
  late final RepresentativeRemoteDataSource _ds;

  /// فهرس تبويب الشريط السفلي في شاشة المندوب الرئيسية.
  final repBottomNavIndex = 0.obs;

  /// فهرس تبويب «الفواتير» في [RepresentativeMainPage] — يجب أن يطابق ترتيب عناصر `pages`.
  static const int repInvoicesNavIndex = 2;

  // ── العملاء ──
  final customers = <Map<String, dynamic>>[].obs;
  final pendingCustomers = <Map<String, dynamic>>[].obs;
  final isLoadingCustomers = true.obs;

  // ── الفواتير ──
  final invoices = <Map<String, dynamic>>[].obs;
  final selectedInvoiceStatus = Rxn<String>();
  final isLoadingInvoices = false.obs;

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

  @override
  void onInit() {
    super.onInit();
    _ds = RepresentativeRemoteDataSource(Get.find<DioClient>());
    loadCustomers();
    loadInvoices();
  }

  @override
  void onClose() {
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
      // بعد إغلاق الصفحة يُعاد بناء الـ overlay — إظهار النجاح في الإطار السابق
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

  // ── الفواتير ──

  // فواتير عميل محدد
  final customerInvoices = <Map<String, dynamic>>[].obs;

  // تفاصيل فاتورة
  final invoiceDetail = Rxn<Map<String, dynamic>>();
  final isLoadingDetail = false.obs;

  Future<void> loadCustomerInvoices(String customerId) async {
    isLoadingInvoices.value = true;
    try {
      final auth = Get.find<AuthService>();
      if (auth.isWholesaleRepresentative) {
        final all = await _ds.getInvoices();
        customerInvoices.value = all.where((i) {
          final c = i['customer'];
          final nested = c is Map ? (c['id'] ?? c['Id']) : null;
          final cid = i['customerId'] ?? nested;
          return cid?.toString() == customerId;
        }).toList();
      } else {
        final data = await _ds.getInvoices(customerId: customerId);
        customerInvoices.value = data;
      }
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

  Future<void> loadInvoices({String? status}) async {
    isLoadingInvoices.value = true;
    if (status != null) {
      selectedInvoiceStatus.value = status.isEmpty ? null : status;
    }
    try {
      invoices.value =
          await _ds.getInvoices(status: selectedInvoiceStatus.value);
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل الفواتير');
    }
    isLoadingInvoices.value = false;
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

    final body = <String, dynamic>{
      'customerId': customerId,
      'employeeId': 0,
      'invoiceSource': 1,
      'promoCode': invoicePromoCode.value.trim(),
      'branchId': invoiceBranchId.value != null
          ? (int.tryParse(invoiceBranchId.value!) ?? 0)
          : 0,
      'deliveryScheduleType': invoiceScheduleType.value,
      if (invoiceScheduleType.value == 1 &&
          invoiceScheduledDate.value != null)
        'scheduledDeliveryDate':
            invoiceScheduledDate.value!.toIso8601String(),
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      'details': details,
    };

    isActing.value = true;
    try {
      await _ds.createInvoice(body);
      clearInvoiceCart();
      await loadInvoices();
      Get.back();
      // بعد إغلاق شاشة الإنشاء: العودة للرئيسية + تبويب الفواتير، وإظهار النجاح فوق الواجهة الرئيسية
      WidgetsBinding.instance.addPostFrameCallback((_) {
        repBottomNavIndex.value = repInvoicesNavIndex;
        SnackbarHelper.showSuccess('تم إنشاء الفاتورة بنجاح');
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
      loadPayments();
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
    isActing.value = true;
    try {
      await _ds.submitPayment(
          invoiceId: invoiceId, amount: amount, notes: notes);
      SnackbarHelper.showSuccess('تم تسليم المبلغ للمحاسب بنجاح');
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
      warehouseId: repMainWarehouseId.value?.toString(),
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
      var mainId = repMainWarehouseId.value ?? 0;
      var subId = repSubWarehouseId.value ?? 0;
      if (auth.isIndividualRepresentative) {
        mainId = 0;
        subId = 0;
      } else if (mainId == 0 || subId == 0) {
        SnackbarHelper.showError(
            'تعذر تحديد المستودعات. تأكد من أن الخادم يُرجع معرف المستودع في بيانات المخزون.');
        isActing.value = false;
        return;
      }
      final body = <String, dynamic>{
        'fromWarehouseId': isReturn ? subId : mainId,
        'toWarehouseId': isReturn ? mainId : subId,
        'orderType': 0,
        'notes': notes ?? '',
        'details': details,
      };
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
