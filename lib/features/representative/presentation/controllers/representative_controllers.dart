// متحكمات المندوب — العملاء، الفواتير، المدفوعات، الديون، المستودع، النقل
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/representative_remote_datasource.dart';

class RepresentativeHomeController extends GetxController {
  late final RepresentativeRemoteDataSource _ds;

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

  // ── أوامر النقل ──
  final transferOrders = <Map<String, dynamic>>[].obs;
  final isLoadingTransfers = false.obs;

  // ── سلة إنشاء الفاتورة ──
  /// عناصر السلة لإنشاء فاتورة جديدة. كل عنصر يحوي:
  /// productId, productName, quantity, price, maxStock
  final invoiceCart = <RepCartItem>[].obs;
  final selectedInvoiceCustomerId = Rxn<String>();

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
      SnackbarHelper.showSuccess('تم إضافة العميل بنجاح — في انتظار الموافقة');
      nameController.clear();
      storeNameController.clear();
      phoneController.clear();
      addressController.clear();
      regionController.clear();
      Get.back();
      loadCustomers();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل إضافة العميل');
    }
    isActing.value = false;
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
  }

  /// إنشاء الفاتورة من السلة بعد اختيار العميل.
  Future<void> submitInvoiceFromCart({String? notes}) async {
    if (selectedInvoiceCustomerId.value == null) {
      SnackbarHelper.showError('يرجى اختيار العميل');
      return;
    }
    if (invoiceCart.isEmpty) {
      SnackbarHelper.showError('السلة فارغة — أضف منتجاً واحداً على الأقل');
      return;
    }
    final data = <String, dynamic>{
      'dto': {
        'invoiceSource': 1, // Representative
        'customerId': selectedInvoiceCustomerId.value,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        'details': invoiceCart
            .map((c) => {
                  'productId': c.productId,
                  'quantity': c.quantity,
                  'unitPrice': c.price,
                })
            .toList(),
      },
    };
    isActing.value = true;
    try {
      await _ds.createInvoice(data);
      SnackbarHelper.showSuccess('تم إنشاء الفاتورة بنجاح');
      clearInvoiceCart();
      loadInvoices();
      Get.back();
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

  Future<void> loadWarehouse() async {
    isLoadingWarehouse.value = true;
    try {
      warehouseItems.value = await _ds.getWarehouseInventory();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل تحميل بيانات المستودع');
    }
    isLoadingWarehouse.value = false;
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

  Future<void> requestTransfer(Map<String, dynamic> data) async {
    isActing.value = true;
    try {
      await _ds.requestTransfer(data);
      SnackbarHelper.showSuccess('تم إرسال طلب النقل بنجاح');
      loadTransferOrders();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل إرسال طلب النقل');
    }
    isActing.value = false;
  }

  Future<void> returnTransfer(Map<String, dynamic> data) async {
    isActing.value = true;
    try {
      await _ds.returnTransfer(data);
      SnackbarHelper.showSuccess('تم إرسال طلب الإرجاع بنجاح');
      loadTransferOrders();
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل إرسال طلب الإرجاع');
    }
    isActing.value = false;
  }
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
