// متحكمات العميل — المنتجات، السلة، الطلبات، الديون، الإشعارات
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../data/models/customer_models.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/entities/customer_entities.dart';

// ──────────────────────────────────────────────────────
// لوحة التحكم الرئيسية
// ──────────────────────────────────────────────────────
class CustomerHomeController extends GetxController {
  late final CustomerRepository _repository;

  final products = <Product>[].obs;
  final categories = <Category>[].obs;
  final isLoading = true.obs;

  final ordersCount = 0.obs;
  final debtsTotal = 0.0.obs;
  final paidTotal = 0.0.obs;
  final activeOrdersCount = 0.obs;
  final totalInvoices = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _repository =
        CustomerRepository(CustomerRemoteDataSource(Get.find<DioClient>()));
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([_loadProducts(), _loadCategories(), _loadStats()]);
    isLoading.value = false;
  }

  Future<void> _loadProducts() async {
    final result = await _repository.getProducts(pageSize: 8);
    result.fold((f) => null, (r) => products.value = r.items);
  }

  Future<void> _loadCategories() async {
    final result = await _repository.getCategories();
    result.fold((f) => null, (data) => categories.value = data);
  }

  Future<void> _loadStats() async {
    try {
      final ordersResult = await _repository.getMyOrders();
      ordersResult.fold((f) => null, (data) {
        ordersCount.value = data.length;
        activeOrdersCount.value = data
            .where((o) =>
                o.status != 'Delivered' &&
                o.status != 'Completed' &&
                o.status != 'Rejected')
            .length;
      });
      final debtsResult = await _repository.getMyDebts();
      debtsResult.fold((f) => null, (d) {
        debtsTotal.value = d.totalDebt;
        paidTotal.value = d.totalPaid;
        totalInvoices.value = d.totalInvoices;
      });
    } catch (_) {}
  }
}

// ──────────────────────────────────────────────────────
// المنتجات — بحث، فلتر، ترقيم صفحات
// ──────────────────────────────────────────────────────
class ProductsController extends GetxController {
  late final CustomerRepository _repository;

  final products = <Product>[].obs;
  final categories = <Category>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  final selectedCategoryId = Rxn<String>();
  final selectedBranchId = Rxn<String>();
  final searchQuery = ''.obs;
  /// فلتر المنتجات القاربة على الانتهاء (X يوم)
  final nearExpiryDays = Rxn<int>();

  int _page = 1;
  static const int _pageSize = 20;
  int _total = 0;
  bool get hasMore => products.length < _total;

  @override
  void onInit() {
    super.onInit();
    _repository =
        CustomerRepository(CustomerRemoteDataSource(Get.find<DioClient>()));
    loadProducts(reset: true);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // تحميل التصنيفات من أول صفحة منتجات لاستخراجها، أو يمكن إضافة endpoint مستقل
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (reset) {
      _page = 1;
      products.clear();
    }
    if (_page == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    final result = await _repository.getProducts(
      page: _page,
      pageSize: _pageSize,
      search: searchQuery.value.isEmpty ? null : searchQuery.value,
      categoryId: selectedCategoryId.value,
      branchId: selectedBranchId.value,
      nearExpiryDays: nearExpiryDays.value,
    );

    result.fold(
      (f) => SnackbarHelper.showError(f.message),
      (r) {
        products.addAll(r.items);
        _total = r.total;
        _page++;
      },
    );
    isLoading.value = false;
    isLoadingMore.value = false;
  }

  void onSearchChanged(String q) {
    searchQuery.value = q;
    loadProducts(reset: true);
  }

  void filterByCategory(String? id) {
    selectedCategoryId.value = id;
    loadProducts(reset: true);
  }

  void filterByBranch(String? id) {
    selectedBranchId.value = id;
    loadProducts(reset: true);
  }

  /// تفعيل/إلغاء فلتر المنتجات القاربة على الانتهاء.
  void filterByNearExpiry(int? days) {
    nearExpiryDays.value = days;
    loadProducts(reset: true);
  }
}

// ──────────────────────────────────────────────────────
// سلة التسوق
// ──────────────────────────────────────────────────────
class CartController extends GetxController {
  late final CustomerRepository _repository;
  final cartItems = <CartItem>[].obs;
  final isSubmitting = false.obs;

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item.total);
  double get deliveryFee => cartItems.isEmpty ? 0 : 15.0;
  double get total => subtotal + deliveryFee;
  int get itemCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void onInit() {
    super.onInit();
    _repository =
        CustomerRepository(CustomerRemoteDataSource(Get.find<DioClient>()));
  }

  void addToCart(Product product) {
    final index =
        cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(product: product));
    }
    SnackbarHelper.showSuccess('تمت الإضافة إلى السلة');
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index =
        cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      cartItems[index].quantity = quantity;
      cartItems.refresh();
    }
  }

  void clearCart() => cartItems.clear();

  Future<void> checkout({
    String? notes,
    String? address,
    String? promoCode,
    String deliveryScheduleType = 'Immediate',
    DateTime? scheduledDeliveryDate,
  }) async {
    if (cartItems.isEmpty) return;
    isSubmitting.value = true;

    final items = cartItems
        .map((c) => {
              'productId': c.product.id,
              'quantity': c.quantity,
              'unitPrice': c.product.discountPrice ?? c.product.price,
            })
        .toList();

    final result = await _repository.createOrder(
      items: items,
      notes: notes,
      address: address,
      promoCode: promoCode,
      deliveryScheduleType: deliveryScheduleType,
      scheduledDeliveryDate: scheduledDeliveryDate,
    );

    isSubmitting.value = false;
    result.fold(
      (f) => SnackbarHelper.showError(f.message),
      (order) {
        clearCart();
        SnackbarHelper.showSuccess('تم إرسال الطلب بنجاح');
        Get.offAllNamed(AppRoutes.myOrders);
      },
    );
  }
}

