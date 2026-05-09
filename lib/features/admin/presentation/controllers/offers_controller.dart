import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/datasources/admin_remote_datasource.dart';

/// أنواع العروض حسب الـ enum في الـ backend (OfferType)
enum OfferTypeKind {
  percentage(0, 'خصم نسبة %'),
  fixedAmount(1, 'خصم مبلغ ثابت'),
  buyXGetY(2, 'اشتري X واحصل على Y'),
  freeShipping(3, 'شحن مجاني'),
  bundle(4, 'باقة'),
  promoCode(5, 'كود خصم');

  final int value;
  final String labelAr;
  const OfferTypeKind(this.value, this.labelAr);

  static OfferTypeKind fromValue(int v) =>
      OfferTypeKind.values.firstWhere((e) => e.value == v,
          orElse: () => OfferTypeKind.percentage);
}

class OffersController extends GetxController {
  late final AdminRemoteDataSource _ds;

  final offers = <Map<String, dynamic>>[].obs;
  final products = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final search = ''.obs;
  final filterActive = Rxn<bool>();

  // form fields
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final discountValueCtrl = TextEditingController();
  final freeQuantityCtrl = TextEditingController();
  final minQuantityCtrl = TextEditingController();
  final promoCodeCtrl = TextEditingController();
  final selectedProductId = RxnString();
  final offerType = OfferTypeKind.percentage.obs;
  final isActive = true.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    load();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    discountValueCtrl.dispose();
    freeQuantityCtrl.dispose();
    minQuantityCtrl.dispose();
    promoCodeCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      offers.value = await _ds.getOffers(
          search: search.value, isActive: filterActive.value);
      if (products.isEmpty) {
        products.value = await _ds.getAllProducts();
      }
    } catch (_) {
      offers.clear();
    }
    isLoading.value = false;
  }

  void clearForm() {
    nameCtrl.clear();
    descCtrl.clear();
    discountValueCtrl.clear();
    freeQuantityCtrl.clear();
    minQuantityCtrl.clear();
    promoCodeCtrl.clear();
    selectedProductId.value = null;
    offerType.value = OfferTypeKind.percentage;
    isActive.value = true;
    startDate.value = null;
    endDate.value = null;
  }

  void fill(Map<String, dynamic> o) {
    nameCtrl.text = (o['name'] ?? '').toString();
    descCtrl.text = (o['description'] ?? '').toString();
    discountValueCtrl.text = (o['discountValue'] ?? '').toString();
    freeQuantityCtrl.text = (o['freeQuantity'] ?? '').toString();
    minQuantityCtrl.text = (o['minimumQuantity'] ?? '').toString();
    promoCodeCtrl.text = (o['promoCode'] ?? '').toString();
    selectedProductId.value = o['productId']?.toString();
    final t = o['offerType'];
    if (t is num) offerType.value = OfferTypeKind.fromValue(t.toInt());
    isActive.value = (o['isActive'] as bool?) ?? true;
    startDate.value = _parseDate(o['startDate']);
    endDate.value = _parseDate(o['endDate']);
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  Map<String, dynamic> _payload() => {
        'name': nameCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'productId': int.tryParse(selectedProductId.value ?? ''),
        'offerType': offerType.value.value,
        'discountValue': double.tryParse(discountValueCtrl.text.trim()),
        'freeQuantity': int.tryParse(freeQuantityCtrl.text.trim()),
        'minimumQuantity': int.tryParse(minQuantityCtrl.text.trim()),
        'promoCode': promoCodeCtrl.text.trim().isEmpty
            ? null
            : promoCodeCtrl.text.trim(),
        'isActive': isActive.value,
        'startDate': startDate.value?.toIso8601String(),
        'endDate': endDate.value?.toIso8601String(),
      };

  Future<bool> create() async {
    if (!formKey.currentState!.validate()) return false;
    isSubmitting.value = true;
    try {
      await _ds.createOffer(_payload());
      SnackbarHelper.showSuccess('تم إضافة العرض');
      await load();
      return true;
    } catch (_) {
      SnackbarHelper.showError('فشلت الإضافة');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> save(String id) async {
    if (!formKey.currentState!.validate()) return false;
    isSubmitting.value = true;
    try {
      await _ds.updateOffer(id, _payload());
      SnackbarHelper.showSuccess('تم تحديث العرض');
      await load();
      return true;
    } catch (_) {
      SnackbarHelper.showError('فشل التحديث');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _ds.deleteOffer(id);
      SnackbarHelper.showSuccess('تم حذف العرض');
      await load();
    } catch (_) {
      SnackbarHelper.showError('فشل الحذف');
    }
  }
}
