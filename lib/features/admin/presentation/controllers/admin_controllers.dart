// متحكمات المدير — لوحة التحكم، العملاء، المنتجات، الفواتير
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminDashboardController extends GetxController {
  late final AdminRemoteDataSource _ds;

  final stats = <String, dynamic>{}.obs;
  final weeklySales = <double>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      stats.value = await _ds.getDashboardStats();
      // Extract weekly sales data from stats or default
      final salesData = stats['weeklySales'];
      if (salesData is List) {
        weeklySales.value = salesData.map((e) => (e as num).toDouble()).toList();
      } else {
        weeklySales.value = List.filled(7, 0.0);
      }
    } catch (_) {
      weeklySales.value = List.filled(7, 0.0);
    }
    isLoading.value = false;
  }
}

class AdminCustomersController extends GetxController {
  late final AdminRemoteDataSource _ds;

  final customers = <Map<String, dynamic>>[].obs;
  final pendingApprovals = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      customers.value = await _ds.getAllCustomers();
      pendingApprovals.value = await _ds.getPendingApprovals();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> approveCustomer(String id) async {
    try {
      await _ds.approveCustomer(id);
      SnackbarHelper.showSuccess('تمت الموافقة على العميل');
      loadCustomers();
    } catch (_) {
      SnackbarHelper.showError('فشلت العملية');
    }
  }

  Future<void> rejectCustomer(String id) async {
    try {
      await _ds.rejectCustomer(id);
      SnackbarHelper.showSuccess('تم رفض العميل');
      loadCustomers();
    } catch (_) {
      SnackbarHelper.showError('فشلت العملية');
    }
  }
}

class AdminProductsController extends GetxController {
  late final AdminRemoteDataSource _ds;

  final products = <Map<String, dynamic>>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final selectedCategoryId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    loadData();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      products.value = await _ds.getAllProducts();
      categories.value = await _ds.getAllCategories();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> createProduct() async {
    if (!formKey.currentState!.validate()) return;
    isSubmitting.value = true;
    try {
      await _ds.createProduct({
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text),
        'description': descriptionController.text.trim(),
        'categoryId': selectedCategoryId.value,
      });
      SnackbarHelper.showSuccess('تم إضافة المنتج');
      clearForm();
      Get.back();
      loadData();
    } catch (_) {
      SnackbarHelper.showError('فشل إضافة المنتج');
    }
    isSubmitting.value = false;
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _ds.deleteProduct(id);
      SnackbarHelper.showSuccess('تم حذف المنتج');
      loadData();
    } catch (_) {
      SnackbarHelper.showError('فشل الحذف');
    }
  }

  void clearForm() {
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    selectedCategoryId.value = null;
  }
}

class AdminOrdersController extends GetxController {
  late final AdminRemoteDataSource _ds;

  final invoices = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    isLoading.value = true;
    try {
      invoices.value = await _ds.getAllInvoices();
    } catch (_) {}
    isLoading.value = false;
  }
}

class AdminDebtsController extends GetxController {
  late final AdminRemoteDataSource _ds;

  final debts = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    loadDebts();
  }

  Future<void> loadDebts() async {
    isLoading.value = true;
    try {
      debts.value = await _ds.getAllDebts();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> settleDebt(String id, double amount) async {
    try {
      await _ds.settleDebt(id, {'amount': amount});
      SnackbarHelper.showSuccess('تمت التسوية بنجاح');
      loadDebts();
    } catch (_) {
      SnackbarHelper.showError('فشلت التسوية');
    }
  }
}

// ──────────────────────────────────────────────────────
// إدارة المخزون
// ──────────────────────────────────────────────────────
class AdminInventoryController extends GetxController {
  late final AdminRemoteDataSource _ds;

  final inventory = <Map<String, dynamic>>[].obs;
  final warehouses = <Map<String, dynamic>>[].obs;
  final selectedWarehouseId = RxnString();
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  final productIdController = TextEditingController();
  final quantityController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    loadData();
  }

  @override
  void onClose() {
    productIdController.dispose();
    quantityController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      warehouses.value = await _ds.getAllWarehouses();
      await loadInventory();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> loadInventory({String? warehouseId}) async {
    isLoading.value = true;
    try {
      inventory.value = await _ds.getInventory(warehouseId: warehouseId ?? selectedWarehouseId.value);
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> updateInventory() async {
    if (!formKey.currentState!.validate()) return;
    isSubmitting.value = true;
    try {
      await _ds.updateInventory({
        'productId': productIdController.text.trim(),
        'warehouseId': selectedWarehouseId.value,
        'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
      });
      SnackbarHelper.showSuccess('تم تحديث المخزون');
      clearForm();
      Get.back();
      loadInventory();
    } catch (_) {
      SnackbarHelper.showError('فشل تحديث المخزون');
    }
    isSubmitting.value = false;
  }

  void clearForm() {
    productIdController.clear();
    quantityController.clear();
  }
}