// ──────────────────────────────────────────────────────
// الطلبات
// ──────────────────────────────────────────────────────
class OrdersController extends GetxController {
  late final CustomerRepository _repository;
  final orders = <Order>[].obs;
  final isLoading = true.obs;
  final isCancelling = false.obs;
  final selectedStatus = Rxn<String>();

  CustomerRepository get repository => _repository;

  static const List<Map<String, String>> statusFilters = [
    {'label': 'الكل', 'value': ''},
    {'label': 'معلق', 'value': 'Pending'},
    {'label': 'مقبول', 'value': 'Accepted'},
    {'label': 'جاري التجهيز', 'value': 'WarehouseProcessing'},
    {'label': 'في التوصيل', 'value': 'AwaitingDelivery'},
    {'label': 'تم التسليم', 'value': 'Delivered'},
    {'label': 'مكتمل', 'value': 'Completed'},
    {'label': 'مرفوض', 'value': 'Rejected'},
  ];

  @override
  void onInit() {
    super.onInit();
    _repository =
        CustomerRepository(CustomerRemoteDataSource(Get.find<DioClient>()));
    loadOrders();
  }

  Future<void> loadOrders({String? status}) async {
    isLoading.value = true;
    if (status != null) selectedStatus.value = status.isEmpty ? null : status;
    final result =
        await _repository.getMyOrders(status: selectedStatus.value);
    result.fold(
      (f) => SnackbarHelper.showError(f.message),
      (data) => orders.value = data,
    );
    isLoading.value = false;
  }

  Future<void> cancelOrder(String orderId) async {
    isCancelling.value = true;
    final result = await _repository.cancelOrder(orderId);
    isCancelling.value = false;
    result.fold(
      (f) => SnackbarHelper.showError(f.message),
      (_) {
        SnackbarHelper.showSuccess('تم إلغاء الطلب بنجاح');
        loadOrders();
      },
    );
  }

  String getInvoiceUrl(String orderId) =>
      _repository.getInvoiceUrl(orderId);
}

// ──────────────────────────────────────────────────────
// الديون
// ──────────────────────────────────────────────────────
class DebtsController extends GetxController {
  late final CustomerRepository _repository;
  final summary = Rxn<DebtSummaryModel>();
  final isLoading = true.obs;

  // فلاتر الديون
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final minAmount = Rxn<double>();
  final maxAmount = Rxn<double>();
  /// `date` | `amount`
  final sortBy = Rxn<String>();
  /// `asc` | `desc`
  final sortDir = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _repository =
        CustomerRepository(CustomerRemoteDataSource(Get.find<DioClient>()));
    loadDebts();
  }

  Future<void> loadDebts() async {
    isLoading.value = true;
    final result = await _repository.getMyDebts(
      from: fromDate.value,
      to: toDate.value,
      minAmount: minAmount.value,
      maxAmount: maxAmount.value,
      sortBy: sortBy.value,
      sortDir: sortDir.value,
    );
    result.fold(
      (f) => SnackbarHelper.showError(f.message),
      (data) => summary.value = data,
    );
    isLoading.value = false;
  }

  /// تطبيق فلاتر جديدة وإعادة التحميل.
  void applyFilters({
    DateTime? from,
    DateTime? to,
    double? min,
    double? max,
    String? sortByValue,
    String? sortDirValue,
  }) {
    fromDate.value = from;
    toDate.value = to;
    minAmount.value = min;
    maxAmount.value = max;
    sortBy.value = sortByValue;
    sortDir.value = sortDirValue;
    loadDebts();
  }

  /// إعادة تعيين جميع الفلاتر.
  void clearFilters() {
    fromDate.value = null;
    toDate.value = null;
    minAmount.value = null;
    maxAmount.value = null;
    sortBy.value = null;
    sortDir.value = null;
    loadDebts();
  }
}

// ──────────────────────────────────────────────────────
// الإشعارات
// ──────────────────────────────────────────────────────
class CustomerNotificationsController extends GetxController {
  late final CustomerRepository _repository;
  final notifications = <NotificationModel>[].obs;
  final isLoading = true.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _repository =
        CustomerRepository(CustomerRemoteDataSource(Get.find<DioClient>()));
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    final result = await _repository.getNotifications();
    result.fold(
      (f) => null,
      (data) => notifications.value = data,
    );
    isLoading.value = false;
  }

  Future<void> markRead(String id) async {
    await _repository.markNotificationRead(id);
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final n = notifications[idx];
      notifications[idx] = NotificationModel(
        id: n.id,
        title: n.title,
        body: n.body,
        isRead: true,
        createdAt: n.createdAt,
      );
    }
  }

  Future<void> markAllRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await _repository.markNotificationRead(n.id);
    }
    notifications.value = notifications.map((n) => NotificationModel(
      id: n.id,
      title: n.title,
      body: n.body,
      isRead: true,
      createdAt: n.createdAt,
    )).toList();
  }
}
